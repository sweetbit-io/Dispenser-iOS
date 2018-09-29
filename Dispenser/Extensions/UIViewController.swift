import UIKit

extension UIViewController {
    func jumpTo(storyboard: String) {
        guard let window = UIApplication.shared.keyWindow else {
            return
        }
        
        guard let rootViewController = window.rootViewController else {
            return
        }
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: storyboard, bundle: nil)
        let vc = mainStoryboard.instantiateInitialViewController()! as UIViewController
        vc.view.frame = rootViewController.view.frame
        vc.view.layoutIfNeeded()
        
        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = vc
        }, completion: { _ in
            // maybe do something here
        })
    }
}
