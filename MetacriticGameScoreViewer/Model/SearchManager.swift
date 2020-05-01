import UIKit
import Alamofire
import SwiftyJSON

protocol SearchManagerDelegate {
    func didTitleSearchRequestFail()
    func didUpdateGamePlatformInfo(gameInfoArray : [GameInfo])
    func didUpdateGameInfo(gameInfoArray : [GameInfo])
}

class SearchManager {
    let metacriticURL = "https://chicken-coop.p.rapidapi.com/games"
    var gameInfoArray : [GameInfo] = []
    var requests : [Alamofire.Request] = []
    var totalRequests : Int = 0
    var requestsDone : Int = 0
    var failCnt : Int = 0
    var titleFailCnt : Int = 0
    let maxFailCnt : Int = 5
    var isAlreadyRequested : Bool = false
    var delegate : SearchManagerDelegate?
    
    func launchSerach(title:String){
        if isAlreadyRequested {
            return
        }
        isAlreadyRequested = true
        requestInfo(title: title)
    }
    
    func requestPlatform(with title:String){
        gameInfoArray.removeAll()
        initValue()
        let headers : [String:String] = [
            "Content-type" : "application/x-www-form-urlencoded",
            "x-rapidapi-host" : "chicken-coop.p.rapidapi.com",
            "x-rapidapi-key" : "c976920022msha45b1a7b96d279ap17e7aejsne930cb2ce86d",
        ]
        let parameters : [String:String] = [
            "title" : title
        ]
        let request = Alamofire.request(metacriticURL, method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
            if response.result.isSuccess {
                let responseJSON : JSON = JSON(response.result.value!)
                print(responseJSON)
                if let jsonArray = responseJSON["result"].array {
                    self.failCnt = 0
                    self.totalRequests = jsonArray.count
                    for item in jsonArray {
                        let platform = item["platform"].stringValue
                        let title = item["title"].stringValue
                        if self.isValidPlatform(platform) {
                            let gameInfo = GameInfo()
                            gameInfo.platform = platform
                            gameInfo.title = title
                            self.gameInfoArray.append(gameInfo)
                        }
                        else {
                            self.totalRequests-=1
                        }
                    }
                    print("totalRequests : \(self.totalRequests)")
                    if self.totalRequests == 0 {
                        self.delegate?.didTitleSearchRequestFail()
                    }
                    else {
                        self.delegate?.didUpdateGamePlatformInfo(gameInfoArray: self.gameInfoArray)
                        //self.delegate?.didUpdateGameInfo(gameInfoArray: self.gameInfoArray)
                    }
                }
                else {
                    self.failCnt += 1
                    if self.failCnt < self.maxFailCnt {
                        self.requestPlatform(with: title)
                    } else {
                        self.failCnt = 0
                        self.delegate?.didTitleSearchRequestFail()
                    }
                }
            }
            else {
                self.failCnt += 1
                if self.failCnt < self.maxFailCnt {
                    self.requestInfo(title: title)
                } else {
                    self.failCnt = 0
                    self.delegate?.didTitleSearchRequestFail()
                }
            }
        }
        requests.append(request)
    }
    
    func requestInfo(title:String){
        gameInfoArray.removeAll()
        initValue()
        let headers : [String:String] = [
            "Content-type" : "application/x-www-form-urlencoded",
            "x-rapidapi-host" : "chicken-coop.p.rapidapi.com",
            "x-rapidapi-key" : "c976920022msha45b1a7b96d279ap17e7aejsne930cb2ce86d",
        ]
        let parameters : [String:String] = [
            "title" : title
        ]
        let request = Alamofire.request(metacriticURL, method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
            if response.result.isSuccess {
                let responseJSON : JSON = JSON(response.result.value!)
                print(responseJSON)
                if let jsonArray = responseJSON["result"].array {
                    self.failCnt = 0
                    self.totalRequests = jsonArray.count
                    for item in jsonArray {
                        let platform = item["platform"].stringValue
                        let title = item["title"].stringValue
                        if self.isValidPlatform(platform) {
                            self.requestInfo(platform: self.convertPlatformString(platform: platform), gameTitle: title)
                        }
                        else {
                            self.totalRequests-=1
                        }
                    }
                    print("totalRequests : \(self.totalRequests)")
                    if self.totalRequests == 0 {
                        self.delegate?.didTitleSearchRequestFail()
                    }
                }
                else {
                    self.failCnt += 1
                    if self.failCnt < self.maxFailCnt {
                        self.requestInfo(title: title)
                    } else {
                        self.failCnt = 0
                        self.delegate?.didTitleSearchRequestFail()
                    }
                }
            }
            else {
                self.failCnt += 1
                if self.failCnt < self.maxFailCnt {
                    self.requestInfo(title: title)
                } else {
                    self.failCnt = 0
                    self.delegate?.didTitleSearchRequestFail()
                }
            }
        }
        requests.append(request)
    }
    
    func requestInfo(platform:String, gameTitle:String){
        let headers : [String:String] = [
            "Content-type" : "application/x-www-form-urlencoded",
            "x-rapidapi-host" : "chicken-coop.p.rapidapi.com",
            "x-rapidapi-key" : "c976920022msha45b1a7b96d279ap17e7aejsne930cb2ce86d",
        ]
        let parameters : [String:String] = [
            "platform" : platform
        ]
        
        let newGameTitle = gameTitle.replacingOccurrences(of: " ", with: "%20")
        let request = Alamofire.request(metacriticURL+"/\(newGameTitle)", method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
            if response.result.isSuccess {
                let responseJSON : JSON = JSON(response.result.value!)
                let score = responseJSON["result"]["score"].stringValue
                let imageURL = responseJSON["result"]["image"].stringValue
                let description = responseJSON["result"]["description"].stringValue
                let gameInfo = GameInfo()
                if self.titleFailCnt < self.maxFailCnt && (score == "" || imageURL == "") {
                    self.titleFailCnt += 1
                    self.requestInfo(platform: platform, gameTitle: gameTitle)
                    return
                }
                gameInfo.imageURL = imageURL
                gameInfo.title = gameTitle
                gameInfo.platform = platform
                gameInfo.score = score
                gameInfo.gameDescription = description
                gameInfo.done = false
                self.gameInfoArray.append(gameInfo)
                self.requestsDone += 1
                print("requestsDone : \(self.requestsDone)")
            }
            else {
                self.requestInfo(platform: platform, gameTitle: gameTitle)
//                if self.failCnt < self.maxFailCnt {
//                    self.failCnt += 1
//                    self.requestInfo(platform: platform, gameTitle: gameTitle)
//                    return
//                }
            }
            if self.isRequestsDone(){
                self.delegate?.didUpdateGameInfo(gameInfoArray: self.gameInfoArray)
                self.isAlreadyRequested = false
            }
        }
        requests.append(request)
    }
    
    func getCompletionRate() -> Float{
         return Float(self.requestsDone) / Float(self.totalRequests)
    }
    
    func isRequestsDone() -> Bool{
        if requestsDone == totalRequests {return true} else {return false}
    }
    
    func initValue(){
        requestsDone = 0
        totalRequests = 0
    }
    
    func cancelRequests(){
        for request in requests {
            request.cancel()
        }
        
        failCnt = 0
        titleFailCnt = 0
        requests.removeAll()
        
    }
    
    func isValidPlatform(_ platform : String) -> Bool {
           switch platform {
           case "PS4":
               return true
           case "PS3":
               return true
           case "PC":
               return true
           case "XONE":
               return true
           case "X360":
               return true
           case "XBOX":
               return true
           case "Switch":
               return true
           default:
               return false
           }
       }
       
       func convertPlatformString(platform : String) -> String{
           switch platform {
           case "PS4":
               return "playstation-4";
           case "PS3":
               return "playstation-3";
           case "PC":
               return "pc";
           case "XONE":
               return "xbox-one";
           case "X360":
               return "xbox-360";
           case "XBOX":
               return "xbox";
           case "Switch":
               return "switch";
           default:
               return platform
           }
       }
}
