import UIKit
import SDWebImage
import RealmSwift

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
    var isBtnEnabled = true
    var isCollapsed = true
    
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
    }
    
    func setData(){
        titleLabel.text = gameScoreInfo?.title
        gameImgView.sd_setImage(with: URL(string: gameScoreInfo!.imageURL))
        gameDesc.text = gameScoreInfo?.gameDescription
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
