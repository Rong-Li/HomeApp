//
//  CategoryPickerView.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct CategoryPickerView: View {
    @Binding var selectedCategory: Category
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Category")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
            
            Picker("Category", selection: $selectedCategory) {
                ForEach(Category.allCases) { category in
                    HStack(spacing: 8) {
                        Image(systemName: category.icon)
                            .foregroundStyle(category.color)
                        Text(category.displayName)
                    }
                    .tag(category)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 120)
            .sensoryFeedback(.selection, trigger: selectedCategory)
        }
    }
}

#Preview {
    CategoryPickerView(selectedCategory: .constant(.groceries))
}
