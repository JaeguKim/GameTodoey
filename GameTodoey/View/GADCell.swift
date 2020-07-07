//
//  GADCell.swift
//  GameTodoey
//
//  Created by 김재구 on 2020/07/07.
//  Copyright © 2020 jaeguKim. All rights reserved.
//

import UIKit

class GADCell: UITableViewCell {

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var headlineView: UILabel!
    @IBOutlet weak var bodyView: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        background.layer.cornerRadius = background.frame.height/5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}