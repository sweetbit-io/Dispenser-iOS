import CoreData
import SwiftGRPC
import SwiftProtobuf
import UIKit
import Drift
import ReSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let store: Store<AppState>
    var window: UIWindow?
    var dispenser: Dispenser?
    
    // Allow view controllers to conveniently access the app delegate and its store
    // ex. AppDelegate.shared.store.dispatch(Action())
    open class var shared: AppDelegate {
        get {
            return UIApplication.shared.delegate as! AppDelegate
        }
    }
    
    // Initialize an empty store that will hold the entire state of the app
    override init() {
        self.store = Store<AppState>(
            reducer: appReducer,
            state: nil,
            middleware: [])
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.tintColor = UIColor.primary
        
        let context = self.persistentContainer.viewContext
        let fetch: NSFetchRequest<Dispenser> = Dispenser.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(key: "lastOpened", ascending: false)]
        
        let dispensers = try? context.fetch(fetch) as [Dispenser]

        if let dispenserToOpen = dispensers?.first {
            self.dispenser = dispenserToOpen
            self.dispenser?.lastOpened = Date()
            
            self.saveContext()
            
            let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let mainViewController: UIViewController = mainStoryboard.instantiateInitialViewController()! as UIViewController
            
            self.window?.rootViewController = mainViewController
        } else {
            let pairingStoryboard: UIStoryboard = UIStoryboard(name: "Pairing", bundle: nil)
            let pairingViewController: UIViewController = pairingStoryboard.instantiateInitialViewController()! as UIViewController
            
            self.window?.rootViewController = pairingViewController
        }

        self.window?.makeKeyAndVisible()
        
        Drift.setup("ydd7gkth62cx")
        Drift.registerUser(UIDevice.init().identifierForVendor?.uuidString ?? "", email: "")

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        self.saveContext()
    }

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Dispenser")
        container.loadPersistentStores(completionHandler: { _, error in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
