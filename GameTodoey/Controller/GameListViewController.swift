import UIKit
import RealmSwift
import SwipeCellKit
import SwiftReorder
import GoogleMobileAds

class GameListViewController: UIViewController {

    var libraryInfo : LibraryInfo?
    @IBOutlet weak var tableView: UITableView!
    var realmManager = RealmManager()
    var adLoader : GADAdLoader!
    var nativeAdView: GADUnifiedNativeAdView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = libraryInfo?.libraryTitle
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.register(UINib(nibName: Const.gameInfoCellNibName, bundle: nil), forCellReuseIdentifier: Const.gameInfoCellIdentifier)
        tableView.register(UINib(nibName: Const.adCellNibName,bundle:nil),forCellReuseIdentifier:Const.adCellIdentifier)
        realmManager.delegate = self
        if libraryInfo?.libraryTitle != "Recents"{
            tableView.reorder.delegate = self
        }
        
        adLoader = GADAdLoader(adUnitID: "ca-app-pub-3940256099942544/3986624511",
            rootViewController: self,
            adTypes: [ GADAdLoaderAdType.unifiedNative ],
            options: [])
        adLoader.delegate = self
        adLoader.load(GADRequest())
        guard let nibObjects = Bundle.main.loadNibNamed("UnifiedNativeAdView", owner: nil,options:nil), let adView = nibObjects.first as? GADUnifiedNativeAdView else { assert(false,"Could not load nib file for adView")
        }
        nativeAdView = adView
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? DescriptionPopupViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let realmObj = libraryInfo!.gameInfoList[indexPath.row]
                let gameScoreInfo = GameInfo()
                gameScoreInfo.title = realmObj.title
                gameScoreInfo.platform = realmObj.platform
                gameScoreInfo.gameDescription = realmObj.gameDescription
                gameScoreInfo.imageURL = realmObj.imageURL
                gameScoreInfo.mainStoryTime = realmObj.mainStoryTime
                gameScoreInfo.mainExtraTime = realmObj.mainExtraTime
                gameScoreInfo.completionTime = realmObj.completionTime
                var text = "?"
                if realmObj.score != "0" {
                    text = realmObj.score
                }
                gameScoreInfo.score = text
                destVC.gameScoreInfo = gameScoreInfo
            }
            //            destVC.isBtnEnabled = false
        }
    }
}
    
    //MARK: - UITableViewDataSource
    extension GameListViewController: UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            let count = libraryInfo?.gameInfoList.count ?? 0
            if count == 0{
                return 1
            }
            else{
                return count+1
            }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let spacer = tableView.reorder.spacerCell(for: indexPath){
            return spacer
        }
        if nativeAdView != nil &&  indexPath.row == (libraryInfo?.gameInfoList.count)!{
            let cell = tableView.dequeueReusableCell(withIdentifier: Const.adCellIdentifier, for: indexPath) as! GADCell
            cell.addSubview(nativeAdView)
            let viewDictionary = ["_nativeAdView":nativeAdView!]
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.gameInfoCellIdentifier,for: indexPath) as! GameInfoCell
        cell.delegate = self
        if let gameInfo = libraryInfo?.gameInfoList[indexPath.row] {
            if gameInfo.imageURL == ""{
                cell.gameImgView.image = UIImage(named: "default.jpg")
            } else {
                cell.gameImgView.sd_setImage(with: URL(string: gameInfo.imageURL))
            }
            cell.titleLabel.text = gameInfo.title
            if let score = Int(gameInfo.score){
                var text = "?"
                if score != 0 {
                    text = String(score)
                }
                cell.scoreLabel.text = text
                cell.setViewBackgroundColor(score: score)
            }
        }
        return cell        
    }
}

//MARK: - UITableViewDelegate
extension GameListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Const.GameListVCToDescVCSegue, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - SwipeTableViewCellDelegate
extension GameListViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {return nil}
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            if let gameInfo = self.libraryInfo?.gameInfoList[indexPath.row] {
                self.realmManager.deleteGameInfo(gameInfo: gameInfo)
            }
        }
        deleteAction.image = UIImage(named: "delete-icon")
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .destructive
        return options
    }
}

//MARK: - RealmMangerDelegate
extension GameListViewController : RealmManagerDelegate {
    func didSave(title: String) {}
    
    func didDelete() {
        libraryInfo?.updateLibraryImage()
    }
    func didFail(error: Error) {}
    
}

//MARK: - TableViewReorderDelegate
extension GameListViewController: TableViewReorderDelegate {
    func tableView(_ tableView: UITableView, reorderRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let gameInfoList = libraryInfo?.gameInfoList{
            realmManager.reorderGameList(gameInfoList: gameInfoList, sourceIndexPath: sourceIndexPath, destinationIndexPath: destinationIndexPath)
        }
    }
}

//MARK: - GADUnifiedNativeAdLoaderDelegate
extension GameListViewController: GADUnifiedNativeAdLoaderDelegate {
    public func adLoader(_ adLoader: GADAdLoader,
                           didReceive nativeAd: GADUnifiedNativeAd){
        print("Received unified native ad: \(nativeAd)")
        nativeAdView.nativeAd = nativeAd
        nativeAd.delegate = self
        (nativeAdView.headlineView as? UILabel)?.text = nativeAd.headline
        (nativeAdView.advertiserView as? UILabel)?.text = nativeAd.advertiser
        (nativeAdView.callToActionView as? UIButton)?.setTitle(nativeAd.callToAction, for: .normal)
        nativeAdView.callToActionView?.isHidden = nativeAd.callToAction == nil
        (nativeAdView.iconView as? UIImageView)?.image = nativeAd.icon?.image
        nativeAdView.iconView?.isHidden = nativeAd.icon == nil
       // nativeAdView.mediaView?.mediaContent = nativeAd.mediaContent
        //let mediaContent = nativeAd.mediaContent
//        if mediaContent.hasVideoContent {
//            mediaContent.videoController.delegate = self
//
//        }
        
        tableView.reloadData()
      }
    func adLoader(_ adLoader: GADAdLoader, didFailToReceiveAdWithError error: GADRequestError) {
        print("Error Occurred \(error)")
    }
}

//MARK: - GADUnifiedNativeAdDelegate
extension GameListViewController: GADUnifiedNativeAdDelegate {
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
