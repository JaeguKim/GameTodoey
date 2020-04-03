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
    func didSave(title : String)
    func didDelete()
    func didFail(error : Error)
}

struct RealmManager {
    var realm = try! Realm()
    var delegate : RealmManagerDelegate?
    let maxRecentsCount = 20
    
    func loadLibraries() -> Results<LibraryInfo> {
        return realm.objects(LibraryInfo.self)
    }
    
    func save(gameInfoArray : [GameInfo]){
        let libraryInfoList = loadLibraries()
        let recentLibrary = libraryInfoList[0]
        let recentGameList = recentLibrary.gameInfoList
        if recentGameList.count + gameInfoArray.count > maxRecentsCount{
            let numOfDelete = recentGameList.count + gameInfoArray.count - maxRecentsCount
            for _ in 0..<numOfDelete{
                do
                {
                    try realm.write {
                        recentGameList.removeFirst()
                    }
                }catch {
                    print("Error Occurred while deleting game from Recents Library : \(error)")
                }
            }
        }
        for gameInfo in gameInfoArray{
            save(gameInfo: gameInfo, selectedLibrary: recentLibrary)
        }
    }
    
    func save(gameInfo : GameInfo, selectedLibrary : LibraryInfo) {
        do {
            try self.realm.write {
                let realmObj = Realm_GameInfo()
                realmObj.title = gameInfo.title
                realmObj.platform = gameInfo.platform
                realmObj.gameDescription = gameInfo.gameDescription
                realmObj.imageURL = gameInfo.imageURL
                realmObj.score = gameInfo.score
                realmObj.id = gameInfo.id
                realmObj.done = gameInfo.done
                selectedLibrary.imageURL = gameInfo.imageURL
                selectedLibrary.gameInfoList.append(realmObj)
            }
        } catch {
            delegate?.didFail(error: error)
            return
        }
        delegate?.didSave(title: selectedLibrary.libraryTitle)
    }
    
    func save(realmObj : LibraryInfo) {
        do {
            try realm.write {
                realm.add(realmObj)
            }
        } catch {
            print("Error Saving context \(error)")
            delegate?.didFail(error: error)
            return
        }
        delegate?.didSave(title: realmObj.libraryTitle)
    }
    
    func reorderGameList(gameInfoList : List<Realm_GameInfo>, sourceIndexPath: IndexPath, destinationIndexPath: IndexPath){
        do {
            try realm.write {
                let movedObj = gameInfoList[sourceIndexPath.row]
                gameInfoList.remove(at: sourceIndexPath.row)
                gameInfoList.insert(movedObj, at: destinationIndexPath.row)
            }
        } catch {
            print("Error Reordering context \(error)")
            return
        }
    }

    func deleteLibrary(libraryInfo : LibraryInfo) {
        do {
            try self.realm.write() {
                self.realm.delete(libraryInfo)
            }
        } catch {
            print("Error occurred when deleting library \(error)")
            delegate?.didFail(error: error)
            return
        }
        delegate?.didDelete()
    }
    
    func deleteGameInfo(gameInfo : Realm_GameInfo) {
        do {
            try self.realm.write() {
                self.realm.delete(gameInfo)
                delegate?.didDelete()
            }
        } catch {
            print("Error occurred when deleting item \(error)")
        }
    }
}
