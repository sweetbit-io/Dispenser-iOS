import UIKit

class ReplaceStoryboardSegue: UIStoryboardSegue {
    override func perform() {
        guard var viewControllers = self.source.navigationController?.viewControllers else { return }

        viewControllers.popLast()
        
        viewControllers.append(self.destination)
        
        self.source.navigationController?.setViewControllers(viewControllers, animated: true)
        
//        self.source.navigationController?.popViewController(animated: false)
//        self.source.navigationController?.pushViewController(self.destination, animated: true)
    }
}
