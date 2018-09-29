import UIKit
// import ExternalAccessory

class ViewController: UIViewController, StreamDelegate {
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func handleButtonClick(_ sender: UIButton) {
//        print("hello world")
//
//        let accessory = EAAccessoryManager.shared().connectedAccessories.first!
//        let session = EASession(accessory: accessory, forProtocol: "Hello")
//
//        session?.outputStream?.delegate = self
//        session?.outputStream?.schedule(in: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
//        session?.outputStream?.open()
//
//        session?.inputStream?.delegate = self
//        session?.inputStream?.schedule(in: RunLoop.main, forMode: RunLoopMode.defaultRunLoopMode)
//        session?.inputStream?.open()
    }
}
