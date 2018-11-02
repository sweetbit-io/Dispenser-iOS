import Drift
import RxSwift
import UIKit

class MainTableViewController: UITableViewController, Storyboarded {
    static let UpdateSection = 1
    static let ControlsSection = 2
    static let RemoteNodeSection = 3
    
    var coordinator: DispenserCoordinator?
    var showUpdateCell = false
    var showRemoteNodeConnectCell = false
    var showRemoteNodeDisconnectCell = false
    var showControlSection = false
    var showRemoteNodeSection = true
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var dispenseOnTouchCell: UITableViewCell!
    @IBOutlet weak var buzzOnDispenseCell: UITableViewCell!
    @IBOutlet var updateCell: UITableViewCell!
    @IBOutlet var unpairCell: UITableViewCell!
    @IBOutlet var unlockCell: UITableViewCell!
    @IBOutlet var disconnectCell: UITableViewCell!
    @IBOutlet var dispenseOnTouchSwitch: UISwitch!
    @IBOutlet var buzzOnDispenseSwitch: UISwitch!
    @IBOutlet weak var remoteNodeDisconnectCellSubtitle: UILabel!
    
    @IBAction func help(_ sender: Any) {
        Drift.showConversations()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell == self.updateCell {
            self.coordinator?.showUpdate()
        } else if cell == self.unlockCell {
            self.connect()
            cell?.isSelected = false
        } else if cell == self.disconnectCell {
            self.disconnect()
            cell?.isSelected = false
        } else if cell == self.unpairCell {
            self.coordinator?.unpair()
            cell?.isSelected = false
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if cell == self.updateCell && !self.showUpdateCell {
            return 0
        } else if cell == self.dispenseOnTouchCell && !self.showControlSection {
            return 0
        } else if cell == self.buzzOnDispenseCell && !self.showControlSection {
            return 0
        } else if cell == self.unlockCell && (!self.showRemoteNodeSection || !self.showRemoteNodeConnectCell) {
            return 0
        } else if cell == self.disconnectCell && (!self.showRemoteNodeSection || !self.showRemoteNodeDisconnectCell) {
            return 0
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == MainTableViewController.UpdateSection && !self.showUpdateCell {
            return 0.1
        } else if section == MainTableViewController.ControlsSection && !self.showControlSection {
            return 0.1
        } else if section == MainTableViewController.RemoteNodeSection && !self.showRemoteNodeSection {
            return 0.1
        } else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == MainTableViewController.UpdateSection && !self.showUpdateCell {
            return 0.1
        } else if section == MainTableViewController.ControlsSection && !self.showControlSection {
            return 0.1
        } else if section == MainTableViewController.RemoteNodeSection && !self.showRemoteNodeSection {
            return 0.1
        } else {
            return super.tableView(tableView, heightForFooterInSection: section)
        }
    }
    
    func connect() {
        self.coordinator?.connectRemoteNode()
    }
    
    func disconnect() {
        self.coordinator?.disconnectRemoteNode()
    }
    
    @IBAction func toggleDispenseOnTouch(_ sender: UISwitch) {
        self.coordinator?.toggleDispenseOnTouch(enable: sender.isOn)
    }
    
    @IBAction func toggleBuzzOnDispense(_ sender: UISwitch) {
        self.coordinator?.toggleBuzzOnDispense(enable: sender.isOn)
    }
    
    override func viewDidLoad() {
        if (self.coordinator?.coordinator.getDispensers().count ?? 0) > 1 {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: #imageLiteral(resourceName: "Menu"),
                style: .plain,
                target: self,
                action: #selector(MainTableViewController.switchDispenser))
        } else {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .add,
                target: self,
                action: #selector(MainTableViewController.addDispenser))
        }
        
        self.coordinator?.version
            .subscribe(onNext: {
                guard let version = $0 else {
                    return
                }
                
                print("Version is \(version)")

//                if isVersion(version, higherOrEqual: "0.3.0") {
//                    self.showRemoteNodeSection = true
//                }
//                if isVersion(version, higherOrEqual: "0.4.0") {
//                    self.showControlSection = true
//                }
                
                // This has a nicer animation, but the cell does not reappear
                // let indexPath = IndexPath(row: 0, section: updateSection)
                // self.tableView.reloadRows(at: [indexPath], with: .automatic)
                
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            })
            .disposed(by: self.disposeBag)
        
        self.coordinator?.remoteNodeUrl
            .subscribe(onNext: {
                print("Remote node \($0 ?? "")")
                
                if let url = $0 {
                    self.showRemoteNodeConnectCell = false
                    self.showRemoteNodeDisconnectCell = true
                    self.remoteNodeDisconnectCellSubtitle.text = url
                } else {
                    self.showRemoteNodeConnectCell = true
                    self.showRemoteNodeDisconnectCell = false
                }
                
                // This has a nicer animation, but the cell does not reappear
                // let indexPath = IndexPath(row: 0, section: updateSection)
                // self.tableView.reloadRows(at: [indexPath], with: .automatic)
                
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            })
            .disposed(by: self.disposeBag)
        
        self.coordinator?.updateAvailable
            .subscribe(onNext: {
                self.showUpdateCell = $0
                
                // This has a nicer animation, but the cell does not reappear
                // let indexPath = IndexPath(row: 0, section: updateSection)
                // self.tableView.reloadRows(at: [indexPath], with: .automatic)
                
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
            })
            .disposed(by: self.disposeBag)
    }
    
    @IBAction func switchDispenser() {
        self.coordinator?.switchDispenser()
    }
    
    @IBAction func addDispenser() {
        self.coordinator?.addDispenser()
    }
}
