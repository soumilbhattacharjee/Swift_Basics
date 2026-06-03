//
//  SwiftUIView.swift
//  NavigationStack
//
//  Created by Bhattacharjee, Soumil on 24/03/26.
//

import SwiftUI

private enum Route: Hashable {
    case detail
    case next
}

struct DetailView: View {
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack(spacing: 16) {
            NavigationLink("NextView", value: Route.next)
            // Pop back to previous view in the navigation stack
            Button("Back") {
                if !path.isEmpty {
                    path.removeLast()
                }
            }
            .buttonStyle(.bordered)
        }
        .navigationTitle("Detail View")
    }
}

// Adding custom Navigation back btn and back to root View
struct NextView: View {
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack(spacing: 16) {
            Button("Back") {
                // Clears the stack to return to the root view.
                path = NavigationPath()
                // If we want to navigate to a perticular view under the Navigation stack we can do like this ->
                path.append(Route.detail)
            }
            
            Button("Back to Root") {
                // Clears the stack to return to the root view.
                path = NavigationPath()
                /*
                 But path = NavigationPath() will clear the stack and navigate to the root view.
                 So then path.append(Route.detail) will navigate like this Root View -> Detail View
                 If we need (root -> detail -> next) we can like this -
                 path = NavigationPath()
                 path.append(Route.detail)
                 path.append(Route.next)
                 */
            }
            .buttonStyle(.borderedProminent)
        }
        .navigationTitle("Next View")
    }
}

struct NavigationLinkView: View {
    @State private var path = NavigationPath() // NavigationPath is an array
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 16) {
                // Default Navigation Button
                NavigationLink("Home", destination: Text("Home"))
                // Custom Navigation Button
                NavigationLink(value: Route.detail) {
                    HStack(spacing: 3) {
                        Image(systemName: "heart")
                        Text("Detail View")
                    }
                    .tint(.red)
                }
            } // Checking the navigation destination for the enum Route
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .detail:
                    DetailView(path: $path)
                case .next:
                    NextView(path: $path)
                }
            }
        }
    }
}

#Preview {
    NavigationLinkView()
}
