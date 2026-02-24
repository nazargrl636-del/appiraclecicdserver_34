import Foundation
import SwiftData

enum PetCategory: String, Codable, CaseIterable {
    case cat = "Cat"
    case dog = "Dog"
    case hamster = "Hamster"
    case guineaPig = "Guinea Pig"
    case parrot = "Parrot"
    case rabbit = "Rabbit"
    case fish = "Fish"
    case turtle = "Turtle"
    case snake = "Snake"
    case lizard = "Lizard"
    case ferret = "Ferret"
    case chinchilla = "Chinchilla"
    case custom = "Custom"

    var icon: String {
        switch self {
        case .cat: return "cat.fill"
        case .dog: return "dog.fill"
        case .hamster: return "hare.fill"
        case .guineaPig: return "hare.fill"
        case .parrot: return "bird.fill"
        case .rabbit: return "hare.fill"
        case .fish: return "fish.fill"
        case .turtle: return "tortoise.fill"
        case .snake: return "lizard.fill"
        case .lizard: return "lizard.fill"
        case .ferret: return "hare.fill"
        case .chinchilla: return "hare.fill"
        case .custom: return "pawprint.fill"
        }
    }
}

@Model
final class Pet {
    var id: UUID
    var name: String
    var category: PetCategory
    var breed: String
    var birthDate: Date?
    var photoData: Data?
    var notes: String
    var customCategoryName: String?
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \CareTask.pet)
    var careTasks: [CareTask] = []

    init(
        id: UUID = UUID(),
        name: String,
        category: PetCategory,
        breed: String = "",
        birthDate: Date? = nil,
        photoData: Data? = nil,
        notes: String = "",
        customCategoryName: String? = nil
    ) {
        self.id = id
        self.name = name
        self.category = category
        self.breed = breed
        self.birthDate = birthDate
        self.photoData = photoData
        self.notes = notes
        self.customCategoryName = customCategoryName
        self.createdAt = Date()
    }

    var displayCategory: String {
        if category == .custom, let customName = customCategoryName {
            return customName
        }
        return category.rawValue
    }

    var age: String {
        guard let birthDate = birthDate else { return "Unknown" }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: birthDate, to: Date())
        if let years = components.year, years > 0 {
            return "\(years) year\(years == 1 ? "" : "s")"
        } else if let months = components.month, months > 0 {
            return "\(months) month\(months == 1 ? "" : "s")"
        }
        return "Less than a month"
    }
}
