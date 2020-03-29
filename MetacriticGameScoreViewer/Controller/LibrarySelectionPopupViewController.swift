import UIKit
import RealmSwift

class LibrarySelectionPopupViewController: LibraryViewController {
    
    var gameScoreInfo : GameInfo?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func cancelBtnPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UICollectionViewDelegate
extension LibrarySelectionPopupViewController  {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
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

//MARK: - RealmManagerDelegate
extension LibrarySelectionPopupViewController {
    override func didSaved() {
        self.collectionView.reloadData()
        showAlertMessage(title: "Saved To Your Library")
    }
    
    override func didSaveFailed(error: Error) {
        showAlertMessage(title: "Failed To Save To Your Library")
        print("Error Occurred while saving context \(error)")
    }
}

