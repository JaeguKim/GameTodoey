import UIKit
import Alamofire
import SwiftyJSON
import SDWebImage
import RealmSwift
import FirebaseAuth

class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var guideLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
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
        showLoadingView(isIdle: true)
        addGestureRecognizer()
    }

    func addGestureRecognizer(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        tap.delegate = self
    }
    
    @objc func dismissKeyboard(){
        searchBar.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        parent?.navigationItem.title = "Search Game"
        parent?.navigationItem.hidesBackButton = true
        parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOut))
         navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        searchBar.searchTextField.textColor = UIColor(named: "LinkColor")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        searchManager.cancelRequests()
    }
    
    func showLoadingView(isIdle:Bool){
        guideLabel.text = isIdle == true ? "" : "Searching"
        loadingView.isHidden = false
        activityIndicator.isHidden = true
        tableView.isHidden = true
    }
    
    func showError(){
        guideLabel.text = "No Results"
        loadingView.isHidden = false
        activityIndicator.isHidden = true
        tableView.isHidden = true
    }
    
    func showTableView(){
        tableView.isHidden = false
        loadingView.isHidden = true
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
        if gameInfo.imageURL == ""{
            cell.gameImgView.image = UIImage(named: "default.jpg")
        } else {
            cell.gameImgView.sd_setImage(with: URL(string: gameInfo.imageURL))
        }
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
            showLoadingView(isIdle: false)
            activityIndicator.isHidden = false
            searchBar.endEditing(true)
            searchManager.requestInfo(title: title)
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchManager.cancelRequests()
        showLoadingView(isIdle: true)
    }
}

//MARK: - SearchManagerDelegate
extension SearchViewController: SearchManagerDelegate {
    func didTitleSearchRequestFail() {
        showError()
    }
    func didUpdateGameInfo(gameInfoArray : [GameInfo] ) {
        if searchManager.isRequestsDone() {
            showTableView()
            searchManager.initValue()
            realmManager.save(gameInfoArray: gameInfoArray)
            tableView.reloadData()
        }
    }
}

//MARK: - UIGestureRecognizerDelegate
extension SearchViewController: UIGestureRecognizerDelegate{
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if (touch.view?.isDescendant(of: tableView))! {
            return false
        }
        return true
    }
}
