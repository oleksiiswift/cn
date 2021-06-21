//
//  ViewController.swift
//  ECleaner
//
//  Created by alexey sorochan on 16.06.2021.
//

import UIKit
import PhotosUI

class ViewController: UIViewController {
    
    var assetCollection: PHAssetCollection!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        PhotoManager.manager.calculateSpace { space in
            debugPrint("->>>>>>>>")
            debugPrint(space)
            debugPrint("<<<<<<<<-")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        U.delay(5) {
            PhotoManager.manager.getPhotoLibrary()
        }
    }
    

}
