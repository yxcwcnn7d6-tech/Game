import SwiftUI

// MARK: - Settings View

struct SettingsView: View {
    @EnvironmentObject var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                // Scan Mode
                Section {
                    Picker("Skanningsläge", selection: $settings.scanMode) {
                        ForEach(ScanMode.allCases, id: \.self) { mode in
                            VStack(alignment: .leading) {
                                Text(mode.rawValue)
                                Text(mode.description)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .tag(mode)
                        }
                    }
                } header: {
                    Text("Skanningsläge")
                } footer: {
                    Text(settings.scanMode.description)
                }

                // Zoom Settings
                Section("Zoom") {
                    Picker("Max zoom-nivå", selection: $settings.maxZoomLevel) {
                        ForEach(ZoomLevel.allCases, id: \.self) { level in
                            Text(level.label).tag(level)
                        }
                    }

                    Stepper(
                        "Antal nivåer: \(settings.numberOfZoomLevels)",
                        value: $settings.numberOfZoomLevels,
                        in: 2...4
                    )
                }

                // AI Settings
                Section {
                    Picker("AI-känslighet", selection: $settings.aiSensitivity) {
                        ForEach(AISensitivity.allCases, id: \.self) { level in
                            VStack(alignment: .leading) {
                                Text(level.rawValue)
                                Text(level.description)
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                            }
                            .tag(level)
                        }
                    }
                } header: {
                    Text("AI-analys")
                } footer: {
                    Text("Hög känslighet ger fler detektioner men kan ge falska positiva")
                }

                // AI API Configuration
                Section {
                    Picker("AI-källa", selection: $settings.aiProvider) {
                        ForEach(AIProvider.allCases, id: \.self) { provider in
                            Text(provider.rawValue).tag(provider)
                        }
                    }

                    if settings.aiProvider == .customAPI {
                        TextField("API-endpoint URL", text: $settings.aiAPIEndpoint)
                            .keyboardType(.URL)
                            .textContentType(.URL)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)

                        SecureField("API-nyckel", text: $settings.aiAPIKey)

                        TextField("Modellnamn (valfritt)", text: $settings.aiModelName)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                } header: {
                    Text("AI-konfiguration")
                } footer: {
                    if settings.aiProvider == .customAPI {
                        Text("API:t ska ta emot en bild (multipart/form-data) och returnera JSON med \"detections\"-array. Varje detektion: {type, confidence, bbox: [x,y,w,h], description}")
                    } else {
                        Text(settings.aiProvider.description)
                    }
                }

                // Auto-capture
                Section("Auto-capture") {
                    Toggle("Automatisk bildtagning", isOn: $settings.autoCaptureEnabled)

                    if settings.autoCaptureEnabled {
                        HStack {
                            Text("Stabiliseringstid")
                            Spacer()
                            Text("\(settings.stabilizationDuration, specifier: "%.1f")s")
                                .foregroundStyle(.secondary)
                        }
                        Slider(
                            value: $settings.stabilizationDuration,
                            in: 0.3...2.0,
                            step: 0.1
                        )
                    }
                }

                // Report
                Section("Rapport") {
                    Picker("Rapport-format", selection: $settings.reportFormat) {
                        ForEach(ReportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                }

                // Data Handling
                Section {
                    Picker("Datahantering", selection: $settings.dataHandling) {
                        ForEach(DataHandling.allCases, id: \.self) { handling in
                            Text(handling.rawValue).tag(handling)
                        }
                    }
                } header: {
                    Text("Datahantering")
                }

                // Report Delivery
                Section {
                    TextField("Mottagarens e-post", text: $settings.reportRecipientEmail)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    TextField("Rapport-API endpoint (valfritt)", text: $settings.reportAPIEndpoint)
                        .keyboardType(.URL)
                        .textContentType(.URL)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)

                    if !settings.reportAPIEndpoint.isEmpty {
                        SecureField("Rapport-API nyckel", text: $settings.reportAPIKey)
                    }

                    Toggle("Skicka rapport automatiskt", isOn: $settings.autoSendReport)
                } header: {
                    Text("Rapportleverans")
                } footer: {
                    if settings.autoSendReport {
                        Text("Rapporten skickas automatiskt via e-post och/eller API när skanningen är klar")
                    } else {
                        Text("Du kan skicka rapporten manuellt från rapportvyn")
                    }
                }

                // About
                Section("Om") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0 MVP")
                            .foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("AI-källa")
                        Spacer()
                        Text(settings.aiProvider == .onDevice ? "Vision Framework (on-device)" : settings.aiAPIEndpoint.isEmpty ? "Ej konfigurerad" : settings.aiAPIEndpoint)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .truncationMode(.middle)
                    }
                    if !settings.reportRecipientEmail.isEmpty {
                        HStack {
                            Text("Rapport till")
                            Spacer()
                            Text(settings.reportRecipientEmail)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
            .navigationTitle("Inställningar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Klar") {
                        settings.save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
