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
    @IBOutlet weak var mainStoryLabel: UILabel!
    @IBOutlet weak var mainExtraLabel: UILabel!
    @IBOutlet weak var completionestLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        view.layer.cornerRadius = view.frame.height / 5
        // Initialization code
    }
    
    func setData(mainStory:String,mainExtra:String,completionest:String){
        mainStoryLabel.text = mainStory
        mainExtraLabel.text = mainExtra
        completionestLabel.text = completionest
    }
    
}
