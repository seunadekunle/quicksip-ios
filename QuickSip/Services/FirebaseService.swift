//
//  FirebaseService.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import Foundation
import Firebase
import FirebaseFirestore
import Combine

class FirebaseService {
    static let shared = FirebaseService()
    
    private let db = Firestore.firestore()
    private let usersCollection = "users"
    private let ordersCollection = "orders"
    
    private init() {}
    
    // MARK: - User Operations
    
    func createUser(name: String, email: String, userId: String, completion: @escaping (Result<User, Error>) -> Void) {
        let newUser = User(id: userId, name: name, email: email)
        
        db.collection(usersCollection).document(userId).setData(newUser.toDictionary()) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(newUser))
        }
    }
    
    func getUser(userId: String, completion: @escaping (Result<User, Error>) -> Void) {
        db.collection(usersCollection).document(userId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists,
                  let user = User(document: snapshot) else {
                completion(.failure(NSError(domain: "FirebaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "User not found"])))
                return
            }
            
            completion(.success(user))
        }
    }
    
    func updateUser(_ user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(usersCollection).document(user.id).setData(user.toDictionary(), merge: true) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(()))
        }
    }
    
    // MARK: - Order Operations
    
    func createOrder(order: Order, completion: @escaping (Result<Order, Error>) -> Void) {
        let batch = db.batch()
        
        // Add to orders collection
        let orderRef = db.collection(ordersCollection).document(order.id)
        batch.setData(order.toDictionary(), forDocument: orderRef)
        
        // Add to user's order history
        let userRef = db.collection(usersCollection).document(order.userId)
        batch.updateData(["orderHistory": FieldValue.arrayUnion([order.toDictionary()])], forDocument: userRef)
        
        // Add to Realtime Database for status updates (implement in future task)
        
        batch.commit { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            completion(.success(order))
        }
    }
    
    func getOrder(orderId: String, completion: @escaping (Result<Order, Error>) -> Void) {
        db.collection(ordersCollection).document(orderId).getDocument { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot, snapshot.exists,
                  let order = Order(document: snapshot) else {
                completion(.failure(NSError(domain: "FirebaseService", code: 404, userInfo: [NSLocalizedDescriptionKey: "Order not found"])))
                return
            }
            
            completion(.success(order))
        }
    }
    
    func updateOrderStatus(orderId: String, status: Order.Status, completion: @escaping (Result<Void, Error>) -> Void) {
        db.collection(ordersCollection).document(orderId).updateData(["status": status.rawValue]) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Update in user's order history (would require more complex operations in production)
            
            completion(.success(()))
        }
    }
    
    func getUserOrders(userId: String, completion: @escaping (Result<[Order], Error>) -> Void) {
        db.collection(ordersCollection)
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
            .getDocuments { snapshot, error in
                if let error = error {
                    completion(.failure(error))
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    completion(.success([]))
                    return
                }
                
                let orders = documents.compactMap { Order(document: $0) }
                completion(.success(orders))
            }
    }
    
    // MARK: - Firestore Document Conversion Helpers
    
    func documentToOrder(_ document: DocumentSnapshot) -> Order? {
        return Order(document: document)
    }
    
    func documentToUser(_ document: DocumentSnapshot) -> User? {
        return User(document: document)
    }
} 