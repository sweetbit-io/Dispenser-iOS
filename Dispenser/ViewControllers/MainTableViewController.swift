import ReSwift
import UIKit

class MainTableViewController: UITableViewController, StoreSubscriber {
    static let UpdateSection = 1
    
    var showUpdateCell = false
    
    @IBOutlet var updateCell: UITableViewCell!
    @IBOutlet var unpairCell: UITableViewCell!
    @IBOutlet var unlockCell: UITableViewCell!
    
    @IBAction func addDispenser(_ sender: Any) {
        jumpTo(storyboard: "Pairing")
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell == self.updateCell {
            // do nothing
        } else if cell == self.unlockCell {
            self.unlock()
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
    
    func unpair() {
        let alert = UIAlertController(
            title: "Unpair",
            message: "Unpairing the dispenser will remove the connection but still keep it running. Do you really want to do that?",
            preferredStyle: UIAlertController.Style.alert
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Unpair", style: .destructive, handler: { _ in
                    print("unpair")
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
    
    func unlock() {
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
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        AppDelegate.shared.store.unsubscribe(self)
    }
    
    func newState(state: AppState) {
        guard let dispenser = state.dispenser else {
            return
        }
        
        switch (dispenser.update) {
        case .updating:
            fallthrough
        case .available(_):
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
