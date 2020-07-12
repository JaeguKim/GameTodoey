import UIKit
import RealmSwift
import SwipeCellKit
import SwiftReorder

class GameListViewController: UIViewController {

    var libraryInfo : LibraryInfo?
    @IBOutlet weak var tableView: UITableView!
    var realmManager = RealmManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = libraryInfo?.libraryTitle
        tableView.dataSource = self
        tableView.delegate = self
        //tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.register(UINib(nibName: Const.gameInfoCellNibName, bundle: nil), forCellReuseIdentifier: Const.gameInfoCellIdentifier)
        realmManager.delegate = self
        if libraryInfo?.libraryTitle != "Recents"{
            tableView.reorder.delegate = self
        }
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
            return libraryInfo?.gameInfoList.count ?? 0
         
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let spacer = tableView.reorder.spacerCell(for: indexPath){
            return spacer
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
            let text = gameInfo.score == "" ? "?" : gameInfo.score; 
            cell.setViewBackgroundColor(score: gameInfo.score)
            cell.scoreLabel.text = text
            
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
