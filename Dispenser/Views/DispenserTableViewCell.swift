import CoreGraphics
import UIKit

class DispenserTableViewCell: UITableViewCell {
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        self.imageView?.bounds = CGRect(x: 0, y: 0, width: 40, height: 60)
        self.imageView?.frame = self.imageView!.frame.inset(by: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))
        self.imageView?.backgroundColor = UIColor.clear
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
