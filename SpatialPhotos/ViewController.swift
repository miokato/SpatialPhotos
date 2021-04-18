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
import AVFoundation

enum MediaType {
    case image
    case video
}

class ViewController: UIViewController {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var selectedImageView: UIImageView!
    
    var photoParentNode = SCNNode()
    
    var defaultConfiguration: ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .vertical
        return configuration
    }
    
    var currentMediaType: MediaType?
    var currentAVAsset: AVAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup AR scene.
        sceneView.scene = SCNScene()
        sceneView.autoenablesDefaultLighting = true
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.debugOptions = [.showWireframe]
        
        sceneView.scene.rootNode.addChildNode(photoParentNode)
        
        // Register gesture.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(gesture:)))
        sceneView.addGestureRecognizer(tapGesture)
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(gesture:)))
        sceneView.addGestureRecognizer(pinchGesture)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(gesture:)))
        sceneView.addGestureRecognizer(panGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        
        let configuration = defaultConfiguration
        sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
    
    // MARK: Gestures -
    @objc func handleTap(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        
        if isHitPhotoNode(location: location) {
            return
        }
        
        switch currentMediaType {
        case .image:
            putPhotoNode(location: location)
        case .video:
            putVideoNode(location: location)
        default:
            break
        }
    }
    
    @objc func handlePinch(gesture: UIPinchGestureRecognizer) {
        guard let activeNode = getActiveNode() else { return }
        let scale = Float(gesture.scale)
        activeNode.screenNode.simdScale = simd_float3(scale, scale, scale)
    }
    
    @objc func handlePan(gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: sceneView)
        guard let query = sceneView.raycastQuery(from: location, allowing: .estimatedPlane, alignment: .vertical),
              let firstResult = sceneView.session.raycast(query).first else { return }
        
        guard let activeNode = getActiveNode() else { return }
        activeNode.simdWorldPosition = firstResult.worldTransform.translation

    }
    
    // MARK: - IBActions
    @IBAction func pressedPlusButton(_ sender: UIButton) {
        showPickerView()
    }
    
    // MARK: Utils -
    private func getActiveNode() -> PhotoNode? {
        let activeNode = photoParentNode.childNodes.filter({ (node) -> Bool in
            guard let photoNode = node as? PhotoNode else { return false }
            return photoNode.state == .active
        }).first
        return activeNode as? PhotoNode
    }
    
    private func isHitPhotoNode(location: CGPoint) -> Bool {
        // Doesn't hit.
        guard let hitResult = sceneView.hitTest(location, options: [:]).first else {
            return false
        }
        
        // Hit but isn't photo node.
        guard let hitPhotoNode = hitResult.node.parent as? PhotoNode else {
            return false
        }
                    
        // Hit then to active.
        hitPhotoNode.state.transition()
        
        // To inactive except hitNode.
        for child in photoParentNode.childNodes {
            guard let photoNode = child as? PhotoNode else { continue }
            if photoNode == hitPhotoNode {
                continue
            }
            photoNode.state.inactive()
        }
        
        return true
    }
    
    private func putVideoNode(location: CGPoint) {
        guard let currentAVAsset = currentAVAsset else {
            let ac = UIAlertController(title: "動画がありません。", message: nil, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            present(ac, animated: true, completion: nil)
            return
        }
        
        guard let query = sceneView.raycastQuery(from: location, allowing: .estimatedPlane, alignment: .vertical),
              let firstResult = sceneView.session.raycast(query).first else { return }
        
        
        let videoNode = VideoNode(withAVAsset: currentAVAsset)
        videoNode.simdWorldTransform = firstResult.worldTransform
        photoParentNode.addChildNode(videoNode)
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
        var config = PHPickerConfiguration()
        config.preferredAssetRepresentationMode = .current

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
        
        guard let itemProvider = results.first?.itemProvider else { return }
        
        // Load image.
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (reading, error) in
                if let error = error {
                    assertionFailure("画像を読み込めない : \(error.localizedDescription)")
                }

                if let image = reading as? UIImage {
                    DispatchQueue.main.async {
                        print("Set image")
                        self.selectedImageView.image = image
                        self.currentMediaType = .image
                    }
                }
            }
        }
        
        // Load movie.
        if itemProvider.hasItemConformingToTypeIdentifier("public.movie") {
            itemProvider.loadFileRepresentation(forTypeIdentifier: "public.movie") { (url, error) in
                guard let url = url else { return }
                let fm = FileManager.default
                // 一次ファイルはシステムに消去されるため、データをコピーする必要があるようだ。
                let destination = fm.temporaryDirectory.appendingPathComponent("video123.mp4")
                try? fm.removeItem(at: destination)
                try? fm.copyItem(at: url, to: destination)
                self.currentMediaType = .video
                print("Set video \(url)")
                self.currentAVAsset = AVURLAsset(url: destination)
            }
        }
    }
}
