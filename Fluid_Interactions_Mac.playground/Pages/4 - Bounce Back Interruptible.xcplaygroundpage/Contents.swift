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

        let gesture = InstantPanGestureRecognizer(target: self, action: #selector(handlePan))
        view.addGestureRecognizer(gesture)
    }

    private var referencePoint: CGPoint = .zero

    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: view)

        switch recognizer.state {
        case .began:
            animator?.stopAnimation(true)

            movableView.origin = location
        case .changed:
            movableView.origin = location
        case .ended, .cancelled:
            snapBack()
        default:
            break
        }
    }

    private var animator: UIViewPropertyAnimator?

    private func snapBack() {
        animator = UIViewPropertyAnimator(duration: 5, curve: .easeInOut, animations: nil)
        animator?.isUserInteractionEnabled = true
        animator?.isInterruptible = true
        animator?.addAnimations {
            self.movableView.origin = self.initialPosition
        }
        animator?.startAnimation()
    }

}

PlaygroundPage.current.liveView = DemoController()
