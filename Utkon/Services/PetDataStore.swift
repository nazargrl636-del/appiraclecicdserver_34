import Foundation
import SwiftData
import Observation

@Observable
@MainActor
final class PetDataStore {
    let modelContainer: ModelContainer
    let modelContext: ModelContext

    init() {
        let schema = Schema([Pet.self, CareTask.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            modelContainer = try ModelContainer(for: schema, configurations: [configuration])
            modelContext = modelContainer.mainContext
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    func addPet(_ pet: Pet) {
        modelContext.insert(pet)
        save()
    }

    func deletePet(_ pet: Pet) {
        modelContext.delete(pet)
        save()
    }

    func addTask(_ task: CareTask, to pet: Pet) {
        task.pet = pet
        pet.careTasks.append(task)
        modelContext.insert(task)
        save()
    }

    func deleteTask(_ task: CareTask) {
        if let notificationId = task.notificationId {
            NotificationManager.shared.cancelNotification(identifier: notificationId)
        }
        modelContext.delete(task)
        save()
    }

    func completeTask(_ task: CareTask) {
        task.isCompleted = true
        task.completedDate = Date()

        if let notificationId = task.notificationId {
            NotificationManager.shared.cancelNotification(identifier: notificationId)
        }

        if task.repeatInterval != .none, let nextDate = task.nextScheduledDate(), let pet = task.pet {
            let newTask = CareTask(
                type: task.type,
                customTypeName: task.customTypeName,
                notes: task.notes,
                scheduledDate: nextDate,
                repeatInterval: task.repeatInterval,
                customRepeatDays: task.customRepeatDays,
                notificationEnabled: task.notificationEnabled,
                pet: pet
            )
            addTask(newTask, to: pet)

            if task.notificationEnabled {
                Task {
                    let notificationId = await NotificationManager.shared.scheduleNotification(for: newTask, petName: pet.name)
                    newTask.notificationId = notificationId
                    save()
                }
            }
        }

        save()
    }

    func fetchPets() -> [Pet] {
        let descriptor = FetchDescriptor<Pet>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            return []
        }
    }

    func fetchTasks(for pet: Pet) -> [CareTask] {
        let petId = pet.id
        let descriptor = FetchDescriptor<CareTask>(
            predicate: #Predicate { $0.pet?.id == petId },
            sortBy: [SortDescriptor(\.scheduledDate)]
        )
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            return []
        }
    }

    func fetchUpcomingTasks() -> [CareTask] {
        let now = Date()
        let descriptor = FetchDescriptor<CareTask>(
            predicate: #Predicate { !$0.isCompleted && $0.scheduledDate >= now },
            sortBy: [SortDescriptor(\.scheduledDate)]
        )
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            return []
        }
    }

    func fetchOverdueTasks() -> [CareTask] {
        let now = Date()
        let descriptor = FetchDescriptor<CareTask>(
            predicate: #Predicate { !$0.isCompleted && $0.scheduledDate < now },
            sortBy: [SortDescriptor(\.scheduledDate)]
        )
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            return []
        }
    }

    func save() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
}
