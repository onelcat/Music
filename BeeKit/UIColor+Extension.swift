//
//  UIColor+Extension.swift
//  BeeKit
//
//  Created by flqy on 2021/1/5.
//

import Foundation
import UIKit

extension UIColor {
    
    static var mainColor: UIColor {
        if #available(iOS 11.0, *) {
            return UIColor(named: "#D0104C")!
        } else {
            return #colorLiteral(red: 0.8156862745, green: 0.06274509804, blue: 0.2980392157, alpha: 1)
        }
    }
    
    var textColor: UIColor {
        // 适配暗黑模式 iOS 13.0
        if #available(iOS 13.0, *) {
            return UIColor { (traitCollection) -> UIColor in
                switch traitCollection.userInterfaceStyle {
                case .unspecified,.light:
                    return .black
                case .dark:
                    return .white
                @unknown default:
                    return .white
                }
           }
        } else {
            // Fallback on earlier versions
            return .white
        }
    }

    
    var image: UIImage {
        // 这里可以缓存图片
        return UIImage.creatImage(color: self)!
    }
    
    
    
}
