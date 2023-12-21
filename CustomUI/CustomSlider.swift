import UIKit

class CustomSlider: UISlider {

    private var animator: UIViewPropertyAnimator?

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        // Настраиваем внешний вид слайдера
        setupSliderAppearance()
    }

    private func setupSliderAppearance() {
        // Убираем бегунок
        setThumbImage(UIImage(), for: .normal)
        setThumbImage(UIImage(), for: .highlighted)

        // Устанавливаем цвет слайдера
        minimumTrackTintColor = .systemBlue // Цвет заполняющейся полоски
        maximumTrackTintColor = .lightGray // Цвет фона слайдера
    }

    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        // Устанавливаем высоту заполняющейся полоски
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
