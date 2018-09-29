import UIKit

class TransparentNavigationBar: UINavigationBar {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.restyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.restyle()
    }

    func restyle() {
        self.barTintColor = UIColor(white: 1, alpha: 1)
        self.isTranslucent = false
        self.setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()
    }
}
