import SwiftUI
import SwiftData

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let pet: Pet

    @State private var selectedType: CareTaskType = .feeding
    @State private var customTypeName = ""
    @State private var notes = ""
    @State private var scheduledDate = Date()
    @State private var repeatInterval: RepeatInterval = .none
    @State private var customRepeatDays = 1
    @State private var notificationEnabled = true

    var isValid: Bool {
        selectedType != .custom || !customTypeName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                taskTypeSection
                scheduleSection
                repeatSection
                notificationSection
                notesSection
            }
            .scrollContentBackground(.hidden)
            .background(Color.darkBackground)
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.darkBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(!isValid)
                }
            }
        }
    }

    private var taskTypeSection: some View {
        Section("Task Type") {
            Picker("Type", selection: $selectedType) {
                ForEach(CareTaskType.allCases, id: \.self) { type in
                    Label(type.rawValue, systemImage: type.icon)
                        .tag(type)
                }
            }
            .listRowBackground(Color.darkSurface)

            if selectedType == .custom {
                TextField("Custom Task Name", text: $customTypeName)
                    .listRowBackground(Color.darkSurface)
            }
        }
    }

    private var scheduleSection: some View {
        Section("Schedule") {
            DatePicker("Date & Time", selection: $scheduledDate, displayedComponents: [.date, .hourAndMinute])
                .listRowBackground(Color.darkSurface)
        }
    }

    private var repeatSection: some View {
        Section("Repeat") {
            Picker("Repeat", selection: $repeatInterval) {
                ForEach(RepeatInterval.allCases, id: \.self) { interval in
                    Text(interval.rawValue).tag(interval)
                }
            }
            .listRowBackground(Color.darkSurface)

            if repeatInterval == .custom {
                Stepper("Every \(customRepeatDays) day\(customRepeatDays == 1 ? "" : "s")", value: $customRepeatDays, in: 1...365)
                    .listRowBackground(Color.darkSurface)
            }
        }
    }

    private var notificationSection: some View {
        Section("Notification") {
            Toggle("Enable Reminder", isOn: $notificationEnabled)
                .listRowBackground(Color.darkSurface)

            if notificationEnabled {
                Text("You'll receive a notification at the scheduled time")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.darkSurface)
            }
        }
    }

    private var notesSection: some View {
        Section("Notes") {
            TextField("Additional notes", text: $notes, axis: .vertical)
                .lineLimit(3...6)
                .listRowBackground(Color.darkSurface)
        }
    }

    private func saveTask() {
        let task = CareTask(
            type: selectedType,
            customTypeName: selectedType == .custom ? customTypeName : nil,
            notes: notes,
            scheduledDate: scheduledDate,
            repeatInterval: repeatInterval,
            customRepeatDays: customRepeatDays,
            notificationEnabled: notificationEnabled,
            pet: pet
        )

        pet.careTasks.append(task)
        modelContext.insert(task)

        if notificationEnabled {
            Task {
                let notificationId = await NotificationManager.shared.scheduleNotification(for: task, petName: pet.name)
                task.notificationId = notificationId
            }
        }

        dismiss()
    }
}

#Preview {
    AddTaskView(pet: Pet(name: "Max", category: .dog))
        .modelContainer(for: [Pet.self, CareTask.self], inMemory: true)
}
