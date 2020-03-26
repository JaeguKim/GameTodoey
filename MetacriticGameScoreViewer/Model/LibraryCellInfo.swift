//
//  LibraryCellInfo.swift
//  MetacriticGameScoreViewer
//
//  Created by 김재구 on 2020/03/26.
//  Copyright © 2020 jaeguKim. All rights reserved.
//

import Foundation
import RealmSwift

class LibraryCellInfo : Object {
    @objc dynamic var imageURL : String = ""
    @objc dynamic var libraryTitle : String = ""
}
