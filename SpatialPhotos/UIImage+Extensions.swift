//
//  UIImage+Extensions.swift
//  SpatialPhotos
//
//  Created by mio kato on 2021/04/18.
//

import UIKit

extension UIImage {
    func fixOrientation () -> UIImage {
        if self.imageOrientation == .up {
            return self
        }
        
        var radian: CGFloat = 0
        switch imageOrientation {
        case .left:
            radian = .pi/2.0
        case .right:
            radian = -.pi/2.0
        case .down:
            radian = .pi
        default:
            break
        }
        let rotatedRect = CGRect(origin: .zero, size: size)
        
        UIGraphicsBeginImageContext(rotatedRect.size)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: rotatedRect.size.width / 2, y: rotatedRect.size.height / 2)
        context.scaleBy(x: 1.0, y: -1.0)
        context.rotate(by: radian)
        let cgRect = CGRect(x: -(size.width/2), y: -(size.height/2), width: size.width, height: size.height)
        context.draw(self.cgImage!, in: cgRect)
        let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return rotatedImage
    }
}
