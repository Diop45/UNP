//
//  TipJarManager.swift
//  SIP SYNC
//
//  Created by AI Assistant
//

import Foundation
import Combine

/// Centralized manager for Tip Jar balance and payments
class TipJarManager: ObservableObject {
    static let shared = TipJarManager()
    
    @Published var balance: Double = 0.00
    
    private init() {
        // Load balance from UserDefaults or backend in production
        loadBalance()
    }
    
    // MARK: - Balance Management
    
    func addToBalance(_ amount: Double) {
        balance += amount
        saveBalance()
    }
    
    func deductFromBalance(_ amount: Double) -> Bool {
        guard amount > 0 else { return false }
        guard balance >= amount else { return false }
        
        balance -= amount
        saveBalance()
        return true
    }
    
    func hasSufficientBalance(for amount: Double) -> Bool {
        return balance >= amount
    }
    
    // MARK: - Payment Processing
    
    /// Process a tip payment for a bartender
    /// - Parameters:
    ///   - amount: The tip amount
    ///   - bartenderId: The bartender's ID
    /// - Returns: Result indicating success or failure with error message
    func processTip(amount: Double, bartenderId: UUID) -> PaymentResult {
        guard amount > 0 else {
            return .failure("Invalid tip amount")
        }
        
        guard hasSufficientBalance(for: amount) else {
            return .insufficientFunds(needed: amount, current: balance)
        }
        
        if deductFromBalance(amount) {
            // In production, send payment to backend here
            // Backend would then transfer funds to bartender
            return .success(amount: amount)
        }
        
        return .failure("Failed to process tip")
    }
    
    /// Process a class payment
    /// - Parameters:
    ///   - amount: The class price
    ///   - classId: The class ID
    /// - Returns: Result indicating success or failure with error message
    func processClassPayment(amount: Double, classId: UUID) -> PaymentResult {
        guard amount > 0 else {
            return .failure("Invalid class price")
        }
        
        guard hasSufficientBalance(for: amount) else {
            return .insufficientFunds(needed: amount, current: balance)
        }
        
        if deductFromBalance(amount) {
            // In production, send payment to backend here
            // Backend would unlock the class for the user
            return .success(amount: amount)
        }
        
        return .failure("Failed to process class payment")
    }
    
    /// Process a subscription payment
    /// - Parameters:
    ///   - amount: The subscription price
    ///   - subscriptionType: The type of subscription
    /// - Returns: Result indicating success or failure with error message
    func processSubscriptionPayment(amount: Double, subscriptionType: String) -> PaymentResult {
        guard amount > 0 else {
            return .failure("Invalid subscription price")
        }
        
        guard hasSufficientBalance(for: amount) else {
            return .insufficientFunds(needed: amount, current: balance)
        }
        
        if deductFromBalance(amount) {
            // In production, send payment to backend here
            // Backend would activate the subscription
            return .success(amount: amount)
        }
        
        return .failure("Failed to process subscription payment")
    }
    
    // MARK: - Persistence
    
    private func saveBalance() {
        UserDefaults.standard.set(balance, forKey: "tipJarBalance")
    }
    
    private func loadBalance() {
        balance = UserDefaults.standard.double(forKey: "tipJarBalance")
    }
}

// MARK: - Payment Result

enum PaymentResult {
    case success(amount: Double)
    case insufficientFunds(needed: Double, current: Double)
    case failure(String)
    
    var isSuccess: Bool {
        if case .success = self {
            return true
        }
        return false
    }
    
    var errorMessage: String? {
        switch self {
        case .success:
            return nil
        case .insufficientFunds(let needed, let current):
            let shortfall = needed - current
            return "Insufficient funds. You need $\(String(format: "%.2f", shortfall)) more. Add funds to your Tip Jar?"
        case .failure(let message):
            return message
        }
    }
}

