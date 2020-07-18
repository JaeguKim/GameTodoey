import Foundation
import Alamofire
import Kanna
import SwiftyJSON

class WebScrapingManager {
    // Grabs the HTML from nycmetalscene.com for parsing.
    func scrapeMetacritic() -> Void {
        Alamofire.request("https://www.metacritic.com/game/playstation-4/the-last-of-us-part-ii").responseString { response in
            print("\(response.result.isSuccess)")
            if let html = response.result.value {
                self.parseHTML(html: html)
            }
        }
    }

    func parseHTML(html: String) -> Void {
        do {
            let doc = try Kanna.HTML(html: html, encoding: String.Encoding.utf8)
            let res = doc.at_xpath("//script[@type='application/ld+json']")
            let js = JSON(parseJSON: res!.text!)
            let image = js["image"].stringValue
            let desc = js["description"].stringValue
            let critic_score = js["aggregateRating"]["ratingValue"].stringValue
            print(image)
            print(desc)
            print(critic_score)
            //print(doc.xpath("//script[@type^='application/ld+json'")[0])
        } catch {
            print("error occurred")
        }
    }
}
