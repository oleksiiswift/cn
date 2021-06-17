//
//  ViewController.swift
//  ECleaner
//
//  Created by mac on 16.06.2021.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
//        PhotoManager.manager.getPhotoLibrary()
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        U.delay(5) {
            PhotoManager.manager.getPhotoLibrary()
        }
    }
}
