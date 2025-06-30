import UIKit

final class PhotoPersentationCell: UICollectionViewCell {
    private let imageView = UIImageView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private var currentImageURL: URL?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setpConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with url: URL) {
        activityIndicator.startAnimating()
        imageView.image = nil
        currentImageURL = url

        let key = url.absoluteString as NSString
        if let cachedImage = ImageCache.shared.image(for: key) {
            activityIndicator.stopAnimating()
            imageView.image = cachedImage
            return
        }

        ImageCache.shared.loadImage(from: url) { [weak self] image in
            guard let self = self, self.currentImageURL == url else { return }

            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.imageView.image = image ?? UIImage.photoPlaceholder(size: CGSize(width: 55, height: 66))
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        currentImageURL = nil
        imageView.image = nil
        activityIndicator.stopAnimating()
    }

    private func setupViews() {
        imageView.contentMode = .scaleAspectFit
        activityIndicator.hidesWhenStopped = true

        contentView.addSubview(imageView)
        contentView.addSubview(activityIndicator)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    }

    private func setpConstraints() {
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),

            activityIndicator.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
