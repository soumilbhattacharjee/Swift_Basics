//
//  ContentView.swift
//  DataPassing
//
//  Created by Bhattacharjee, Soumil on 03/06/26.
//

import SwiftUI

struct ContentView: View {
    @State private var items: [String] = ["Apple", "Banana", "Orange"]
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 20) {
                Text("Main View - Initial Data")
                    .font(.title2)
                    .fontWeight(.bold)
                
                List(items, id: \.self) { item in
                    Text(item)
                }
                .contentMargins(.top, 20)
                NavigationLink(destination: SecondView(items: $items)) {
                    HStack {
                        Image(systemName: "arrow.right")
                        Text("Go to Next View")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(.horizontal)
            }
            .padding()
            .navigationTitle("Data Passing Demo")
        }
    }
}

#Preview {
    ContentView()
}
