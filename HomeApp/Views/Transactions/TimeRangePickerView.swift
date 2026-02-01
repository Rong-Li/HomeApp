//
//  TimeRangePickerView.swift
//  HomeApp
//
//  Family Expense Tracker
//

import SwiftUI

struct TimeRangePickerView: View {
    @Binding var selectedRange: TimeRange
    
    var body: some View {
        Menu {
            ForEach(TimeRange.allCases) { range in
                Button {
                    selectedRange = range
                } label: {
                    HStack {
                        Text(range.displayName)
                        if selectedRange == range {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(selectedRange.displayName)
                    .font(.subheadline.weight(.medium))
                Image(systemName: "chevron.down")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.secondarySystemBackground))
            .clipShape(Capsule())
        }
    }
}

#Preview {
    TimeRangePickerView(selectedRange: .constant(.oneMonth))
}
