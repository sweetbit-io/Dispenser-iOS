import Down
import UIKit

class UpdateViewController: UIViewController, Storyboarded {
    var coordinator: UpdateCoordinator?
    var notesView: DownView?
    
    @IBOutlet var mainView: UIView!
    @IBOutlet var wrapperView: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var sizeLabel: UILabel!
    @IBOutlet weak var updateButton: LoadingButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let notes = self.coordinator?.release.notes {
            self.notesView = try! DownView(frame: self.view.bounds, markdownString: notes)
        }
        
        self.nameLabel.text = self.coordinator?.release.name
        
        if let publishedAt = self.coordinator?.release.publishedAt {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM d, yyyy"
            
            self.dateLabel.text = formatter.string(from: publishedAt)
        }
        
        if let size = self.coordinator?.release.packages.first?.size {
            let byteFormatter = ByteCountFormatter()
            self.sizeLabel.text = byteFormatter.string(fromByteCount: Int64(size))
        }
        
        self.wrapperView.addSubview(self.notesView!)
        
        self.mainView.backgroundColor = UIColor(red: (247 / 255), green: (247 / 255), blue: (247 / 255), alpha: 1)
        self.mainView.addBottomBorderWithColor(color: UIColor(red: 219 / 255, green: 219 / 255, blue: 223 / 255, alpha: 1), width: 1)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.shadowImage = UIImage(named: "Transparent")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.navigationBar.shadowImage = nil
    }
    
    @IBAction func update(_ sender: LoadingButton) {
        guard let release = self.coordinator?.release else {
            return
        }
        
        self.coordinator?.update(release: release)
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.coordinator?.cancel()
    }
}
