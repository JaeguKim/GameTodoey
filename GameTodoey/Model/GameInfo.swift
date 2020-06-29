
import Foundation

class GameInfo {
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
    var mainStoryTime : String = ""
    var mainExtraTime : String = ""
    var completionTime : String = ""
}
