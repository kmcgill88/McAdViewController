//
//  NonRootViewController.swift
//  McAdViewControllerExample
//
//  Created by Kevin McGill on 5/4/17.
//  Copyright © 2017 McGill DevTech, LLC. All rights reserved.
//

import UIKit

class NonRootViewController: UIViewController {
    
    let app:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    @IBAction func displayInterstitial(_ sender: UIButton) {
        
        // From a View Controller that isn't in the view hierchy you'll need to pass the non-root view controller
        // If you don't you'll get an error like:
        //
        // Attempt to present <GADInterstitialViewController: 0x7fbd47607880> on <McAdViewControllerExample.McAdViewController: 0x7fbd4760a8b0>
        // whose view is not in the window hierarchy!
        app.mcAdViewController?.displayInterstitial(fromViewController: self)
    }

    @IBAction func dismiss(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
