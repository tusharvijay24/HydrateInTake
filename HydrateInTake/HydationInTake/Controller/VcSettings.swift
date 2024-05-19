//
//  VcSettings.swift
//  HydationInTake
//
//  Created by Tushar on 19/05/24.
//

import UIKit
import UserNotifications

class VcSettings: UIViewController {
    @IBOutlet weak var glassSizePicker: UIPickerView!
    @IBOutlet weak var setGoalLabel: UILabel!
    @IBOutlet weak var setGoalStepper: UIStepper!
    @IBOutlet weak var notificationSwitch: UISwitch!
    
    let center = UNUserNotificationCenter.current()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        glassSizePicker.dataSource = self
        glassSizePicker.delegate = self

        loadData()
        createNotification()
    }
    
    @IBAction func setGoal(_ sender: UIStepper) {
        setGoalLabel.text = "\(Int(sender.value)) glasses /day"
        GlassManager.sharedInstance.currentGoal = Float(sender.value)
    }
    
    typealias AlertMethodHandler = () -> Void
    typealias AlertMethodHandlerNo = () -> Void
    
    func presentAlert(title titleString: String, message messageString: String, alertYesClicked: @escaping AlertMethodHandler) {
        let alert = UIAlertController(title: titleString, message: messageString, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "No", style: .destructive, handler: { action in
            DispatchQueue.main.async {
                self.notificationSwitch.isOn = true
            }
        }))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { action in
            alertYesClicked()
        }))

        self.present(alert, animated: true)
    }
    
    @IBAction func notificationSwitchChanged(_ sender: UISwitch) {
        if sender.isOn {
            presentAlert(title: "Are you sure you want to turn on daily notifications?", message: "The app will send you a notification daily at 6pm to remind you to drink water") {
                self.authorizeNotifications()
                GlassManager.sharedInstance.notificationEnabled = true
            }
        } else {
            presentAlert(title: "Disable notifications?", message: "You will no longer receive daily reminders to drink water.") {
                self.center.removeAllPendingNotificationRequests()
                GlassManager.sharedInstance.notificationEnabled = false
            }
        }
    }
    
    func loadData() {
        let goal = GlassManager.sharedInstance.currentGoal
        setGoalLabel.text = "\(Int(goal)) glasses /day"
        setGoalStepper.value = Double(goal)
        notificationSwitch.isOn = GlassManager.sharedInstance.notificationEnabled
    }
    
    @IBAction func applyChanges(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name("SettingsChanged"), object: nil)
        self.dismiss(animated: true, completion: nil)
    }
}

// MARK: - Notification initialization
extension VcSettings {
    func createNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Daily Hydrate Reminder"
        content.body = "Don't forget to log your consumption and complete your daily goal!"
        
        var dateComponents = DateComponents()
        dateComponents.calendar = Calendar.current
        dateComponents.hour = 18
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let uuid = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        
        center.add(request, withCompletionHandler: nil)
    }
    
    func authorizeNotifications() {
        center.requestAuthorization(options: [.alert, .sound], completionHandler: { (granted, err) in
            if !granted {
                DispatchQueue.main.async {
                    let notifDenied = UIAlertController(title: "Notifications not allowed on this device", message: "If you change your mind later, you can change the notification preferences from the system settings for the app.", preferredStyle: .alert)
                    notifDenied.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
                    self.present(notifDenied, animated: true)
                }
            }
        })
    }
}

extension VcSettings: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return GlassManager.sharedInstance.glassSizes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return GlassManager.sharedInstance.glassSizes[row] + " oz"
    }
}
