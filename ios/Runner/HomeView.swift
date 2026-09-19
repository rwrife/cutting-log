import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var store: JournalStore
    @State private var showingNewPlant = false
    @State private var search = ""

    private var matchingPlants: [Plant] {
        guard !search.isEmpty else { return store.activePlants }
        return store.activePlants.filter {
            $0.nickname.localizedCaseInsensitiveContains(search)
                || $0.species.localizedCaseInsensitiveContains(search)
                || store.cuttings(for: $0.id).contains {
                    $0.name.localizedCaseInsensitiveContains(search)
                        || $0.tags.contains { $0.localizedCaseInsensitiveContains(search) }
                }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink {
                        HelpView()
                    } label: {
                        Label("Private journal ready", systemImage: "lock.shield")
                    }
                    Text("Your cutting history stays on this iPhone. No account or network is required.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section("Journal overview") {
                    LabeledContent("Parent plants", value: "\(store.activePlants.count)")
                    LabeledContent(
                        "Active cuttings",
                        value: "\(store.library.cuttings.filter { $0.archivedAt == nil }.count)"
                    )
                    LabeledContent("Storage", value: "Offline and account-free")
                }

                Section("Parent plants") {
                    if matchingPlants.isEmpty {
                        ContentUnavailableView(
                            search.isEmpty ? "No parent plants yet" : "No matches",
                            systemImage: "leaf",
                            description: Text(
                                search.isEmpty
                                    ? "Create the mature plant you take cuttings from."
                                    : "Try another plant, cutting, or tag."
                            )
                        )
                    }
                    ForEach(matchingPlants) { plant in
                        NavigationLink(value: plant) {
                            Label {
                                VStack(alignment: .leading) {
                                    Text(plant.nickname)
                                    if !plant.species.isEmpty {
                                        Text(plant.species).font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                            } icon: {
                                Image(systemName: plant.icon)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Cutting Log")
            .navigationDestination(for: Plant.self) { plant in
                PlantView(plant: plant)
            }
            .searchable(text: $search, prompt: "Search plants, cuttings, or tags")
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    NavigationLink {
                        AdvancedToolsView()
                    } label: {
                        Label("Advanced data tools", systemImage: "wrench.and.screwdriver")
                    }
                    Button {
                        showingNewPlant = true
                    } label: {
                        Label("Create parent plant", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingNewPlant) {
                NewPlantView()
            }
            .alert(
                "Cutting Log",
                isPresented: Binding(
                    get: { store.errorMessage != nil },
                    set: { if !$0 { store.errorMessage = nil } }
                )
            ) {
                Button("OK") { store.errorMessage = nil }
            } message: {
                Text(store.errorMessage ?? "")
            }
        }
    }
}

private struct NewPlantView: View {
    @EnvironmentObject private var store: JournalStore
    @Environment(\.dismiss) private var dismiss
    @State private var nickname = ""
    @State private var species = ""
    @State private var notes = ""
    @State private var icon = "leaf"
    private let icons = ["leaf", "tree", "tree.fill", "camera.macro", "laurel.leading", "drop", "sun.max", "mountain.2", "ladybug"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Parent plant") {
                    TextField("Nickname", text: $nickname)
                    TextField("Species (optional)", text: $species)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(2...5)
                }
                Section("Icon") {
                    Picker("Plant icon", selection: $icon) {
                        ForEach(icons, id: \.self) {
                            Label($0, systemImage: $0).tag($0)
                        }
                    }
                }
            }
            .navigationTitle("Create parent")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        store.createPlant(nickname: nickname, species: species, notes: notes, icon: icon)
                        if store.errorMessage == nil { dismiss() }
                    }
                    .disabled(nickname.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

struct PlantView: View {
    @EnvironmentObject private var store: JournalStore
    let plant: Plant
    @State private var showingNewCutting = false

    var body: some View {
        List {
            if !plant.notes.isEmpty {
                Section("Notes") { Text(plant.notes) }
            }
            Section("Active cuttings") {
                if store.cuttings(for: plant.id).isEmpty {
                    Text("No active cuttings for this parent.")
                        .foregroundStyle(.secondary)
                }
                ForEach(store.cuttings(for: plant.id)) { cutting in
                    NavigationLink(value: cutting) {
                        let state = store.library.state(for: cutting.id)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(cutting.name)
                            Text("\(state.stage.title) • \(state.outcome.title) • \(cutting.method) in \(cutting.medium)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
            Section("Sibling timeline summary") {
                ForEach(store.cuttings(for: plant.id)) { cutting in
                    let state = store.library.state(for: cutting.id)
                    LabeledContent(cutting.name, value: "\(state.stage.title), \(state.outcome.title)")
                }
            }
        }
        .navigationTitle(plant.nickname)
        .navigationDestination(for: Cutting.self) { cutting in
            CuttingDetailView(cutting: cutting)
        }
        .toolbar {
            Button {
                showingNewCutting = true
            } label: {
                Label("Start a cutting", systemImage: "plus")
            }
        }
        .sheet(isPresented: $showingNewCutting) {
            NewCuttingView(plant: plant)
        }
    }
}

private struct NewCuttingView: View {
    @EnvironmentObject private var store: JournalStore
    @Environment(\.dismiss) private var dismiss
    let plant: Plant
    @State private var name = ""
    @State private var method = "Stem"
    @State private var medium = "Water"
    @State private var location = ""
    @State private var tags = ""
    @State private var note = ""
    @State private var date = Date()
    private let methods = ["Stem", "Leaf", "Root", "Division", "Air layer", "Water propagation"]
    private let media = ["Water", "Soil", "Perlite", "Sphagnum moss", "Vermiculite", "Sand"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Start a cutting") {
                    TextField("Name (defaults to Cutting 1)", text: $name)
                    Picker("Method", selection: $method) {
                        ForEach(methods, id: \.self) { Text($0) }
                    }
                    Picker("Medium", selection: $medium) {
                        ForEach(media, id: \.self) { Text($0) }
                    }
                    DatePicker("Start date", selection: $date, in: ...Date(), displayedComponents: .date)
                }
                Section("Optional details") {
                    TextField("Location", text: $location)
                    TextField("Tags, comma separated", text: $tags)
                    TextField("Initial observation", text: $note, axis: .vertical)
                }
            }
            .navigationTitle("New cutting")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        store.createCutting(
                            plantID: plant.id,
                            name: name,
                            method: method,
                            medium: medium,
                            location: location,
                            tags: tags,
                            startedAt: date,
                            initialNote: note
                        )
                        if store.errorMessage == nil { dismiss() }
                    }
                }
            }
        }
    }
}
