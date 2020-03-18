//
//  GameInfoCell.swift
//  MetacriticGameScoreViewer
//
//  Created by 김재구 on 2020/03/18.
//  Copyright © 2020 jaeguKim. All rights reserved.
//

import UIKit

class GameInfoCell: UITableViewCell {

    @IBOutlet weak var gameInfoCell: UIStackView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var platformLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var gameImgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
