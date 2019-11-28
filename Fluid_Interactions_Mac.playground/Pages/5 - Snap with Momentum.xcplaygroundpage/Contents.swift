import UIKit
import PlaygroundSupport

final class DemoController: UIViewController {

    private lazy var momentumLabel: UILabel = {
        let l = UILabel()
        l.text = "Momentum"
        l.textColor = .secondaryLabel
        return l
    }()

    private lazy var momentumSwitch: UISwitch = {
        let s = UISwitch()
        s.isOn = false
        return s
    }()

    private lazy var momentumStack: UIStackView = {
        let v = UIStackView(arrangedSubviews: [self.momentumLabel, self.momentumSwitch])
        v.axis = .horizontal
        v.spacing = 8
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private lazy var movableView: UIView = {
        let v = UIView(frame: .zero)
        v.backgroundColor = .systemBlue
        v.layer.cornerRadius = 22
        v.layer.cornerCurve = .continuous
        return v
    }()

    private lazy var dockingStation: UIView = {
        let v = UIView(frame: CGRect(x: 50, y: 400, width: 100, height: 100))
        v.backgroundColor = .systemGray6
        v.layer.cornerRadius = 22
        v.layer.cornerCurve = .continuous
        return v
    }()

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground

        view.addSubview(dockingStation)
        view.addSubview(movableView)
        view.addSubview(momentumStack)

        NSLayoutConstraint.activate([
            momentumStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            momentumStack.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16),
        ])

        let moveGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        movableView.addGestureRecognizer(moveGesture)

        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(reset))
        doubleTapGesture.numberOfTapsRequired = 2
        view.addGestureRecognizer(doubleTapGesture)
    }

    @objc private func reset() {
        movableView.frame = CGRect(x: view.bounds.width-150, y: 50, width: 100, height: 100)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.movableView.frame = CGRect(x: self.view.bounds.width-150, y: 50, width: 100, height: 100)
            self.dockingStation.frame = CGRect(x: 50, y: self.view.bounds.height-150, width: 100, height: 100)
        }
    }

    private var referencePoint: CGPoint = .zero

    @objc private func handlePan(_ recognizer: UIPanGestureRecognizer) {
        let velocity = recognizer.velocity(in: view)

        switch recognizer.state {
        case .began:
            animator?.stopAnimation(true)

            referencePoint = recognizer.location(in: movableView)
        case .changed:
            let location = recognizer.location(in: view)
            movableView.origin = location - referencePoint
        case .ended, .cancelled:
            snapToDockingStation(with: velocity)
        default:
            break
        }
    }

    private var animator: UIViewPropertyAnimator?

    private func timingCurve(with velocity: CGFloat) -> FluidTimingCurve {
        let damping: CGFloat = velocity.isZero ? 100 : 30

        return FluidTimingCurve(
            velocity: CGVector(dx: velocity, dy: velocity),
            stiffness: 400,
            damping: damping
        )
    }

    private func snapToDockingStation(with velocity: CGPoint) {
        // the 0.5 is to ensure there's always some distance for the gesture to work with
        let distanceY = (movableView.frame.origin.y - 0.5) - dockingStation.frame.origin.y

        let effectiveVelocity = velocity.y.isInfinite || velocity.y.isNaN ? 2000 : velocity.y

        let initialVelocityY = distanceY.isZero ? 0 : effectiveVelocity/distanceY * -1

        let timing: FluidTimingCurve

        if momentumSwitch.isOn {
            timing = timingCurve(with: initialVelocityY)
        } else {
            timing = FluidTimingCurve(velocity: CGVector(dx: 1, dy: 1), stiffness: 400, damping: 30)
        }

        animator = UIViewPropertyAnimator(duration: 2, timingParameters: timing)
        animator?.addAnimations {
            self.movableView.origin = self.dockingStation.origin
        }
        animator?.startAnimation()
    }

}

PlaygroundPage.current.liveView = DemoController()
