//
//  MailerLiteService.swift
//  SpendLess
//
//  Service for submitting emails to MailerLite for lead magnet
//

import Foundation

enum EmailSubmissionError: LocalizedError {
    case invalidEmail
    case networkError
    case serverError
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address"
        case .networkError:
            return "Network error. We'll send your guide when you're back online."
        case .serverError:
            return "Something went wrong. Please try again."
        case .unknown:
            return "An unexpected error occurred."
        }
    }
}

struct EmailResponse: Codable {
    let success: Bool
    let error: String?
}

@Observable
final class MailerLiteService {
    static let shared = MailerLiteService()
    
    /// Cloudflare Worker endpoint - proxies requests to MailerLite API
    private let workerURL: String
    
    /// MailerLite Group ID for app subscribers
    private let groupId = "173692205558400340"
    
    private init() {
        // Get from Constants - Cloudflare Worker endpoint
        self.workerURL = AppConstants.mailerLiteWorkerURL
    }
    
    /// Submit email to MailerLite via Cloudflare Worker for lead magnet PDF delivery
    /// - Parameters:
    ///   - email: User's email address
    ///   - optedIntoMarketing: Whether user opted into marketing emails
    ///   - source: Where the email was collected from
    /// - Returns: Success status
    func submitEmailForPDF(
        email: String,
        optedIntoMarketing: Bool,
        source: LeadMagnetSource
    ) async throws {
        // Validate email format
        guard isValidEmail(email) else {
            throw EmailSubmissionError.invalidEmail
        }
        
        guard let url = URL(string: workerURL) else {
            throw EmailSubmissionError.serverError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Build request body matching Cloudflare Worker interface
        let body: [String: Any] = [
            "email": email,
            "group_id": groupId,
            "source": source.rawValue,
            "marketing_opted_in": optedIntoMarketing
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw EmailSubmissionError.serverError
            }
            
            // Check HTTP status code
            guard httpResponse.statusCode == 200 else {
                print("❌ MailerLite Worker error: Status \(httpResponse.statusCode)")
                throw EmailSubmissionError.serverError
            }
            
            // Decode and check response
            let result = try JSONDecoder().decode(EmailResponse.self, from: data)
            if !result.success {
                print("❌ MailerLite Worker returned error: \(result.error ?? "Unknown error")")
                throw EmailSubmissionError.serverError
            }
        } catch let error as EmailSubmissionError {
            throw error
        } catch let decodingError as DecodingError {
            print("❌ Failed to decode response: \(decodingError)")
            throw EmailSubmissionError.serverError
        } catch {
            // Network errors
            if (error as NSError).code == NSURLErrorNotConnectedToInternet ||
               (error as NSError).code == NSURLErrorNetworkConnectionLost {
                throw EmailSubmissionError.networkError
            }
            print("❌ Email submission error: \(error)")
            throw EmailSubmissionError.networkError
        }
    }
    
    /// Validate email format
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}

// MARK: - Offline Queue Support

struct PendingEmailSubmission: Codable {
    let email: String
    let optedIntoMarketing: Bool
    let source: LeadMagnetSource
    let queuedAt: Date
}

final class PendingSubmissionsStore {
    static let shared = PendingSubmissionsStore()
    
    private let key = "pendingEmailSubmissions"
    
    private init() {}
    
    func add(_ submission: PendingEmailSubmission) {
        var pending = all()
        pending.append(submission)
        
        if let encoded = try? JSONEncoder().encode(pending) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func all() -> [PendingEmailSubmission] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let decoded = try? JSONDecoder().decode([PendingEmailSubmission].self, from: data) else {
            return []
        }
        return decoded
    }
    
    func remove(_ submission: PendingEmailSubmission) {
        var pending = all()
        pending.removeAll { $0.email == submission.email && $0.queuedAt == submission.queuedAt }
        
        if let encoded = try? JSONEncoder().encode(pending) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func clear() {
        UserDefaults.standard.removeObject(forKey: key)
    }
}
