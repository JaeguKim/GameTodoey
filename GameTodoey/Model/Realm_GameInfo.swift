
import Foundation
import RealmSwift

class Realm_GameInfo : Object {
    @objc dynamic var imageURL : String = ""
    @objc dynamic var title : String = ""
    @objc dynamic var platform : String = ""
    @objc dynamic var score : String = ""
    @objc dynamic var gameDescription : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var id : String = ""
    @objc dynamic var date = Date()
    @objc dynamic var mainStoryTime : String = ""
    @objc dynamic var mainExtraTime : String = ""
    @objc dynamic var completionTime : String = ""
    var parentLibrary = LinkingObjects(fromType: LibraryInfo.self, property: "gameInfoList")
}
