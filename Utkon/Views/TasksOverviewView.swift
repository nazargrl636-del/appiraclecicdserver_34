import SwiftUI
import SwiftData

struct TasksOverviewView: View {
    @Query(sort: \CareTask.scheduledDate) private var allTasks: [CareTask]
    @Environment(\.modelContext) private var modelContext

    @State private var selectedFilter: TaskFilter = .upcoming

    enum TaskFilter: String, CaseIterable {
        case upcoming = "Upcoming"
        case overdue = "Overdue"
        case today = "Today"
        case completed = "Completed"
    }

    var filteredTasks: [CareTask] {
        let now = Date()
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: now)
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!

        switch selectedFilter {
        case .upcoming:
            return allTasks.filter { !$0.isCompleted && $0.scheduledDate >= now }
        case .overdue:
            return allTasks.filter { !$0.isCompleted && $0.scheduledDate < now }
        case .today:
            return allTasks.filter { !$0.isCompleted && $0.scheduledDate >= startOfToday && $0.scheduledDate < endOfToday }
        case .completed:
            return allTasks.filter { $0.isCompleted }.sorted { ($0.completedDate ?? Date()) > ($1.completedDate ?? Date()) }
        }
    }

    var overdueTasks: [CareTask] {
        allTasks.filter { !$0.isCompleted && $0.scheduledDate < Date() }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Tasks")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                filterPicker

                ZStack {
                    tasksList
                    if filteredTasks.isEmpty {
                        PetAnimationsOverlay()
                    }
                }
            }
            .background(Color.darkBackground)
            .navigationBarHidden(true)
        }
    }

    private var filterPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(TaskFilter.allCases, id: \.self) { filter in
                    FilterChip(
                        title: filter.rawValue,
                        count: countForFilter(filter),
                        isSelected: selectedFilter == filter,
                        color: colorForFilter(filter)
                    ) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedFilter = filter
                        }
                    }
                }
            }
            .padding()
        }
        .background(Color.darkBackground)
    }

    private var tasksList: some View {
        List {
            if filteredTasks.isEmpty {
                ContentUnavailableView {
                    Label(emptyStateTitle, systemImage: emptyStateIcon)
                } description: {
                    Text(emptyStateDescription)
                }
                .listRowBackground(Color.darkBackground)
            } else {
                ForEach(filteredTasks) { task in
                    if let pet = task.pet {
                        TaskWithPetRowView(task: task, pet: pet) {
                            completeTask(task)
                        }
                        .listRowBackground(Color.darkSurface)
                    }
                }
                .onDelete(perform: deleteTasks)
            }
        }
        .scrollContentBackground(.hidden)
        .background(Color.darkBackground)
    }

    private var emptyStateTitle: String {
        switch selectedFilter {
        case .upcoming: return "No Upcoming Tasks"
        case .overdue: return "No Overdue Tasks"
        case .today: return "No Tasks Today"
        case .completed: return "No Completed Tasks"
        }
    }

    private var emptyStateIcon: String {
        switch selectedFilter {
        case .upcoming: return "calendar"
        case .overdue: return "checkmark.circle"
        case .today: return "sun.max"
        case .completed: return "tray"
        }
    }

    private var emptyStateDescription: String {
        switch selectedFilter {
        case .upcoming: return "All caught up!"
        case .overdue: return "Great job keeping up!"
        case .today: return "No tasks scheduled for today"
        case .completed: return "Complete tasks to see them here"
        }
    }

    private func countForFilter(_ filter: TaskFilter) -> Int {
        let now = Date()
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: now)
        let endOfToday = calendar.date(byAdding: .day, value: 1, to: startOfToday)!

        switch filter {
        case .upcoming:
            return allTasks.filter { !$0.isCompleted && $0.scheduledDate >= now }.count
        case .overdue:
            return allTasks.filter { !$0.isCompleted && $0.scheduledDate < now }.count
        case .today:
            return allTasks.filter { !$0.isCompleted && $0.scheduledDate >= startOfToday && $0.scheduledDate < endOfToday }.count
        case .completed:
            return allTasks.filter { $0.isCompleted }.count
        }
    }

    private func colorForFilter(_ filter: TaskFilter) -> Color {
        switch filter {
        case .upcoming: return .blue
        case .overdue: return .red
        case .today: return .orange
        case .completed: return .green
        }
    }

    private func completeTask(_ task: CareTask) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
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

    private func deleteTasks(at offsets: IndexSet) {
        for index in offsets {
            let task = filteredTasks[index]
            if let notificationId = task.notificationId {
                NotificationManager.shared.cancelNotification(identifier: notificationId)
            }
            modelContext.delete(task)
        }
    }
}

struct FilterChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text(title)
                if count > 0 {
                    Text("\(count)")
                        .font(.caption2)
                        .fontWeight(.bold)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white.opacity(0.3) : color.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color.darkElevated)
            .foregroundStyle(isSelected ? .white : .primary)
            .clipShape(Capsule())
            .scaleEffect(isPressed ? 0.95 : 1)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
    }
}

struct TaskWithPetRowView: View {
    let task: CareTask
    let pet: Pet
    let onComplete: () -> Void

    @State private var isCompleting = false
    @State private var showCheckmark = false

    var isOverdue: Bool {
        task.scheduledDate < Date() && !task.isCompleted
    }

    var body: some View {
        HStack(spacing: 12) {
            if !task.isCompleted {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isCompleting = true
                        showCheckmark = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        onComplete()
                    }
                } label: {
                    ZStack {
                        Image(systemName: "circle")
                            .font(.title2)
                            .foregroundStyle(isOverdue ? .red : .accentColor)
                            .opacity(showCheckmark ? 0 : 1)
                            .scaleEffect(showCheckmark ? 0.5 : 1)

                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.green)
                            .opacity(showCheckmark ? 1 : 0)
                            .scaleEffect(showCheckmark ? 1 : 0.5)
                    }
                }
                .buttonStyle(.plain)
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.green)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: task.type.icon)
                        .symbolEffect(.bounce, value: isCompleting)
                    Text(task.displayType)
                        .fontWeight(.medium)
                }

                HStack {
                    if let photoData = pet.photoData, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 16, height: 16)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: pet.category.icon)
                            .font(.caption2)
                    }
                    Text(pet.name)
                        .font(.caption)
                }
                .foregroundStyle(.secondary)

                if task.isCompleted, let completedDate = task.completedDate {
                    Text("Completed \(completedDate, style: .relative) ago")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    HStack {
                        Text(task.scheduledDate, style: .date)
                        Text(task.scheduledDate, style: .time)
                    }
                    .font(.caption)
                    .foregroundStyle(isOverdue ? .red : .secondary)
                }
            }
            .opacity(isCompleting ? 0.5 : 1)

            Spacer()

            if task.repeatInterval != .none {
                Image(systemName: "repeat")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .symbolEffect(.pulse, options: .repeating, value: !task.isCompleted)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TasksOverviewView()
        .modelContainer(for: [Pet.self, CareTask.self], inMemory: true)
}
