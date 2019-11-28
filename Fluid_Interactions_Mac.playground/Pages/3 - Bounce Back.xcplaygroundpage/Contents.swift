import UIKit
import PlaygroundSupport

final class DemoController: UIViewController {

    private let initialPosition = CGPoint(x: 50, y: 50)

    private lazy var movableView: UIView = {
        let v = UIView(frame: CGRect(origin: initialPosition, size: CGSize(width: 100, height: 100)))
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
        case .ended, .cancelled:
            snapBack()
        default:
            break
        }
    }

    private func snapBack() {
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: [.allowUserInteraction, .beginFromCurrentState, .allowAnimatedContent], animations: {
            var f = self.movableView.frame
            f.origin = self.initialPosition
            self.movableView.frame = f
        }, completion: nil)
    }

}

PlaygroundPage.current.liveView = DemoController()
