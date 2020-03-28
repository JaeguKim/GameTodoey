import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import RealmSwift

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchUIAlert : UIAlertController?
    var searchManager = SearchManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.parent?.navigationItem.title = "Search Game"
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.register(UINib(nibName: Const.gameInfoCellNibName, bundle: nil), forCellReuseIdentifier: Const.gameInfoCellIdentifier)
        searchManager.searchManagerDelegate = self
    }
    
    func showNoResultAlert(){
        self.searchUIAlert?.title = "No Results"
        self.searchUIAlert?.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination as? DescriptionPopupViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                destVC.gameScoreInfo = searchManager.gameInfoArrary[indexPath.row]
            }
        }
    }
}

//MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchManager.gameInfoArrary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.gameInfoCellIdentifier,for: indexPath) as! GameInfoCell
        let gameScoreInfoArray = searchManager.gameInfoArrary
        cell.gameImgView.sd_setImage(with: URL(string: gameScoreInfoArray[indexPath.row].imageURL))
        cell.titleLabel.text = gameScoreInfoArray[indexPath.row].title
        if let score = Int(gameScoreInfoArray[indexPath.row].score){
            let color : UIColor?
            if score >= 80 {
                color = UIColor.green
            } else if score >= 70 {
                color = UIColor.yellow
            } else {
                color = UIColor.red
            }
            cell.scoreLabel.text = String(gameScoreInfoArray[indexPath.row].score)
            cell.scoreBackgroundView.backgroundColor = color
        }
        
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
            searchManager.cancelRequests()
            tableView.reloadData()
            self.searchUIAlert = UIAlertController(title: "Searching...", message: "", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action) in
                self.searchManager.cancelRequests()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            searchUIAlert?.addAction(cancelAction)
            self.present(self.searchUIAlert!, animated: true)
            searchManager.requestInfo(title: title)
        }
    }
}

//MARK: - searchManagerDelegate
extension SearchViewController: SearchManagerDelegate {
    func didTitleSearchRequestFail() {
        showNoResultAlert()
    }
    func didUpdateGameInfo(gameInfoArrary : [GameInfo] ) {
        self.searchUIAlert?.title = "\(searchManager.getCompletionPercent())% Loaded"
        if searchManager.isRequestsDone() {
            searchUIAlert?.dismiss(animated: true, completion: nil)
            searchManager.initValue()
            tableView.reloadData()
        }
    }
}
