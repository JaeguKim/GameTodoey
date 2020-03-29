import UIKit
import RealmSwift
import SwipeCellKit

class LibrarySelectionPopupViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var realm = try! Realm()
    var libraryInfoList : Results<LibraryInfo>?
    let realmManager = RealmManager()
    var gameScoreInfo : GameInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.register(UINib(nibName: Const.LibraryCellNibName, bundle: nil), forCellReuseIdentifier: Const.libraryCellIdentifier)
        libraryInfoList = realmManager.loadLibraries()
    }
   
    func showAlertMessage(title : String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    func addLibraryBtnPressed() {
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
    
}

extension LibrarySelectionPopupViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let libraryList = libraryInfoList {
            return libraryList.count + 1
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.libraryCellIdentifier,for: indexPath) as! LibraryInfoCell
        cell.delegate = self
        if indexPath.row == 0 {
            cell.libraryTitle.text = "New Library..."
        }else {
            if let libraryInfo = libraryInfoList?[indexPath.row - 1] {
                if libraryInfo.imageURL == "" {
                    cell.libraryImgView.image = UIImage(named: "default.jpg")
                } else{
                cell.libraryImgView.sd_setImage(with: URL(string: libraryInfo.imageURL))
                }
                cell.libraryTitle.text = libraryInfo.libraryTitle
            }
        }
        return cell
    }
}

extension LibrarySelectionPopupViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let gameScoreData = gameScoreInfo else {return}
        if indexPath.row == 0 {
            addLibraryBtnPressed()
            return
        }
        guard let selectedLibrary = libraryInfoList?[indexPath.row - 1] else {return}
        for item in selectedLibrary.gameScoreInfoList {
            if gameScoreData.id == item.id {
                showAlertMessage(title: "Already Added To Library")
                return
            }
        }
        do {
            try self.realm.write {
                let realmObj = Realm_GameScoreInfo()
                realmObj.title = gameScoreData.title
                realmObj.platform = gameScoreData.platform
                realmObj.gameDescription = gameScoreData.gameDescription
                realmObj.imageURL = gameScoreData.imageURL
                realmObj.score = gameScoreData.score
                realmObj.id = gameScoreData.id
                realmObj.done = gameScoreData.done
                selectedLibrary.imageURL = gameScoreData.imageURL
                selectedLibrary.gameScoreInfoList.append(realmObj)
            }
        } catch {
            showAlertMessage(title: "Failed To Save To Your Library")
            print("Error Occurred while saving context \(error)")
            return
        }
        self.tableView.reloadData()
        showAlertMessage(title: "Saved To Your Library")
    }
}

//MARK: - SwipeTableViewCellDelegate
extension LibrarySelectionPopupViewController : SwipeTableViewCellDelegate {
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



