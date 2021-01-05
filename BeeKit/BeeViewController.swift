//
//  BeeViewController.swift
//  BeeKit
//
//  Created by flqy on 2021/1/5.
//

import UIKit

class BeeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    @available(iOS 12.0, *)
    func reloadColor(userInterfaceStyle: UIUserInterfaceStyle) {
        switch userInterfaceStyle {
        case .unspecified:
            break
        case .light:
            break
        case .dark:
            break
        @unknown default:
            break
        }
    }
    
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        if #available(iOS 13.0, *) {
            if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
                let userInterfaceStyle = self.traitCollection.userInterfaceStyle
                reloadColor(userInterfaceStyle: userInterfaceStyle)
            } else {
                
            }
        } else {
            // Fallback on earlier versions
        }
        

    }
    
    
    

}
