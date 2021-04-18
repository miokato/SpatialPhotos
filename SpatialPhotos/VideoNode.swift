//
//  PhotoNode.swift
//  SpatialPhotos
//
//  Created by mio kato on 2021/04/18.
//

import SceneKit

class VideoNode: SCNNode, StatableNode {
   
    var screenNode: SCNNode!
    var state: State = .inactive {
        didSet {
            switch state {
            case .active:
                print("to active")
                opacity = 0.5
                runAction(SCNAction.repeatForever(SCNAction.sequence([
                    SCNAction.scale(to: 1.05, duration: 0.5),
                    SCNAction.scale(to: 0.95, duration: 0.5),
                ])))
                
            case .inactive:
                print("to inactive")
                opacity = 1.0
                removeAllActions()
            }
        }
    }
    
    convenience init(withImage image: UIImage) {
        self.init()
        let ratio = image.size.height / image.size.width
        let width: CGFloat = 0.2
        let height: CGFloat = width * ratio
        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial?.diffuse.contents = image
        screenNode = SCNNode(geometry: plane)
        screenNode.eulerAngles.x -= Float.pi / 2.0

        addChildNode(screenNode)
    }
}

