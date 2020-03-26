import UIKit
import RealmSwift
import SwipeCellKit

class LibraryViewController: UIViewController {

    @IBOutlet weak var libraryTableView: UITableView!
    var realm = try! Realm()
    var libraryInfoList : Results<LibraryInfo>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        libraryTableView.dataSource = self
        libraryTableView.delegate = self
    }
   
    @IBAction func plusBtnPressed(_ sender: UIBarButtonItem) {
        
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
        libraryInfoList?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Const.libraryCellIdentifier,for: indexPath) as! LibraryTableViewCell
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

