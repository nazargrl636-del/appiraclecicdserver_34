import SwiftUI
import SwiftData
import PhotosUI

struct PetDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var pet: Pet

    @State private var showingEditSheet = false
    @State private var showingAddTask = false

    var pendingTasks: [CareTask] {
        pet.careTasks.filter { !$0.isCompleted }.sorted { $0.scheduledDate < $1.scheduledDate }
    }

    var completedTasks: [CareTask] {
        pet.careTasks.filter { $0.isCompleted }.sorted { ($0.completedDate ?? Date()) > ($1.completedDate ?? Date()) }
    }

    var body: some View {
        List {
            petInfoSection
                .listRowBackground(Color.darkSurface)
            statsSection
            pendingTasksSection
            completedTasksSection
        }
        .scrollContentBackground(.hidden)
        .background(Color.darkBackground)
        .navigationTitle(pet.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.darkBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Edit Pet", systemImage: "pencil")
                    }

                    Button {
                        showingAddTask = true
                    } label: {
                        Label("Add Task", systemImage: "plus")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            EditPetView(pet: pet)
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(pet: pet)
        }
    }

    private var petInfoSection: some View {
        Section {
            HStack(spacing: 16) {
                if let photoData = pet.photoData, let uiImage = UIImage(data: photoData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 80, height: 80)
                        .clipShape(Circle())
                } else {
                    Image(systemName: pet.category.icon)
                        .font(.largeTitle)
                        .foregroundStyle(.white)
                        .frame(width: 80, height: 80)
                        .background(Color.blue.gradient)
                        .clipShape(Circle())
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(pet.name)
                        .font(.title2)
                        .fontWeight(.bold)

                    if !pet.breed.isEmpty {
                        Text(pet.breed)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Label(pet.displayCategory, systemImage: pet.category.icon)
                        if pet.birthDate != nil {
                            Text("•")
                            Text(pet.age)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 8)

            if !pet.notes.isEmpty {
                Text(pet.notes)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var statsSection: some View {
        Section("Overview") {
            HStack {
                StatCard(title: "Pending", value: "\(pendingTasks.count)", color: .orange)
                StatCard(title: "Completed", value: "\(completedTasks.count)", color: .green)
                StatCard(title: "Total", value: "\(pet.careTasks.count)", color: .blue)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            .listRowBackground(Color.darkBackground)
        }
    }

    private var pendingTasksSection: some View {
        Section {
            if pendingTasks.isEmpty {
                ContentUnavailableView {
                    Label("No Pending Tasks", systemImage: "checkmark.circle")
                } description: {
                    Text("All caught up!")
                }
                .listRowBackground(Color.darkBackground)
            } else {
                ForEach(pendingTasks) { task in
                    TaskRowView(task: task) {
                        completeTask(task)
                    }
                    .listRowBackground(Color.darkSurface)
                }
                .onDelete { indexSet in
                    deleteTasks(at: indexSet, from: pendingTasks)
                }
            }
        } header: {
            HStack {
                Text("Pending Tasks")
                Spacer()
                Button {
                    showingAddTask = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
            }
        }
    }

    private var completedTasksSection: some View {
        Section("Completed") {
            if completedTasks.isEmpty {
                Text("No completed tasks yet")
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.darkSurface)
            } else {
                ForEach(completedTasks.prefix(10)) { task in
                    CompletedTaskRowView(task: task)
                        .listRowBackground(Color.darkSurface)
                }
                .onDelete { indexSet in
                    deleteTasks(at: indexSet, from: Array(completedTasks.prefix(10)))
                }
            }
        }
    }

    private func completeTask(_ task: CareTask) {
        withAnimation {
            task.isCompleted = true
            task.completedDate = Date()

            if let notificationId = task.notificationId {
                NotificationManager.shared.cancelNotification(identifier: notificationId)
            }

            if task.repeatInterval != .none, let nextDate = task.nextScheduledDate() {
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
                pet.careTasks.append(newTask)
                modelContext.insert(newTask)

                if newTask.notificationEnabled {
                    Task {
                        let notificationId = await NotificationManager.shared.scheduleNotification(for: newTask, petName: pet.name)
                        newTask.notificationId = notificationId
                    }
                }
            }
        }
    }

    private func deleteTasks(at offsets: IndexSet, from tasks: [CareTask]) {
        for index in offsets {
            let task = tasks[index]
            if let notificationId = task.notificationId {
                NotificationManager.shared.cancelNotification(identifier: notificationId)
            }
            modelContext.delete(task)
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundStyle(color)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct TaskRowView: View {
    let task: CareTask
    let onComplete: () -> Void

    var isOverdue: Bool {
        task.scheduledDate < Date()
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onComplete) {
                Image(systemName: "circle")
                    .font(.title2)
                    .foregroundStyle(isOverdue ? .red : .accentColor)
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: task.type.icon)
                        .foregroundStyle(colorForType(task.type))
                    Text(task.displayType)
                        .fontWeight(.medium)
                }

                HStack {
                    Text(task.scheduledDate, style: .date)
                    Text(task.scheduledDate, style: .time)
                }
                .font(.caption)
                .foregroundStyle(isOverdue ? .red : .secondary)

                if !task.notes.isEmpty {
                    Text(task.notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }

            Spacer()

            if task.repeatInterval != .none {
                Image(systemName: "repeat")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            if task.notificationEnabled {
                Image(systemName: "bell.fill")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.vertical, 4)
    }

    func colorForType(_ type: CareTaskType) -> Color {
        switch type.defaultColor {
        case "orange": return .orange
        case "blue": return .blue
        case "green": return .green
        case "purple": return .purple
        case "red": return .red
        case "pink": return .pink
        case "mint": return .mint
        case "cyan": return .cyan
        case "yellow": return .yellow
        case "indigo": return .indigo
        case "gray": return .gray
        case "brown": return .brown
        case "teal": return .teal
        default: return .accentColor
        }
    }
}

struct CompletedTaskRowView: View {
    let task: CareTask

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(.green)

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: task.type.icon)
                    Text(task.displayType)
                }
                .foregroundStyle(.secondary)

                if let completedDate = task.completedDate {
                    Text("Completed \(completedDate, style: .relative) ago")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        PetDetailView(pet: Pet(name: "Max", category: .dog, breed: "Golden Retriever"))
    }
    .modelContainer(for: [Pet.self, CareTask.self], inMemory: true)
}
