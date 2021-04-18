//
//  ViewController.swift
//  SpatialPhotos
//
//  Created by mio kato on 2021/04/18.
//

import UIKit
import ARKit
import SceneKit

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    
    var defaultConfiguration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        return configuration
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup AR scene.
        sceneView.scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Register gesture.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        sceneView.addGestureRecognizer(tapGesture)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = defaultConfiguration
        sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
    
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        print("tap")
    }
    
    
}

extension ViewController: ARSessionDelegate {
    
}

extension ViewController: ARSCNViewDelegate {
    
}
