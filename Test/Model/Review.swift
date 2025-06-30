import Foundation
/// Модель отзыва.
struct Review: Decodable {
    
    /// Имя пользователя
    let firstName: String
    /// Фамилия пользователя
    let lastName: String
    /// Количество звезд рейтинга
    let rating: Int
    /// Текст отзыва.
    let text: String
    /// Время создания отзыва.
    let created: String
    /// url аватара пользователя
    let avatarURL: URL?
    /// url фотографий пользователя
    let photoURLs: [URL]?

    private enum CodingKeys: String, CodingKey {
        case firstName = "first_name"
        case lastName = "last_name"
        case rating
        case text
        case created
        case avatarURL = "avatar_url"
        case photoURLs = "photo_urls"
    }
}
