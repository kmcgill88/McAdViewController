//
//  McAdViewController.swift
//  McAdViewControllerExample
//
//  Created by Kevin McGill on 4/6/17.
//  Copyright © 2017 McGill DevTech, LLC. All rights reserved.
//

import UIKit
import GoogleMobileAds


open class McAdViewController : UIViewController {

    open var bannerAdUnitId:String?
    open var interstantialAdUnitId:String?
    open var BANNER_ANIMATION_INTERVAL:TimeInterval = 0.35
    open var isBannerBottom:Bool = true
    open var debug:Bool = false {
        didSet {
            prepareInterstantialAd()
            requestBannerAd()
        }
    }
    
    fileprivate var bannerAdView:GADBannerView?
    fileprivate var interstantialAd:GADInterstitial?
    fileprivate var bannerAdFailedToLoad = false

    private var contentController:UIViewController!

    public convenience init(contentController:UIViewController, applicationId:String, bannerAdUnitId:String? = nil, interstantialAdUnitId:String? = nil, isBannerBottom:Bool? = true, debug:Bool? = false) {
        self.init(nibName: nil, bundle: nil)
        
        if bannerAdUnitId == nil && interstantialAdUnitId == nil {
            fatalError("No adUnit ID provided! You must supply a bannerAdUnitId and/or interstantialAdUnitId")
        }
        
        GADMobileAds.configure(withApplicationID: applicationId)
        self.contentController = contentController
        self.bannerAdUnitId = bannerAdUnitId
        self.interstantialAdUnitId = interstantialAdUnitId
        self.isBannerBottom = isBannerBottom!
        self.debug = debug!

        // Setup Ads if needed
        //
        prepareInterstantialAd()
        requestBannerAd()
    }

    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
   
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    open func removeBannerAd(){
        // Update the status bar color to default
        //
        isBannerBottom = true
        setNeedsStatusBarAppearanceUpdate()
        
        // Simulator failure to remove from view
        //
        bannerAdFailedToLoad = true
        resizeScreen()
        
        // Release from memory
        //
        bannerAdView = nil
    }

    override open func loadView() {
        let contentView = UIView(frame: UIScreen.main.bounds)
        contentView.addSubview(bannerAdView!)
        
        self.addChildViewController(contentController)
        contentView.addSubview(contentController.view)
        contentController.didMove(toParentViewController: self)
        
        self.view = contentView
    }
    
    override open func viewDidLayoutSubviews() {
        if let gAd = getBannerAdView() {
            self.makeBannerChanges(bannerAdView: gAd)
        }
    }
    
    fileprivate func resizeScreen(){
        UIView.animate(withDuration: BANNER_ANIMATION_INTERVAL, animations:{
            self.view.layoutIfNeeded()
        })
    }

    private func makeBannerChanges(bannerAdView:GADBannerView) {
        
        var contentFrame:CGRect = self.view.bounds
        var bannerFrame:CGRect = bannerAdView.frame
        
        
        // Make content view smaller to accomidate banner
        //
        contentFrame.size.height -= bannerAdView.frame.size.height
        
        if isBannerBottom {
            // Put banner at the bottom of screen
            //
            bannerFrame.origin.y = contentFrame.size.height
        } else {
            // Put banner at top of screen, but under status bar
            //
            contentFrame.size.height -= UIApplication.shared.statusBarFrame.height
            contentFrame.origin.y = (bannerAdView.frame.size.height + UIApplication.shared.statusBarFrame.height)
            bannerFrame.origin.y = 0 + UIApplication.shared.statusBarFrame.height
        }

        //if ads don't load then give user full screen
        if(bannerAdFailedToLoad){
            // Push banner off screen
            //
            bannerFrame.origin.y = 0 - bannerFrame.size.height
            
            // Full screen content view controller
            //
            contentFrame = self.view.bounds
        }
        
        // Set new frames
        //
        bannerAdView.frame = bannerFrame
        contentController.view.frame = contentFrame
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
         super.viewWillTransition(to: size, with: coordinator)
        
        // Set the ad to the right size
        //
        if size.width > size.height {
            bannerAdView?.adSize = kGADAdSizeSmartBannerLandscape
        } else {
            bannerAdView?.adSize = kGADAdSizeSmartBannerPortrait
        }
    }
    
    override open var preferredStatusBarStyle : UIStatusBarStyle {
        return (isBannerBottom) ? .default : .lightContent
    }
    
    fileprivate func printDebug(_ text:String) {
        if debug {
            print(text)
        }
    }
}

extension McAdViewController : GADBannerViewDelegate {
    
    public func adViewDidReceiveAd(_ view: GADBannerView) {
        bannerAdFailedToLoad = false
        printDebug("Banner Ad - adViewDidReceiveAd")
        resizeScreen()
    }
    
    public func adView(_ view: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        bannerAdFailedToLoad = true
        printDebug("Banner Ad - didFailToReceiveAdWithError")
        resizeScreen()
    }
    
    fileprivate func getBannerAdView() -> GADBannerView? {
        
        if bannerAdView == nil && bannerAdUnitId != nil {
            bannerAdView = GADBannerView(adSize:kGADAdSizeSmartBannerPortrait)
            bannerAdView!.adUnitID = bannerAdUnitId
            bannerAdView!.rootViewController = self
            bannerAdView!.delegate = self
        }

        return bannerAdView
    }
    
    fileprivate func requestBannerAd() {
        if let bannerAd = getBannerAdView() {
            let request = GADRequest()
            if debug {
                request.testDevices = [kGADSimulatorID]
            }
            bannerAd.load(request)
        }
    }
}

extension McAdViewController : GADInterstitialDelegate {
    
    fileprivate func prepareInterstantialAd() {

        if let intAd = getInterstitialAd() {
            let request = GADRequest()
            if debug {
                request.testDevices = [kGADSimulatorID]
            }
            intAd.load(request)
        }
    }
    
    fileprivate func getInterstitialAd() -> GADInterstitial? {
        
        if interstantialAdUnitId != nil {
            interstantialAd = GADInterstitial(adUnitID: interstantialAdUnitId!)
            interstantialAd!.delegate = self
        }
        
        return interstantialAd
    }

    open func displayInterstitial(){
        if let inter = interstantialAd {
            if inter.isReady {
                inter.present(fromRootViewController: self)
            } else {
                printDebug("Interstitial Ad not ready, requesting to prep now.")
                prepareInterstantialAd()
            }
        }
    }
    
    public func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        prepareInterstantialAd()
    }
    public func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        printDebug("Interstitial - DidReceiveAd")
    }
    public func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        printDebug("Interstitial - didFailToReceiveAdWithError \(error)")
    }
}
