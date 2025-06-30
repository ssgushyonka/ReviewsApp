import UIKit

extension UIImage {
    static func photoPlaceholder(size: CGSize, color: UIColor = .gray) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            color.setFill()
            ctx.fill(CGRect(origin: .zero, size: size))
        }
    }
}
