import UIKit
import RealmSwift
import SwipeCellKit

class BookmarkViewController: UIViewController {
    
    var realm = try! Realm()
    var gameInfoList : Results<GameScoreInfo>?
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.register(UINib(nibName: "GameInfoCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        loadGameScoreInfo()
    }
    
    func loadGameScoreInfo() {
        gameInfoList = realm.objects(GameScoreInfo.self)
        tableView.reloadData()
    }
    
    func updateModel(at indexPath: IndexPath) {
          if let itemForDeletion = self.gameInfoList?[indexPath.row]
          {
              do {
                  try self.realm.write() {
                      self.realm.delete(itemForDeletion)
                  }
              } catch {
                  print("Error occurred when deleting item \(error)")
              }
          }
    }
}

//MARK: - UITableViewDataSource
extension BookmarkViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameInfoList?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell",for: indexPath) as! GameInfoCell
        cell.delegate = self
        if let gameInfo = gameInfoList?[indexPath.row] {
            cell.gameImgView.sd_setImage(with: URL(string: gameInfo.imageURL))
            cell.titleLabel.text = gameInfo.title
            cell.scoreLabel.text = String(gameInfo.score)
            cell.accessoryType = .checkmark
        }
        return cell        
    }
}

//MARK: - SwipeTableViewCellDelegate
extension BookmarkViewController: SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {return nil}
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.updateModel(at: indexPath)
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
