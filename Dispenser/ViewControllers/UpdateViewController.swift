import Down
import UIKit
import ReSwift

class UpdateViewController: UIViewController, StoreSubscriber {
    var notesView: DownView?
    
    @IBOutlet var mainView: UIView!
    @IBOutlet var wrapperView: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var sizeLabel: UILabel!
    @IBOutlet weak var updateButton: LoadingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.notesView = try! DownView(frame: self.view.bounds, markdownString: "")
        
        self.wrapperView.addSubview(self.notesView!)
        
        self.mainView.backgroundColor = UIColor(red: (247 / 255), green: (247 / 255), blue: (247 / 255), alpha: 1)
        self.mainView.addBottomBorderWithColor(color: UIColor(red: 219 / 255, green: 219 / 255, blue: 223 / 255, alpha: 1), width: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.shadowImage = UIImage(named: "Transparent")
        
        AppDelegate.shared.store.subscribe(self) { subcription in
            subcription.select { state in state.dispenser?.update }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.shadowImage = nil
        
        AppDelegate.shared.store.unsubscribe(self)
    }
    
    @IBAction func update(_ sender: LoadingButton) {
        AppDelegate.shared.store.dispatch(DispenserActions.update)
    }
    
    func newState(state: UpdateState?) {
        guard let update = state else {
            return
        }
        
        switch update {
        case let .available(release):
            try! self.notesView?.update(markdownString: release.notes)
            self.nameLabel.text = release.name
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
            
            self.dateLabel.text = formatter.string(from: release.publishedAt)
            
            let byteFormatter = ByteCountFormatter()
            self.sizeLabel.text = byteFormatter.string(fromByteCount: Int64(release.packages.first!.size))
        case .updating:
            self.updateButton.showLoading()
        default:
            return
        }
    }
}
