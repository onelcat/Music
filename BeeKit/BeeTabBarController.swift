//
//  BeeTabBarController.swift
//  BeeKit
//
//  Created by flqy on 2021/1/5.
//

import UIKit

final class BeeTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        removeTopLine()
    }
    
    func removeTopLine() {
        let image: UIImage
        if #available(iOS 11.0, *) {
            image = UIColor(named: "#D0104C")!.image
        } else {
            // Fallback on earlier versions
            image = UIColor.red.image
        }
        
        if #available(iOS 13.0, *) {
            let appearance = self.tabBar.standardAppearance.copy()
            // tabBar
            appearance.backgroundImage = image
            // 线
            appearance.shadowImage = image
            self.tabBar.standardAppearance = appearance
        } else {
            self.tabBar.backgroundImage = image
            self.tabBar.shadowImage = image
        }
        
    }
}

extension BeeTabBarController: UITabBarControllerDelegate {
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    
    
}
