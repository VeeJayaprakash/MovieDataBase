import SwiftUI
import Kingfisher

struct MovieDetailView: View {
    
    @StateObject private var viewModel: MovieDetailViewModel
    @Environment(\.colorScheme) var colorScheme

    init(movie:Movie) {
        _viewModel = StateObject(wrappedValue: MovieDetailViewModel(movie: movie))
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
              ScrollView(showsIndicators: false) {
                  VStack(alignment: .leading, spacing: 0) {
                      backdrop
                      content
                          .padding(.horizontal, 20)
                          .padding(.top, 60)
                  }
              }
          }
          .navigationTitle(viewModel.movie.originalTitle)
    }
    
    // MARK: - Header (backdrop + overlapping poster)
    private var backdrop: some View {
        Group {
            if let url = viewModel.backdropURL {
                KFImage(url)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Color.gray.opacity(0.2)
            }
        }
        .frame(height: 240)
        .clipped()
    }


    // MARK: - Content
    private var content: some View {
        VStack(alignment: .leading, spacing: 20) {
            titleBlock
            overviewSection
            infoSection
        }
        .padding(.bottom, 32)
    }

    private var titleBlock: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(viewModel.title)
                .font(.title2.bold())

            HStack(spacing: 10) {
                Label(viewModel.ratingText, systemImage: "star.fill")
                    .foregroundStyle(colorScheme == .dark ? .yellow : .blue)
                    .fontWeight(.semibold)

                Text(viewModel.releaseYear)
                    .foregroundStyle(.opacity(0.7))

                Text("•")
                    .foregroundStyle(.opacity(0.4))

                Text(viewModel.voteCountText)
                    .foregroundStyle(.opacity(0.7))
            }
            .font(.subheadline)
        }
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Overview")
                .font(.headline)

            Text(viewModel.overview)
                .font(.subheadline)
                .foregroundStyle(.opacity(0.8))
                .lineSpacing(4)
        }
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Details")
                .font(.headline)
                

            VStack(spacing: 0) {
                if viewModel.showOriginalTitle {
                    infoRow(label: "Original Title", value: viewModel.movie.originalTitle)
                }
                infoRow(label: "Original Language", value: viewModel.originalLanguageDisplay)
                infoRow(label: "Audience", value: viewModel.isAdult ? "Adult" : "General Audiences")
            }
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.opacity(0.6))
            Spacer()
            Text(value)
        }
        .font(.subheadline)
        .padding(.vertical, 10)
    }
}

// MARK: - Preview

#Preview {
    
    @Previewable @Namespace var nameSpace
    
    NavigationStack {
        MovieDetailView(
            movie: Movie(
                id: 640146,
                adult: false,
                backdropPath: "/8YFL5QQVPy3AgrEQxNYVSgiPEbe.jpg",
                genreIds: [12, 878, 35],
                originalLanguage: "en",
                originalTitle: "Ant-Man and the Wasp: Quantumania",
                overview: "Super-Hero partners Scott Lang and Hope van Dyne, along with with Hope's parents Janet van Dyne and Hank Pym, and Scott's daughter Cassie Lang, find themselves exploring the Quantum Realm.",
                popularity: 1418.4,
                posterPath: "/qnqGbB22YJ7dSs4o6M7exTpNxPz.jpg",
                releaseDate: "2023-02-15",
                title: "Ant-Man and the Wasp: Quantumania",
                video: false,
                voteAverage: 6.5,
                voteCount: 3122
            ))
    }
}
