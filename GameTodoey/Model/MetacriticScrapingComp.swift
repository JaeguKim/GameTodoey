import Alamofire
import Kanna
import SwiftyJSON

class MetacriticScrapingComp{
    var gameInfo: GameInfo!
    var key: String!
    
    var delegate: ScrapingDelegate?
    
    func scrapeMetacritic(key: String, gameInfo: GameInfo, platform: String, gameTitle: String) -> Void {
        self.key = key
        self.gameInfo = gameInfo
        let newPlatform = self.convertPlatformString(platform: platform)
        let newTitle = gameTitle.replacingOccurrences(of:":",with:"").replacingOccurrences(of:"'",with:"").replacingOccurrences(of: " ", with: "-").lowercased()
        let requestURL = "https://www.metacritic.com/game/\(newPlatform)/\(newTitle)"
        Alamofire.request(requestURL).responseString { response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value {
                self.parseMetacriticHTML(html: html)
            }
        }
    }
    
    func parseMetacriticHTML(html: String) -> Void {
        do {
            let doc = try Kanna.HTML(html: html, encoding: String.Encoding.utf8)
            let js = JSON(parseJSON: doc.at_xpath("//script[@type='application/ld+json']")!.text!)
            let image = js["image"].stringValue
            let desc = js["description"].stringValue
            //let criticScore = js["aggregateRating"]["ratingValue"].stringValue
            let detailsDiv = doc.at_xpath("//div[@class='details side_details']")!
            let metascoreDiv = detailsDiv.at_css("div[class^='metascore_w']")!
            let userScore = metascoreDiv.content!.trimmingCharacters(in: .whitespacesAndNewlines)
            self.gameInfo.imageURL = image
            self.gameInfo.gameDescription = desc
            self.gameInfo.score = userScore
            delegate?.didScrapingFinished(key: key,gameInfo: gameInfo)
        } catch {
            delegate?.didScrapingFail(Error : "Error Occurred while parsing HTML of metacritic")
        }
    }
    
    func convertPlatformString(platform: String) -> String{
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
