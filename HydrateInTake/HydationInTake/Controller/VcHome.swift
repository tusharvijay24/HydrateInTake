//
//  VcHome.swift
//  HydationInTake
//
//  Created by Tushar on 19/05/24.
//
import UIKit

class VcHome: UIViewController {

    @IBOutlet weak var currentLabel: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    @IBOutlet weak var percentLabel: UILabel!
    @IBOutlet weak var waterBar: UIProgressView!
    @IBOutlet weak var glassStepper: UIStepper!
    
    var current: Float = 0.0
    var percent: Float = 0.0
    var goal: Float = GlassManager.sharedInstance.currentGoal
    var date = Date()
    var currentDateString: String = ""
    var goalComplete: Bool = false
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateSettings), name: NSNotification.Name("SettingsChanged"), object: nil)
        
        date = Date()
        let df = DateFormatter()
        df.dateFormat = "MM-dd-yyyy"
        currentDateString = df.string(from: date)
        loadGoalData()
        loadMainData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        waterBar.transform = waterBar.transform.rotated(by: 270 * .pi / 180)
        waterBar.transform = waterBar.transform.scaledBy(x: 1.8, y: 100)
        glassStepper.maximumValue = Double(goal)
    }
    
    @IBAction func glassesStepper(_ sender: UIStepper) {
        if Float(sender.value) > goal {
            sender.value = Double(goal)
        }
        
        current = Float(sender.value)
        
        currentLabel.text = String(format: "%.0f/%.0f", current, goal)
            
        percent = current / goal
        waterBar.setProgress(percent, animated: true)
        
        if percent * 100 < 1000 {
            percentLabel.text = String(format: "%.0f", percent * 100) + "%"
        } else {
            percentLabel.text = "999%"
        }
        
        if percent >= 1.0 {
            goalComplete = true
        } else {
            goalComplete = false
        }
        
        GlassManager.sharedInstance.updateTodayHydrationRecord(amount: current)
    }
    
    func loadGoalData() {
        goal = GlassManager.sharedInstance.currentGoal
        glassStepper.maximumValue = Double(goal)
        setGoalItems(goal: goal, currentValue: current)
    }
    
    func loadMainData() {
        current = GlassManager.sharedInstance.getTodayIntake()
        glassStepper.value = Double(current)
        setGoalItems(goal: goal, currentValue: current)
    }
    
    @objc func updateSettings() {
        goal = GlassManager.sharedInstance.currentGoal
        glassStepper.maximumValue = Double(goal)
        setGoalItems(goal: goal, currentValue: current)
    }
}

extension VcHome {
    func setGoalItems(goal: Float, currentValue: Float) {
        percent = currentValue / goal
        waterBar.setProgress(percent, animated: true)
        glassStepper.value = Double(currentValue)
        
        if percent * 100 < 1000 {
            percentLabel.text = String(format: "%.0f", percent * 100) + "%"
        } else {
            percentLabel.text = "999%"
        }
        
        goalLabel.text = String(format: "Current Daily Goal: %.0f glasses", goal)
        currentLabel.text = String(format: "%.0f/%.0f", currentValue, goal)
    }
}
