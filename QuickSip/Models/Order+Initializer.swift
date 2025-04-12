//
//  Order+Initializer.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import Foundation

// Additional Order extensions and initializers
extension Order {
    // Initialize with all parameters for deserialization from Firestore
    init(id: String, userId: String, drinkType: String, location: String, paymentMethod: String, additionalRequests: String?, status: String, timestamp: Date) {
        self.id = id
        self.userId = userId
        self.drinkType = drinkType
        self.location = location
        self.paymentMethod = paymentMethod
        self.additionalRequests = additionalRequests
        self.status = status
        self.timestamp = timestamp
    }
    
    // Helper for creating a test order
    static func testOrder(userId: String = "test_user") -> Order {
        return Order(
            userId: userId,
            drinkType: DrinkType.icedCoffee.rawValue,
            location: "Main Library",
            paymentMethod: "Apple Pay",
            additionalRequests: "Extra ice please"
        )
    }
} 