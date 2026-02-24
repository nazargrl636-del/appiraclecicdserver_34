import SwiftUI
import SwiftData
import PhotosUI

struct EditPetView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var pet: Pet

    @State private var name: String
    @State private var selectedCategory: PetCategory
    @State private var breed: String
    @State private var customCategoryName: String
    @State private var birthDate: Date
    @State private var hasBirthDate: Bool
    @State private var notes: String
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?

    init(pet: Pet) {
        self.pet = pet
        _name = State(initialValue: pet.name)
        _selectedCategory = State(initialValue: pet.category)
        _breed = State(initialValue: pet.breed)
        _customCategoryName = State(initialValue: pet.customCategoryName ?? "")
        _birthDate = State(initialValue: pet.birthDate ?? Date())
        _hasBirthDate = State(initialValue: pet.birthDate != nil)
        _notes = State(initialValue: pet.notes)
        _photoData = State(initialValue: pet.photoData)
    }

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty &&
        (selectedCategory != .custom || !customCategoryName.trimmingCharacters(in: .whitespaces).isEmpty)
    }

    var body: some View {
        NavigationStack {
            Form {
                photoSection
                basicInfoSection
                categorySection
                breedSection
                birthDateSection
                notesSection
            }
            .scrollContentBackground(.hidden)
            .background(Color.darkBackground)
            .navigationTitle("Edit Pet")
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
                        savePet()
                    }
                    .disabled(!isValid)
                }
            }
            .onChange(of: selectedPhoto) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        photoData = data
                    }
                }
            }
        }
    }

    private var photoSection: some View {
        Section {
            HStack {
                Spacer()
                PhotosPicker(selection: $selectedPhoto, matching: .images) {
                    if let photoData, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.accentColor, lineWidth: 2))
                    } else {
                        VStack(spacing: 8) {
                            Image(systemName: "camera.fill")
                                .font(.largeTitle)
                            Text("Add Photo")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                        .frame(width: 120, height: 120)
                        .background(Color.darkElevated)
                        .clipShape(Circle())
                    }
                }
                Spacer()
            }
        }
        .listRowBackground(Color.darkBackground)
    }

    private var basicInfoSection: some View {
        Section("Basic Info") {
            TextField("Pet Name", text: $name)
                .listRowBackground(Color.darkSurface)
        }
    }

    private var categorySection: some View {
        Section("Category") {
            Picker("Type", selection: $selectedCategory) {
                ForEach(PetCategory.allCases, id: \.self) { category in
                    Label(category.rawValue, systemImage: category.icon)
                        .tag(category)
                }
            }
            .listRowBackground(Color.darkSurface)

            if selectedCategory == .custom {
                TextField("Custom Category Name", text: $customCategoryName)
                    .listRowBackground(Color.darkSurface)
            }
        }
    }

    private var breedSection: some View {
        Section("Breed") {
            TextField("Breed", text: $breed)
                .listRowBackground(Color.darkSurface)
        }
    }

    private var birthDateSection: some View {
        Section("Birth Date") {
            Toggle("Has Birth Date", isOn: $hasBirthDate)
                .listRowBackground(Color.darkSurface)

            if hasBirthDate {
                DatePicker("Birth Date", selection: $birthDate, in: ...Date(), displayedComponents: .date)
                    .listRowBackground(Color.darkSurface)
            }
        }
    }

    private var notesSection: some View {
        Section("Notes") {
            TextField("Additional notes about your pet", text: $notes, axis: .vertical)
                .lineLimit(3...6)
                .listRowBackground(Color.darkSurface)
        }
    }

    private func savePet() {
        pet.name = name.trimmingCharacters(in: .whitespaces)
        pet.category = selectedCategory
        pet.breed = breed
        pet.birthDate = hasBirthDate ? birthDate : nil
        pet.photoData = photoData
        pet.notes = notes
        pet.customCategoryName = selectedCategory == .custom ? customCategoryName : nil
        dismiss()
    }
}

#Preview {
    EditPetView(pet: Pet(name: "Max", category: .dog, breed: "Golden Retriever"))
        .modelContainer(for: [Pet.self, CareTask.self], inMemory: true)
}
