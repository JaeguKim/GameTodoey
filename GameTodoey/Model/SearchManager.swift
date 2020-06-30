import UIKit
import Alamofire
import SwiftyJSON

protocol SearchManagerDelegate {
    func didTitleSearchRequestFail()
    func didUpdateGameInfo(gameInfoDict : [String:GameInfo])
}

class SearchManager {
    let metacriticURL = "https://chicken-coop.p.rapidapi.com/games"
    let playTimeURL = "http://hltb-api-env.eba-2upuxuta.us-west-2.elasticbeanstalk.com/hltb/"
    var gameInfoDict : [String:GameInfo] = [:]
    var keyDict : [String:[String]] = ["PC":[],"PS":[],"XBOX":[],"SWITCH":[]]
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
    
    func requestInfo(title:String){
        gameInfoDict.removeAll()
        for key in keyDict.keys{
            keyDict[key]?.removeAll()
        }
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
                            gameInfo.title = title
                            gameInfo.platform = platform
                            let key = title + platform
                            self.keyDict[self.getKey(with: platform)]?.append(key)
                            self.gameInfoDict.updateValue(gameInfo, forKey: key)
                            self.requestInfo(platform: platform, gameTitle: title)
                            //시간구하기
                            let requestURL = (self.playTimeURL+title).replacingOccurrences(of: " ", with: "%20")
                            Alamofire.request(requestURL, method: .get, parameters: nil, headers: ["Content-type" : "application/x-www-form-urlencoded"]).responseJSON { (response) in
                                if response.result.isSuccess {
                                    for (title, playInfoJSON) in JSON(response.result.value!) {
                                        print(title)
                                        print(playInfoJSON["main"])
                                        print(playInfoJSON["main+extra"])
                                        print(playInfoJSON["completionist"])
                                    }
                                }
                            }
                        }
                        else {
                            self.totalRequests-=1
                        }
                    }
                    self.delegate?.didUpdateGameInfo(gameInfoDict: self.gameInfoDict)
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
                        self.isAlreadyRequested = false
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
        
        let newPlatform = self.convertPlatformString(platform: platform)
        let newTitle = gameTitle.replacingOccurrences(of: " ", with: "%20")

        let headers : [String:String] = [
            "Content-type" : "application/x-www-form-urlencoded",
            "x-rapidapi-host" : "chicken-coop.p.rapidapi.com",
            "x-rapidapi-key" : "c976920022msha45b1a7b96d279ap17e7aejsne930cb2ce86d",
        ]

        let parameters : [String:String] = [
            "platform" : newPlatform
        ]
        
        let request = Alamofire.request(metacriticURL+"/\(newTitle)", method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
            if response.result.isSuccess {
                let responseJSON : JSON = JSON(response.result.value!)
                let score = responseJSON["result"]["score"].stringValue
                let imageURL = responseJSON["result"]["image"].stringValue
                let description = responseJSON["result"]["description"].stringValue.replacingOccurrences(of: " &hellip;  Expand", with: "")
                
                if self.titleFailCnt < self.maxFailCnt && (score == "" || imageURL == "") {
                    self.titleFailCnt += 1
                    self.requestInfo(platform: platform, gameTitle: gameTitle)
                    return
                }
                let key = gameTitle+platform
                if let gameInfo = self.gameInfoDict[key]{
                    gameInfo.imageURL = imageURL
                    gameInfo.title = gameTitle
                    gameInfo.platform = platform
                    gameInfo.score = score
                    gameInfo.gameDescription = description
                    gameInfo.done = false
                    self.gameInfoDict[key] = gameInfo
                }
                self.requestsDone += 1
                print("requestsDone : \(self.requestsDone)")
            }
            else {
                self.requestInfo(platform: platform, gameTitle: gameTitle)
            }
            if self.isRequestsDone(){
                self.delegate?.didUpdateGameInfo(gameInfoDict: self.gameInfoDict)
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
       
    func getKey(with platform:String)->String{
        if platform == "PC"{
            return "PC"
        } else if platform.hasPrefix("PS"){
            return "PS"
        } else if platform.hasPrefix("X"){
            return "XBOX"
        } else if platform == "Switch"{
            return "SWITCH"
        }
        return ""
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
