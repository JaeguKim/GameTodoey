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
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameImgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        scoreBackgroundView.layer.cornerRadius = scoreBackgroundView.frame.height / 5
        // Initialization code
    }
    
    func setViewBackgroundColor(score : Int) {
        let color : UIColor?
        if score >= 80 {
            color = UIColor.green
        } else if score >= 70 {
            color = UIColor.yellow
        } else {
            color = UIColor.red
        }
        scoreBackgroundView.backgroundColor = color
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
