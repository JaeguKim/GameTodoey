
import Foundation
import RealmSwift

class LibraryInfo : Object {
    @objc dynamic var imageURL : String = ""
    @objc dynamic var libraryTitle : String = ""
    let gameInfoList = List<Realm_GameInfo>()
    
    override static func primaryKey() -> String? {
        return Const.libraryTitleStr
    }
}
