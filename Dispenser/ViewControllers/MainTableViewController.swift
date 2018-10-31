import Drift
import ReSwift
import UIKit

class MainTableViewController: UITableViewController, StoreSubscriber {
    static let UpdateSection = 1
    
    var showUpdateCell = false
    
    @IBOutlet var updateCell: UITableViewCell!
    @IBOutlet var unpairCell: UITableViewCell!
    @IBOutlet var unlockCell: UITableViewCell!
    @IBOutlet weak var disconnectCell: UITableViewCell!
    @IBOutlet weak var dispenseOnTouchSwitch: UISwitch!
    @IBOutlet weak var buzzOnDispenseSwitch: UISwitch!
    
    @IBAction func addDispenser(_ sender: Any) {
        jumpTo(storyboard: "Pairing")
    }
    
    @IBAction func help(_ sender: Any) {
        Drift.showConversations()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell == self.updateCell {
            // do nothing
        } else if cell == self.unlockCell {
            self.connect()
            cell?.isSelected = false
        } else if cell == self.disconnectCell {
            self.disconnect()
            cell?.isSelected = false
        } else if cell == self.unpairCell {
            self.unpair()
            cell?.isSelected = false
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if cell == self.updateCell && !self.showUpdateCell {
            return 0
        }
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == MainTableViewController.UpdateSection && !self.showUpdateCell {
            return 0.1
        } else {
            return super.tableView(tableView, heightForHeaderInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == MainTableViewController.UpdateSection && !self.showUpdateCell {
            return 0.1
        } else {
            return super.tableView(tableView, heightForFooterInSection: section)
        }
    }
    
    func disconnect() {
        let alert = UIAlertController(
            title: "Disconnect",
            message: "This will stop dispensing candy for incoming payments through the currently connected node. You can re-connect anytime again.",
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Disconnect", style: .destructive, handler: { _ in
                    print("disconnect")
                }
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Cancel", style: .cancel, handler: { _ in
                    // do nothing
                }
            )
        )
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func unpair() {
        let alert = UIAlertController(
            title: "Unpair",
            message: "This will drop the connection to the dispenser, but still keep it running. You can pair anytime again.",
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Unpair", style: .destructive, handler: { _ in
                    print("unpair")
                    
                    self.jumpTo(storyboard: "Pairing")
                }
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Cancel", style: .cancel, handler: { _ in
                    // do nothing
                }
            )
        )
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func connect() {}
    
    @IBAction func toggleDispenseOnTouch(_ sender: UISwitch) {
    }
    
    @IBAction func toggleBuzzOnDispense(_ sender: UISwitch) {
    }
    
    func toggleUpdateCell() {
        self.showUpdateCell.toggle()
        
        // This has a nicer animation, but the cell does not reappear
        // let indexPath = IndexPath(row: 0, section: updateSection)
        // self.tableView.reloadRows(at: [indexPath], with: .automatic)
        
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        AppDelegate.shared.store.subscribe(self)
        
        AppDelegate.shared.store.dispatch(DispenserActions.check)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppDelegate.shared.store.unsubscribe(self)
    }
    
    func newState(state: AppState) {
        guard let dispenser = state.dispenser else {
            return
        }
        
        switch dispenser.update {
        case .updating:
            fallthrough
        case .available:
            if !self.showUpdateCell {
                self.toggleUpdateCell()
            }
        case .none:
            fallthrough
        case .searching:
            fallthrough
        default:
            if self.showUpdateCell {
                self.toggleUpdateCell()
            }
        }
    }
}
