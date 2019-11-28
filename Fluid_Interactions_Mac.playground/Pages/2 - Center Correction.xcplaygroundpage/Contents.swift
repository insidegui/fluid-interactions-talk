import UIKit
import PlaygroundSupport

final class SimpleMoveController: UIViewController {

    private lazy var movableView: UIView = {
        let v = UIView(frame: CGRect(x: 50, y: 50, width: 100, height: 100))
        v.backgroundColor = .systemBlue
        v.layer.cornerRadius = 22
        v.layer.cornerCurve = .continuous
        return v
    }()

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground

        view.addSubview(movableView)

        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        movableView.addGestureRecognizer(gesture)
    }

    private var referencePoint: CGPoint = .zero

    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
            case .began:
                referencePoint = recognizer.location(in: movableView)
            case .changed:
                let location = recognizer.location(in: view)
                var f = movableView.frame
                f.origin = location - referencePoint
                movableView.frame = f
            default:
                break
        }
    }

}

PlaygroundPage.current.liveView = SimpleMoveController()
