//
//  WelcomeViewController.swift
//  MetacriticGameScoreViewer
//
//  Created by 김재구 on 2020/03/22.
//  Copyright © 2020 jaeguKim. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if UserDefaults.standard.bool(forKey: "isLogIn") == true {
            performSegue(withIdentifier: Const.welcomeVCToSearchVCSegue, sender: self)
        }
    }

}
