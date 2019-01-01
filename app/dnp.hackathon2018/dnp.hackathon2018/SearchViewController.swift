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
    @IBOutlet weak var searchTextBGUIView:UIView!
    @IBOutlet weak var searchInputRoll01:UIButton!
    @IBOutlet weak var searchInputRoll02:UIButton!
    @IBOutlet weak var searchInputRoll03:UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // searchTextBGUIView
        searchTextBGUIView.layer.borderWidth = 1.0
        searchTextBGUIView.layer.borderColor = UIColor.gray.cgColor
        searchTextBGUIView.layer.cornerRadius = 5.0
        
        searchInputRoll01.layer.borderWidth = 1.0
        searchInputRoll01.layer.borderColor = UIColor(red: 94/255, green: 194/255, blue: 57/255, alpha: 1).cgColor
        searchInputRoll01.layer.cornerRadius = 15.0
        
        searchInputRoll02.layer.borderWidth = 1.0
        searchInputRoll02.layer.borderColor = UIColor(red: 94/255, green: 194/255, blue: 57/255, alpha: 1).cgColor
        searchInputRoll02.layer.cornerRadius = 15.0
        
        searchInputRoll03.layer.borderWidth = 1.0
        searchInputRoll03.layer.borderColor = UIColor(red: 94/255, green: 194/255, blue: 57/255, alpha: 1).cgColor
        searchInputRoll03.layer.cornerRadius = 15.0
        
        
    }
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue){
        if(unwindSegue.identifier=="ARViewSegue"){
            
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier=="ARViewSegue") {//ここでB4でつけた名前を用いる。
            let vcTo = segue.destination as! ARViewController;// destinationViewController;
            vcTo.searchText = searchUITextField.text
        }
    }
    
    override func canPerformUnwindSegueAction(_ action: Selector, from fromViewController: UIViewController, withSender sender: Any) -> Bool {
        return true
    }
}

