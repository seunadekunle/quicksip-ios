//
//  FirestoreEncoder.swift
//  QuickSip
//
//  Created by Seun Adekunle on 4/12/25.
//

import Foundation
import FirebaseFirestore

struct FirestoreEncoder {
    // Convert Swift Date to Firestore Timestamp
    static func dateToTimestamp(_ date: Date) -> Timestamp {
        return Timestamp(date: date)
    }
    
    // Convert Firestore Timestamp to Swift Date
    static func timestampToDate(_ timestamp: Timestamp) -> Date {
        return timestamp.dateValue()
    }
    
    // Convert dictionary with Dates to dictionary with Timestamps
    static func convertDatesInDictionary(_ dict: [String: Any]) -> [String: Any] {
        var result = [String: Any]()
        
        for (key, value) in dict {
            if let date = value as? Date {
                result[key] = Timestamp(date: date)
            } else if let nestedDict = value as? [String: Any] {
                result[key] = convertDatesInDictionary(nestedDict)
            } else if let arrayValue = value as? [Any] {
                result[key] = convertDatesInArray(arrayValue)
            } else {
                result[key] = value
            }
        }
        
        return result
    }
    
    // Convert array with potential Dates to array with Timestamps
    static func convertDatesInArray(_ array: [Any]) -> [Any] {
        return array.map { value in
            if let date = value as? Date {
                return Timestamp(date: date)
            } else if let dict = value as? [String: Any] {
                return convertDatesInDictionary(dict)
            } else if let nestedArray = value as? [Any] {
                return convertDatesInArray(nestedArray)
            } else {
                return value
            }
        }
    }
    
    // Utility function to encode a Codable object to a Firestore-compatible dictionary
    static func encode<T: Encodable>(_ value: T) throws -> [String: Any] {
        let data = try JSONEncoder().encode(value)
        let jsonObject = try JSONSerialization.jsonObject(with: data)
        
        guard let dictionary = jsonObject as? [String: Any] else {
            throw EncodingError.invalidValue(value, EncodingError.Context(
                codingPath: [], debugDescription: "Failed to encode value as Firestore dictionary"))
        }
        
        return convertDatesInDictionary(dictionary)
    }
} 