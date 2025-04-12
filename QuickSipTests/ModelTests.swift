//
//  ModelTests.swift
//  QuickSipTests
//
//  Created by Seun Adekunle on 4/12/25.
//

import XCTest
@testable import QuickSip

final class ModelTests: XCTestCase {
    
    func testOrderInitialization() {
        // Test basic initializer
        let order = Order(
            userId: "test_user_123",
            drinkType: "Iced Coffee",
            location: "Library",
            paymentMethod: "Apple Pay",
            additionalRequests: "Extra ice"
        )
        
        XCTAssertEqual(order.userId, "test_user_123")
        XCTAssertEqual(order.drinkType, "Iced Coffee")
        XCTAssertEqual(order.location, "Library")
        XCTAssertEqual(order.paymentMethod, "Apple Pay")
        XCTAssertEqual(order.additionalRequests, "Extra ice")
        XCTAssertEqual(order.status, Order.Status.placed.rawValue)
        
        // Test full initializer
        let date = Date()
        let fullOrder = Order(
            id: "order_123",
            userId: "test_user_123",
            drinkType: "Iced Matcha",
            location: "Dorm",
            paymentMethod: "Credit Card",
            additionalRequests: nil,
            status: Order.Status.delivered.rawValue,
            timestamp: date
        )
        
        XCTAssertEqual(fullOrder.id, "order_123")
        XCTAssertEqual(fullOrder.drinkType, "Iced Matcha")
        XCTAssertNil(fullOrder.additionalRequests)
        XCTAssertEqual(fullOrder.status, Order.Status.delivered.rawValue)
        XCTAssertEqual(fullOrder.timestamp, date)
    }
    
    func testUserInitialization() {
        // Test basic initializer
        let user = User(
            id: "user_123",
            name: "Test User",
            email: "test@example.com"
        )
        
        XCTAssertEqual(user.id, "user_123")
        XCTAssertEqual(user.name, "Test User")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertTrue(user.orderHistory.isEmpty)
        
        // Test with order history
        let order = Order.testOrder(userId: "user_123")
        let userWithOrder = user.addingOrder(order)
        
        XCTAssertEqual(userWithOrder.orderHistory.count, 1)
        XCTAssertEqual(userWithOrder.orderHistory[0].userId, "user_123")
    }
    
    func testOrderToDictionary() {
        let order = Order.testOrder()
        let dict = order.toDictionary()
        
        XCTAssertEqual(dict["userId"] as? String, "test_user")
        XCTAssertEqual(dict["drinkType"] as? String, "Iced Coffee")
        XCTAssertEqual(dict["location"] as? String, "Main Library")
        XCTAssertEqual(dict["paymentMethod"] as? String, "Apple Pay")
        XCTAssertEqual(dict["additionalRequests"] as? String, "Extra ice please")
        XCTAssertEqual(dict["status"] as? String, Order.Status.placed.rawValue)
    }
    
    func testUserToDictionary() {
        let user = User(
            id: "user_123",
            name: "Test User",
            email: "test@example.com"
        )
        
        let dict = user.toDictionary()
        
        XCTAssertEqual(dict["name"] as? String, "Test User")
        XCTAssertEqual(dict["email"] as? String, "test@example.com")
        
        let orderHistoryArray = dict["orderHistory"] as? [[String: Any]]
        XCTAssertNotNil(orderHistoryArray)
        XCTAssertTrue(orderHistoryArray!.isEmpty)
    }
} 