
import Foundation
import RealmSwift

class LibraryInfo : Object {
    @objc dynamic var imageURL : String = ""
    @objc dynamic var libraryTitle : String = ""
    let gameScoreInfoList = List<Realm_GameScoreInfo>()
    
    override static func primaryKey() -> String? {
        return Const.libraryTitleStr
    }
}
