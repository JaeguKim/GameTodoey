//
//  LibraryTableViewCell.swift
//  MetacriticGameScoreViewer
//
//  Created by 김재구 on 2020/03/26.
//  Copyright © 2020 jaeguKim. All rights reserved.
//

import UIKit
import SwipeCellKit

class LibraryInfoCell: SwipeTableViewCell {

    @IBOutlet weak var libraryImgView: UIImageView!
    @IBOutlet weak var libraryTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
