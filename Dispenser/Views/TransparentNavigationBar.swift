import UIKit

class TransparentNavigationBar: UINavigationBar {
    override init(frame: CGRect) {
        super.init(frame: frame)
        restyle()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        restyle()
    }

    func restyle() {
        self.barTintColor = UIColor(white: 1, alpha: 1)
        self.isTranslucent = false
        self.setBackgroundImage(UIImage(), for: .default)
        self.shadowImage = UIImage()
    }
}
