//
//  LibraryCollectionViewCell.swift
//  MetacriticGameScoreViewer
//
//  Created by 김재구 on 2020/03/29.
//  Copyright © 2020 jaeguKim. All rights reserved.
//

import UIKit

class LibraryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var libraryImgView: UIImageView!
    @IBOutlet weak var libraryTitle: UILabel!
    @IBOutlet weak var countOfGames: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        libraryImgView.layer.cornerRadius = libraryImgView.frame.height / 5
        // Initialization code
    }

}
