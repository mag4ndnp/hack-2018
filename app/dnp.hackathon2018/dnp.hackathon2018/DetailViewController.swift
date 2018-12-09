//
//  DetailViewController.swift
//  dnp.hackathon2018
//
//  Created by tofubook on 2018/12/09.
//  Copyright © 2018年 tofubook. All rights reserved.
//

import UIKit

class DetailViewController:UIViewController {
    @IBOutlet weak var detailView:UIView!
    
    var isDetailViewToTop:Bool! = false
    var bottomPoint:CGPoint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // 詳細画面のオリジナル位置
        bottomPoint = detailView.frame.origin
    }
    
    @IBAction func downGesture(_ sender: UISwipeGestureRecognizer) {
        if isDetailViewToTop {
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.detailView.frame.origin.y = (self.bottomPoint?.y)!
            }, completion: { (Bool) in
                self.isDetailViewToTop = false
            })
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func upGesture(_ sender: UISwipeGestureRecognizer) {
        if !isDetailViewToTop {
            
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.detailView.frame.origin.y = 44
            }, completion: { (Bool) in
                self.isDetailViewToTop = true
            })
        }
    }
    
}
