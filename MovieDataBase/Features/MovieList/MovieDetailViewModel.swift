import Foundation
import Combine

/// Formats and exposes `Movie` data for `MovieDetailView`.
/// No network dependency — the list screen already fetched everything this view needs.
@MainActor
final class MovieDetailViewModel: ObservableObject {
     let movie: Movie
     @Published var item:String = ""
    
    init(movie: Movie) {
        self.movie = movie
    }

    var title: String { movie.title }

    var overview: String {
        movie.overview.isEmpty ? "No overview available." : movie.overview
    }

    var releaseYear: String {
        String(movie.releaseDate.prefix(4))
    }

    var ratingText: String {
        String(format: "%.1f", movie.voteAverage)
    }

    var voteCountText: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let count = formatter.string(from: NSNumber(value: movie.voteCount)) ?? "\(movie.voteCount)"
        return "\(count) votes"
    }

    var popularityText: String {
        String(format: "%.0f", movie.popularity)
    }

    var showOriginalTitle: Bool {
        movie.originalTitle != movie.title
    }

    var originalLanguageDisplay: String {
        Locale.current.localizedString(forLanguageCode: movie.originalLanguage)?.capitalized
            ?? movie.originalLanguage.uppercased()
    }

    var isAdult: Bool { movie.adult }
    
    var posterURL: URL? {
        guard let path = movie.posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    var backdropURL: URL? {
        guard let path = movie.backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w780\(path)")
    }
}
