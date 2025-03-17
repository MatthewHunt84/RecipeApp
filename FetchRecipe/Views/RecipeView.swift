//
//  RecipeView.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 3/17/25.
//

import SwiftUI

struct RecipeView: View {
    let recipe: Recipe
    @State private var showingDetail = false
    
    var body: some View {
        
        HStack {
            
            AsyncImage(url: URL(string: recipe.photoUrlSmall ?? ""), scale: 1) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable()
                default:
                    EmptyView()
                }
            }
            .frame(width: 90, height: 90)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            VStack(alignment: .leading, spacing: 0) {
                
                Text(recipe.name)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.bottom, 5)
                
                if let source = recipe.sourceUrl, let url = URL(string: source) {
                    linkView(title: "Recipe:", url: url)
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
                            showingDetail = true
                        }) {
                            
                            Image(systemName: "video")
                                .foregroundColor(.blue)
                            
                            
                            
                        }
                        .buttonStyle(.borderless)
                        .contentShape(Rectangle())
                        .sheet(isPresented: $showingDetail) {
                            YouTubeView(url: url, title: recipe.name)
                        }
                    }
                }
            }
        }
    }
    
    
    func titleView(title: String, cuisine: String) -> Text {
        var name: AttributedString {
            var result = AttributedString(title)
            result.font = .headline
            return result
        }
        
        var cuisineType: AttributedString {
            var result = AttributedString(" (\(cuisine))")
            result.font = .body
            return result
        }
        
        return Text(name + cuisineType)
    }
    
    func linkView(title: String, url: URL) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .bold()
            Link(destination: url) {
                hostDisplayString(for: url)
                    .font(.subheadline)
            }
        }
        .buttonStyle(.borderless)
        .contentShape(Rectangle())
    }
    
    func hostDisplayString(for url: URL) -> Text {
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

#Preview {
    RecipeView(recipe: RecipeListPreviewHelper.expectedRecipe(at: 4))
}
