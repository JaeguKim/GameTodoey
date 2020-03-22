//
//  WelcomeViewController.swift
//  MetacriticGameScoreViewer
//
//  Created by 김재구 on 2020/03/22.
//  Copyright © 2020 jaeguKim. All rights reserved.
//

import UIKit
import CLTypingLabel

class WelcomeViewController: UIViewController {

    @IBOutlet weak var titleLabel: CLTypingLabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = "🎮Todoey🎮"
    }

}
