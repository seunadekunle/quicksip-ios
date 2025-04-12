//
//  Order.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import Foundation
import FirebaseFirestore

struct Order: Codable, Identifiable {
    let id: String
    let userId: String
    let drinkType: String // "Iced Coffee" or "Iced Matcha"
    let location: String
    let paymentMethod: String
    let additionalRequests: String?
    let status: String // "Placed", "In Progress", "Delivered"
    let timestamp: Date
    
    enum DrinkType: String, Codable {
        case icedCoffee = "Iced Coffee"
        case icedMatcha = "Iced Matcha"
    }
    
    enum Status: String, Codable {
        case placed = "Placed"
        case inProgress = "In Progress"
        case delivered = "Delivered"
        case cancelled = "Cancelled"
    }
    
    // Convenience initializer for creating a new order
    init(userId: String, drinkType: String, location: String, paymentMethod: String, additionalRequests: String? = nil) {
        self.id = UUID().uuidString
        self.userId = userId
        self.drinkType = drinkType
        self.location = location
        self.paymentMethod = paymentMethod
        self.additionalRequests = additionalRequests
        self.status = Status.placed.rawValue
        self.timestamp = Date()
    }
    
    // Firestore conversion
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let userId = data["userId"] as? String,
              let drinkType = data["drinkType"] as? String,
              let location = data["location"] as? String,
              let paymentMethod = data["paymentMethod"] as? String,
              let status = data["status"] as? String,
              let timestamp = data["timestamp"] as? Timestamp else {
            return nil
        }
        
        self.id = document.documentID
        self.userId = userId
        self.drinkType = drinkType
        self.location = location
        self.paymentMethod = paymentMethod
        self.additionalRequests = data["additionalRequests"] as? String
        self.status = status
        self.timestamp = timestamp.dateValue()
    }
    
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "userId": userId,
            "drinkType": drinkType,
            "location": location,
            "paymentMethod": paymentMethod,
            "status": status,
            "timestamp": Timestamp(date: timestamp)
        ]
        
        if let additionalRequests = additionalRequests {
            dict["additionalRequests"] = additionalRequests
        }
        
        return dict
    }
} 