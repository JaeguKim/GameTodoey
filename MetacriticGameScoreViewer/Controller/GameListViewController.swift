import UIKit
import RealmSwift
import SwipeCellKit

class GameListViewController: UIViewController {
    
    var gameInfoList : List<Realm_GameScoreInfo>?
    @IBOutlet weak var tableView: UITableView!
    let realmManager = RealmManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.register(UINib(nibName: Const.gameInfoCellNibName, bundle: nil), forCellReuseIdentifier: Const.gameInfoCellIdentifier)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? DescriptionPopupViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let realmObj = gameInfoList![indexPath.row]
                let gameScoreInfo = GameInfo()
                gameScoreInfo.title = realmObj.title
                gameScoreInfo.platform = realmObj.platform
                gameScoreInfo.gameDescription = realmObj.gameDescription
                gameScoreInfo.imageURL = realmObj.imageURL
                gameScoreInfo.score = realmObj.score
                gameScoreInfo.done = realmObj.done
                destVC.gameScoreInfo = gameScoreInfo
            }
            destVC.isBtnEnabled = false
        }
    }
}

//MARK: - UITableViewDataSource
extension GameListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameInfoList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.gameInfoCellIdentifier,for: indexPath) as! GameInfoCell
        cell.delegate = self
        if let gameInfo = gameInfoList?[indexPath.row] {
            cell.gameImgView.sd_setImage(with: URL(string: gameInfo.imageURL))
            cell.titleLabel.text = gameInfo.title
            if let score = Int(gameInfo.score){
                cell.scoreLabel.text = String(gameInfo.score)
                cell.setViewBackgroundColor(score: score)
            }
        }
        return cell        
    }
}

//MARK: - UITableViewDelegate
extension GameListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: Const.bookmarkToDescSegue, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - SwipeTableViewCellDelegate
extension GameListViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {return nil}
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            if let gameInfo = self.gameInfoList?[indexPath.row] {
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
