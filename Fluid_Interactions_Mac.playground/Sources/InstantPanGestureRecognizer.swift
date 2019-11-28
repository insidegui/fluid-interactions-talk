
import UIKit
import UIKit.UIGestureRecognizerSubclass

public final class InstantPanGestureRecognizer: UIPanGestureRecognizer {
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        self.state = .began
    }
}
