//
//  EkoDateFormatter.swift
//  TestMigration
//
//  Created by Nontapat Siengsanor on 5/4/2564 BE.
//

import UIKit

extension Date {
    var yearsFromNow: Int {
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year!
    }
    var monthsFromNow: Int {
        return Calendar.current.dateComponents([.month], from: self, to: Date()).month!
    }
    var weeksFromNow: Int {
        return Calendar.current.dateComponents([.weekOfYear], from: self, to: Date()).weekOfYear!
    }
    var daysFromNow: Int {
        return Calendar.current.dateComponents([.day], from: self, to: Date()).day!
    }
    var isInYesterday: Bool {
        return Calendar.current.isDateInYesterday(self)
    }
    var hoursFromNow: Int {
        return Calendar.current.dateComponents([.hour], from: self, to: Date()).hour!
    }
    var minutesFromNow: Int {
        return Calendar.current.dateComponents([.minute], from: self, to: Date()).minute!
    }
    var secondsFromNow: Int {
        return Calendar.current.dateComponents([.second], from: self, to: Date()).second!
    }
    var relativeTime: String {
        if yearsFromNow > 0 {
            return "\(yearsFromNow) year" + (yearsFromNow > 1 ? "s" : "") + " ago"
        }
        if monthsFromNow > 0 {
            return "\(monthsFromNow) month" + (monthsFromNow > 1 ? "s" : "") + " ago"
        }
        if weeksFromNow > 0 {
            return "\(weeksFromNow) week" + (weeksFromNow > 1 ? "s" : "") + " ago"
        }
        if isInYesterday {
            return "Yesterday"
        }
        if daysFromNow > 0 {
            return "\(daysFromNow) day" + (daysFromNow > 1 ? "s" : "") + " ago"
        }
        if hoursFromNow > 0 {
            return "\(hoursFromNow) hour" + (hoursFromNow > 1 ? "s" : "") + " ago"
        }
        if minutesFromNow > 0 {
            return "\(minutesFromNow) minute" + (minutesFromNow > 1 ? "s" : "") + " ago"
        }
        return "Just now"
    }
    
    var message: String {
        if daysFromNow > 1 {
            return ""
        }
        
        if isInYesterday {
            return "Yesterday"
        }

        return "Today"
    }
}

struct EkoDateFormatter {
    
    private init() { }
    
    private static var calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US")
        return calendar
    }()
    
    private static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = calendar
        return dateFormatter
    }()
    
    static func dateString(from date: Date) -> String {
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        dateFormatter.dateFormat = "M/dd/yy"
        let dateString = dateFormatter.string(from: date)
        guard let _date = dateFormatter.date(from: dateString) else { return "" }
        if _date.message == "" {
            dateFormatter.dateFormat = "MMMM dd, yyyy"
            return dateFormatter.string(from: _date)
        }
        return _date.message
    }
    
    static func timeString(from date: Date) -> String {
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        dateFormatter.dateFormat = "h:mm a"
        return dateFormatter.string(from: date)
    }
    
}
