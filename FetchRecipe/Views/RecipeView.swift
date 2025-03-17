//
//  RecipeView.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 3/17/25.
//

import SwiftUI

struct RecipeView: View {
    let recipe: Recipe

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
            .frame(width: 80, height: 80)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            
            VStack(alignment: .leading) {
                
                titleView(title: recipe.name, cuisine: recipe.cuisine)
                    .padding(.bottom, 10)

                
                if let source = recipe.sourceUrl, let url = URL(string: source) {
                    linkView(title: "Recipe:", url: url)
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
                .font(.callout)
            Link(destination: url) {
                hostDisplayString(for: url)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
    RecipeView(recipe: RecipeListPreviewHelper.expectedRecipe(at: 0))
}
