
import UIKit
import RealmSwift

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
    
}

//MARK: - UITableViewDataSource
extension BookmarkViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameInfoList?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell",for: indexPath) as! GameInfoCell
        if let gameInfo = gameInfoList?[indexPath.row] {
            cell.gameImgView.sd_setImage(with: URL(string: gameInfo.imageURL))
            cell.titleLabel.text = gameInfo.title
            cell.platformLabel.text = gameInfo.platform
            cell.scoreLabel.text = String(gameInfo.score)
        }
        return cell        
    }
}
