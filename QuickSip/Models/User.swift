//
//  User.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import Foundation
import FirebaseFirestore

struct User: Codable, Identifiable {
    let id: String
    let name: String
    let email: String
    let orderHistory: [Order]
    
    // Convenience initializer for creating a new user
    init(id: String, name: String, email: String) {
        self.id = id
        self.name = name
        self.email = email
        self.orderHistory = []
    }
    
    // Firestore conversion
    init?(document: DocumentSnapshot) {
        guard let data = document.data(),
              let name = data["name"] as? String,
              let email = data["email"] as? String else {
            return nil
        }
        
        self.id = document.documentID
        self.name = name
        self.email = email
        
        // Handle order history
        if let orderHistoryData = data["orderHistory"] as? [[String: Any]] {
            var orders: [Order] = []
            
            for orderData in orderHistoryData {
                if let orderDict = orderData as? [String: Any],
                   let id = orderDict["id"] as? String,
                   let userId = orderDict["userId"] as? String,
                   let drinkType = orderDict["drinkType"] as? String,
                   let location = orderDict["location"] as? String,
                   let paymentMethod = orderDict["paymentMethod"] as? String,
                   let status = orderDict["status"] as? String,
                   let timestamp = orderDict["timestamp"] as? Timestamp {
                    
                    let order = Order(
                        id: id,
                        userId: userId,
                        drinkType: drinkType,
                        location: location,
                        paymentMethod: paymentMethod,
                        additionalRequests: orderDict["additionalRequests"] as? String,
                        status: status,
                        timestamp: timestamp.dateValue()
                    )
                    
                    orders.append(order)
                }
            }
            
            self.orderHistory = orders
        } else {
            self.orderHistory = []
        }
    }
    
    func toDictionary() -> [String: Any] {
        let orderHistoryArray = orderHistory.map { $0.toDictionary() }
        
        return [
            "name": name,
            "email": email,
            "orderHistory": orderHistoryArray
        ]
    }
    
    // For adding an order to history
    func addingOrder(_ order: Order) -> User {
        var updatedOrderHistory = self.orderHistory
        updatedOrderHistory.append(order)
        
        return User(
            id: self.id,
            name: self.name,
            email: self.email
        )
    }
} 
