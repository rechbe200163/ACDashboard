import SwiftUI
import AcBridgeKit

/// Die View kennt nur das ViewModel und zeigt dessen Properties an. Keine Logik, kein Formatieren.
/// Host: "localhost", wenn die Bridge im Mock-Modus am selben Mac läuft (Simulator),
/// sonst die IP vom Windows-PC (ipconfig).
struct LiveView: View {
    // @State hält das VM am Leben, solange die View existiert (≈ DataContext)
    @Environment(AcBridgeClient.self) private var client
    var body: some View {
        let vm = LiveViewModel(source: client)
        NavigationStack {
          // if vm.hasData {
            VStack(spacing: 24) {
                LiveDeltaView(deltaMs: vm.liveDelta, predictedLapText: vm.predictedLapText, bestLapText: vm.bestLapText)
                    HStack(spacing: 40) {
                        ValueTile(label: "km/h", value: vm.speedText)
                        ValueTile(label: "Gang", value: vm.gearText)
                        ValueTile(label: "RPM",  value: vm.rpmText)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ProgressView(value: vm.rpmFraction).tint(.orange)
                        ProgressView(value: vm.throttle).tint(.green)
                        ProgressView(value: vm.brake).tint(.red)
                    }
                    .frame(width: 320)
            }
            .safeAreaInset(edge: .top) {         // Segmente fix oben
                SegementsView(segments: vm.currentSegments)
            }
            Spacer()
           /* } else {
                Text("Noch keine Daten (in AC auf die Strecke fahren)")
                    .foregroundStyle(.secondary)
            }*/
        }
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                HStack {
                    Circle()
                        .fill(vm.isConnected ? .green : .red)
                        .frame(width: 10, height: 10)
                    Text(vm.connectionText)
                }
            }
            ToolbarItemGroup(placement: .primaryAction) {   // rechts oben
                Text(vm.positionText)
                    .font(.headline.monospacedDigit())
            }
        }
        .navigationTitle("Home")
        .navigationBarTitleDisplayMode(.inline)
        .padding()
    }

    private func header(_ vm: LiveViewModel) -> some View {
        VStack(spacing: 4) {
            HStack(spacing: 6) {
                Circle()
                    .fill(vm.isConnected ? .green : .gray)
                    .frame(width: 8, height: 8)
                Text(vm.connectionText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            if let title = vm.sessionTitle {
                Text(title).font(.headline)
            }
        }
    }
}

/// Wiederverwendbare Kachel (≈ UserControl mit zwei Dependency Properties)
struct ValueTile: View {
    let label: String
    let value: String
    var size: CGFloat = 44

    var body: some View {
        VStack {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: size, weight: .bold, design: .rounded).monospacedDigit())
        }
    }
}

#Preview {
    LiveView()
        .environment(AcBridgeClient(host: "localhost"))
}
