//
//  MovieGridItem.swift
//  MovieDataBase
//
//  Created by Vijendran  on 8/2/26.
//

import SwiftUI
import Kingfisher

struct MovieGridItem:View {
    
    let movie: Movie
     @Environment(\.colorScheme) private var colorScheme
    
    private var posterURL: URL? {
        guard let path = movie.posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }

    private var releaseYear: String {
        String(movie.releaseDate.prefix(4))
    }

    var body: some View {
        
        VStack(alignment:.leading, spacing: 12) {
            KFImage(posterURL)
                .placeholder {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                }
                .resizable()
                .aspectRatio(contentMode: .fit)
                .cornerRadius(4)
            
                Text(movie.title)
                    .font(.headline)
                    .lineLimit(2)

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .foregroundStyle(colorScheme == .dark ? .yellow : .blue)
                    .font(.caption)
                
                Text(String(format: "%.1f", movie.voteAverage))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Text(releaseYear)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

}


#Preview ("medium title", traits: .fixedLayout(width: 300, height: 150)) {
    MovieGridItem(movie: MockMovieRepository().mockMovie())
}
