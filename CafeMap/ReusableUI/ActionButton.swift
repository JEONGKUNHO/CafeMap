//
//  ActionButton.swift
//  CafeMap
//
//  Created by 정건호 on 4/19/25.
//

import SwiftUI

struct ActionButton: View {
    let icon: String
    let text: String
    let color: Color
    let isFullWidth: Bool
    let action: () -> Void
    
    init(icon: String, text: String, color: Color, isFullWidth: Bool = false, action: @escaping () -> Void) {
        self.icon = icon
        self.text = text
        self.color = color
        self.isFullWidth = isFullWidth
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                Text(text)
            }
            .frame(maxWidth: isFullWidth ? .infinity : nil)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(color.opacity(0.1))
            .foregroundColor(color)
            .cornerRadius(8)
        }
    }
}

