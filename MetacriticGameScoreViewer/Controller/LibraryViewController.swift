import UIKit
import RealmSwift

class LibraryViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var libraryInfoList : Results<LibraryInfo>?
    var selectedLibrary : LibraryInfo?
    var realmManager = RealmManager()
    private let sectionInsets = UIEdgeInsets(top: 50.0,
                                             left: 20.0,
                                             bottom: 50.0,
                                             right: 20.0)
    var isEditMode = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        realmManager.delegate = self
        self.collectionView.register(UINib(nibName: Const.LibraryCellNibName, bundle: nil), forCellWithReuseIdentifier: Const.libraryCellIdentifier)
        libraryInfoList = realmManager.loadLibraries()
        collectionView.reloadData()
    }
 
    override func viewWillAppear(_ animated: Bool) {
        initNavigationItem()
        parent?.navigationItem.title = "Library"
         navigationController?.navigationBar.standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        collectionView.reloadData()
        collectionView.allowsSelection = true
    }
    
    @objc func addBtnPressed() {
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
            guard let libraryTitle = textField.text else {return}
            if libraryTitle == ""
            {
                self.showAlertMessage(title: "library name should not be blank")
                return
            }
            if let libraryList = self.libraryInfoList {
                for item in libraryList {
                    if  item.libraryTitle == libraryTitle {
                        self.showAlertMessage(title: "library name is duplicated")
                        return
                    }
                }
                let newLibrary = LibraryInfo()
                newLibrary.libraryTitle = textField.text!
                self.realmManager.save(realmObj: newLibrary)
            }
        }
        alert.addAction(cancelAction)
        alert.addAction(saveAction)
        present(alert,animated: true, completion: nil)
    }
    
    @objc func editButtonPressed(){
        let leftButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addBtnPressed))
        let rightButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneButtonPressed))
        parent?.navigationItem.leftBarButtonItem = leftButton
        parent?.navigationItem.rightBarButtonItem = rightButton
        collectionView.allowsSelection = false
        isEditMode = true
        collectionView.reloadData()
    }
    
    @objc func doneButtonPressed(){
        initNavigationItem()
        collectionView.allowsSelection = true
        collectionView.reloadData()
    }
    
    func initNavigationItem(){
        self.parent?.navigationItem.hidesBackButton = true
        parent?.navigationItem.leftBarButtonItem = nil
        parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(editButtonPressed))
       isEditMode = false
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
        destVC.libraryInfo = selectedLibrary
    }
}

//MARK: - RealmManagerDelegate
extension LibraryViewController : RealmManagerDelegate {
    
    @objc func didSave(title : String) {
        self.collectionView.reloadData()
        showAlertMessage(title: "Saved To Your Library")
    }
    
    func didDelete() {
        self.collectionView.reloadData()
        showAlertMessage(title: "Deleted from your Library")
    }
    
    @objc func didFail(error: Error) {
        showAlertMessage(title: "Failed To Save To Your Library")
        print("Error Occurred while saving context \(error)")
    }
}

//MARK: - UICollectionViewDataSource
extension LibraryViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return libraryInfoList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Const.libraryCellIdentifier,for: indexPath) as! LibraryCollectionViewCell
        cell.delegate = self
        cell.indexPath = indexPath
        if let libraryInfo = libraryInfoList?[indexPath.row] {
            cell.canDelete = Const.defaultLibraryTitles.contains(libraryInfo.libraryTitle) ? false : true
            cell.isInEditMode = isEditMode
            if libraryInfo.imageURL == "" {
                cell.libraryImgView.image = UIImage(named: "default.jpg")
            } else{
                cell.libraryImgView.sd_setImage(with: URL(string: libraryInfo.imageURL))
            }
            cell.libraryTitle.text = libraryInfo.libraryTitle
            cell.countOfGames.text = String(libraryInfo.gameInfoList.count)
        }
        return cell
    }
}

//MARK: - UICollectionViewDelegate
extension LibraryViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let libraryInfo = libraryInfoList?[indexPath.row] {
            selectedLibrary = libraryInfo
            performSegue(withIdentifier: Const.libraryVCToGameListVCSegue, sender: self)
        }
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension LibraryViewController : UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let itemsPerRow = 2
        let paddingSpace = sectionInsets.left * CGFloat(itemsPerRow + 1)
        let availableWidth = view.frame.width - paddingSpace
        let widthPerItem = Int(availableWidth) / itemsPerRow
        return CGSize(width: widthPerItem, height: widthPerItem)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInsets
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInsets.left
    }
}

//MARK: - LibraryCollectionViewCellDelegate
extension LibraryViewController : LibraryCollectionViewCellDelegate {
    func deleteBtnPressed(indexPath : IndexPath) {
        if let libraryInfo = libraryInfoList?[indexPath.row]{
            let optionMenu = UIAlertController(title: "Delete \"\(libraryInfo.libraryTitle)\"", message: "Are you sure you want to delete the library \"\(libraryInfo.libraryTitle)\"?\nThe game lists will be deleted", preferredStyle: .actionSheet)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
                self.realmManager.deleteLibrary(libraryInfo: libraryInfo)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                optionMenu.dismiss(animated: true, completion: nil)
            }
            optionMenu.addAction(deleteAction)
            optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: true, completion: nil)
           
        }
    }
}
