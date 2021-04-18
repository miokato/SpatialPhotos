//
//  ViewController.swift
//  SpatialPhotos
//
//  Created by mio kato on 2021/04/18.
//

import UIKit
import ARKit
import SceneKit
import PhotosUI
import CoreGraphics

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var selectedImageView: UIImageView!
    
    var photoParentNode = SCNNode()
    
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
        
        sceneView.scene.rootNode.addChildNode(photoParentNode)
        
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
        let location = gesture.location(in: sceneView)
        
        if isHitPhotoNode(location: location) {
            return
        }
        
        putPhotoNode(location: location)
    }    
    
    @IBAction func pressedPlusButton(_ sender: UIButton) {
        showPickerView()
    }
    
    // MARK: Utils -
    private func isHitPhotoNode(location: CGPoint) -> Bool {
        // Doesn't hit.
        guard let hitResult = sceneView.hitTest(location, options: [:]).first else {
            return false
        }
        
        // Hit but isn't photo node.
        guard let photoNode = hitResult.node.parent as? PhotoNode else {
            return false
        }
            
        // Hit
        photoNode.state.transition()
        
        return true
    }
    
    private func putPhotoNode(location: CGPoint) {
        guard let _image = selectedImageView.image else {
            let ac = UIAlertController(title: "画像を選択してください。", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(ac, animated: true, completion: nil)
            return
        }
        
        guard let query = sceneView.raycastQuery(from: location, allowing: .estimatedPlane, alignment: .vertical),
              let firstResult = sceneView.session.raycast(query).first else { return }
        
        let image = _image.fixOrientation()
        let photoNode = PhotoNode(withImage: image)
        photoNode.simdWorldTransform = firstResult.worldTransform
        photoParentNode.addChildNode(photoNode)
    }
    
    private func showPickerView() {
        let config = PHPickerConfiguration()

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    
}

extension ViewController: ARSessionDelegate {
    
}

extension ViewController: ARSCNViewDelegate {
    
}

extension ViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        
        let itemProvider = results.first?.itemProvider
        
        if let itemProvider = itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (reading, error) in
                if let error = error {
                    assertionFailure("画像を読み込めない : \(error.localizedDescription)")
                }

                if let image = reading as? UIImage {
                    DispatchQueue.main.async {
                        self.selectedImageView.image = image
                    }
                }
            }
        }    
    }
}
