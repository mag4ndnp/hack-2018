//
//  ViewController.swift
//  dnp.hackathon2018
//
//  Created by tofubook on 2018/12/04.
//  Copyright © 2018年 tofubook. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    @IBOutlet weak var searchUITextField:UITextField!
    @IBOutlet weak var searchUISegmentedControl:UISegmentedControl!
    @IBOutlet weak var searchTextBGUIView:UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // searchTextBGUIView
        searchTextBGUIView.layer.borderWidth = 1.0
        searchTextBGUIView.layer.borderColor = UIColor.gray.cgColor
        searchTextBGUIView.layer.cornerRadius = 5.0
        
    }
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue){
        if(unwindSegue.identifier=="ARViewSegue"){
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier=="ARViewSegue") {//ここでB4でつけた名前を用いる。
            let vcTo = segue.destination as! ARViewController;// destinationViewController;
            vcTo.searchText = searchUITextField.text
            vcTo.searchDistanceIndex = searchUISegmentedControl.selectedSegmentIndex
        }
    }
    
    override func canPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any) -> Bool {
        return true
    }
}

