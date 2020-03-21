//
//  gameScoreInfo.swift
//  MetacriticGameScoreViewer
//
//  Created by 김재구 on 2020/03/18.
//  Copyright © 2020 jaeguKim. All rights reserved.
//

import Foundation
import RealmSwift

class GameScoreInfo : Object {
    @objc dynamic var imageURL : String = ""
    @objc dynamic var title : String = ""
    @objc dynamic var platform : String = ""
    @objc dynamic var score : String = ""

}