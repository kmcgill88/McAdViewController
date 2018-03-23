# McAdViewController
![](https://mcgilldevtech.com/img/github/mcadviewcontroller/mcadviewcontroller-1.0.0-top.png)![](https://mcgilldevtech.com/img/github/mcadviewcontroller/mcadviewcontroller-1.0.0-bottom.png)


## About
McAdViewController is a UIViewController used to display Google Banner and Interstitial Ads. Animation and rotation ready, this view controller will automatically resize child view controllers so you can focus on developing without the burden of doing this yourself.

## Usage

1. Run `pod install` like normal, then [add McAdViewController to your project](http://mcgilldevtech.com/img/github/mcadviewcontroller/add-to-project.jpg)
2. [Remove Main interface](http://mcgilldevtech.com/img/github/mcadviewcontroller/target-settings.jpg) from your targets `General Settings`
3. [Uncheck initial View Controller](http://mcgilldevtech.com/img/github/mcadviewcontroller/initial-viewcontroller.jpg) in your storyboard.
4. [Tag your view controller with an Id](http://mcgilldevtech.com/img/github/mcadviewcontroller/storyboard-id.jpg)
5. In your `AppDelegate` do something similar to the below. Don't forget to put in your own `applicationId`, ect...
```swift
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mcAdViewController:McAdViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        // Be sure to tag your view controller in the storyboard.
        //
        let viewController:ViewController = storyboard.instantiateViewController(withIdentifier: "ViewControllerId") as! ViewController

        // Initialize McAdViewcontroller and pass your 'contentController' viewController
        //
        mcAdViewController = McAdViewController(contentController: viewController, // Required
                                                applicationId: "ca-app-pub-<YOUR APP ID>", // Required
                                                bannerAdUnitId: "ca-app-pub-<YOUR BANNER ID>", // Conditional Optional - Required if interstantialAdUnitId not provided
                                                interstantialAdUnitId: "ca-app-pub-<YOUR INT ID>", // Conditional Optional - Required if bannerAdUnitId not provided
                                                isBannerBottom: false, // Optional - Default: true
                                                debug: true) // Optional - Default: false
        // safeAreaColor defaults to black
        //
        mcAdViewController?.safeAreaColor = .red

        // Set McAdViewController as the root
        //
        window!.rootViewController = mcAdViewController!
        window!.makeKeyAndVisible()

        return true
    }
}
```

### Displaying Interstitial Ads and Removing the Banner Ad
```swift
class ViewController: UIViewController {

    let app:AppDelegate = UIApplication.shared.delegate as! AppDelegate

    @IBAction func displayInterstitial(_ sender: UIButton) {

      // Display Interstitial Ad from Root ViewController
      //
      app.mcAdViewController?.displayInterstitial()

      // Display Interstitial Ad from a Non-root ViewController.
      // ie. You subsequently presented a ViewController modally.
      //
      //app.mcAdViewController?.displayInterstitial(fromViewController: <Not McAdViewController>)
    }

    @IBAction func removeBannerAd(_ sender: UIButton) {
      // Remove the banner ad because, reasons.
      //
      app.mcAdViewController?.removeBannerAd()
    }
}
```

#### Example
To run the example project, clone the repo, run `pod install` then run it in from Xcode.
> Note: Be sure to put in your own `applicationId`, ect... in the `AppDelegate`


## Requirements
- Swift 4
- Xcode 9

## Installation
Unfortunately, McAdViewController is _**NOT**_ available through [CocoaPods](http://cocoapods.org) due to Google distributing static libraries. Discussed at length [here](https://github.com/CocoaPods/CocoaPods/issues/5624).

- Add the following line to your Podfile:

```ruby
pod 'Google-Mobile-Ads-SDK', '~> 7.29'

puts "Downloading McAdViewController..."
require 'open-uri'
open('./McAdViewController.swift', 'wb') do |file|
  file << open('https://raw.githubusercontent.com/kmcgill88/McAdViewController/master/McAdViewControllerExample/McAdViewController.swift').read
end
puts "Successfully downloaded McAdViewController! :)"
```
- Run `pod install`
- In Xcode, right click in Project navigator and [add McAdViewController to your project](http://mcgilldevtech.com/img/github/mcadviewcontroller/add-to-project.jpg)

#### Optional Installation
- To stay on tagged release, replace `master` with the tag number. ie. `https://raw.githubusercontent.com/kmcgill88/McAdViewController/1.0.0/McAdViewControllerExample/McAdViewController.swift`
-  To change the download directory, replace `McAdViewControllerExample` with your project folder name ie:
```
open('./<YOUR PROJECT NAME>/McAdViewController.swift', 'wb') do |file|
```


## Author

Kevin McGill, kevin@mcgilldevtech.com

## License

McAdViewController is available under the MIT license. See the LICENSE file for more info.
