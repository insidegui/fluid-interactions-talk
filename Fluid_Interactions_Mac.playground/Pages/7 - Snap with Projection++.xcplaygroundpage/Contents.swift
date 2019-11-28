import UIKit
import PlaygroundSupport

final class DemoController: UIViewController {

    private lazy var movableView: UIView = {
        let v = UIView(frame: .zero)
        v.backgroundColor = .systemBlue
        v.layer.cornerRadius = 22
        v.layer.cornerCurve = .continuous
        return v
    }()

    private func makeDockingStation() -> UIView {
        let v = UIView()
        v.layer.borderColor = UIColor.systemBlue.cgColor
        v.layer.borderWidth = 1
        v.layer.cornerRadius = 22
        v.layer.cornerCurve = .continuous
        return v
    }

    private lazy var dockingStationTopRight: UIView = {
        makeDockingStation()
    }()
    private lazy var dockingStationBottomRight: UIView = {
        makeDockingStation()
    }()
    private lazy var dockingStationBottomLeft: UIView = {
        makeDockingStation()
    }()

    private lazy var dockingStations: [UIView] = {
        [dockingStationTopRight, dockingStationBottomLeft, dockingStationBottomRight]
    }()

    override func loadView() {
        view = UIView()
        view.backgroundColor = .systemBackground

        dockingStations.forEach(view.addSubview)

        view.addSubview(movableView)

        let moveGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        movableView.addGestureRecognizer(moveGesture)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        DispatchQueue.main.asyncAfter(deadline: .now()+1) {
            self.setupViews()
        }
    }

    private func setupViews() {
        movableView.frame = CGRect(x: view.bounds.width-150, y: 50, width: 100, height: 100)
        dockingStationTopRight.frame = movableView.frame
        dockingStationBottomLeft.frame = CGRect(x: 50, y: view.bounds.height-150, width: 100, height: 100)
        dockingStationBottomRight.frame = CGRect(x: movableView.frame.origin.x, y: view.bounds.height-150, width: 100, height: 100)
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
            snapToClosestDockingStation(from: movableView.origin, with: velocity)
        default:
            break
        }
    }

    private func project(initialVelocity: CGFloat, decelerationRate: CGFloat) -> CGFloat {
        return (initialVelocity / 1000.0) * decelerationRate / (1.0 - decelerationRate)
    }

    func projectedTargetPosition(with velocity: CGVector, from position: CGPoint) -> CGPoint {
        var velocity = velocity

        // Make sure the dominant axis has more weight when projecting the final position
        if velocity.dx != 0 || velocity.dy != 0 {
            let velocityInPrimaryDirection = max(abs(velocity.dx), abs(velocity.dy))

            velocity.dx *= abs(velocity.dx / velocityInPrimaryDirection)
            velocity.dy *= abs(velocity.dy / velocityInPrimaryDirection)
        }

        let decelerationRate = UIScrollView.DecelerationRate.normal.rawValue

        return CGPoint(
            x: position.x - 0.001 * velocity.dx / log(decelerationRate),
            y: position.y - 0.001 * velocity.dy / log(decelerationRate)
        )
    }

    private func closestDockingStation(from currentOrigin: CGPoint, with velocity: CGPoint) -> CGPoint {
        let projectedPosition = projectedTargetPosition(with: CGVector(dx: velocity.x, dy: velocity.y), from: currentOrigin)
        return dockingStations.min(by: { projectedPosition.distance(to: $0.center) < projectedPosition.distance(to: $1.center) })!.origin
    }

    private func snapToClosestDockingStation(from currentOrigin: CGPoint, with velocity: CGPoint) {
        let closest = closestDockingStation(from: currentOrigin, with: velocity)
        snapToDockingStation(at: closest, with: velocity)
    }

    private func timingCurve(with velocity: CGVector) -> FluidTimingCurve {
        let damping: CGFloat = velocity.dy.isZero ? 100 : 30

        return FluidTimingCurve(
            velocity: velocity,
            stiffness: 400,
            damping: damping
        )
    }

    private var animator: UIViewPropertyAnimator?
    private var bounceAnimator: UIViewPropertyAnimator?

    private func snapToDockingStation(at position: CGPoint, with velocity: CGPoint) {
        // the 0.5 is to ensure there's always some distance for the gesture to work with
        let distanceX = (movableView.frame.origin.x - 0.5) - position.x
        let distanceY = (movableView.frame.origin.y - 0.5) - position.y

        var initialVelocityX = abs(velocity.x/distanceX)
        var initialVelocityY = abs(velocity.y/distanceY)

        if initialVelocityX.isInfinite || initialVelocityX.isNaN { initialVelocityX = 1 }
        if initialVelocityY.isInfinite || initialVelocityY.isNaN { initialVelocityY = 1 }

        let timing = timingCurve(with: CGVector(dx: initialVelocityX, dy: initialVelocityY))

        animator = UIViewPropertyAnimator(duration: 0, timingParameters: timing)
        bounceAnimator = UIViewPropertyAnimator(duration: animator!.duration, curve: .easeOut, animations: nil)

        animator?.addAnimations {
            self.movableView.origin = position
        }

        bounceAnimator?.addAnimations({
            self.movableView.layer.transform = CATransform3DMakeScale(0.6, 0.6, 1)
        }, delayFactor: 0)
        bounceAnimator?.addAnimations({
            self.movableView.layer.transform = CATransform3DIdentity
        }, delayFactor: 0.24)

        animator?.startAnimation()
        bounceAnimator?.startAnimation()
    }

}

PlaygroundPage.current.liveView = DemoController()
