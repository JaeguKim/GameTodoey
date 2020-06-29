import UIKit
import SDWebImage
import RealmSwift

class DescriptionPopupViewController: UIViewController {
    
    var gameScoreInfo : GameInfo?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gameImgView: UIImageView!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var gameDesc: UILabel!
    @IBOutlet weak var descBtn: UIButton!
    var isBtnEnabled = true
    var isCollapsed = true
    @IBOutlet weak var playTimeTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isBtnEnabled == false {
            saveBtn.isEnabled = isBtnEnabled
            saveBtn.alpha = 0.0
        }
        playTimeTableView.dataSource = self
        playTimeTableView.rowHeight = 150
        playTimeTableView.estimatedRowHeight = 150
        playTimeTableView.register(UINib(nibName: Const.playTimeCellNibName, bundle: nil), forCellReuseIdentifier: Const.playTimeCellIdentifier)
        gameDesc.layer.cornerRadius = gameDesc.frame.height / 5
        setData()
        descBtn.setTitleColor(UIColor(named: "LinkColor"), for: .selected)
        descBtn.setTitleColor(UIColor(named: "LinkColor"), for: .highlighted)
        closeDesc()
        
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

extension DescriptionPopupViewController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = playTimeTableView.dequeueReusableCell(withIdentifier: Const.playTimeCellIdentifier,for: indexPath) as! PlayTimeInfoCell
        cell.setData(mainStory: gameScoreInfo!.mainStoryTime, mainExtra: gameScoreInfo!.mainExtraTime, completionest: gameScoreInfo!.completionTime)
        return cell
    }
}
