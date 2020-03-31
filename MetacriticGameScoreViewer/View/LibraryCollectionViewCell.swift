//
//  LibraryCollectionViewCell.swift
//  MetacriticGameScoreViewer
//
//  Created by 김재구 on 2020/03/29.
//  Copyright © 2020 jaeguKim. All rights reserved.
//

import UIKit

protocol LibraryCollectionViewCellDelegate {
    func deleteBtnPressed(indexPath : IndexPath)
}

class LibraryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var libContentView: UIView!
    @IBOutlet weak var libraryImgView: UIImageView!
    @IBOutlet weak var libraryTitle: UILabel!
    @IBOutlet weak var countOfGames: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    var indexPath : IndexPath?
    var delegate : LibraryCollectionViewCellDelegate?

    var isInEditMode : Bool = false {
        didSet {
            deleteButton.isHidden = !isInEditMode
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        libContentView.layer.cornerRadius = libContentView.frame.height / 5
        deleteButton.isHidden = true
    }
    
    @IBAction func deleteBtnPressed(_ sender: UIButton) {
        delegate?.deleteBtnPressed(indexPath: indexPath!)
    }
}
