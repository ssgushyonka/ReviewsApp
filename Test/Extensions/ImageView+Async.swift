import UIKit

extension UIImageView {
    func setImage(from url: URL?, placeholder: UIImage? = nil) {
        image = placeholder
        guard let url = url else { return }

        let key = url.absoluteString as NSString
        if let cached = ImageCache.shared.image(for: key) {
            image = cached
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard
                let data = data,
                let img = UIImage(data: data)
            else { return }
            ImageCache.shared.insert(img, for: key)
            DispatchQueue.main.async {
                self?.image = img
            }
        }.resume()
    }
}
