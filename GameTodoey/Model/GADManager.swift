import GoogleMobileAds
protocol GADManagerDelegate {
    func didAdLoaded(nativeAdView : GADUnifiedNativeAdView)
}

class GADManager : NSObject {
    var adLoader : GADAdLoader!
    var nativeAdView: GADUnifiedNativeAdView!
    var delegate : GADManagerDelegate?
    var isActivated : Bool = false
    
    func initAdLoader(viewController:UIViewController){
        adLoader = GADAdLoader(adUnitID: "ca-app-pub-3940256099942544/3986624511",
            rootViewController: viewController,
            adTypes: [ GADAdLoaderAdType.unifiedNative ],
            options: [])
        adLoader.delegate = self
        adLoader.load(GADRequest())
        guard let nibObjects = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil,options:nil), let adView = nibObjects.first as? GADUnifiedNativeAdView else { assert(false,"Could not load nib file for adView")
        }
        nativeAdView = adView
    }
}

//MARK: - GADUnifiedNativeAdLoaderDelegate
extension GADManager: GADUnifiedNativeAdLoaderDelegate {
    public func adLoader(_ adLoader: GADAdLoader,
                           didReceive nativeAd: GADUnifiedNativeAd){
        print("Received unified native ad: \(nativeAd)")
        nativeAdView.nativeAd = nativeAd
        nativeAd.delegate = self
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
        delegate?.didAdLoaded(nativeAdView: nativeAdView)
    }
    
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("Error Occurred \(error)")
    }
}

//MARK: - GADUnifiedNativeAdDelegate
extension GADManager: GADUnifiedNativeAdDelegate {
    func nativeAdDidRecordClick(_ nativeAd: GADUnifiedNativeAd) {
      print("\(#function) called")
    }

    func nativeAdDidRecordImpression(_ nativeAd: GADUnifiedNativeAd) {
      print("\(#function) called")
    }

    func nativeAdWillPresentScreen(_ nativeAd: GADUnifiedNativeAd) {
      print("\(#function) called")
    }

    func nativeAdWillDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
      print("\(#function) called")
    }

    func nativeAdDidDismissScreen(_ nativeAd: GADUnifiedNativeAd) {
      print("\(#function) called")
    }

    func nativeAdWillLeaveApplication(_ nativeAd: GADUnifiedNativeAd) {
      print("\(#function) called")
    }
}

