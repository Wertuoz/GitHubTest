//
//  AppDelegate.swift
//  GitHubTest
//
//  Created by Anton Trofimenko on 25/02/2019.
//  Copyright © 2019 Anton Trofimenko. All rights reserved.
//

import UIKit
import KeychainAccess
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        print(paths[0])
        window = UIWindow(frame: UIScreen.main.bounds)
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        let keychain = Keychain(service: ApiManager.keychainAppName)
        if keychain[ApiManager.keychainAuthToken] != nil {
            let initialVC = sb.instantiateViewController(withIdentifier: "MainApp")
            window?.rootViewController = initialVC
            window?.makeKeyAndVisible()
//            keychain[ApiManager.keychainAuthToken] = nil
        } else {
            let initialVC = sb.instantiateViewController(withIdentifier: "OnBoardingLogin")
            window?.rootViewController = initialVC
            window?.makeKeyAndVisible()
        }
        
        return true
        
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

