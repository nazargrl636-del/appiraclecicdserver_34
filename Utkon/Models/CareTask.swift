import Foundation
import SwiftData

enum CareTaskType: String, Codable, CaseIterable {
    case feeding = "Feeding"
    case water = "Water"
    case walking = "Walking"
    case grooming = "Grooming"
    case medication = "Medication"
    case vetVisit = "Vet Visit"
    case vaccination = "Vaccination"
    case cleaning = "Cleaning"
    case playtime = "Playtime"
    case training = "Training"
    case weighing = "Weighing"
    case nailTrimming = "Nail Trimming"
    case teethCleaning = "Teeth Cleaning"
    case bathTime = "Bath Time"
    case custom = "Custom"

    var icon: String {
        switch self {
        case .feeding: return "fork.knife"
        case .water: return "drop.fill"
        case .walking: return "figure.walk"
        case .grooming: return "comb.fill"
        case .medication: return "pills.fill"
        case .vetVisit: return "cross.case.fill"
        case .vaccination: return "syringe.fill"
        case .cleaning: return "sparkles"
        case .playtime: return "gamecontroller.fill"
        case .training: return "medal.fill"
        case .weighing: return "scalemass.fill"
        case .nailTrimming: return "scissors"
        case .teethCleaning: return "mouth.fill"
        case .bathTime: return "shower.fill"
        case .custom: return "star.fill"
        }
    }

    var defaultColor: String {
        switch self {
        case .feeding: return "orange"
        case .water: return "blue"
        case .walking: return "green"
        case .grooming: return "purple"
        case .medication: return "red"
        case .vetVisit: return "pink"
        case .vaccination: return "mint"
        case .cleaning: return "cyan"
        case .playtime: return "yellow"
        case .training: return "indigo"
        case .weighing: return "gray"
        case .nailTrimming: return "brown"
        case .teethCleaning: return "teal"
        case .bathTime: return "blue"
        case .custom: return "purple"
        }
    }
}

enum RepeatInterval: String, Codable, CaseIterable {
    case none = "None"
    case daily = "Daily"
    case weekly = "Weekly"
    case biweekly = "Every 2 Weeks"
    case monthly = "Monthly"
    case yearly = "Yearly"
    case custom = "Custom"

    var calendarComponent: Calendar.Component? {
        switch self {
        case .none: return nil
        case .daily: return .day
        case .weekly: return .weekOfYear
        case .biweekly: return .weekOfYear
        case .monthly: return .month
        case .yearly: return .year
        case .custom: return .day
        }
    }

    var defaultValue: Int {
        switch self {
        case .none: return 0
        case .daily: return 1
        case .weekly: return 1
        case .biweekly: return 2
        case .monthly: return 1
        case .yearly: return 1
        case .custom: return 1
        }
    }
}

@Model
final class CareTask {
    var id: UUID
    var type: CareTaskType
    var customTypeName: String?
    var notes: String
    var scheduledDate: Date
    var isCompleted: Bool
    var completedDate: Date?
    var repeatInterval: RepeatInterval
    var customRepeatDays: Int
    var notificationEnabled: Bool
    var notificationId: String?
    var pet: Pet?
    var createdAt: Date

    init(
        id: UUID = UUID(),
        type: CareTaskType,
        customTypeName: String? = nil,
        notes: String = "",
        scheduledDate: Date,
        isCompleted: Bool = false,
        completedDate: Date? = nil,
        repeatInterval: RepeatInterval = .none,
        customRepeatDays: Int = 1,
        notificationEnabled: Bool = true,
        notificationId: String? = nil,
        pet: Pet? = nil
    ) {
        self.id = id
        self.type = type
        self.customTypeName = customTypeName
        self.notes = notes
        self.scheduledDate = scheduledDate
        self.isCompleted = isCompleted
        self.completedDate = completedDate
        self.repeatInterval = repeatInterval
        self.customRepeatDays = customRepeatDays
        self.notificationEnabled = notificationEnabled
        self.notificationId = notificationId
        self.pet = pet
        self.createdAt = Date()
    }

    var displayType: String {
        if type == .custom, let customName = customTypeName {
            return customName
        }
        return type.rawValue
    }

    func nextScheduledDate() -> Date? {
        guard repeatInterval != .none else { return nil }
        let calendar = Calendar.current
        guard let component = repeatInterval.calendarComponent else { return nil }
        let value = repeatInterval == .custom ? customRepeatDays : repeatInterval.defaultValue
        return calendar.date(byAdding: component, value: value, to: scheduledDate)
    }
}
