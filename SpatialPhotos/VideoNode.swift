//
//  PhotoNode.swift
//  SpatialPhotos
//
//  Created by mio kato on 2021/04/18.
//

import SceneKit
import AVFoundation
import SpriteKit

class VideoNode: SCNNode, StatableNode {
   
    var screenNode: SCNNode!
    var avPlayer: AVPlayer!
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
    var maxLength: CGFloat {
        max(UIScreen.main.nativeBounds.width, UIScreen.main.nativeBounds.height)
    }
    var viewSize: CGSize {
        CGSize(width: maxLength, height: maxLength)
    }
    
    convenience init(withPlayeItem item: AVPlayerItem) {
        self.init()
        avPlayer = createAVPlayer(withPlayerItem: item)
        let skVideoNode = createSKVideo(avPlayer: avPlayer, viewSize: viewSize)
        let skScene = createSKScene(skVideo: skVideoNode, viewSize: viewSize)
        let plane = SCNPlane(width: 0.5, height: 0.5)
        plane.firstMaterial?.diffuse.contents = skScene
        screenNode = SCNNode(geometry: plane)
        screenNode.eulerAngles.x -= Float.pi / 2.0
        avPlayer.play()

        addChildNode(screenNode)
    }
    
    private func createAVPlayer(withPlayerItem item: AVPlayerItem) -> AVPlayer {
        let player = AVPlayer(playerItem: item)
        player.actionAtItemEnd = .none
        
        return player
    }
    
    /// 再生用のビデオノードを作成
    private func createSKVideo(avPlayer: AVPlayer, viewSize: CGSize) -> SKVideoNode {
        let node = SKVideoNode(avPlayer: avPlayer)
        node.position = CGPoint(x: viewSize.width/2,
                                y: viewSize.height/2)
        // キャラクターを抜くための画像を右に配置しているため、横幅を二倍にする
        node.size = CGSize(width: viewSize.width, height: viewSize.height)
        node.yScale = -1.0
        node.pause()
        node.alpha = 1.0
        
        return node
    }
     
    /// ビデオ再生用のSKScene作成
    private func createSKScene(skVideo: SKVideoNode, viewSize: CGSize) -> SKScene {
        let skScene = SKScene(size: viewSize)
        skScene.backgroundColor = UIColor.blue
        skScene.scaleMode = .aspectFit
        skScene.addChild(skVideo)
        
        return skScene
    }
    
   
}

