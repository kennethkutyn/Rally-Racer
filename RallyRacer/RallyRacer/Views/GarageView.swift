import SwiftUI
import SpriteKit

struct GarageView: View {
    @EnvironmentObject var appState: AppState
    @State private var editingCar: CarConfig
    @State private var editingIndex: Int? // nil = creating new
    @State private var showDeleteAlert = false
    @State private var expandedColor: String? // which color property picker is open

    @State private var previewScene: GaragePreviewScene

    init() {
        let defaultCar = CarConfig.stockOrange
        _editingCar = State(initialValue: defaultCar)
        _editingIndex = State(initialValue: nil)

        let scene = GaragePreviewScene(size: CGSize(width: 400, height: 200))
        scene.scaleMode = .aspectFill
        _previewScene = State(initialValue: scene)
    }

    private var isWide: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [
                    Color(hex: "#501444").opacity(0.85),
                    Color(hex: "#0a0514").opacity(0.95)
                ],
                center: UnitPoint(x: 0.6, y: 0.4),
                startRadius: 0,
                endRadius: 600
            )
            .ignoresSafeArea()

            if isWide {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
        .onAppear {
            loadActiveCar()
            previewScene.updateCar(config: editingCar)
            previewScene.setupPreview()
        }
    }

    // MARK: - iPad layout: car list | colors | big preview + buttons

    private var iPadLayout: some View {
        HStack(spacing: 0) {
            // Car list (narrow)
            carListPanel
                .frame(width: 200)

            Divider().background(Color.white.opacity(0.2))

            // Color editor (compact)
            colorEditorCompact
                .frame(width: 260)

            Divider().background(Color.white.opacity(0.2))

            // Preview (takes remaining space) + action buttons
            VStack(spacing: 12) {
                Text("PREVIEW")
                    .font(.custom("RussoOne-Regular", size: 14))
                    .foregroundColor(Color(hex: "#ffcc00"))

                SpriteView(scene: previewScene)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )

                actionButtons
            }
            .padding()
        }
        .padding(.leading)
    }

    // MARK: - iPhone layout: 3 columns, no scroll, buttons at bottom

    private var iPhoneLayout: some View {
        VStack(spacing: 6) {
            // 3-column row: pick car | pick colours | preview
            HStack(alignment: .top, spacing: 8) {
                // Column 1: car list
                VStack(spacing: 4) {
                    Text("CARS")
                        .font(.custom("RussoOne-Regular", size: 11))
                        .foregroundColor(Color(hex: "#ffcc00"))

                    ScrollView {
                        VStack(spacing: 4) {
                            ForEach(Array(appState.garage.enumerated()), id: \.element.id) { index, car in
                                Button {
                                    selectCar(index: index)
                                } label: {
                                    HStack(spacing: 4) {
                                        Circle()
                                            .fill(Color(hex: car.body))
                                            .frame(width: 16, height: 16)
                                        Text(car.name)
                                            .font(.custom("RussoOne-Regular", size: 11))
                                            .foregroundColor(editingIndex == index ? Color(hex: "#ffcc00") : .white)
                                            .lineLimit(1)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 8)
                                    .background(editingIndex == index ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
                                    .cornerRadius(4)
                                }
                            }
                            Button {
                                newCar()
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.system(size: 13))
                                        .foregroundColor(Color(hex: "#88ff00"))
                                    Text("New")
                                        .font(.custom("RussoOne-Regular", size: 11))
                                        .foregroundColor(Color(hex: "#88ff00"))
                                    Spacer()
                                }
                                .padding(.horizontal, 6)
                                .padding(.vertical, 8)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(4)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)

                // Column 2: colour picker
                VStack(spacing: 4) {
                    Text("COLOURS")
                        .font(.custom("RussoOne-Regular", size: 11))
                        .foregroundColor(Color(hex: "#ffcc00"))

                    // Name
                    TextField("Name", text: $editingCar.name)
                        .textFieldStyle(.plain)
                        .font(.custom("RussoOne-Regular", size: 11))
                        .foregroundColor(.white)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(4)
                        .autocorrectionDisabled()

                    ScrollView {
                        VStack(spacing: 3) {
                            compactColorRow(label: "BODY", hex: editingCar.body, key: "body")
                            compactColorRow(label: "CABIN", hex: editingCar.cabin, key: "cabin")
                            compactColorRow(label: "WHEEL", hex: editingCar.wheels, key: "wheels")
                            compactColorRow(label: "LIGHT", hex: editingCar.lights, key: "lights")
                            compactColorRow(label: "FLAME", hex: editingCar.flame, key: "flame")
                        }
                    }
                }
                .frame(maxWidth: .infinity)

                // Column 3: preview
                VStack(spacing: 4) {
                    Text("PREVIEW")
                        .font(.custom("RussoOne-Regular", size: 11))
                        .foregroundColor(Color(hex: "#ffcc00"))

                    SpriteView(scene: previewScene)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                }
                .frame(maxWidth: .infinity)
            }

            // Bottom row: 3 buttons in a row
            HStack(spacing: 8) {
                garageButton(title: "BACK", gradient: [Color.white.opacity(0.2), Color.white.opacity(0.1)], textColor: .white) {
                    appState.analytics.trackButtonClick("back", page: "garage")
                    appState.navigateTo(.menu)
                }

                garageButton(title: "SAVE", gradient: [Color(hex: "#88ff00"), Color(hex: "#44cc00")], textColor: Color(hex: "#111")) {
                    saveCar()
                }

                garageButton(title: "RACE!", gradient: [Color(hex: "#ffcc00"), Color(hex: "#ff8800")], textColor: Color(hex: "#111")) {
                    saveCar()
                    appState.analytics.trackButtonClick("race", page: "garage")
                    appState.startGame()
                }

                if editingIndex != nil && appState.garage.count > 1 {
                    garageButton(title: "DEL", gradient: [Color(hex: "#ff4444"), Color(hex: "#cc2222")], textColor: .white) {
                        showDeleteAlert = true
                    }
                    .alert("Delete Car", isPresented: $showDeleteAlert) {
                        Button("Cancel", role: .cancel) {}
                        Button("Delete", role: .destructive) { deleteCar() }
                    } message: {
                        Text("Delete \"\(editingCar.name)\"?")
                    }
                }
            }
            .padding(.top, 4)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
    }

    // MARK: - iPad color editor (compact, no hex codes)

    private var colorEditorCompact: some View {
        VStack(spacing: 8) {
            // Name field
            HStack {
                Text("NAME")
                    .font(.custom("RussoOne-Regular", size: 12))
                    .foregroundColor(Color.white.opacity(0.6))
                TextField("Car Name", text: $editingCar.name)
                    .textFieldStyle(.plain)
                    .font(.custom("RussoOne-Regular", size: 14))
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(6)
                    .autocorrectionDisabled()
            }

            // Color rows
            colorRow(label: "BODY", hex: editingCar.body, key: "body")
            colorRow(label: "CABIN", hex: editingCar.cabin, key: "cabin")
            colorRow(label: "WHEELS", hex: editingCar.wheels, key: "wheels")
            colorRow(label: "LIGHTS", hex: editingCar.lights, key: "lights")
            colorRow(label: "FLAME", hex: editingCar.flame, key: "flame")

            Spacer()
        }
        .padding()
    }

    // MARK: - Shared Panels

    private var carListPanel: some View {
        VStack(spacing: 8) {
            Text("YOUR CARS")
                .font(.custom("RussoOne-Regular", size: 14))
                .foregroundColor(Color(hex: "#ffcc00"))

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(Array(appState.garage.enumerated()), id: \.element.id) { index, car in
                        Button {
                            selectCar(index: index)
                        } label: {
                            HStack {
                                Circle()
                                    .fill(Color(hex: car.body))
                                    .frame(width: 22, height: 22)
                                Text(car.name)
                                    .font(.custom("RussoOne-Regular", size: 14))
                                    .foregroundColor(editingIndex == index ? Color(hex: "#ffcc00") : .white)
                                    .lineLimit(1)
                                Spacer()
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 12)
                            .background(editingIndex == index ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
                            .cornerRadius(6)
                        }
                    }

                    // New car button
                    Button {
                        newCar()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(Color(hex: "#88ff00"))
                            Text("New Car")
                                .font(.custom("RussoOne-Regular", size: 14))
                                .foregroundColor(Color(hex: "#88ff00"))
                            Spacer()
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(6)
                    }
                }
            }
        }
        .padding(.vertical)
    }

    // MARK: - Color rows

    private func colorRow(label: String, hex: String, key: String) -> some View {
        VStack(spacing: 4) {
            HStack {
                Text(label)
                    .font(.custom("RussoOne-Regular", size: 12))
                    .foregroundColor(Color.white.opacity(0.6))
                    .frame(width: 60, alignment: .leading)

                Spacer()

                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(hex: hex))
                    .frame(width: 80, height: 32)
                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.white.opacity(0.3), lineWidth: 1))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            expandedColor = expandedColor == key ? nil : key
                        }
                    }
            }
            .padding(.vertical, 4)

            if expandedColor == key {
                ColorSwatchGrid(selected: hex) { newHex in
                    setColor(key: key, hex: newHex)
                    expandedColor = nil
                }
            }
        }
    }

    private func compactColorRow(label: String, hex: String, key: String) -> some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Text(label)
                    .font(.custom("RussoOne-Regular", size: 9))
                    .foregroundColor(Color.white.opacity(0.6))
                    .frame(width: 38, alignment: .leading)

                Spacer()

                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: hex))
                    .frame(height: 26)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.white.opacity(0.3), lineWidth: 1))
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            expandedColor = expandedColor == key ? nil : key
                        }
                    }
            }
            .padding(.vertical, 2)

            if expandedColor == key {
                ColorSwatchGrid(selected: hex) { newHex in
                    setColor(key: key, hex: newHex)
                    expandedColor = nil
                }
            }
        }
    }

    // MARK: - Action Buttons (iPad)

    private var actionButtons: some View {
        VStack(spacing: 10) {
            HStack(spacing: 12) {
                Button {
                    saveCar()
                } label: {
                    Text("SAVE")
                        .font(.custom("RussoOne-Regular", size: 14))
                        .foregroundColor(Color(hex: "#111"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(colors: [Color(hex: "#88ff00"), Color(hex: "#44cc00")], startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(8)
                }

                if editingIndex != nil && appState.garage.count > 1 {
                    Button {
                        showDeleteAlert = true
                    } label: {
                        Text("DELETE")
                            .font(.custom("RussoOne-Regular", size: 14))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(colors: [Color(hex: "#ff4444"), Color(hex: "#cc2222")], startPoint: .top, endPoint: .bottom)
                            )
                            .cornerRadius(8)
                    }
                    .alert("Delete Car", isPresented: $showDeleteAlert) {
                        Button("Cancel", role: .cancel) {}
                        Button("Delete", role: .destructive) { deleteCar() }
                    } message: {
                        Text("Delete \"\(editingCar.name)\"?")
                    }
                }
            }

            HStack(spacing: 12) {
                Button {
                    appState.analytics.trackButtonClick("back", page: "garage")
                    appState.navigateTo(.menu)
                } label: {
                    Text("BACK")
                        .font(.custom("RussoOne-Regular", size: 14))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.white.opacity(0.15))
                        .cornerRadius(8)
                }

                Button {
                    saveCar()
                    appState.analytics.trackButtonClick("race", page: "garage")
                    appState.startGame()
                } label: {
                    Text("RACE!")
                        .font(.custom("RussoOne-Regular", size: 14))
                        .foregroundColor(Color(hex: "#111"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(
                            LinearGradient(colors: [Color(hex: "#ffcc00"), Color(hex: "#ff8800")], startPoint: .top, endPoint: .bottom)
                        )
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal, 4)
    }

    // MARK: - Compact button helper

    private func garageButton(title: String, gradient: [Color], textColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.custom("RussoOne-Regular", size: 12))
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    LinearGradient(colors: gradient, startPoint: .top, endPoint: .bottom)
                )
                .cornerRadius(8)
        }
    }

    // MARK: - Actions

    private func loadActiveCar() {
        if let idx = appState.garage.firstIndex(where: { $0.id == appState.carConfig.id }) {
            editingIndex = idx
            editingCar = appState.garage[idx]
        } else if !appState.garage.isEmpty {
            editingIndex = 0
            editingCar = appState.garage[0]
        } else {
            editingIndex = nil
            editingCar = CarConfig.stockOrange
        }
    }

    private func selectCar(index: Int) {
        editingIndex = index
        editingCar = appState.garage[index]
        previewScene.updateCar(config: editingCar)
        appState.carConfig = editingCar
        appState.saveCarConfig()
    }

    private func newCar() {
        editingIndex = nil
        editingCar = CarConfig(name: "New Car", body: "#ff8800", cabin: "#cc6600", wheels: "#222222", lights: "#ffee88", flame: "#ff6600")
        previewScene.updateCar(config: editingCar)
    }

    private func saveCar() {
        let name = editingCar.name.trimmingCharacters(in: .whitespacesAndNewlines)
        if name.isEmpty {
            editingCar.name = "Unnamed"
        }

        if let idx = editingIndex {
            appState.garage[idx] = editingCar
        } else {
            appState.garage.append(editingCar)
            editingIndex = appState.garage.count - 1
        }
        appState.carConfig = editingCar
        appState.saveGarageList()
        previewScene.updateCar(config: editingCar)
    }

    private func deleteCar() {
        guard let idx = editingIndex, appState.garage.count > 1 else { return }
        appState.garage.remove(at: idx)
        let newIdx = min(idx, appState.garage.count - 1)
        editingIndex = newIdx
        editingCar = appState.garage[newIdx]
        appState.carConfig = editingCar
        appState.saveGarageList()
        previewScene.updateCar(config: editingCar)
    }

    private func setColor(key: String, hex: String) {
        switch key {
        case "body": editingCar.body = hex
        case "cabin": editingCar.cabin = hex
        case "wheels": editingCar.wheels = hex
        case "lights": editingCar.lights = hex
        case "flame": editingCar.flame = hex
        default: break
        }
        previewScene.updateCar(config: editingCar)
    }
}
