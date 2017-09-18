//
//  AppDelegate.swift
//  Flicks
//
//  Created by Diana Fisher on 9/12/17.
//  Copyright © 2017 Diana Fisher. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        // Create the now playing navigation controller
        let nowPlayingNavigationController = navigationControllerForEndpoint("now_playing", title: "Now Playing", tabImage: UIImage(named: "tickets")!)
                
        // Create the top rated navigation controller
        let topRatedNavigationController = navigationControllerForEndpoint("top_rated", title: "Top Rated", tabImage: UIImage(named: "star")!)
        
        // Create a tab bar controller.
        let tabBarController = UITabBarController()
        
        // Set the tint and background image of the tab bar
        tabBarController.tabBar.tintColor = UIColor(red: 1, green: 0.8, blue: 0, alpha: 1.0)
        tabBarController.tabBar.backgroundImage = UIImage(named: "nav-bar")
        
        // Link each navigation controller
        tabBarController.viewControllers = [nowPlayingNavigationController, topRatedNavigationController]
        
        // Set the tab bar controller as the root view controller.
        window?.rootViewController = tabBarController
        
        // Show the window and make it the key window
        window?.makeKeyAndVisible()
        
        return true
    }
    
    /*
     Creates a UINavigationController for the specified endpoint
     */
    func navigationControllerForEndpoint(_ endpoint: String, title: String, tabImage: UIImage) -> UINavigationController {
        // Get our storyboard
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let navigationController = storyboard.instantiateViewController(withIdentifier: "MoviesNavigationController") as! UINavigationController
        
        // Set the background image
        let navigationBar = navigationController.navigationBar        
        navigationBar.setBackgroundImage(UIImage(named: "nav-bar"), for: .default)
        
        let shadow = NSShadow()
        shadow.shadowColor = UIColor.gray.withAlphaComponent(0.5)
        shadow.shadowOffset = CGSize.init(width: 2, height: 2)
        shadow.shadowBlurRadius = 4
        navigationBar.titleTextAttributes = [
            NSFontAttributeName : UIFont.boldSystemFont(ofSize: 22),
            NSForegroundColorAttributeName : UIColor(red: 1, green: 0.8, blue: 0, alpha: 0.8),
            NSShadowAttributeName : shadow
        ]
        
        
        // Set the title and image of the navigatinon controller tab bar item
        navigationController.tabBarItem.title = title
        navigationController.tabBarItem.image = tabImage
        
        let viewController = navigationController.topViewController as! MoviesViewController
        viewController.endpoint = endpoint        
        viewController.navTitle = title
        viewController.view.backgroundColor = UIColor.black
        
        return navigationController
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
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

