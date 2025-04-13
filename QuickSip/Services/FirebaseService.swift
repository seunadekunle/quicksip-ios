//
//  FirebaseService.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseDatabase
import Combine

class FirebaseService {
    static let shared = FirebaseService()
    
    private let db: Firestore
    private let rtdb: DatabaseReference
    private let usersCollection = "users"
    private let ordersCollection = "orders"
    
    private init() {
        // Configure the Realtime Database persistence before creating any references
        Database.database().isPersistenceEnabled = true
        
        // Initialize database references after configuring persistence
        self.db = Firestore.firestore()
        self.rtdb = Database.database().reference()
    }
    
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
        
        // Add to Realtime Database for status updates
        let orderData: [String: Any] = [
            "status": order.status,
            "userId": order.userId,
            "timestamp": ServerValue.timestamp()
        ]
        rtdb.child("orders").child(order.id).setValue(orderData)
        
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
        // Update in Firestore for persistence
        db.collection(ordersCollection).document(orderId).updateData(["status": status.rawValue]) { error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Update in Realtime Database for real-time updates is now handled by StatusUpdateService
            
            completion(.success(()))
        }
    }
    
    func getUserOrders(userId: String, completion: @escaping (Result<[Order], Error>) -> Void) {
        // Query using the composite index (userId + timestamp)
        let ordersRef = db.collection(ordersCollection)
            .whereField("userId", isEqualTo: userId)
            .order(by: "timestamp", descending: true)
        
        ordersRef
            .addSnapshotListener { querySnapshot, error in
                // If we get an index error, fall back to querying without the sort
                // This can happen while the index is being built
                if let error = error, error.localizedDescription.contains("The query requires an index") {
                    print("Index not ready yet, using fallback query")
                    // Fallback query without order by
                    self.db.collection(self.ordersCollection)
                        .whereField("userId", isEqualTo: userId)
                        .getDocuments { (snapshot, error) in
                            if let error = error {
                                completion(.failure(error))
                                return
                            }
                            
                            guard let documents = snapshot?.documents else {
                                completion(.success([]))
                                return
                            }
                            
                            let orders = documents.compactMap { Order(document: $0) }
                            // Sort in memory since we don't have the index yet
                            let sortedOrders = orders.sorted { $0.timestamp > $1.timestamp }
                            completion(.success(sortedOrders))
                        }
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error?.localizedDescription ?? "Unknown error")")
                    completion(.failure(error ?? NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error fetching documents"])))
                    return
                }
                
                let orders = documents.compactMap { document -> Order? in
                    return Order(document: document)
                }
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