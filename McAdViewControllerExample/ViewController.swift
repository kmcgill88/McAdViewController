//
//  ViewController.swift
//  McAdViewControllerExample
//
//  Created by Kevin McGill on 4/6/17.
//  Copyright © 2017 McGill DevTech, LLC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let app:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override open var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }

    @IBAction func displayInterstitial(_ sender: UIButton) {
        app.mcAdViewController?.displayInterstitial()
    }

    @IBAction func removeBannerAd(_ sender: UIButton) {
        app.mcAdViewController?.removeBannerAd()
    }
}
