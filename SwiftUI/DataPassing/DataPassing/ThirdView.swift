//
//  ThirdView.swift
//  DataPassing
//
//  Created by Bhattacharjee, Soumil on 03/06/26.
//

import SwiftUI

struct ThirdView: View {
    let allItems: [String]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Final View - All Combined Data")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Total Items: \(allItems.count)")
                .font(.headline)
                .foregroundColor(.blue)
            
            List(allItems, id: \.self) { item in
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text(item)
                }
            }
            
            VStack(spacing: 12) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "arrow.left")
                        Text("Back to Main")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Final View")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        ThirdView(allItems: ["Apple", "Banana", "Orange", "Grape", "Mango"])
    }
}
