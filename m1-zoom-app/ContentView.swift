//
//  ContentView.swift
//  m1-zoom-app
//
//  Created by satoreo on 2024/05/14.
//

import SwiftUI
import RealityKit
import CoreMotion

struct ContentView : View {
    var body: some View {
        ARViewContainer().edgesIgnoringSafeArea(.all)
    }
}

struct ARViewContainer: UIViewRepresentable {
    
    class Coordinator: NSObject {
        private var motionManager: CMMotionManager
        private var initialPitch: Double? // 起動時の初期角度を保存する変数
        private var zoomHandler: ZoomHandler?
        
        override init() {
            self.motionManager = CMMotionManager()
            super.init()
            
            if motionManager.isDeviceMotionAvailable {
                motionManager.deviceMotionUpdateInterval = 0.1
                motionManager.startDeviceMotionUpdates(to: .main) { [weak self] (motion, error) in
                    guard let self = self, let motion = motion else { return }
                    
                    let rotationMatrix = motion.attitude.rotationMatrix
                    let currentPitchRadians = atan2(rotationMatrix.m21, rotationMatrix.m11)
                    let currentPitchDegrees = currentPitchRadians * 180 / .pi
                    
                    if self.initialPitch == nil {
                        // 初期角度を保存
                        self.initialPitch = currentPitchDegrees
                    }
                    
                    if let initialPitch = self.initialPitch {
                        // 相対角度を計算
                        let relativePitchDegrees = currentPitchDegrees - initialPitch
                        print("Relative device Pitch around x-axis: \(relativePitchDegrees) degrees")
                    }
                }
            } else {
                print("Device motion is not available.")
            }
        }
        
        func setZoomHandler(arView: ARView) {
                    zoomHandler = ZoomHandler(arView: arView)
        }
        
        deinit {
            motionManager.stopDeviceMotionUpdates()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        
        // Create a cube model
        let mesh = MeshResource.generateBox(size: 0.1, cornerRadius: 0.005)
        let material = SimpleMaterial(color: .red, roughness: 0.15, isMetallic: true)
        let model = ModelEntity(mesh: mesh, materials: [material])
        model.transform.translation.y = 0.1
        model.transform.translation.z = -0.9
        
        // Create horizontal plane anchor for the content
        let anchor = AnchorEntity(.plane(.horizontal, classification: .any, minimumBounds: SIMD2<Float>(0.2, 0.2)))
        anchor.children.append(model)
        
        // Add the horizontal plane anchor to the scene
        arView.scene.anchors.append(anchor)
        
        // Set up the zoom handler
        context.coordinator.setZoomHandler(arView: arView)
        
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {}
}

#Preview {
    ContentView()
}
