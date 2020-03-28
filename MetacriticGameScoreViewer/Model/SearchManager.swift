import UIKit
import Alamofire
import SwiftyJSON

protocol SearchManagerDelegate {
    func didTitleSearchRequestFail()
    func didUpdateGameInfo(gameInfoArrary : [GameInfo])
}

class SearchManager {
    let metacriticURL = "https://chicken-coop.p.rapidapi.com/games"
    var gameInfoArrary : [GameInfo] = []
    var requests : [Alamofire.Request] = []
    var totalRequests : Int = 0
    var requestsDone : Int = 0
    
    var searchManagerDelegate : SearchManagerDelegate?
    
    func requestInfo(title:String){
       
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
                if let jsonArray = responseJSON["result"].array {
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
                        self.searchManagerDelegate?.didTitleSearchRequestFail()
                    }
                }
                else {
                     self.searchManagerDelegate?.didTitleSearchRequestFail()
                }
            }
            else {
                self.searchManagerDelegate?.didTitleSearchRequestFail()
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
                let gameScoreInfo = GameInfo()
                gameScoreInfo.imageURL = imageURL
                gameScoreInfo.title = gameTitle
                gameScoreInfo.platform = platform
                gameScoreInfo.score = score
                gameScoreInfo.gameDescription = description
                gameScoreInfo.done = false
                self.gameInfoArrary.append(gameScoreInfo)
            }
            self.requestsDone += 1
            print("requestsDone : \(self.requestsDone)")
            self.searchManagerDelegate?.didUpdateGameInfo(gameInfoArrary: self.gameInfoArrary)
        }
        requests.append(request)
    }
    
    func getCompletionPercent() -> Int{
         return (self.requestsDone * 100) / self.totalRequests
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
        requests.removeAll()
        gameInfoArrary.removeAll()
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
