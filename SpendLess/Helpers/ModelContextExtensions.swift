//
//  ModelContextExtensions.swift
//  SpendLess
//
//  Safe save helpers for ModelContext with error handling
//

import Foundation
import SwiftData

extension ModelContext {
    /// Safely saves the context with error handling
    /// Returns true if save succeeded, false otherwise
    /// Logs errors for debugging
    @discardableResult
    func saveSafely() -> Bool {
        do {
            try self.save()
            return true
        } catch {
            print("❌ ModelContext save failed: \(error)")
            // TODO: Consider showing user-friendly error alert in production
            // For now, we log the error to help debug issues
            return false
        }
    }
    
    /// Saves the context and throws if it fails
    /// Use this when you need to handle errors at the call site
    func saveOrThrow() throws {
        try self.save()
    }
}
