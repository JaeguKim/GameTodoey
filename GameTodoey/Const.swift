//
//  K.swift
//  MetacriticGameScoreViewer
//
//  Created by 김재구 on 2020/03/22.
//  Copyright © 2020 jaeguKim. All rights reserved.
//

import Foundation

struct Const {
    static let appName = "🎮GamePlanner🎮"
    static let registerSegue = "RegisterVCToSearchVC"
    static let loginSegue = "LoginVCToSearchVC"
    static let searchToDescSegue = "SearchVCToDescVC"
    static let descToLibSegue = "DescVCToLibPopupVC"
    static let welcomeVCToSearchVCSegue = "WelcomeVCToSearchVC"
    static let libraryVCToGameListVCSegue = "LibVCToGameListVC"
    static let GameListVCToDescVCSegue = "GameListVCToDescVC"
    static let gameInfoCellIdentifier = "GameInfoCell"
    static let playTimeCellIdentifier = "PlayTimeInfoCell"
    static let libraryCellIdentifier = "LibraryCell"
    static let gameInfoCellNibName = "GameInfoCell"
    static let playTimeCellNibName = "PlayTimeInfoCell"
    static let LibraryCellNibName = "LibraryCollectionViewCell"
    static let idStr = "id"
    static let libraryTitleStr = "libraryTitle"
    static let defaultLibraryTitles = ["Recents","Favorite👍"]
    static let dictKey = [0:"PC",1:"PS",2:"XBOX",3:"SWITCH"]
}
