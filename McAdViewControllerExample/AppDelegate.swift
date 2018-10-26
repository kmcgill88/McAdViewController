//
//  AppDelegate.swift
//  McAdViewControllerExample
//
//  Created by Kevin McGill on 4/6/17.
//  Copyright © 2017-2018 McGill DevTech, LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mcAdViewController:McAdViewController?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Be sure to tag your view controller in the storyboard.
        //
        let viewController:ViewController = storyboard.instantiateViewController(withIdentifier: "ViewControllerId") as! ViewController
        
        // Initialize McAdViewcontroller and pass your 'contentController' viewController
        //
        // Test Ad units from https://developers.google.com/admob/ios/test-ads#sample_ad_units
        //
        mcAdViewController = McAdViewController(contentController: viewController, // Required
                                                applicationId: "ca-app-pub-<YOUR APP ID>", // Required
                                                bannerAdUnitId: "ca-app-pub-<YOUR BANNER ID>", // Conditional Optional - Required if interstantialAdUnitId not provided
                                                interstantialAdUnitId: "ca-app-pub-<YOUR INT ID>", // Conditional Optional - Required if bannerAdUnitId not provided
                                                isBannerBottom: false, // Optional - Default: true
                                                debug: true) // Optional - Default: false
        
        mcAdViewController?.safeAreaColor = .red
        // Set McAdViewController as the root
        //
        window!.rootViewController = mcAdViewController!
        window!.makeKeyAndVisible()
        
        return true
    }
}

