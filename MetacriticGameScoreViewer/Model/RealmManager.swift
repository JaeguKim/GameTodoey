//
//  RealmManager.swift
//  MetacriticGameScoreViewer
//
//  Created by 김재구 on 2020/03/28.
//  Copyright © 2020 jaeguKim. All rights reserved.
//

import Foundation
import RealmSwift

protocol RealmManagerDelegate {
    func didSaved()
    func didSaveFailed(error : Error)
}

struct RealmManager {
    var realm = try! Realm()
    var delegate : RealmManagerDelegate?
    
    func loadLibraries() -> Results<LibraryInfo> {
        return realm.objects(LibraryInfo.self)
    }
    
    func save(gameInfo : GameInfo, selectedLibrary : LibraryInfo) {
        do {
            try self.realm.write {
                let realmObj = Realm_GameScoreInfo()
                realmObj.title = gameInfo.title
                realmObj.platform = gameInfo.platform
                realmObj.gameDescription = gameInfo.gameDescription
                realmObj.imageURL = gameInfo.imageURL
                realmObj.score = gameInfo.score
                realmObj.id = gameInfo.id
                realmObj.done = gameInfo.done
                selectedLibrary.imageURL = gameInfo.imageURL
                selectedLibrary.gameScoreInfoList.append(realmObj)
            }
        } catch {
            delegate?.didSaveFailed(error: error)
            return
        }
        delegate?.didSaved()
    }
    
    func save(realmObj : LibraryInfo) {
        do {
            try realm.write {
                realm.add(realmObj)
            }
        } catch {
            print("Error Saving context \(error)")
            delegate?.didSaveFailed(error: error)
            return
        }
        delegate?.didSaved()
    }
    
    func deleteLibrary(libraryInfo : LibraryInfo) {
        do {
            try self.realm.write() {
                self.realm.delete(libraryInfo)
            }
        } catch {
            print("Error occurred when deleting library \(error)")
            delegate?.didSaveFailed(error: error)
            return
        }
        delegate?.didSaved()
    }
    
    func deleteGameInfo(gameInfo : Realm_GameScoreInfo) {
//        if let itemForDeletion = self.gameInfoList?[indexPath.row]
//        {
        do {
            try self.realm.write() {
                self.realm.delete(gameInfo)
            }
        } catch {
            print("Error occurred when deleting item \(error)")
        }
    }
}
