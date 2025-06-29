import UIKit

final class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 100
        cache.totalCostLimit = 50 * 1024 * 1024
    }

    func image(for key: NSString) -> UIImage? {
        cache.object(forKey: key)
    }

    func insert(_ image: UIImage, for key: NSString) {
        cache.setObject(image, forKey: key)
    }

    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let key = url.absoluteString as NSString
        
        if let image = cache.object(forKey: key) {
            completion(image)
            return
        }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            var image: UIImage? = nil
            
            if let data = data, let img = UIImage(data: data) {
                image = img
                self?.cache.setObject(img, forKey: key)
            }
            DispatchQueue.main.async { completion(image) }
        }.resume()
    }
}
