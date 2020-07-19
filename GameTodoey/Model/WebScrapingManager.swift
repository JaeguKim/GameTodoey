import Alamofire
import Kanna
import SwiftyJSON

class WebScrapingManager {

    let metacriticComp = MetacriticScrapingComp()
    let hltbComp = HLTBScrapingComp()
    
    func scrapeMetacritic(platform: String, gameTitle: String){
        metacriticComp.scrapeMetacritic(platform: platform, gameTitle: gameTitle)
    }
    
    func scrapeHowLongToBeat(title: String){
        hltbComp.scrapeHowLongToBeat(title: title)
    }
}
