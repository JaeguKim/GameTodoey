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
        tableView.register(CustomHeader.self, forHeaderFooterViewReuseIdentifier: "sectionHeader")
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
                let key = searchManager.keyDict[Const.dictKey[indexPath.section]!]![indexPath.row]
                destVC.gameScoreInfo = searchManager.gameInfoDict[key]
            }
        }
    }
}

//MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return searchManager.keyDict.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchManager.keyDict[Const.dictKey[section]!]?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.gameInfoCellIdentifier,for: indexPath) as! GameInfoCell
        let key = searchManager.keyDict[Const.dictKey[indexPath.section]!]![indexPath.row]
        cell.showLoadingIndicator()
        if let gameInfo =  searchManager.gameInfoDict[key]{
            if gameInfo.imageURL == ""{
                cell.gameImgView.image = UIImage(named: "default.jpg")
            } else {
                cell.gameImgView.sd_setImage(with: URL(string: gameInfo.imageURL))
            }
            cell.titleLabel.text = gameInfo.title
            
            if let score = Int(gameInfo.score){
                cell.hideLoadingIndicator()
                var text = "?"
                if score != 0{
                    text = String(score)
                }
                cell.scoreLabel.text = text
                cell.setViewBackgroundColor(score: score)
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionImages = ["pc.png","ps.png","xbox.png","switch.png"]
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "sectionHeader") as! CustomHeader
        view.contentView.backgroundColor = UIColor(named: "BrandLightBlue")
        view.image.image = UIImage(named: sectionImages[section])
        if section == 0{
            view.image.image = view.image.image?.withTintColor(UIColor.black)
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if searchManager.keyDict[Const.dictKey[section]!]!.count == 0{
            return 0.0
        }
        return 50.0
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
            if title != "" {
                searchManager.cancelRequests()
                showLoadingView(isIdle: false)
                activityIndicator.isHidden = false
                searchBar.endEditing(true)
                searchManager.launchSerach(title: title)
            }
            searchBar.endEditing(true)
        }
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchManager.cancelRequests()
        showLoadingView(isIdle: true)
        searchBar.endEditing(true)
    }
}

//MARK: - SearchManagerDelegate
extension SearchViewController: SearchManagerDelegate {
    func didTitleSearchRequestFail() {
        showError()
    }
    func didUpdateGameInfo(gameInfoDict : [String:GameInfo] ) {
        showTableView()
        //searchManager.initValue()
        realmManager.save(gameInfoDict: gameInfoDict)
        tableView.reloadData()
        searchBar.endEditing(true)
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

class CustomHeader: UITableViewHeaderFooterView {
    var image = UIImageView()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureContents()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureContents(){
        image.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(image)
        
        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: 50),
            image.heightAnchor.constraint(equalToConstant: 50),
            image.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            image.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
}
