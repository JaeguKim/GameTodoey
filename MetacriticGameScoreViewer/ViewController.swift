import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage

class GameScoreInfoCell : UITableViewCell{
    @IBOutlet weak var gameImgView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var platformLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    
}

class ViewController: UIViewController {
    
    let metacriticURL = "https://chicken-coop.p.rapidapi.com/games"
    var gameScoreInfoArray : [GameScoreInfo] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.dataSource = self
//        gameScoreInfoArray.append(GameScoreInfo(imageURL: "https://static.metacritic.com/images/products/games/5/c7a344249ff5b2a49917c70d765dfdf6-98.jpg", title: "Halo Wars 2", platform: "xbox-one", score: "79"))
//        
//        gameScoreInfoArray.append(GameScoreInfo(imageURL: "https://static.metacritic.com/images/products/games/5/c7a344249ff5b2a49917c70d765dfdf6-98.jpg", title: "Halo Wars 2", platform: "xbox-one", score: "79"))
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        //tableView.register(UINib(nibName: "GameInfoCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
    }
    
    func convertPlatformString(platform : String) -> String{
        switch platform {
        case "PS4":
            return "playstation-4";
        case "PS3":
            return "playstation-3";
        case "PC":
            return "pc";
        case "XONE":
            return "xbox-one";
        case "X360":
            return "xbox-360";
        case "XBOX":
            return "xbox";
        case "Switch":
            return "switch";
        default:
            print("platform string is wrong")
        }
        return ""
    }
    
    func requestInfo(title:String){
        let headers : [String:String] = [
            "Content-type" : "application/x-www-form-urlencoded",
            "x-rapidapi-host" : "chicken-coop.p.rapidapi.com",
            "x-rapidapi-key" : "c976920022msha45b1a7b96d279ap17e7aejsne930cb2ce86d",
        ]
        let parameters : [String:String] = [
            "title" : title
        ]
        Alamofire.request(metacriticURL, method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
            if response.result.isSuccess {
                let responseJSON : JSON = JSON(response.result.value!)
                if let jsonArray = responseJSON["result"].array {
                    for item in jsonArray {
                        let platform = item["platform"]
                        let title = item["title"]
                        self.requestInfo(platform: self.convertPlatformString(platform: platform.stringValue), gameTitle: title.stringValue)
                    }
                }
            }
        }
    }
    
    func requestInfo(platform:String, gameTitle:String){
        let headers : [String:String] = [
            "Content-type" : "application/x-www-form-urlencoded",
            "x-rapidapi-host" : "chicken-coop.p.rapidapi.com",
            "x-rapidapi-key" : "c976920022msha45b1a7b96d279ap17e7aejsne930cb2ce86d",
        ]
        let parameters : [String:String] = [
            "platform" : platform
        ]
        
        let newGameTitle = gameTitle.replacingOccurrences(of: " ", with: "%20")
        Alamofire.request(metacriticURL+"/\(newGameTitle)", method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
            if response.result.isSuccess {
                let responseJSON : JSON = JSON(response.result.value!)
                let score = responseJSON["result"]["score"].stringValue
                let imageURL = responseJSON["result"]["image"].stringValue
                self.gameScoreInfoArray.append(GameScoreInfo(imageURL: imageURL, title: gameTitle, platform: platform, score: score))
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
}

//MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameScoreInfoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell",for: indexPath) as! GameScoreInfoCell
        cell.gameImgView.sd_setImage(with: URL(string: gameScoreInfoArray[indexPath.row].imageURL))
        cell.titleLabel.text = gameScoreInfoArray[indexPath.row].title
        cell.platformLabel.text = gameScoreInfoArray[indexPath.row].platform
        cell.scoreLabel.text = String(gameScoreInfoArray[indexPath.row].score)
        return cell
    }
}

//MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let title = searchBar.searchTextField.text {
            gameScoreInfoArray.removeAll()
            tableView.reloadData()
            requestInfo(title: title )
        }
    }
    
}
