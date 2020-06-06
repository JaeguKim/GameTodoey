import UIKit
import SDWebImage
import RealmSwift

class DescriptionPopupViewController: UIViewController {
    
    var gameScoreInfo : GameInfo?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gameImgView: UIImageView!
    @IBOutlet weak var gameDescLabel: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var scrollView: UIScrollView!
    var isBtnEnabled = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
        if isBtnEnabled == false {
            saveBtn.isEnabled = isBtnEnabled
            saveBtn.alpha = 0.0
        }
        scrollView.layer.cornerRadius = scrollView.frame.height / 10
    }
    
    func setData(){
        titleLabel.text = gameScoreInfo?.title
        gameImgView.sd_setImage(with: URL(string: gameScoreInfo!.imageURL))
        gameDescLabel.text = gameScoreInfo?.gameDescription
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
}
