//
//  PhotoNode.swift
//  SpatialPhotos
//
//  Created by mio kato on 2021/04/18.
//

import SceneKit

class PhotoNode: SCNNode {
    convenience init(withImage image: UIImage) {
        self.init()
        let ratio = image.size.height / image.size.width
        let width: CGFloat = 0.2
        let height: CGFloat = width * ratio
        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial?.diffuse.contents = image
        let node = SCNNode(geometry: plane)
        node.eulerAngles.x -= Float.pi / 2.0

        addChildNode(node)
    }
}
