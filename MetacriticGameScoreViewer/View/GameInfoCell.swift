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

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
