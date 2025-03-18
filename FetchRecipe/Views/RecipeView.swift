//
//  RecipeView.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 3/17/25.
//

import SwiftUI

public typealias ImageDataCachingAction = (Data, URL) async -> Void

struct RecipeView: View {
    let recipe: Recipe
    let cacheImageData: ImageDataCachingAction
    @State private var isShowingVideoSheet = false
    
    var body: some View {
        
        HStack {
            ViewModel.CachingAsyncImageView(
                recipe: recipe,
                cacheAction: cacheImageData
            )
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            VStack(alignment: .leading, spacing: 0) {
                Text(recipe.name)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                    .padding(.bottom, 5)
                
                if let source = recipe.sourceUrl, let url = URL(string: source) {
                    ViewModel.linkView(title: "Recipe:", url: url)
                }
                
                HStack {
                    Text("Cuisine:")
                        .font(.subheadline)
                        .bold()
                    Text(recipe.cuisine)
                        .font(.subheadline)
                }
                
                if let source = recipe.youtubeUrl, let url = URL(string: source) {
                    HStack {
                        Text("Video:")
                            .font(.subheadline)
                            .bold()
                        
                        Button(action: {
                            isShowingVideoSheet = true
                        }) {
                            Image(systemName: "video")
                                .foregroundColor(.blue)
                        }
                        .buttonStyle(.borderless)
                        .contentShape(Rectangle())
                        .sheet(isPresented: $isShowingVideoSheet) {
                            YouTubeView(url: url, title: recipe.name)
                        }
                    }
                }
            }
        }
    }
}

extension RecipeView {
    
    struct ViewModel {
        
        static func CachingAsyncImageView(recipe: Recipe, cacheAction: @escaping ImageDataCachingAction) -> some View {
            Group {
                if let cachedImageData = recipe.photoUrlSmallImageData,
                   let uiImage = UIImage.from(data: cachedImageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                } else {
                    CachingAsyncImage(
                        url: URL(string: recipe.photoUrlSmall ?? ""),
                        cacheAction: cacheAction
                    )
                }
            }
        }
        
        static func CachingAsyncImage(url: URL?, cacheAction: @escaping ImageDataCachingAction) -> some View {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable()
                        .onAppear {
                            Task {
                                if let url = url, let imageData = try? await fetchImageData(from: url) {
                                    await cacheAction(imageData, url)
                                }
                            }
                        }
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .foregroundColor(.gray)
                @unknown default:
                    EmptyView()
                }
            }
        }
        
        static func fetchImageData(from url: URL) async throws -> Data {
            let (data, _) = try await URLSession.shared.data(from: url)
            return data
        }
        
        static func linkView(title: String, url: URL) -> some View {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .bold()
                Link(destination: url) {
                    hostWebsiteDisplayString(for: url)
                        .font(.subheadline)
                }
            }
            .buttonStyle(.borderless)
            .contentShape(Rectangle())
        }
        
        static func hostWebsiteDisplayString(for url: URL) -> Text {
            let defaultLabel = Text("Visit Website")
            guard let host = url.host else {
                return defaultLabel
            }
            let hostWithoutWWW = host.hasPrefix("www.") ? String(host.dropFirst(4)) : host
            let components = hostWithoutWWW.components(separatedBy: ".")
            guard let website = components.first else {
                return defaultLabel
            }
            return Text(website)
        }
    }
}

extension UIImage {
    static func from(data: Data) -> UIImage? {
        return UIImage(data: data)
    }
}

#Preview {
    RecipeView(recipe: RecipeListPreviewHelper.expectedRecipe(at: 4), cacheImageData: RecipeListPreviewHelper.cacheMockData)
}
