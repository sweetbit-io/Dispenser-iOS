import UIKit

protocol Storyboarded {
    static func instantiate(fromStoryboard: String) -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate(fromStoryboard: String = "Main") -> Self {
        // this pulls out "MyApp.MyViewController"
        let fullName = NSStringFromClass(self)
        
        // this splits by the dot and uses everything after, giving "MyViewController"
        let className = fullName.components(separatedBy: ".").last!
        
        // load our storyboard
        let storyboard = UIStoryboard(name: fromStoryboard, bundle: Bundle.main)
        
        // instantiate a view controller with that identifier, and force cast as the type that was requested
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }
}
