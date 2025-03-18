//
//  ErrorView.swift
//  FetchRecipe
//
//  Created by Matt Hunt on 3/17/25.
//

import SwiftUI

struct CompositionErrorView: View {
    let error: Error
    let retryAction: () -> Void
    
    init(error: Error, retryAction: @escaping () -> Void) {
        self.error = error
        self.retryAction = retryAction
    }
    
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            Rectangle().fill(.blue.gradient).ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(systemName: "exclamationmark.bubble")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("D'oh!")
                    .font(.title)
                
                Text(error.localizedDescription)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Button("Retry", systemImage: "arrow.clockwise", action: retryAction)
                    .padding()
                    .background(.green.gradient)
                    .tint(.primary)
                    .clipShape(.capsule)
            }
            .padding()
        }
    }
}


#Preview {
    CompositionErrorView(error: NSError(domain: "Failed to do something important -", code: 0)) {
        print("Retry")
    }
}
