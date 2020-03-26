
import Foundation

class GameScoreInfo {
    var imageURL : String = ""
    var title : String = ""
    var platform : String = ""
    var score : String = ""
    var gameDescription : String = ""
    var done : Bool = false
    var id : String {
        get {
            return title+platform
        }
    }
}
