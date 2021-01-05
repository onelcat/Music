//
//  BeeNavigationController.swift
//  BeeKit
//
//  Created by flqy on 2021/1/5.
//

import UIKit

final class BeeNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        removeBottomLine()
    }
    
    func removeBottomLine() {
        let image: UIImage
        if #available(iOS 11.0, *) {
            image = UIColor(named: "mainColor")!.image
        } else {
            // Fallback on earlier versions
            image = UIColor.red.image
        }
        // navigationBar
        self.navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
        // 线
        self.navigationBar.shadowImage = image
    }
    

}

extension BeeNavigationController: UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        debugPrint("willShow viewController", viewController, viewControllers.count)
            
        if viewControllers.count == 1 {
            viewController.hidesBottomBarWhenPushed = false
        }
        else {
            viewController.hidesBottomBarWhenPushed = true
        }
        
        
        if viewController is PlayerViewController {
            viewController.navigationController?.setNavigationBarHidden(true, animated: false)
        }
        
//
//        if viewController is SongListViewController {
//            viewController.navigationController?.setNavigationBarHidden(true, animated: false)
//        }
        
    }
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        debugPrint("didShow viewController", viewControllers.count)
    }
    

}
