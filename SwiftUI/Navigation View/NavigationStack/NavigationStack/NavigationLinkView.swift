//
//  SwiftUIView.swift
//  NavigationStack
//
//  Created by Bhattacharjee, Soumil on 24/03/26.
//

import SwiftUI

struct DetailView: View {
    var body: some View {
        Text("DetailView")
    }
}

struct NavigationLinkView: View {
    var body: some View {
        NavigationStack {
             NavigationLink("Home", destination: Text("Home"))
            NavigationLink(
                destination: DetailView()) {
                    HStack(spacing: 3) {
                        Image(systemName: "heart")
                        Text("Detail View")
                    }
                    .tint(.red)
                }
        }
    }
}

#Preview {
    NavigationLinkView()
}
