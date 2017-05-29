//
//  ViewController.swift
//  MetronomeController Example iOS
//
//  Created by James Bean on 5/28/17.
//  Copyright © 2017 James Bean. All rights reserved.
//

import UIKit
import MetronomeController

class ViewController: UIViewController {

    lazy var meterLabel: UILabel = {
        let label = UILabel()
        let margin: CGFloat = 10
        let height: CGFloat = 40
        label.frame = CGRect(
            x: margin,
            y: self.view.frame.height - height - margin,
            width: 200, height: height
        )
        return label
    }()
    
    override func viewDidLoad() {
        meterLabel.text = "4/4"
        view.addSubview(meterLabel)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
