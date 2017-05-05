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
        
        // Simulate failure to remove from view
        //
        bannerAdFailedToLoad = true
        resizeScreen()
        
        // Remove and release from memory
        //
        bannerAdView?.removeFromSuperview()
        bannerAdView = nil
    }

    override open func loadView() {
        let contentView = UIView(frame: UIScreen.main.bounds)
        
        if let gAd = self.getBannerAdView() {
            contentView.addSubview(gAd)
        } else {
            // Update the status bar color to default
            //
            isBannerBottom = true
            setNeedsStatusBarAppearanceUpdate()
        }
        
        self.addChildViewController(contentController)
        contentView.addSubview(contentController.view)
        contentController.didMove(toParentViewController: self)
        
        self.view = contentView
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Ads if needed
        //
        prepareInterstantialAd()
        requestBannerAd()
    }
    
    fileprivate func resizeScreen(){
        UIView.animate(withDuration: BANNER_ANIMATION_INTERVAL, animations:{
            if let gAd = self.getBannerAdView() {
                self.makeBannerChanges(bannerAdView: gAd)
            }
            self.view.layoutIfNeeded()
        })
    }
    
    fileprivate func fullScreen(height:CGFloat) {
        // Push banner off screen
        //
        if bannerAdView != nil {
            var bannerFrame:CGRect = bannerAdView!.frame
            bannerFrame.origin.y = (isBannerBottom) ? height : 0 - bannerFrame.size.height
            bannerAdView!.frame = bannerFrame
        }
        
        // Full screen content view controller
        //
        let controllerFrame:CGRect = self.view.bounds
        contentController.view.frame = controllerFrame
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

        // If ad doesn't load then give user full screen
        //
        if(bannerAdFailedToLoad){
            fullScreen(height: self.view.bounds.size.height)
            return
        }
        
        // Set new frames
        //
        bannerAdView.frame = bannerFrame
        contentController.view.frame = contentFrame
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        fullScreen(height: size.height)
        setBannerSmartSize(size: size)
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
            bannerAdView = GADBannerView()
            var bannerFrame:CGRect = bannerAdView!.frame
            bannerFrame.origin.y = (isBannerBottom) ? self.view.bounds.size.height : 0 - bannerFrame.size.height
            bannerAdView?.frame = bannerFrame
            bannerAdView!.adUnitID = bannerAdUnitId
            bannerAdView!.rootViewController = self
            bannerAdView!.delegate = self
            setBannerSmartSize(size: CGSize(width: self.view.bounds.size.width, height: self.view.bounds.size.height))
        }

        return bannerAdView
    }
    
    fileprivate func setBannerSmartSize(size: CGSize) {
        // Set the ad to the right size
        //
        if size.width > size.height {
            bannerAdView?.adSize = kGADAdSizeSmartBannerLandscape
        } else {
            bannerAdView?.adSize = kGADAdSizeSmartBannerPortrait
        }
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
        if let interstantial = getInterstitialAd() {
            let request = GADRequest()
            if debug {
                request.testDevices = [kGADSimulatorID]
            }
            interstantial.load(request)
        }
    }
    
    fileprivate func getInterstitialAd() -> GADInterstitial? {
        if interstantialAdUnitId != nil {
            interstantialAd = GADInterstitial(adUnitID: interstantialAdUnitId!)
            interstantialAd!.delegate = self
        }
        
        return interstantialAd
    }

    open func displayInterstitial(fromViewController:UIViewController? = nil){
        if let interstantial = interstantialAd {
            if interstantial.isReady && !interstantial.hasBeenUsed {
                interstantial.present(fromRootViewController: fromViewController ?? self)
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
