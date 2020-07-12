//
//  GameInfoCell.swift
//  MetacriticGameScoreViewer
//
//  Created by 김재구 on 2020/03/18.
//  Copyright © 2020 jaeguKim. All rights reserved.
//

import UIKit
import SwipeCellKit

class GameInfoCell: SwipeTableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var scoreBackgroundView: UIView!
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameImgView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    var key = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        scoreBackgroundView.layer.cornerRadius = scoreBackgroundView.frame.height / 5
        view.layer.cornerRadius = view.frame.height / 5
        hideLoadingIndicator()
    }
    
    func setViewBackgroundColor(score : String) {
        guard let score = Float(score) else {
            scoreBackgroundView.backgroundColor = UIColor.red
            return
        }
        let color : UIColor?
        if score >= 8.0 {
            color = UIColor.green
        } else if score >= 7.0 {
            color = UIColor.yellow
        } else {
            color = UIColor.red
        }
        scoreBackgroundView.backgroundColor = color
    }
    
    func showLoadingIndicator()
    {
        scoreLabel.text = ""
        scoreBackgroundView.backgroundColor = UIColor.clear
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
    }
    
    func hideLoadingIndicator()
    {
        activityIndicator.isHidden = true
    }
    
    func setKey(key : String){
        self.key = key
    }
    
    func getKey() -> String {
        return key
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
