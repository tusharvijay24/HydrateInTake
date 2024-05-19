//
//  VcCalender.swift
//  HydationInTake
//
//  Created by Tushar on 19/05/24.
//

import UIKit
import FSCalendar

class VcCalender: UIViewController {
    
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var goalCompleteLabel: UILabel!
    @IBOutlet weak var goalPercent: UILabel!
    @IBOutlet weak var goalPercentProgressBar: UIProgressView!
    
    var dateArray: [Date] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
        calendar.dataSource = self

        goalPercentProgressBar.layer.cornerRadius = 8
        goalPercentProgressBar.clipsToBounds = true
        goalPercentProgressBar.layer.sublayers?[1].cornerRadius = 8
        goalPercentProgressBar.subviews[1].clipsToBounds = true
        
        getDates()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCurrentDateProgress()
    }
    
    func loadCurrentDateProgress() {
        let currentDate = Date()
        retrieveDateData(forDate: currentDate)
        calendar.select(currentDate) // Optionally select the current date in the calendar
    }

    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter.string(from: date)
    }

    func retrieveDateData(forDate date: Date) {
        let records = GlassManager.sharedInstance.getHydrationRecords()
        let dateString = formatDate(date)
        
        let totalAmount = records.filter { formatDate($0.date) == dateString }
                                 .reduce(0) { $0 + $1.amount }
        
        DispatchQueue.main.async {
            self.goalLabel.text = String(format: "Consumption: %.0f glasses", totalAmount)
            let goalComplete = totalAmount >= GlassManager.sharedInstance.currentGoal
            self.goalCompleteLabel.text = goalComplete ? "Goal Complete!" : "Goal Incomplete"
            self.goalCompleteLabel.textColor = goalComplete ? UIColor(red: 0.0078, green: 0.6078, blue: 0, alpha: 1) : .red

            let percent = totalAmount / GlassManager.sharedInstance.currentGoal
            self.goalPercentProgressBar.setProgress(percent, animated: true)
            self.goalPercent.text = String(format: "Goal %.0f%% Complete", percent * 100)
        }
    }

    func getDates() {
        let records = GlassManager.sharedInstance.getHydrationRecords()
        dateArray = records.filter { $0.amount >= GlassManager.sharedInstance.currentGoal }.map { $0.date }
    }
}

// MARK: - FSCalendar
extension VcCalender: FSCalendarDelegate, FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return dateArray.contains(date) ? 1 : 0
    }

    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        retrieveDateData(forDate: date)
    }
}
