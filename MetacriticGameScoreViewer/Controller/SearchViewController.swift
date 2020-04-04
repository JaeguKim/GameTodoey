import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import RealmSwift
import FirebaseAuth

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var progressUIView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var idleView: UIView!
    @IBOutlet weak var guideLabel: UILabel!
    
    var searchManager = SearchManager()
    var realmManager = RealmManager()
    var libraryInfoList : Results<LibraryInfo>?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.register(UINib(nibName: Const.gameInfoCellNibName, bundle: nil), forCellReuseIdentifier: Const.gameInfoCellIdentifier)
        searchManager.delegate = self
        searchBar.showsCancelButton = true
        libraryInfoList = realmManager.loadLibraries()
        AddDefaultCollection()
        showIdleView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        parent?.navigationItem.title = "Search Game"
        parent?.navigationItem.hidesBackButton = true
        parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOut))
        guideLabel.text = ""
    }
    
    func showIdleView(){
        guideLabel.text = ""
        idleView.isHidden = false
        tableView.isHidden = true
        progressUIView.isHidden = true
    }
    
    func showTableView(){
        progressView.progress = 0.0
        tableView.isHidden = false
        idleView.isHidden = true
        progressUIView.isHidden = true
    }
    
    func showProgressView(){
        progressUIView.isHidden = false
        idleView.isHidden = true
        tableView.isHidden = true
    }
    
    @objc func logOut(){
        do {
            try Auth.auth().signOut()
            parent?.navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
    }
    
     func AddDefaultCollection(){
         if let libraryList = self.libraryInfoList {
            for title in Const.defaultLibraryTitles{
                 var isAdd = true
                 for item in libraryList{
                     if title == item.libraryTitle{
                         isAdd = false
                         break
                     }
                 }
                 if isAdd{
                     let newLibrary = LibraryInfo()
                     newLibrary.libraryTitle = title
                     self.realmManager.save(realmObj: newLibrary)
                 }
             }
         }
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
            showProgressView()
            searchManager.requestInfo(title: title)
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchManager.cancelRequests()
        showIdleView()
    }
}

//MARK: - SearchManagerDelegate
extension SearchViewController: SearchManagerDelegate {
    func didTitleSearchRequestFail() {
        showIdleView()
        guideLabel.text = "No Results"
    }
    func didUpdateGameInfo(gameInfoArray : [GameInfo] ) {
        progressView.progress = searchManager.getCompletionRate()
        if searchManager.isRequestsDone() {
            showTableView()
            searchManager.initValue()
            realmManager.save(gameInfoArray: gameInfoArray)
            tableView.reloadData()
        }
    }
}
