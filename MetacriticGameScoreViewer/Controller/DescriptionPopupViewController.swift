import UIKit
import SDWebImage
import RealmSwift

class DescriptionPopupViewController: UIViewController {
    
    var gameScoreInfo : GameScoreInfo?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gameImgView: UIImageView!
    @IBOutlet weak var gameDescLabel: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    let realm = try! Realm()
    var isBtnEnabled = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
        if isBtnEnabled == false {
            saveBtn.isEnabled = isBtnEnabled
            saveBtn.alpha = 0.0
        }
    }
    
    func setData(){
        titleLabel.text = gameScoreInfo?.title
        gameImgView.sd_setImage(with: URL(string: gameScoreInfo!.imageURL))
        gameDescLabel.text = gameScoreInfo?.gameDescription
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let descVC = segue.destination as! LibrarySelectionPopupViewController
        descVC.gameScoreInfo = gameScoreInfo
    }
    
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        performSegue(withIdentifier: Const.DescToLibSegue, sender: self)
    }
    
    func showAlertMessage(title : String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func save(realmObj : Realm_GameScoreInfo) {
        do {
            try realm.write {
                realm.add(realmObj)
            }
        } catch {
            print("Error Saving context \(error)")
        }
    }
}
