import UIKit
import SwipeCellKit
import RealmSwift

class LibraryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
  
    var libraryInfoList : Results<LibraryInfo>?
    var selectedLibrary : LibraryInfo?
    let realmManager = RealmManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        parent?.navigationItem.title = "Library"
        let rightButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBtnPressed(_:)))
        parent?.navigationItem.rightBarButtonItem = rightButton
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.register(UINib(nibName: Const.LibraryCellNibName, bundle: nil), forCellReuseIdentifier: Const.libraryCellIdentifier)
        libraryInfoList = realmManager.loadLibraries()
        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    @IBAction func addBtnPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "New Library", message: "Enter a name for this library", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Title"
            textField = alertTextField
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            let newLibrary = LibraryInfo()
            newLibrary.libraryTitle = textField.text!
            self.realmManager.save(realmObj: newLibrary)
            self.tableView.reloadData()
        }
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert,animated: true, completion: nil)
    }

  
    
    func showAlertMessage(title : String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destVC = segue.destination as! GameListViewController
        destVC.gameInfoList = selectedLibrary?.gameScoreInfoList
    }
}

//MARK: - UITableViewDataSource
extension LibraryViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        libraryInfoList?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.libraryCellIdentifier,for: indexPath) as! LibraryInfoCell
          cell.delegate = self
        if let libraryInfo = libraryInfoList?[indexPath.row] {
            if libraryInfo.imageURL == "" {
                cell.libraryImgView.image = UIImage(named: "default.jpg")
            } else{
                cell.libraryImgView.sd_setImage(with: URL(string: libraryInfo.imageURL))
            }
            cell.libraryTitle.text = libraryInfo.libraryTitle
          }
          return cell
    }
    
    
}

//MARK: - UITableViewDelegate
extension LibraryViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let libraryInfo = libraryInfoList?[indexPath.row] {
            selectedLibrary = libraryInfo
            performSegue(withIdentifier: Const.libraryVCToGameListVCSegue, sender: self)
        }
    }
}

//MARK: - SwipeTableViewCellDelegate
extension LibraryViewController : SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {return nil}
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            if let libraryInfo = self.libraryInfoList?[indexPath.row] {
                self.realmManager.deleteLibrary(libraryInfo: libraryInfo)
            }
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

