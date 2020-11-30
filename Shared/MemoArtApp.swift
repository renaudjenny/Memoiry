import SwiftUI
import ComposableArchitecture

@main
struct MemoArtApp: App {
    #if os(macOS)
    // swiftlint:disable:next weak_delegate
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    #endif

    let store = Store(
        initialState: AppState(
            game: GameState(cards: .newGame(
                from: loadConfiguration().selectedArts,
                level: loadGame().level
            )),
            configuration: loadConfiguration()
        ),
        reducer: appReducer,
        environment: AppEnvironment(
            mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
            saveGame: saveGame,
            loadGame: loadGame,
            clearGameBackup: clearGameBackup,
            loadHighScores: loadHighScores,
            saveHighScores: saveHighScores,
            generateRandomCards: { .newGame(from: $0, level: $1) },
            saveConfiguration: saveConfiguration,
            loadConfiguration: loadConfiguration
        )
    )
    @State private var isAboutWindowOpened = false
    @State private var isNewGameAlertPresented = false

    var body: some Scene {
        WindowGroup {
            WithViewStore(store) { viewStore in
                MainView(store: store)
                    .background(EmptyView().sheet(isPresented: $isAboutWindowOpened) {
                        AboutSheetView(isOpen: $isAboutWindowOpened)
                    })
                    .modifier(SetupNewGameAlert(
                        store: store.gameStore,
                        isPresented: $isNewGameAlertPresented
                    ))
                    .onAppear { viewStore.send(.game(.load)) }
                    .onAppear { viewStore.send(.highScores(.load)) }
            }
        }
        .commands {
            CommandGroup(replacing: CommandGroupPlacement.newItem) {
                WithViewStore(store) { viewStore in
                    Button {
                        guard viewStore.game.moves > 0 else {
                            viewStore.send(.game(.new))
                            return
                        }
                        isNewGameAlertPresented = true
                    } label: {
                        Text("New Game")
                    }
                    .disabled(!viewStore.game.isGameInProgress)
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            CommandGroup(replacing: CommandGroupPlacement.pasteboard) {
                EmptyView()
            }
            CommandGroup(replacing: CommandGroupPlacement.undoRedo) {
                EmptyView()
            }
            CommandGroup(replacing: CommandGroupPlacement.help) {
                EmptyView()
            }
            CommandGroup(replacing: CommandGroupPlacement.appInfo) {
                Button {
                    isAboutWindowOpened = true
                } label: {
                    Text("About MemoArt")
                }
            }
        }
    }
}

// MARK: Game Persistence
extension MemoArtApp {
    private static let gameKey = "MemoArtGameState"

    private static func saveGame(game: GameState) {
        UserDefaults.standard.setValue(try? JSONEncoder().encode(game), forKey: gameKey)
    }

    private static func loadGame() -> GameState {
        guard
            let data = UserDefaults.standard.data(forKey: gameKey),
            let game = try? JSONDecoder().decode(GameState.self, from: data)
        else { return GameState() }

        return game
    }

    private static func clearGameBackup() {
        UserDefaults.standard.removeObject(forKey: gameKey)
    }
}

// MARK: High Scores Persistence
extension MemoArtApp {
    private static let highScoresKey = "MemoArtHighScores"

    private static func loadHighScores() -> [HighScore] {
        guard
            let data = UserDefaults.standard.data(forKey: highScoresKey),
            let highScores = try? JSONDecoder().decode([HighScore].self, from: data)
        else { return [] }

        return highScores
    }

    private static func saveHighScores(highScores: [HighScore]) {
        UserDefaults.standard.setValue(try? JSONEncoder().encode(highScores), forKey: highScoresKey)
    }
}

// MARK: Configuration Persistence
extension MemoArtApp {
    private static let configurationKey = "MemoArtConfigurationState"

    private static func saveConfiguration(configuration: ConfigurationState) {
        UserDefaults.standard.setValue(try? JSONEncoder().encode(configuration), forKey: configurationKey)
    }

    private static func loadConfiguration() -> ConfigurationState {
        guard
            let data = UserDefaults.standard.data(forKey: configurationKey),
            let configuration = try? JSONDecoder().decode(ConfigurationState.self, from: data)
        else { return ConfigurationState() }

        return configuration
    }
}
