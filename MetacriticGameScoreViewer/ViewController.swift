/*
 var requestURI = `https://chicken-coop.p.rapidapi.com/games?title=${gameTitle}`;
 xhr.open("GET", requestURI);
 xhr.responseType = 'json';
 xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded')
 xhr.setRequestHeader("x-rapidapi-host", "chicken-coop.p.rapidapi.com");
 xhr.setRequestHeader("x-rapidapi-key", "c976920022msha45b1a7b96d279ap17e7aejsne930cb2ce86d");
 
 var requestURI = `https://chicken-coop.p.rapidapi.com/games/${gameTitle}?platform=${convPlatformStr}`;
 xhr.open("GET", requestURI);
 xhr.responseType = 'json';
 xhr.setRequestHeader('Content-type', 'application/x-www-form-urlencoded')
 xhr.setRequestHeader("x-rapidapi-host", "chicken-coop.p.rapidapi.com");
 xhr.setRequestHeader("x-rapidapi-key", "c976920022msha45b1a7b96d279ap17e7aejsne930cb2ce86d");
 xhr.send(data);
 */

import UIKit
import Alamofire
import SwiftyJSON

class ViewController: UIViewController {
    
    let metacriticURL = "https://chicken-coop.p.rapidapi.com/games"
    
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
            print("platform string is wrong")
        }
        return ""
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestInfo(title: "Halo")
        // Do any additional setup after loading the view.
    }
    
    func requestInfo(title:String){
        let headers : [String:String] = [
            "Content-type" : "application/x-www-form-urlencoded",
            "x-rapidapi-host" : "chicken-coop.p.rapidapi.com",
            "x-rapidapi-key" : "c976920022msha45b1a7b96d279ap17e7aejsne930cb2ce86d",
        ]
        let parameters : [String:String] = [
            "title" : title
        ]
        Alamofire.request(metacriticURL, method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
            if response.result.isSuccess {
                print("Got Game list")
                let responseJSON : JSON = JSON(response.result.value!)
                if let jsonArray = responseJSON["result"].array {
                    for item in jsonArray {
                        let platform = item["platform"]
                        let title = item["title"]
                        self.requestInfo(platform: self.convertPlatformString(platform: platform.stringValue), gameTitle: title.stringValue)
                    }
                }
                /*
                 let flowerJSON : JSON = JSON(response.result.value!)
                 let pageId = flowerJSON["query"]["pageids"][0].stringValue
                 let extract = flowerJSON["query"]["pages"][pageId]["extract"].stringValue
                 let flowerImageURL = flowerJSON["query"]["pages"][pageId]["thumbnail"]["source"].stringValue
                 
                 self.cameraImageView.sd_setImage(with: URL(string: flowerImageURL))
                 self.flowerDescriptionLabel!.text = extract
                 */
            }
            
        }
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
        Alamofire.request(metacriticURL+"/\(newGameTitle)", method: .get, parameters: parameters, headers: headers).responseJSON { (response) in
            if response.result.isSuccess {
                print("Got Game Score list")
                let responseJSON : JSON = JSON(response.result.value!)
                if let jsonArray = responseJSON["result"].array {
                    for item in jsonArray {
                        let score = item["score"]
                        let imageURL = item["image"]
                        print("platform : \(platform), title : \(gameTitle), score : \(score),imageURL : \(imageURL)")
                    }
                }
            }
        }
    }
}
