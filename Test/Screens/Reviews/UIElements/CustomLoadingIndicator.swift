import UIKit

final class CustomLoadingIndicator: UIView {
    private lazy var replicatorLayer: CAReplicatorLayer = {
        let caLayer = CAReplicatorLayer()
        shapeLayer.fillColor = UIColor.blue.cgColor
        return caLayer
    }()

    private lazy var shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        return shapeLayer
    }()

    private let keyAnimation = "opacityAnimation"

    convenience init(squareLength: CGFloat) {
        let mainBounds = UIScreen.main.bounds
        let rect = CGRect(origin: CGPoint(x: (mainBounds.width-squareLength)/2,
                                          y: (mainBounds.height-squareLength)/2),
                          size: CGSize(width: squareLength, height: squareLength))
        self.init(frame: rect)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(replicatorLayer)
        replicatorLayer.addSublayer(shapeLayer)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let size = min(bounds.width/1.5, bounds.height/1.5)
        let rect = CGRect(x: size/4, y: size/4, width: size/4, height: size/4)
        let path = UIBezierPath(rect: rect)
        shapeLayer.path = path.cgPath
        replicatorLayer.frame = bounds
        replicatorLayer.position = CGPoint(x: size, y:  size)
    }
    
    func startAnimation(delay: TimeInterval, replicates: Int) {
        replicatorLayer.instanceCount = replicates
        replicatorLayer.instanceDelay = delay
        let angle = CGFloat(2.0 * Double.pi) / CGFloat(replicates)
        replicatorLayer.instanceTransform = CATransform3DMakeRotation(angle, 0.0, 0.0, 1.0)

        shapeLayer.opacity = 0
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.fromValue = 0.2
        opacityAnimation.toValue = 0.9

        opacityAnimation.duration = Double(replicates) * delay
        opacityAnimation.repeatCount = Float.infinity
        shapeLayer.add(opacityAnimation, forKey: keyAnimation)
    }
    
    func stopAnimation() {
        guard shapeLayer.animation(forKey: keyAnimation) != nil else {
            return
        }
        shapeLayer.removeAnimation(forKey: keyAnimation)
    }

    // MARK: - Deinit
    deinit {
        stopAnimation()
    }
}
