//
//  GlassManager.swift
//  HydationInTake
//
//  Created by Tushar on 19/05/24.
//

import Foundation

class GlassManager {
    // Singleton instance
    static let sharedInstance = GlassManager()
    
    var currentGoal: Float = 8
    let glassSizes: [String] = ["4", "6", "8", "9", "10", "12", "14", "16"]
    private var hydrationRecords: [HydrationModel] = []
    var notificationEnabled: Bool = false
    
    private init() {}
    
    // Add a new hydration record
    func addHydrationRecord(amount: Float) {
        let record = HydrationModel(date: Date(), amount: amount)
        hydrationRecords.append(record)
    }
    
    // Update hydration record for today
    func updateTodayHydrationRecord(amount: Float) {
        let today = Calendar.current.startOfDay(for: Date())
        if let index = hydrationRecords.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            hydrationRecords[index].amount = amount
        } else {
            addHydrationRecord(amount: amount)
        }
    }
    
    // Get all hydration records
    func getHydrationRecords() -> [HydrationModel] {
        return hydrationRecords
    }
    
    // Get total water intake for the current day
    func getTodayIntake() -> Float {
        let today = Calendar.current.startOfDay(for: Date())
        return hydrationRecords
            .filter { Calendar.current.isDate($0.date, inSameDayAs: today) }
            .reduce(0) { $0 + $1.amount }
    }
    
    // Remove a specific hydration record
    func removeHydrationRecord(at index: Int) {
        if index >= 0 && index < hydrationRecords.count {
            hydrationRecords.remove(at: index)
        }
    }
}
