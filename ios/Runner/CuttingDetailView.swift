import PhotosUI
import SwiftUI

struct CuttingDetailView: View {
    @EnvironmentObject private var store: JournalStore
    @Environment(\.dismiss) private var dismiss
    let cutting: Cutting
    @State private var observation = ""
    @State private var photoCaption = ""
    @State private var photoItem: PhotosPickerItem?
    @State private var cameraImage: UIImage?
    @State private var showingCamera = false
    @State private var reminderDate = Date().addingTimeInterval(86_400)
    @State private var showingReminder = false
    @State private var correctingEvent: JournalEvent?
    @State private var correction = ""

    private var events: [JournalEvent] { store.library.events(for: cutting.id) }
    private var checkIns: [CheckIn] {
        store.library.checkIns.filter {
            $0.cuttingID == cutting.id && $0.completedAt == nil && !$0.isCancelled
        }.sorted { $0.scheduledAt < $1.scheduledAt }
    }

    var body: some View {
        List {
            Section("Details") {
                let state = store.library.state(for: cutting.id)
                LabeledContent("Stage", value: state.stage.title)
                LabeledContent("Outcome", value: state.outcome.title)
                LabeledContent("Method", value: cutting.method)
                LabeledContent("Medium", value: cutting.medium)
                if !cutting.location.isEmpty { LabeledContent("Location", value: cutting.location) }
                if !cutting.tags.isEmpty { LabeledContent("Tags", value: cutting.tags.joined(separator: ", ")) }
                LabeledContent("Started", value: cutting.startedAt.formatted(date: .abbreviated, time: .omitted))
            }

            Section("Timeline") {
                if events.isEmpty {
                    Text("No timeline events yet.").foregroundStyle(.secondary)
                }
                ForEach(events.reversed()) { event in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label(eventTitle(event), systemImage: eventIcon(event))
                                .font(.headline)
                            Spacer()
                            Button("Correct") {
                                correctingEvent = event
                                correction = event.note
                            }
                            .font(.caption)
                        }
                        if !event.note.isEmpty { Text(event.note) }
                        Text(event.occurredAt.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let image = store.image(for: event) {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 240)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            if !event.photoCaption.isEmpty { Text(event.photoCaption).font(.caption) }
                            Button("Remove photo", role: .destructive) {
                                store.deletePhoto(from: event.id)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            Section("Add observation") {
                TextField("What did you observe?", text: $observation, axis: .vertical)
                Button("Add observation") {
                    store.addObservation(to: cutting.id, note: observation)
                    if store.errorMessage == nil { observation = "" }
                }
                Menu("Record stage change") {
                    ForEach(CuttingStage.allCases) { stage in
                        Button(stage.title) { store.changeStage(for: cutting.id, to: stage) }
                    }
                }
                Menu("Record outcome") {
                    ForEach(CuttingOutcome.allCases.filter { $0 != .active }) { outcome in
                        Button(outcome.title) { store.recordOutcome(for: cutting.id, outcome: outcome) }
                    }
                }
            }

            Section("Photo for latest event") {
                TextField("Caption (optional)", text: $photoCaption)
                PhotosPicker(selection: $photoItem, matching: .images) {
                    Label("From photo library", systemImage: "photo")
                }
                .disabled(events.isEmpty)
                Button {
                    showingCamera = true
                } label: {
                    Label("Use camera", systemImage: "camera")
                }
                .disabled(events.isEmpty || !UIImagePickerController.isSourceTypeAvailable(.camera))
            }

            Section("Check-ins") {
                if checkIns.isEmpty {
                    Text("No pending check-ins.").foregroundStyle(.secondary)
                }
                ForEach(checkIns) { checkIn in
                    VStack(alignment: .leading) {
                        Text(checkIn.scheduledAt.formatted(date: .abbreviated, time: .shortened))
                        HStack {
                            Button("Complete") { store.complete(checkIn) }
                            Button("Snooze 1 day") { Task { await store.snooze(checkIn) } }
                            Button("Remove", role: .destructive) { store.remove(checkIn) }
                        }
                        .buttonStyle(.borderless)
                    }
                }
                Button("Add check-in") { showingReminder = true }
            }

            Section {
                Button("Archive cutting", role: .destructive) {
                    store.archive(cutting)
                    dismiss()
                }
            }
        }
        .navigationTitle(cutting.name)
        .onChange(of: photoItem) { item in
            guard let item else { return }
            Task {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data),
                   let latest = events.last {
                    store.attachPhoto(image, caption: photoCaption, to: latest.id)
                    photoCaption = ""
                }
                photoItem = nil
            }
        }
        .onChange(of: cameraImage) { image in
            if let image, let latest = events.last {
                store.attachPhoto(image, caption: photoCaption, to: latest.id)
                photoCaption = ""
                cameraImage = nil
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraPicker(image: $cameraImage)
                .ignoresSafeArea()
        }
        .sheet(isPresented: $showingReminder) {
            NavigationStack {
                Form {
                    DatePicker("Check-in time", selection: $reminderDate, in: Date()...)
                    Text("Check-ins remain visible here if notification permission is denied.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .navigationTitle("Add check-in")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { showingReminder = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            Task { await store.scheduleCheckIn(for: cutting.id, at: reminderDate) }
                            showingReminder = false
                        }
                    }
                }
            }
        }
        .alert(
            "Correct event note",
            isPresented: Binding(
                get: { correctingEvent != nil },
                set: { if !$0 { correctingEvent = nil } }
            )
        ) {
            TextField("Replacement note", text: $correction)
            Button("Cancel", role: .cancel) { correctingEvent = nil }
            Button("Save correction") {
                if let event = correctingEvent { store.correct(event, note: correction) }
                correctingEvent = nil
            }
        } message: {
            Text("The original event remains in history.")
        }
    }

    private func eventTitle(_ event: JournalEvent) -> String {
        switch event.kind {
        case .observation: return "Observation"
        case .stage: return event.stage?.title ?? "Stage"
        case .outcome: return event.outcome?.title ?? "Outcome"
        }
    }

    private func eventIcon(_ event: JournalEvent) -> String {
        switch event.kind {
        case .observation: return "note.text"
        case .stage: return "arrow.up.right"
        case .outcome: return "checkmark.circle"
        }
    }
}

private struct CameraPicker: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    @Binding var image: UIImage?

    func makeCoordinator() -> Coordinator { Coordinator(parent: self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: CameraPicker
        init(parent: CameraPicker) { self.parent = parent }

        func imagePickerController(
            _ picker: UIImagePickerController,
            didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
        ) {
            parent.image = info[.originalImage] as? UIImage
            parent.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
