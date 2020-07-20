import Alamofire
import Kanna
import SwiftyJSON

class HLTBScrapingComp {
    
    let HLTB_BASE_URL = "https://howlongtobeat.com"
    let HLTB_SEARCH_SUFFIX = "search_results.php"
    var deleagte : ScrapingDelegate?
    
    func scrapeHowLongToBeat(key: String, gameInfo: GameInfo, title: String) {
        getHowLongToBeatSearchResult(key:key,gameInfo:gameInfo,title: title)
    }
    
    func getHowLongToBeatSearchResult(key:String,gameInfo:GameInfo,title: String){
        let newTitle = title.replacingOccurrences(of:":",with:"").replacingOccurrences(of:"'",with:"")
        
        let headers : [String : String] = [
            "User-Agent": "Mozilla/5.0"
        ]
        let parameters : [String:String] = [
            "queryString": newTitle,
            "t": "games",
            "sorthead": "popular",
            "sortd": "Normal Order",
            "plat": "",
            "length_type": "main",
            "length_min": "",
            "length_max": "",
            "detail": "0"
        ]
        _ = Alamofire.request("\(HLTB_BASE_URL)/\(HLTB_SEARCH_SUFFIX)",method: .post, parameters: parameters, headers: headers).responseString { (response) in
            print(response.result.isSuccess)
            if response.result.isSuccess {
                let results = self.parseHtml(html: response.result.value!,originalTitle: newTitle)
                gameInfo.mainStoryTime = "\(results["Main"]!)"
                gameInfo.mainExtraTime = "\(results["MainExtra"]!)"
                gameInfo.completionTime = "\(results["Completionist"]!)"
                self.deleagte?.didScrapingFinished(key: key, gameInfo: gameInfo)
            }
            else{
                self.deleagte?.didScrapingFail(Error : "HowLongToBeat Request Failed")
            }
        }
    }
    
    func parseHtml(html: String, originalTitle: String) -> [String : String]{
        var results : [String : String] = [:]
        var main = "N/A", mainExtra = "N/A", complete = "N/A"
        if html.contains("No results"){
            results["Main"] = main
            results["MainExtra"] = mainExtra
            results["Completionist"] = complete
            return results
        }
        do {
            print(originalTitle)
            let doc = try Kanna.HTML(html: html, encoding: String.Encoding.utf8)
            for elem in doc.xpath("//li"){
                let gameTitleAnchor = elem.xpath("//a")[0]
                let gameName = gameTitleAnchor["title"]
                if gameName!.contains("DLC") || gameName!.count != originalTitle.count {
                    continue
                }
                let gameTimeDivTags = elem.css("div[class*=search_list_tidbit]")
                for i in 0...gameTimeDivTags.count-1 {
                    let line = gameTimeDivTags[i].text!
                    if line.starts(with: "Main Story") || line.starts(with: "Single-Player") || line.starts(with: "Solo"){
                        main = "\(String(parseTime(gameTimeDivTags[i+1].text!)))Hours"
                    }
                    else if line.starts(with: "Main + Extra") || line.starts(with: "Co-Op"){
                        mainExtra = "\(String(parseTime(gameTimeDivTags[i+1].text!)))Hours"
                    }
                    else if line.starts(with: "Completionist") || line.starts(with: "Vs."){
                        complete = "\(String(parseTime(gameTimeDivTags[i+1].text!)))Hours"
                    }
                }
                break
            }
        } catch {
            self.deleagte?.didScrapingFail(Error : "Error occurred while scraping HTML of howLongToBeat")
        }
        results["Main"] = main
        results["MainExtra"] = mainExtra
        results["Completionist"] = complete
        return results
    }
    
    func parseTime(_ text: String)->Double{
        if text.starts(with: "--"){
            return 0
        }
        if text.contains("-"){
            return handleRange(text)
        }
        return getTime(text)
    }
    
    func handleRange(_ text: String)->Double{
        let range = text.components(separatedBy: " - ")
        let number = (self.getTime(range[0])+getTime(range[1]))/2
        return number
    }
    
    func getTime(_ text: String) -> Double{
        let blankIdx = text.firstIndex(of: " ")
        let timeUnit = String(text.suffix(from: blankIdx!))
        if timeUnit == "Mins"{
            return 1
        }
        let time = String(text.prefix(upTo: blankIdx!))
        if time.contains("½"){
            return 0.5 + (String(text.prefix(upTo: text.firstIndex(of: "½")!)) as NSString).doubleValue
        }
        return (time as NSString).doubleValue
    }
    
}
