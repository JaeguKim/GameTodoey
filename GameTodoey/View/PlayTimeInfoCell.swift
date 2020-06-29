//
//  gameTimeInfoCell.swift
//  GameTodoey
//
//  Created by 김재구 on 2020/06/29.
//  Copyright © 2020 jaeguKim. All rights reserved.
//

import UIKit

class PlayTimeInfoCell: UITableViewCell {

    @IBOutlet weak var view: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view.layer.cornerRadius = view.frame.height / 5
        // Initialization code
    }
    
    func setData(title:String,time:String){
        titleLabel.text = title
        timeLabel.text = time
    }
    
}
