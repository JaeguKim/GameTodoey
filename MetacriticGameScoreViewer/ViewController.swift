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

class ViewController: UIViewController {

    let metacriticURL = "https://chicken-coop.p.rapidapi.com/games"
    override func viewDidLoad() {
        super.viewDidLoad()
        requestInfo(with: "Halo")
        // Do any additional setup after loading the view.
    }
    
    func requestInfo(with title:String){
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
                print("Got game info.")
                print(response)
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
    

}

