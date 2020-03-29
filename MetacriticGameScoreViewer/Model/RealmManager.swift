//
//  RealmManager.swift
//  MetacriticGameScoreViewer
//
//  Created by 김재구 on 2020/03/28.
//  Copyright © 2020 jaeguKim. All rights reserved.
//

import Foundation
import RealmSwift

struct RealmManager {
    var realm = try! Realm()
    
    func loadLibraries() -> Results<LibraryInfo> {
        return realm.objects(LibraryInfo.self)
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
    
    func deleteLibrary(libraryInfo : LibraryInfo) {
        do {
            try self.realm.write() {
                self.realm.delete(libraryInfo)
            }
        } catch {
            print("Error occurred when deleting library \(error)")
        }
    }
}
