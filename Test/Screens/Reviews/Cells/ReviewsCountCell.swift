import UIKit

struct ReviewsCountCellConfig: TableCellConfig {
    static let reuseId = String(describing: ReviewsCountCellConfig.self)
    let reviewsCount: Int

    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewsCountCell else { return }
        cell.countLabel.text = "\(reviewsCount) отзывов"
    }

    func height(with size: CGSize) -> CGFloat {
        44
    }
}

final class ReviewsCountCell: UITableViewCell {
    let countLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        countLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(countLabel)

        countLabel.font = .reviewCount
        countLabel.textColor = .reviewCount
        countLabel.textAlignment = .center
        countLabel.numberOfLines = 0

        NSLayoutConstraint.activate([
            countLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 9),
            countLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            countLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
    }
}
