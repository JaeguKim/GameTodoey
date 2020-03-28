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
        searchManager.delegate = self
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
        let gameInfo = searchManager.gameInfoArrary[indexPath.row]
        cell.gameImgView.sd_setImage(with: URL(string: gameInfo.imageURL))
        cell.titleLabel.text = gameInfo.title
        if let score = Int(gameInfo.score){
            cell.scoreLabel.text = String(gameInfo.score)
            cell.setViewBackgroundColor(score: score)
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

//MARK: - SearchManagerDelegate
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
