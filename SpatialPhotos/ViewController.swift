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


class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var selectedImageView: UIImageView!
    
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
        showPickerView()
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
