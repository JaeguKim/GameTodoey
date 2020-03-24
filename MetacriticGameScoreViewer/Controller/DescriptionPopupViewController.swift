//
//  DescriptionPopupViewController.swift
//  MetacriticGameScoreViewer
//
//  Created by 김재구 on 2020/03/24.
//  Copyright © 2020 jaeguKim. All rights reserved.
//

import UIKit
import SDWebImage

class DescriptionPopupViewController: UIViewController {

    var gameScoreData : GameScoreInfo?
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gameImgView: UIImageView!
    @IBOutlet weak var gameDescLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setData()
    }
    
    func setData(){
        titleLabel.text = gameScoreData?.title
        gameImgView.sd_setImage(with: URL(string: gameScoreData!.imageURL))
        gameDescLabel.text = gameScoreData?.gameDescription
    }

}
