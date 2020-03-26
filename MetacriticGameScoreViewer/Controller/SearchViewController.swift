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
    var requests : [Alamofire.Request] = []
    var searchUIAlert : UIAlertController?
    var totalRequests : Int = 0
    var requestsDone : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.register(UINib(nibName: "GameInfoCell", bundle: nil), forCellReuseIdentifier: Const.gameInfoCellIdentifier)
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
        self.searchUIAlert = UIAlertController(title: "Searching...", message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
            self.cancelRequests()
            self.gameScoreInfoArray.removeAll()
            self.tableView.reloadData()
        }
        searchUIAlert?.addAction(cancelAction)
        self.present(self.searchUIAlert!, animated: true)
        let headers : [String:String] = [
            "Content-type" : "application/x-www-form-urlencoded",
            "x-rapidapi-host" : "chicken-coop.p.rapidapi.com",
            "x-rapidapi-key" : "c976920022msha45b1a7b96d279ap17e7aejsne930cb2ce86d",
        ]
        let parameters : [String:String] = [
            "title" : title
        ]
        let request = Alamofire.request(metacriticURL, method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
            if response.result.isSuccess {
                let responseJSON : JSON = JSON(response.result.value!)
                if let jsonArray = responseJSON["result"].array {
                    self.totalRequests = jsonArray.count
                    
                    for item in jsonArray {
                        let platform = item["platform"].stringValue
                        let title = item["title"].stringValue
                        if self.isValidPlatform(platform) {
                            self.requestInfo(platform: self.convertPlatformString(platform: platform), gameTitle: title)
                        }
                        else {
                            self.totalRequests-=1
                        }
                    }
                    print("totalRequests : \(self.totalRequests)")
                    // if there is no valid total request
                    if self.totalRequests == 0 {
                        self.searchUIAlert?.title = "No Results"
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.searchUIAlert?.dismiss(animated: true, completion: nil)
                        }
                    }
                }
                else {
                    // if jsonarray has 0 elem
                    self.searchUIAlert?.title = "No Results"
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.searchUIAlert?.dismiss(animated: true, completion: nil)
                    }
                }
            }
            else {
                // if request is failed,
                self.searchUIAlert?.title = "No Results"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.searchUIAlert?.dismiss(animated: true, completion: nil)
                }
            }
        }
        requests.append(request)
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
        let request = Alamofire.request(metacriticURL+"/\(newGameTitle)", method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
            if response.result.isSuccess {
                let responseJSON : JSON = JSON(response.result.value!)
                let score = responseJSON["result"]["score"].stringValue
                let imageURL = responseJSON["result"]["image"].stringValue
                let description = responseJSON["result"]["description"].stringValue
                let gameScoreInfo = GameScoreInfo()
                gameScoreInfo.imageURL = imageURL
                gameScoreInfo.title = gameTitle
                gameScoreInfo.platform = platform
                gameScoreInfo.score = score
                gameScoreInfo.gameDescription = description
                gameScoreInfo.done = false
                self.gameScoreInfoArray.append(gameScoreInfo)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            self.requestsDone += 1
            print("requestsDone : \(self.requestsDone)")
            let percent = (self.requestsDone * 100) / self.totalRequests
            self.searchUIAlert?.title = "\(percent)% Loaded"
            if self.requestsDone == self.totalRequests {
                self.searchUIAlert?.dismiss(animated: true, completion: {
                    self.requestsDone = 0
                    self.totalRequests = 0
                })
            }
        }
        requests.append(request)
    }
    
    func cancelRequests(){
        for request in requests {
            request.cancel()
        }
        requests.removeAll()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? DescriptionPopupViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                destVC.gameScoreInfo = gameScoreInfoArray[indexPath.row]
            }
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
        cell.scoreLabel.text = String(gameScoreInfoArray[indexPath.row].score)
        return cell
    }
}

//MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: Const.searchToDescSegue, sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

//MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let title = searchBar.searchTextField.text {
            cancelRequests()
            gameScoreInfoArray.removeAll()
            tableView.reloadData()
            requestInfo(title: title )
        }
    }
    
}
