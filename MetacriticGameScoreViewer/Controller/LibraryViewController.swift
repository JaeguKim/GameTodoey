import UIKit
import RealmSwift
import SwipeCellKit

class LibraryViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var realm = try! Realm()
    var libraryInfoList : Results<LibraryInfo>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 150
        tableView.register(UINib(nibName: Const.LibraryCellNibName, bundle: nil), forCellReuseIdentifier: Const.libraryCellIdentifier)
    }
   
    @IBAction func plusBtnPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "New Library", message: "Enter a name for this library", preferredStyle: .alert)
        alert.addTextField { (alertTextField) in
            textField.placeholder = "Title"
            textField = alertTextField
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            alert.dismiss(animated: true, completion: nil)
        }
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action) in
            let newLibrary = LibraryInfo()
            newLibrary.libraryTitle = textField.text!
            self.save(realmObj: newLibrary)
            self.tableView.reloadData()
        }
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert,animated: true, completion: nil)
    }
    
    func loadLibraries() {
        libraryInfoList = realm.objects(LibraryInfo.self)
        tableView.reloadData()
    }
    
    func save(realmObj : LibraryInfo) {
        do {
            try realm.write {
                realm.add(realmObj)
            }
        } catch {
            print("Error Saving context \(error)")
        }
    }
    
    func updateModel(at indexPath: IndexPath) {
          if let itemForDeletion = self.libraryInfoList?[indexPath.row]
          {
              do {
                  try self.realm.write() {
                      self.realm.delete(itemForDeletion)
                  }
              } catch {
                  print("Error occurred when deleting item \(error)")
              }
          }
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
            cell.libraryImgView.sd_setImage(with: URL(string: libraryInfo.imageURL))
            cell.libraryTitle.text = libraryInfo.libraryTitle
          }
          return cell
    }
    
    
}

//MARK: - UITableViewDelegate
extension LibraryViewController : UITableViewDelegate {
    
}

//MARK: - SwipeTableViewCellDelegate
extension LibraryViewController : SwipeTableViewCellDelegate {
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else {return nil}
        let deleteAction = SwipeAction(style: .destructive, title: "Delete") { (action, indexPath) in
            self.updateModel(at: indexPath)
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

