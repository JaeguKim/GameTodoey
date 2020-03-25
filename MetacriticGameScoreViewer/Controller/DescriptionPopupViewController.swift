//
//  DescriptionPopupViewController.swift
//  MetacriticGameScoreViewer
//
//  Created by 김재구 on 2020/03/24.
//  Copyright © 2020 jaeguKim. All rights reserved.
//

import UIKit
import SDWebImage
import RealmSwift

class DescriptionPopupViewController: UIViewController {
    
    var gameScoreInfo : GameScoreInfo?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gameImgView: UIImageView!
    @IBOutlet weak var gameDescLabel: UILabel!
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
    }
    
    func setData(){
        titleLabel.text = gameScoreInfo?.title
        gameImgView.sd_setImage(with: URL(string: gameScoreInfo!.imageURL))
        gameDescLabel.text = gameScoreInfo?.gameDescription
    }
    
    @IBAction func saveBtnPressed(_ sender: UIButton) {
        guard let gameScoreData = gameScoreInfo else {return}
        let gameThatExists = realm.object(ofType: Realm_GameScoreInfo.self, forPrimaryKey: gameScoreInfo?.id)
        if gameThatExists == nil {
            let realmObj = Realm_GameScoreInfo()
            realmObj.title = gameScoreData.title
            realmObj.platform = gameScoreData.platform
            realmObj.gameDescription = gameScoreData.gameDescription
            realmObj.imageURL = gameScoreData.imageURL
            realmObj.score = gameScoreData.score
            realmObj.id = gameScoreData.id
            realmObj.done = gameScoreData.done
            save(realmObj:realmObj)
            showAlertMessage(title: "Saved To Your Library")
        }
        else {
            showAlertMessage(title: "Already Added To Library")
        }
        
    }
    
    func showAlertMessage(title : String) {
        let alert = UIAlertController(title: title, message: "", preferredStyle: .alert)
        present(alert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                alert.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func save(realmObj : Realm_GameScoreInfo) {
        do {
            try realm.write {
                realm.add(realmObj)
            }
        } catch {
            print("Error Saving context \(error)")
        }
    }
}
