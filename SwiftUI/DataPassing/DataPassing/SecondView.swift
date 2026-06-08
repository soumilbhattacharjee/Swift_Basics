//
//  SecondView.swift
//  DataPassing
//
//  Created by Bhattacharjee, Soumil on 03/06/26.
//

import SwiftUI

struct SecondView: View {
    @Binding var items: [String]
    @State private var combinedItems: [String] = []
    @State private var newItemText: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Second View - Adding More Data")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Data from Main View:")
                .font(.headline)
            
            List(items, id: \.self) { item in
                Text(item)
            }
            .frame(height: 120)
            
            Text("New Data Added:")
                .font(.headline)
            
            HStack {
                TextField("Enter item", text: $newItemText)
                    .textFieldStyle(.roundedBorder)
                Button(action: addMoreItems) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                }
            }
            .padding(.horizontal)
            
            if !combinedItems.isEmpty {
                List(combinedItems, id: \.self) { item in
                    Text(item)
                }
            }
            
            NavigationLink(destination: ThirdView(allItems: items + combinedItems)) {
                HStack {
                    Image(systemName: "arrow.right")
                    Text("Go to Final View")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .padding(.horizontal)
            Spacer()
        }
        .task {
            print("Task")
            combinedItems = ["Grape"]
        }
        .padding()
        .navigationTitle("Second View")
        .onAppear {
            print("onAppear")
        }
    }
    
    private func addMoreItems() {
        if !newItemText.isEmpty {
            combinedItems.append(newItemText)
            newItemText = ""
        }
    }
}

#Preview {
    NavigationStack {
        SecondView(items: .constant(["Apple", "Banana", "Orange"]))
    }
}
