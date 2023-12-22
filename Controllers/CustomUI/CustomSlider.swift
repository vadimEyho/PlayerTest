import UIKit

class CustomSlider: UISlider {

    private var animator: UIViewPropertyAnimator?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupSliderAppearance()
    }

    private func setupSliderAppearance() {
        setThumbImage(UIImage(), for: .normal)
        setThumbImage(UIImage(), for: .highlighted)
        minimumTrackTintColor = .systemBlue
        maximumTrackTintColor = .lightGray
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        return CGRect(origin: bounds.origin, size: CGSize(width: bounds.width, height: 5.0))
    }

    override func setValue(_ value: Float, animated: Bool) {
        if animated {
            if let animator = animator, animator.isRunning {
                animator.stopAnimation(true)
            }

            animator = UIViewPropertyAnimator(duration: 0.3, curve: .linear) {
                super.setValue(value, animated: false)
                self.layoutIfNeeded()
            }

            animator?.startAnimation()
        } else {
            super.setValue(value, animated: false)
            self.layoutIfNeeded()
        }
    }
}
