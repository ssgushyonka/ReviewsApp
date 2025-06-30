import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {

    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)
    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    /// Имя пользователя
    let firstName: NSAttributedString
    /// Фамилия пользователя
    let lastName: NSAttributedString
    /// Количество звезд рейтинга
    let rating: Int
    /// Полное имя пользователя
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    /// Текст отзыва.
    let reviewText: NSAttributedString
    /// Максимальное отображаемое количество строк текста. По умолчанию 3.
    var maxLines = 3
    /// Время создания отзыва.
    let created: NSAttributedString
    /// url аватара пользователя
    let avatarURL: URL?
    ///urls добавленных фото пользователя
    let photoURLs: [URL]?
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onTapShowMore: (UUID) -> Void

    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCellLayout()

}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }
        let fullName = NSMutableAttributedString()
        fullName.append(firstName)
        fullName.append(NSAttributedString(string: " "))
        fullName.append(lastName)

        cell.nameTextLabel.attributedText = fullName
        cell.ratingImageView.image = RatingRenderer().ratingImage(rating)
        cell.reviewTextLabel.attributedText = reviewText
        cell.reviewTextLabel.numberOfLines = maxLines
        cell.createdLabel.attributedText = created
        cell.configureAvatar(with: avatarURL)
        cell.updatePhotos(with: photoURLs)
        cell.config = self
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }

}

// MARK: - Private

private extension ReviewCellConfig {

    /// Текст кнопки "Показать полностью...".
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)

}

// MARK: - Cell

final class ReviewCell: UITableViewCell {

    fileprivate var config: Config?
    fileprivate let avatarImageView = UIImageView()
    fileprivate let nameTextLabel = UILabel()
    fileprivate let ratingImageView = UIImageView()
    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()
    fileprivate var photoImageViews: [UIImageView] = []

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarImageView.image = nil
        photoImageViews.forEach { $0.image = nil }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        avatarImageView.frame = layout.avatarImageViewFrame
        nameTextLabel.frame = layout.nameLabelFrame
        ratingImageView.frame = layout.ratingFrame
        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        showMoreButton.frame = layout.showMoreButtonFrame
        
        guard photoImageViews.count == layout.photoFrames.count else { return }
        
        for (index, frame) in layout.photoFrames.enumerated() {
            photoImageViews[index].frame = frame
        }
    }

    @objc
    private func showMoreTapped() {
        guard let config else { return }
        config.onTapShowMore(config.id)
    }
}

// MARK: - Private

private extension ReviewCell {

    func setupCell() {
        setupUserAvatarImageView()
        setupReviewTextLabel()
        setupCreatedLabel()
        setupShowMoreButton()
        setupNameLabel()
        setupRatingImageView()
    }
    
    func setupUserAvatarImageView() {
        contentView.addSubview(avatarImageView)
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = Layout.avatarCornerRadius
        avatarImageView.image = .l5W5AIHioYc
    }
    
    func setupNameLabel() {
        contentView.addSubview(nameTextLabel)
        nameTextLabel.font = UIFont.username
        nameTextLabel.textColor = .black
        nameTextLabel.numberOfLines = 1
    }
    
    func setupRatingImageView() {
        contentView.addSubview(ratingImageView)
        ratingImageView.contentMode = .scaleAspectFit
    }

    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }

    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }

    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
        showMoreButton.addTarget(self, action: #selector(showMoreTapped), for: .touchUpInside)
    }

}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {
    private static let ratingSize = CGSize(width: 84, height: 16)
    private static let nameHeight: CGFloat = 20

    // MARK: - Размеры

    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
    fileprivate static let avatarCornerRadius = 18.0
    fileprivate static let photoCornerRadius = 8.0

    private static let photoSize = CGSize(width: 55.0, height: 66.0)
    private static let showMoreButtonSize = Config.showMoreText.size()

    // MARK: - Фреймы

    private(set) var avatarImageViewFrame = CGRect.zero
    private(set) var nameLabelFrame = CGRect.zero
    private(set) var ratingFrame = CGRect.zero
    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero
    private(set) var photoFrames: [CGRect] = []

    // MARK: - Отступы

    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

    /// Горизонтальный отступ от аватара до имени пользователя.
    private let avatarToUsernameSpacing = 10.0
    /// Вертикальный отступ от имени пользователя до вью рейтинга.
    private let usernameToRatingSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
    private let ratingToTextSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до фото.
    private let ratingToPhotosSpacing = 10.0
    /// Горизонтальные отступы между фото.
    private let photosSpacing = 8.0
    /// Вертикальный отступ от фото (если они есть) до текста отзыва.
    private let photosToTextSpacing = 10.0
    /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
    private let reviewTextToCreatedSpacing = 6.0
    /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
    private let showMoreToCreatedSpacing = 6.0

    // MARK: - Расчёт фреймов и высоты ячейки

    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let contentLeft = insets.left + Self.avatarSize.width + avatarToUsernameSpacing
        var maxY = insets.top
        var showShowMoreButton = false
        
        avatarImageViewFrame = CGRect(
            x: insets.left,
            y: insets.top,
            width: Self.avatarSize.width,
            height: Self.avatarSize.height
        )
        
        nameLabelFrame = CGRect(
            x: contentLeft,
            y: insets.top,
            width: maxWidth - contentLeft - insets.right,
            height: Self.nameHeight
        )
        maxY = nameLabelFrame.maxY + usernameToRatingSpacing

        ratingFrame = CGRect(
            x: contentLeft,
            y: maxY,
            width: Self.ratingSize.width,
            height: Self.ratingSize.height
        )
        maxY = ratingFrame.maxY + ratingToTextSpacing
        
        photoFrames = []
        if let photoURLs = config.photoURLs, !photoURLs.isEmpty {
            let maxPhotosPerRow = Int((maxWidth - contentLeft - insets.right) / (Self.photoSize.width + photosSpacing))
            let photosCount = min(photoURLs.count, maxPhotosPerRow)
            
            for i in 0..<photosCount {
                let x = contentLeft + CGFloat(i) * (Self.photoSize.width + photosSpacing)
                photoFrames.append(CGRect(
                    x: x,
                    y: maxY,
                    width: Self.photoSize.width,
                    height: Self.photoSize.height
                ))
            }
            if !photoFrames.isEmpty {
                maxY = photoFrames.last!.maxY + photosToTextSpacing
            }
        }

        if !config.reviewText.isEmpty() {
            // Высота текста с текущим ограничением по количеству строк.
            let currentTextHeight = (config.reviewText.font()?.lineHeight ?? .zero) * CGFloat(config.maxLines)
            // Максимально возможная высота текста, если бы ограничения не было.
            let actualTextHeight = config.reviewText.boundingRect(width: maxWidth - contentLeft - insets.right).size.height
            // Показываем кнопку "Показать полностью...", если максимально возможная высота текста больше текущей.
            showShowMoreButton = config.maxLines != .zero && actualTextHeight > currentTextHeight

            reviewTextLabelFrame = CGRect(
                origin: CGPoint(x: contentLeft, y: maxY),
                size: config.reviewText.boundingRect(width: maxWidth - contentLeft - insets.right,
                                                     height: currentTextHeight).size
            )
            maxY = reviewTextLabelFrame.maxY + reviewTextToCreatedSpacing
        }

        if showShowMoreButton {
            showMoreButtonFrame = CGRect(
                origin: CGPoint(x: contentLeft, y: maxY),
                size: Self.showMoreButtonSize
            )
            maxY = showMoreButtonFrame.maxY + showMoreToCreatedSpacing
        } else {
            showMoreButtonFrame = .zero
        }

        createdLabelFrame = CGRect(
            origin: CGPoint(x: contentLeft, y: maxY),
            size: config.created.boundingRect(width: maxWidth - contentLeft - insets.right).size
        )
        return createdLabelFrame.maxY + insets.bottom
    }
}

extension ReviewCell {

    fileprivate func updatePhotos(with urls: [URL]?) {
        photoImageViews.forEach { $0.removeFromSuperview() }
        photoImageViews.removeAll()

        guard let urls = urls, !urls.isEmpty else { return }

        for (index, url) in urls.prefix(5).enumerated() {

            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.layer.cornerRadius = ReviewCellLayout.photoCornerRadius
            imageView.isUserInteractionEnabled = true
            imageView.tag = index

            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(photoTapped(_:)))
            imageView.addGestureRecognizer(tapGesture)
            contentView.addSubview(imageView)
            photoImageViews.append(imageView)

            ImageCache.shared.loadImage(from: url) { [weak imageView] image in
                DispatchQueue.main.async {
                    imageView?.image = image ?? .photoPlaceholder(size: CGSize(width: 55, height: 66))
                }
            }
        }
    }

    fileprivate func configureAvatar(with url: URL?) {
        if let url {
            ImageCache.shared.loadImage(from: url) { [weak self] image in
                DispatchQueue.main.async {
                    self?.avatarImageView.image = image ?? .l5W5AIHioYc
                }
            }
        } else {
            avatarImageView.image = .l5W5AIHioYc
        }
    }

    @objc private func photoTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag,
              let photoURLs = config?.photoURLs,
              index < photoURLs.count else { return }
        let galleryVC = PhotoPersentationViewController(photoURLs: photoURLs, initialIndex: index)
        var responder: UIResponder? = self
        while responder != nil {
            if let vc = responder as? UIViewController {
                vc.present(galleryVC, animated: true)
                break
            }
            responder = responder?.next
        }
    }
}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout
