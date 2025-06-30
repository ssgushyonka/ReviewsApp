import Foundation

enum ReviewsError: Error {
    case loadingFailed(underlyingError: Error)
    case decodingFailed(underlyingError: Error)
    case networkUnavailable // на случай реального апи
    case accessDenied // тоже на случай реального апи

    var localizedDescription: String {
        switch self {
        case .loadingFailed(let error):
            return "ошибка загрузки: \(error.localizedDescription)"
        case .decodingFailed(let error):
            return "ошибка декодирования: \(error.localizedDescription)"
        case .networkUnavailable:
            return "невозможно зарузить из за проблем с сетью"
        case .accessDenied:
            return "доступ запрещен"
        }
    }
}
