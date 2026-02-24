import SwiftUI
import SwiftData

struct PetListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Pet.createdAt, order: .reverse) private var pets: [Pet]
    @State private var showingAddPet = false
    @State private var searchText = ""

    var filteredPets: [Pet] {
        if searchText.isEmpty {
            return pets
        }
        return pets.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.breed.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            Group {
                if pets.isEmpty {
                    emptyStateView
                } else {
                    petsList
                }
            }
            .background(Color.darkBackground)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        SittingDogView()
                            .scaleEffect(0.5)
                            .frame(width: 25, height: 40)
                        Text("My Pets")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddPet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search pets")
            .toolbarBackground(Color.darkBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showingAddPet) {
                AddPetView()
            }
        }
    }

    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Pets Yet", systemImage: "pawprint.fill")
        } description: {
            Text("Add your first pet to start tracking their care")
        } actions: {
            Button("Add Pet") {
                showingAddPet = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.darkBackground)
    }

    private var petsList: some View {
        List {
            ForEach(filteredPets) { pet in
                NavigationLink(destination: PetDetailView(pet: pet)) {
                    PetRowView(pet: pet)
                }
                .listRowBackground(Color.darkSurface)
            }
            .onDelete(perform: deletePets)
        }
        .scrollContentBackground(.hidden)
        .background(Color.darkBackground)
    }

    private func deletePets(at offsets: IndexSet) {
        for index in offsets {
            let pet = filteredPets[index]
            modelContext.delete(pet)
        }
    }
}

struct PetRowView: View {
    let pet: Pet

    var body: some View {
        HStack(spacing: 12) {
            if let photoData = pet.photoData, let uiImage = UIImage(data: photoData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Image(systemName: pet.category.icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 50, height: 50)
                    .background(Color.blue.gradient)
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(pet.name)
                    .font(.headline)
                Text(pet.breed.isEmpty ? pet.displayCategory : "\(pet.breed) (\(pet.displayCategory))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            if !pet.careTasks.filter({ !$0.isCompleted }).isEmpty {
                Text("\(pet.careTasks.filter { !$0.isCompleted }.count)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange)
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    PetListView()
        .modelContainer(for: [Pet.self, CareTask.self], inMemory: true)
}
