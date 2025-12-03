//
//  View+KeyboardDismiss.swift
//  SpendLess
//
//  Extension to dismiss keyboard on tap outside text fields
//

import SwiftUI

extension View {
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil,
                from: nil,
                for: nil
            )
        }
    }
}

