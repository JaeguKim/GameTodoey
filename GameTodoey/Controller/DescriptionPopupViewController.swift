import UIKit
import SDWebImage
import RealmSwift
import GoogleMobileAds

class DescriptionPopupViewController: UIViewController {
    
    var gameScoreInfo : GameInfo?
    var playTimeDict : [Int:[String:String]] = [0:["title":"Main Story","time":""],
                                                1:["title":"Main + Extra","time":""],
                                                2:["title":"Completionest","time":""]]
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gameImgView: UIImageView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var gameDesc: UILabel!
    @IBOutlet weak var descBtn: UIButton!
    @IBOutlet weak var gameTimeStackView: UIStackView!
    @IBOutlet weak var mainTimeLabel: UILabel!
    @IBOutlet weak var mainExtraLabel: UILabel!
    @IBOutlet weak var completionestTimeLabel: UILabel!
    @IBOutlet weak var adView: UIView!
    
    var isBtnEnabled = true
    var isCollapsed = true
    var adLoader : GADAdLoader!
    var adManager : GADManager = GADManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isBtnEnabled == false {
            saveBtn.isEnabled = isBtnEnabled
            saveBtn.alpha = 0.0
        }
        gameDesc.layer.cornerRadius = gameDesc.frame.height / 5
        setData()
        descBtn.setTitleColor(UIColor(named: "LinkColor"), for: .selected)
        descBtn.setTitleColor(UIColor(named: "LinkColor"), for: .highlighted)
        closeDesc()
        for childView in gameTimeStackView.arrangedSubviews{
            childView.layer.cornerRadius = childView.frame.height/5
        }
        adManager.delegate = self
        adManager.initAdLoader(viewController: self)
    }
    
    func setData(){
        titleLabel.text = gameScoreInfo?.title
        gameImgView.sd_setImage(with: URL(string: gameScoreInfo!.imageURL))
        gameDesc.text = gameScoreInfo?.gameDescription
        mainTimeLabel.text = gameScoreInfo?.mainStoryTime
        mainExtraLabel.text = gameScoreInfo?.mainExtraTime
        completionestTimeLabel.text = gameScoreInfo?.completionTime
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let descVC = segue.destination as! LibrarySelectionPopupViewController
        descVC.gameInfo = gameScoreInfo
    }
    
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: Const.descToLibSegue, sender: self)
    }
    
    @IBAction func dismissBtnPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func descLabelBtn(_ sender: UIButton) {
        if (isCollapsed){
            expandDesc()
        }
        else{
            closeDesc()
        }
    }
    
    func expandDesc(){
        gameDesc.numberOfLines = 0
        descBtn.setTitle("Close", for: .normal)
        isCollapsed = false
    }
    
    func closeDesc(){
        gameDesc.numberOfLines = 10
        descBtn.setTitle("Expand", for: .normal)
        isCollapsed = true
    }
}

extension DescriptionPopupViewController : GADManagerDelegate {
    func didAdLoaded(nativeAdView: GADUnifiedNativeAdView) {
        adView.addSubview(nativeAdView)
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        let constW:NSLayoutConstraint = NSLayoutConstraint(item: nativeAdView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: adView, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0);
        adView.addConstraint(constW);
        let constH:NSLayoutConstraint = NSLayoutConstraint(item: nativeAdView, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: adView, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0);
        adView.addConstraint(constH);
    }
}
