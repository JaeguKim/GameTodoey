
import Foundation
import RealmSwift

class Realm_GameScoreInfo : Object {
    @objc dynamic var imageURL : String = ""
    @objc dynamic var title : String = ""
    @objc dynamic var platform : String = ""
    @objc dynamic var score : String = ""
    @objc dynamic var gameDescription : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var id : String = ""
    override static func primaryKey() -> String? {
        return Const.idStr
    }
    
}
