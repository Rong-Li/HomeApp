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
            HStack(spacing: 5) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 12, weight: .semibold))
                Text(selectedRange.displayName)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(.tertiary)
            }
            .foregroundStyle(.primary)
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(Color(.tertiarySystemFill))
            )
        }
    }
}

#Preview {
    TimeRangePickerView(selectedRange: .constant(.oneMonth))
}
