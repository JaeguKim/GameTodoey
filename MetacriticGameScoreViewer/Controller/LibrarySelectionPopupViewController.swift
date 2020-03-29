import UIKit
import RealmSwift

class LibrarySelectionPopupViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    var libraryInfoList : Results<LibraryInfo>?
    var realmManager = RealmManager()
    var gameScoreInfo : GameInfo?
    private let sectionInsets = UIEdgeInsets(top: 50.0,
                                              left: 20.0,
                                              bottom: 50.0,
                                              right: 20.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        realmManager.delegate = self
        self.collectionView!.register(UINib(nibName: Const.LibraryCellNibName, bundle: nil), forCellWithReuseIdentifier: Const.libraryCellIdentifier)
        libraryInfoList = realmManager.loadLibraries()
        collectionView.reloadData()
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
}

//MARK: - UICollectionViewDataSource
extension LibrarySelectionPopupViewController : UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return libraryInfoList?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Const.libraryCellIdentifier,for: indexPath) as! LibraryCollectionViewCell
         if let libraryInfo = libraryInfoList?[indexPath.row] {
             if libraryInfo.imageURL == "" {
                cell.libraryImgView.image = UIImage(named: "default.jpg")
             } else{
                 cell.libraryImgView.sd_setImage(with: URL(string: libraryInfo.imageURL))
             }
             cell.libraryTitle.text = libraryInfo.libraryTitle
            cell.countOfGames.text = String(libraryInfo.gameScoreInfoList.count)
           }
           return cell
     }
}

//MARK: - UICollectionViewDelegate
extension LibrarySelectionPopupViewController : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let gameScoreData = gameScoreInfo else {return}
        guard let selectedLibrary = libraryInfoList?[indexPath.row] else {return}
        for item in selectedLibrary.gameScoreInfoList {
            if gameScoreData.id == item.id {
                showAlertMessage(title: "Already Added To Library")
                return
            }
        }
        realmManager.save(gameInfo: gameScoreData, selectedLibrary: selectedLibrary)
    }
}

extension LibrarySelectionPopupViewController : RealmManagerDelegate {
    func didSaved() {
        self.collectionView.reloadData()
        showAlertMessage(title: "Saved To Your Library")
    }
     
    func didSaveFailed(error: Error) {
         showAlertMessage(title: "Failed To Save To Your Library")
         print("Error Occurred while saving context \(error)")
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension LibrarySelectionPopupViewController : UICollectionViewDelegateFlowLayout {
    
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

