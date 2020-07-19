import Alamofire
import Kanna
import SwiftyJSON

class HLTBScrapingComp {

    let HLTB_BASE_URL = "https://howlongtobeat.com"
    let HLTB_SEARCH_SUFFIX = "search_results.php"
    
    func scrapeHowLongToBeat(title: String) {
        getHowLongToBeatSearchResult(title: title)
    }

    func getHowLongToBeatSearchResult(title: String){
        let headers : [String : String] = [
            "User-Agent": "Mozilla/5.0"
        ]
        let parameters : [String:String] = [
            "queryString": title,
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
            //print(response.result.error)
            self.parseHtml(html: response.result.value!)
        }
    }
    
    func parseHtml(html: String) -> [String : Double]{
        var results : [String : Double] = [:]
        do {
            let doc = try Kanna.HTML(html: html, encoding: String.Encoding.utf8)
            for elem in doc.xpath("//li"){
                //let gameTitleAnchor = elem.xpath("//a")[0]
                //let gameName = gameTitleAnchor["title"]
                var main = 0.0, mainExtra = 0.0, complete = 0.0
                let gameTimeDivTags = elem.css("div[@class*=search_list_tidbit]")
                for i in 1...gameTimeDivTags.count {
                    let line = gameTimeDivTags[i].text!
                    if line.starts(with: "Main Story") || line.starts(with: "Single-Player") || line.starts(with: "Solo"){
                        main = parseTime(String(gameTimeDivTags[i+1].text!))
                        results["Main"] = main
                    }
                    else if line.starts(with: "Main + Extra") || line.starts(with: "Co-Op"){
                        mainExtra = parseTime(String(gameTimeDivTags[i+1].text!))
                        results["MainExtra"] = mainExtra
                    }
                    else if line.starts(with: "Completionist") || line.starts(with: "Vs."){
                        complete = parseTime(String(gameTimeDivTags[i+1].text!))
                        results["Completionist"] = complete
                    }
                }
            }
        } catch {
            print("error occurred")
        }
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
