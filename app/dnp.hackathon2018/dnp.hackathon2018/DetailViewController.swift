//
//  DetailViewController.swift
//  dnp.hackathon2018
//
//  Created by tofubook on 2018/12/09.
//  Copyright © 2018年 tofubook. All rights reserved.
//

import UIKit

class DetailViewController:UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

    }
    
    @IBAction func downGesture(_ sender: UISwipeGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func upGesture(_ sender: UISwipeGestureRecognizer) {
        
        
    }
    
}
