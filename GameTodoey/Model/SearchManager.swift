import UIKit
import Alamofire
import SwiftyJSON

protocol SearchManagerDelegate {
    func didTitleSearchRequestFail()
    func didUpdateGameInfo(gameInfoDict : [String:GameInfo])
}

protocol ScrapingDelegate {
    func didScrapingFail(Error: String)
    func didScrapingFinished(key: String, gameInfo: GameInfo)
}

class SearchManager {
    let gameListURL = "https://chicken-coop.p.rapidapi.com/games"
    let metacriticURL = "http://hltb-api-env.eba-2upuxuta.us-west-2.elasticbeanstalk.com/metacritic/"
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
    let metacriticScrapingComp = MetacriticScrapingComp()
    let hltbScrapingComp = HLTBScrapingComp()
    var delegate : SearchManagerDelegate?
    var cntOfFinishedScraping = 0
    
    func launchSerach(title:String){
        if isAlreadyRequested {
            return
        }
        self.metacriticScrapingComp.delegate = self
        self.hltbScrapingComp.deleagte = self
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
        let request = Alamofire.request(gameListURL, method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
            if response.result.isSuccess {
                let responseJSON : JSON = JSON(response.result.value!)
                print(responseJSON)
                if let jsonArray = responseJSON["result"].array {
                    self.failCnt = 0
                    self.totalRequests = 0
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
                            self.metacriticScrapingComp.scrapeMetacritic(key:key,gameInfo: gameInfo, platform: platform, gameTitle: title)
                            self.hltbScrapingComp.scrapeHowLongToBeat(key:key,gameInfo: gameInfo, title: title)
                            self.totalRequests += 1
                        }
                    }
                    print("totalRequests : \(self.totalRequests)")
                    if self.totalRequests == 0 {
                        self.delegate?.didTitleSearchRequestFail()
                    }
                    else {
                        self.delegate?.didUpdateGameInfo(gameInfoDict: self.gameInfoDict)
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
//            else {
//                self.failCnt += 1
//                if self.failCnt < self.maxFailCnt {
//                    self.requestInfo(title: title)
//                } else {
//                    self.failCnt = 0
//                    self.delegate?.didTitleSearchRequestFail()
//                }
//            }
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
}

extension SearchManager : ScrapingDelegate {
    func didScrapingFail(Error: String) {
        print(Error)
        cntOfFinishedScraping += 1
    }
    
    func didScrapingFinished(key: String, gameInfo : GameInfo) {
        cntOfFinishedScraping += 1
        print(cntOfFinishedScraping)
        if gameInfo.imageURL != "" && gameInfo.mainStoryTime != ""{
            self.gameInfoDict.updateValue(gameInfo, forKey: key)
            delegate?.didUpdateGameInfo(gameInfoDict: gameInfoDict)
        }
        if cntOfFinishedScraping == 2*totalRequests {
            self.isAlreadyRequested = false
            cntOfFinishedScraping = 0
        }
    }
}
