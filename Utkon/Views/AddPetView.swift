import SwiftUI
import SwiftData
import PhotosUI

struct AddPetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var name = ""
    @State private var selectedCategory: PetCategory = .cat
    @State private var selectedBreed: PresetBreed?
    @State private var customBreed = ""
    @State private var customCategoryName = ""
    @State private var birthDate = Date()
    @State private var hasBirthDate = false
    @State private var notes = ""
    @State private var selectedPhoto: PhotosPickerItem?
    @State private var photoData: Data?

    var availableBreeds: [PresetBreed] {
        PresetBreeds.breeds(for: selectedCategory)
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
                    .listRowBackground(Color.darkSurface)
                categorySection
                breedSection
                birthDateSection
                notesSection
            }
            .scrollContentBackground(.hidden)
            .background(Color.darkBackground)
            .navigationTitle("Add Pet")
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
            .onChange(of: selectedCategory) { _, _ in
                selectedBreed = nil
                customBreed = ""
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
            if !availableBreeds.isEmpty {
                Picker("Select Breed", selection: $selectedBreed) {
                    Text("Select...").tag(nil as PresetBreed?)
                    ForEach(availableBreeds) { breed in
                        Text(breed.name).tag(breed as PresetBreed?)
                    }
                }
                .listRowBackground(Color.darkSurface)
            }

            TextField("Or enter custom breed", text: $customBreed)
                .listRowBackground(Color.darkSurface)
        }
    }

    private var birthDateSection: some View {
        Section("Birth Date") {
            Toggle("Add Birth Date", isOn: $hasBirthDate)
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
        let breed = selectedBreed?.name ?? customBreed
        let pet = Pet(
            name: name.trimmingCharacters(in: .whitespaces),
            category: selectedCategory,
            breed: breed,
            birthDate: hasBirthDate ? birthDate : nil,
            photoData: photoData,
            notes: notes,
            customCategoryName: selectedCategory == .custom ? customCategoryName : nil
        )

        modelContext.insert(pet)
        dismiss()
    }
}

#Preview {
    AddPetView()
        .modelContainer(for: [Pet.self, CareTask.self], inMemory: true)
}
