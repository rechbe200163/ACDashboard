import SwiftUI
import AcBridgeKit

/// Die View kennt nur das ViewModel und zeigt dessen Properties an. Keine Logik, kein Formatieren.
/// Host: "localhost", wenn die Bridge im Mock-Modus am selben Mac läuft (Simulator),
/// sonst die IP vom Windows-PC (ipconfig).
import SwiftUI
import AcBridgeKit

struct LiveView: View {
    @Environment(AcBridgeClient.self) private var client

    var body: some View {
        let vm = LiveViewModel(source: client)

        NavigationStack {
            VStack(spacing: 15) {

                // Zeile 1: ganze Breite, eigene Höhe
                LiveDeltaView(deltaMs: vm.liveDelta,
                              predictedLapText: vm.predictedLapText,
                              bestLapText: vm.bestLapText)

                // Zeile 2: 4 gleich große Cards
                HStack(spacing: 15) {
                    if let tyres = vm.tyres {
                        TyreTemperatureView(data: tyres)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        CardView {
                            Text("Keine Daten").foregroundStyle(.secondary)
                        }
                    }

                    SectorsView(currentLapSectorDeltas: vm.currentLapSectorDeltas)

                    CardView {
                        Text(vm.bestLapText)
                            .font(.title2.monospacedDigit())
                    }
                }
                .frame(maxHeight: .infinity)

                // Zeile 3: 3 gleich große Cards
                HStack(spacing: 15) {
                    CardView { Text("Card 5") }
                    CardView { Text("Card 6") }
                    CardView { Text("Card 7") }
                }
                .frame(height: 100)
            }
            .padding()
            .safeAreaInset(edge: .top) {
                SegementsView(segments: vm.currentSegments)
                    .padding(.horizontal)
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    HStack {
                        Circle()
                            .fill(vm.isConnected ? .green : .red)
                            .frame(width: 10, height: 10)
                        Text(vm.connectionText)
                    }
                }
                /*ToolbarItemGroup(placement: .primaryAction) {
                    Text(vm.positionText)
                        .font(.headline.monospacedDigit())
                }*/
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
