import RxDataSources
import RxSwift
import UIKit

class PairingWifiListViewController: PairingBaseViewController {
    let disposeBag = DisposeBag()
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        
        refreshControl.addTarget(self, action: #selector(PairingWifiListViewController.handleRefresh(_:)), for: UIControl.Event.valueChanged)
        
        return refreshControl
    }()
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.addSubview(self.refreshControl)
        
        self.coordinator?.networks
            .bind(to: self.tableView.rx.items(cellIdentifier: "networkCell")) { _, model, cell in
                cell.textLabel?.text = model.ssid
                
                cell.imageView?.image = #imageLiteral(resourceName: "Wi-Fi")
                
                if model.connected {
                    cell.accessoryType = .checkmark
                } else {
                    cell.accessoryType = .none
                }
            }
            .disposed(by: self.disposeBag)
        
        self.tableView.rx
            .modelSelected(Network.self)
            .subscribe(onNext: { network in
                self.coordinator?.selectWifi(network: network)
            })
            .disposed(by: self.disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let indexPath = self.tableView.indexPathForSelectedRow {
            self.tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if self.isMovingToParent {
            self.refreshControl.programaticallyBeginRefreshing(in: self.tableView)
            
            self.coordinator?.refreshWifiNetworks {
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    @IBAction func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.coordinator?.refreshWifiNetworks {
            self.refreshControl.endRefreshing()
        }
    }
}
