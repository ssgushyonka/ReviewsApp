import UIKit

final class ReviewsViewController: UIViewController {

    private lazy var reviewsView = makeReviewsView()
    private let viewModel: ReviewsViewModel
    private let loadingIndicator = CustomLoadingIndicator(squareLength: 100)

    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        view = reviewsView
        title = "Отзывы"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        setupLoadingIndicator()
        setupRefreshControl()
        viewModel.getReviews()
    }

    private func setupRefreshControl() {
        reviewsView.refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
    }

    private func setupLoadingIndicator() {
        loadingIndicator.startAnimation(delay: 0.01, replicates: 16)
        loadingIndicator.isHidden = true
        view.addSubview(loadingIndicator)
    }

    @objc
    private func pullToRefresh() {
        viewModel.refreshReviews { [weak self] in
            self?.reviewsView.refreshControl.endRefreshing()
        }
    }
}

// MARK: - Private

private extension ReviewsViewController {

    func makeReviewsView() -> ReviewsView {
        let reviewsView = ReviewsView()
        reviewsView.tableView.delegate = viewModel
        reviewsView.tableView.dataSource = viewModel
        return reviewsView
    }

    private func setupViewModel() {
        viewModel.onStateChange = { [weak self] state in
            DispatchQueue.main.async {
                if let refreshControl = self?.reviewsView.tableView.refreshControl,
                   refreshControl.isRefreshing {
                    return
                }
                if state.isLoading && state.items.isEmpty {
                    self?.loadingIndicator.isHidden = false
                    self?.loadingIndicator.startAnimation(delay: 0.04, replicates: 16)
                } else {
                    self?.loadingIndicator.stopAnimation()
                    self?.loadingIndicator.isHidden = true
                }
                self?.reviewsView.tableView.reloadData()
            }
        }
        viewModel.onError = { [weak self] error in
            DispatchQueue.main.async {
                self?.showErrorAlert(error)
            }
        }
    }
    
    private func showErrorAlert(_ error: ReviewsError) {
        let alert = UIAlertController(
            title: "Ошибка",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "ОК", style: .default))
        present(alert, animated: true)
    }
}
