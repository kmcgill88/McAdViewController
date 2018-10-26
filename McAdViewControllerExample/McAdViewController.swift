/*
 Copyright (c) 2017-2018 Kevin McGill <kevin@mcgilldevtech.com>
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

import UIKit
import GoogleMobileAds


open class McAdViewController : UIViewController {

    open var bannerAdUnitId: String?
    open var interstantialAdUnitId: String?
    open var BANNER_ANIMATION_INTERVAL: TimeInterval = 0.35
    open var isBannerBottom: Bool = true
    
    open var safeAreaColor: UIColor?
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

    public convenience init(contentController:UIViewController,
                            applicationId:String,
                            bannerAdUnitId:String? = nil,
                            interstantialAdUnitId:String? = nil,
                            isBannerBottom:Bool = true,
                            debug:Bool = false) {
        self.init(nibName: nil, bundle: nil)

        if bannerAdUnitId == nil && interstantialAdUnitId == nil {
            fatalError("No adUnit ID provided! You must supply a bannerAdUnitId and/or interstantialAdUnitId")
        }
        
        GADMobileAds.configure(withApplicationID: applicationId)
        self.contentController = contentController
        self.bannerAdUnitId = bannerAdUnitId
        self.interstantialAdUnitId = interstantialAdUnitId
        self.isBannerBottom = isBannerBottom
        self.debug = debug
        
        // Setup Interstantial Ad if needed
        //
        prepareInterstantialAd()
    }

    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
   
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    open func removeBannerAd() {
        
        useContentViewControllerPreferredStatusBarStyle()
        
        // Simulate failure to remove from view
        //
        bannerAdFailedToLoad = true
        resizeScreen()
        
        // Remove and release from memory
        //
        bannerAdView?.removeFromSuperview()
        bannerAdView = nil
        bannerAdUnitId = nil
    }

    override open func loadView() {
        let contentView = UIView(frame: UIScreen.main.bounds)
        
        if let gAd = self.getBannerAdView() {
            contentView.addSubview(gAd)
        } else {
            useContentViewControllerPreferredStatusBarStyle()
        }
        
        self.addChildViewController(contentController)
        contentView.addSubview(contentController.view)
        contentController.didMove(toParentViewController: self)
        
        self.view = contentView
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Setup Banner Ad if needed
        //
        requestBannerAd()
    }
    
    fileprivate func resizeScreen() {
        UIView.animate(withDuration: BANNER_ANIMATION_INTERVAL, animations:{
            if let gAd = self.getBannerAdView() {
                self.makeBannerChanges(bannerAdView: gAd)
            }
            self.view.layoutIfNeeded()
        })
    }
    
    fileprivate func fullScreen(size: CGSize) {
        if bannerAdView != nil {
            var bannerFrame: CGRect = bannerAdView!.frame
            
            // Push banner off screen
            //
            bannerFrame.origin.y = (isBannerBottom) ? size.height : 0 - bannerFrame.size.height
            bannerFrame.origin.x = isPortrait(size: size) ? 0 : safeAreaInsetsTop()
            
            bannerAdView!.frame = bannerFrame
        }
        
        // Full screen content view controller
        //
        contentController.view.frame = self.view.bounds
    }

    private func makeBannerChanges(bannerAdView:GADBannerView) {
        var contentFrame: CGRect = self.view.bounds
        var bannerFrame: CGRect = bannerAdView.frame
        
        let verticalSafeArea = getVerticalSafeArea()
        let bannerHeight = bannerAdView.frame.size.height
        let viewBounds = self.view.bounds
        
        // Make content view smaller to accomidate banner
        //
        contentFrame.size.height -= (bannerHeight + verticalSafeArea)
        
        if isBannerBottom {
            // Put banner at the bottom of screen
            //
            bannerFrame.origin.y = contentFrame.size.height
        } else {
            // Put banner at top of screen, but under the safe area
            //
            contentFrame.origin.y = (bannerHeight + verticalSafeArea)
            bannerFrame.origin.y = 0 + verticalSafeArea
        }
        
        if !isPortrait(size: viewBounds.size) && safeAreaExists() {
            bannerFrame.size.width = viewBounds.width - safeAreaInsetsLeft() - safeAreaInsetsRight()
            bannerFrame.origin.x = safeAreaInsetsLeft()
        } else {
            bannerFrame.origin.x = 0
            bannerFrame.size.width = viewBounds.width
        }

        // If ad doesn't load then give user full screen
        //
        if bannerAdFailedToLoad {
            fullScreen(size: self.view.bounds.size)
            return
        }
        
        // Set new frames
        //
        bannerAdView.frame = bannerFrame
        contentController.view.frame = contentFrame
    }
    
    private func getVerticalSafeArea() -> CGFloat {
        UIApplication.shared.keyWindow?.backgroundColor = safeAreaColor
        if safeAreaExists(), #available(iOS 11.0, *) {
            printDebug("safeAreaInsets: \(String(describing: UIApplication.shared.keyWindow?.safeAreaInsets))")
            if let window = UIApplication.shared.keyWindow {
                return isBannerBottom ? window.safeAreaInsets.bottom : window.safeAreaInsets.top
            }
        }
        return isBannerBottom ? 0 : UIApplication.shared.statusBarFrame.height
    }

    private func safeAreaExists() -> Bool {
         if #available(iOS 11.0, *) {
            if let window = UIApplication.shared.keyWindow {
                return window.safeAreaInsets.top != 0 ||
                    window.safeAreaInsets.bottom != 0 ||
                    window.safeAreaInsets.right != 0 ||
                    window.safeAreaInsets.left != 0
            }
        }
        return false
    }
    
    private func safeAreaInsetsLeft() -> CGFloat {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets.left ?? 0
        }
        return 0
    }
    
    private func safeAreaInsetsRight() -> CGFloat {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets.right ?? 0
        }
        return 0
    }
    
    private func safeAreaInsetsTop() -> CGFloat {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.keyWindow?.safeAreaInsets.top ?? 0
        }
        return 0
    }

    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setBannerSmartSize(size: size)
        fullScreen(size: size)
    }
    
    override open var preferredStatusBarStyle : UIStatusBarStyle {
        return isBannerBottom ? contentController.preferredStatusBarStyle : .lightContent
    }
    
    private func useContentViewControllerPreferredStatusBarStyle() {
        // Update the status bar color
        // Simulate isBannerBottom = true to use contentController.preferredStatusBarStyle
        //
        isBannerBottom = true
        setNeedsStatusBarAppearanceUpdate()
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
            var bannerFrame: CGRect = bannerAdView!.frame
            bannerFrame.origin.y = (isBannerBottom) ? self.view.bounds.size.height : 0 - bannerFrame.size.height
            bannerAdView?.frame = bannerFrame
            bannerAdView!.adUnitID = bannerAdUnitId
            bannerAdView!.rootViewController = self
            bannerAdView!.delegate = self
            setBannerSmartSize(size: self.view.bounds.size)
        }

        return bannerAdView
    }
    
    fileprivate func setBannerSmartSize(size: CGSize) {
        // Set the ad to the right size
        //
        if isPortrait(size: size) {
            bannerAdView?.adSize = kGADAdSizeSmartBannerPortrait
        } else {
            bannerAdView?.adSize = kGADAdSizeSmartBannerLandscape
        }
    }
    
    fileprivate func isPortrait(size: CGSize) -> Bool {
        return size.height > size.width
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
                printDebug("Interstitial Ad 'isReady'=false or 'hasBeenUsed'=true, new Interstitial required. Requesting to prepareInterstantialAd now.")
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
        
        if let interstantial = interstantialAd {
            if interstantial.hasBeenUsed {
                printDebug("Interstitial Ad 'hasBeenUsed', requesting to prepareInterstantialAd now.")
                prepareInterstantialAd()
            }
        }
    }
}
