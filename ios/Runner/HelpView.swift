import SwiftUI

struct HelpView: View {
    private let steps = [
        "Create a parent plant: the mature plant you take cuttings from.",
        "Start a cutting. Choose its method, medium, start date, and optional details.",
        "Log observations, stage changes, and a final outcome over time.",
        "Optionally attach private copies of photos to the latest event.",
        "Add a check-in if you want an in-app reminder and optional notification.",
        "Search from the journal to find plants, cuttings, or tags.",
        "Use Advanced data tools to export, restore, or erase your local library."
    ]

    var body: some View {
        List {
            Section {
                Text("Cutting Log is a private observation journal for plant propagation. You record what you see; the app keeps dates, lineage, and photos organized.")
            }
            Section("Basic flow") {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 12) {
                        Text("\(index + 1)")
                            .font(.headline)
                            .frame(width: 32, height: 32)
                            .background(Color.accentColor.opacity(0.2), in: Circle())
                            .accessibilityLabel("Step \(index + 1)")
                        Text(step)
                    }
                }
            }
            Section("Privacy") {
                Text("Everything stays in this app's private storage on this iPhone. There is no account, analytics, or automatic upload. Export and sharing are always user-initiated.")
            }
            Section("What Cutting Log does not do") {
                Text("It does not diagnose plants, prescribe treatment, recommend pesticides, assess toxicity or food safety, or predict propagation success.")
            }
        }
        .navigationTitle("How to use Cutting Log")
    }
}
