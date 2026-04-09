//
//  SharedStyles.swift
//  SIP SYNC
//
//  Created by Diop Shumake on 10/23/25.
//

import SwiftUI

// MARK: - Custom Text Field Style (theme-aware)
struct CustomTextFieldStyle: TextFieldStyle {
    @EnvironmentObject var theme: AppTheme
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(theme.inputBackground)
            .cornerRadius(12)
            .foregroundColor(theme.textPrimary)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(theme.borderColor, lineWidth: 1)
            )
    }
}

