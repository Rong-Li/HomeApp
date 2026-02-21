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
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 11, weight: .semibold))
                Text(selectedRange.displayName)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .lineLimit(1)
                    .fixedSize()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundStyle(.tertiary)
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.tertiarySystemFill).opacity(0.8))
                    .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
            )
        }
    }
}

#Preview {
    TimeRangePickerView(selectedRange: .constant(.oneMonth))
}
