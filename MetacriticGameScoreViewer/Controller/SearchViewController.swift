import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import RealmSwift

class SearchViewController: UIViewController {
    
    let metacriticURL = "https://chicken-coop.p.rapidapi.com/games"
    var gameScoreInfoArray : [GameScoreInfo] = []
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.register(UINib(nibName: "GameInfoCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
    }
    
    func isValidPlatform(_ platform : String) -> Bool {
        switch platform {
        case "PS4":
            return true
        case "PS3":
             return true
        case "PC":
            return true
        case "XONE":
            return true
        case "X360":
            return true
        case "XBOX":
             return true
        case "Switch":
             return true
        default:
            return false
        }
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
            return platform
        }
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
                        let platform = item["platform"].stringValue
                        let title = item["title"].stringValue
                        if self.isValidPlatform(platform) {
                        self.requestInfo(platform: self.convertPlatformString(platform: platform), gameTitle: title)
                        }
                    }
                }
                else {
                    let alert = UIAlertController(title: "No Results", message: "", preferredStyle: .alert)
                    self.present(alert, animated: true) {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            alert.dismiss(animated: true, completion: nil)
                        }
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
                let gameScoreInfo = GameScoreInfo()
                gameScoreInfo.imageURL = imageURL
                gameScoreInfo.title = gameTitle
                gameScoreInfo.platform = platform
                gameScoreInfo.score = score
                self.gameScoreInfoArray.append(gameScoreInfo)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    func save(gameScoreInfo : GameScoreInfo) {
        do {
            try realm.write {
                realm.add(gameScoreInfo)
            }
        } catch {
            print("Error Saving context \(error)")
        }
    }
}

//MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameScoreInfoArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell",for: indexPath) as! GameInfoCell
        cell.gameImgView.sd_setImage(with: URL(string: gameScoreInfoArray[indexPath.row].imageURL))
        cell.titleLabel.text = gameScoreInfoArray[indexPath.row].title
        cell.platformLabel.text = gameScoreInfoArray[indexPath.row].platform
        cell.scoreLabel.text = String(gameScoreInfoArray[indexPath.row].score)
        return cell
    }
}

//MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        save(gameScoreInfo: gameScoreInfoArray[indexPath.row])
        let alert = UIAlertController(title: "Saved To Your Library", message: "", preferredStyle: .alert)
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let title = searchBar.searchTextField.text {
            gameScoreInfoArray.removeAll()
            tableView.reloadData()
            requestInfo(title: title )
        }
    }
    
}
