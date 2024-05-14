import UIKit
import RealityKit

class ZoomHandler: NSObject {
    private weak var arView: ARView?

    init(arView: ARView) {
        self.arView = arView
        super.init()
        addPinchGesture()
    }

    private func addPinchGesture() {
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
        arView?.addGestureRecognizer(pinchGestureRecognizer)
    }

    @objc private func handlePinch(_ gesture: UIPinchGestureRecognizer) {
        guard let arView = arView else { return }
        
        // カメラアンカーを取得
        guard let cameraAnchor = arView.scene.anchors.first(where: { $0.name == "cameraAnchor" }) else {
            print("Camera anchor not found")
            return
        }
        
        let scale = Float(gesture.scale)
        
        // Z軸方向にスケールを適用
        cameraAnchor.transform.translation.z *= scale
        
        // ジェスチャーのスケールをリセット
        gesture.scale = 1.0
    }
}
