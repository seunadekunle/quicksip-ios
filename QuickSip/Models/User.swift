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
    init(id: String, name: String, email: String, orderHistory: [Order] = []) {
        self.id = id
        self.name = name
        self.email = email
        self.orderHistory = orderHistory
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
                if let id = orderData["id"] as? String,
                   let userId = orderData["userId"] as? String,
                   let drinkType = orderData["drinkType"] as? String,
                   let location = orderData["location"] as? String,
                   let paymentMethod = orderData["paymentMethod"] as? String,
                   let status = orderData["status"] as? String,
                   let timestamp = orderData["timestamp"] as? Timestamp {
                    
                    let size = orderData["size"] as? String ?? "Medium"
                    let milk = orderData["milk"] as? String ?? ""
                    let flavor = orderData["flavor"] as? String ?? ""
                    let isIced = orderData["isIced"] as? Bool ?? true
                    let price = orderData["price"] as? Double ?? 4.99
                    
                    let order = Order(
                        userId: userId,
                        drinkType: drinkType,
                        size: size,
                        milk: milk,
                        flavor: flavor,
                        isIced: isIced,
                        price: price,
                        location: location,
                        paymentMethod: paymentMethod,
                        additionalRequests: orderData["additionalRequests"] as? String
                    )
                    
                    orders.append(order)
                }
            }
            
            self.orderHistory = orders.sorted(by: { $0.timestamp > $1.timestamp }) // Sort by newest first
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
            email: self.email,
            orderHistory: updatedOrderHistory
        )
    }
    
    // Update orders with cloud data
    func updatingOrders(_ orders: [Order]) -> User {
        // Create a dictionary of existing orders by ID for quick lookup
        let existingOrdersDict = Dictionary(uniqueKeysWithValues: self.orderHistory.map { ($0.id, $0) })
        
        // Merge new orders with existing ones, preserving local data if not updated in cloud
        var updatedOrders = orders.map { cloudOrder -> Order in
            if let existingOrder = existingOrdersDict[cloudOrder.id] {
                // If order exists locally and cloud status is not newer, keep local version
                if let cloudTimestamp = cloudOrder.timestamp as? Timestamp,
                   let localTimestamp = existingOrder.timestamp as? Timestamp,
                   cloudTimestamp.seconds <= localTimestamp.seconds {
                    return existingOrder
                }
            }
            return cloudOrder
        }
        
        // Sort by newest first
        updatedOrders.sort(by: { $0.timestamp > $1.timestamp })
        
        return User(
            id: self.id,
            name: self.name,
            email: self.email,
            orderHistory: updatedOrders
        )
    }
} 
