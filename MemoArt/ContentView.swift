import SwiftUI
import ComposableArchitecture

struct ContentView: View {
    let store: Store<AppState, AppAction>
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        WithViewStore(store) { viewStore in
            NavigationView {
                stackOrScroll {
                    gameOverView
                    LazyVGrid(columns: columns) {
                        ForEach(0..<20) {
                            CardView(store: store.scope(state: { $0.game }, action: AppAction.game), id: $0)
                        }
                    }
                    .padding()
                }
                .animation(.spring())
                .onAppear(perform: { viewStore.send(.highScores(.load)) })
                .navigationBarTitle("Moves: \(viewStore.game.moves)", displayMode: .inline)
                .navigationBarItems(trailing: highScoresNavigationLink)
            }
            .sheet(isPresented: viewStore.binding(get: { $0.isNewHighScoreEntryPresented }, send: .newHighScoreEntered), content: {
                NewHighScoreView(store: store)
            })
            .navigationViewStyle(StackNavigationViewStyle())
        }
    }

    var columns: [GridItem] {
        let gridItemPattern = GridItem(.flexible(minimum: 50, maximum: 125))
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.compact, .regular):
            // 4x5 Grid
            return Array(repeating: gridItemPattern, count: 4)
        case (.compact, .compact):
            // 7x3 Grid
            return Array(repeating: gridItemPattern, count: 7)
        case (.regular, .regular):
            // 5x4 Grid, bigger images
            return Array(repeating: gridItemPattern, count: 5)
        default:
            return [GridItem(.adaptive(minimum: 100))]
        }
    }

    private var highScoresNavigationLink: some View {
        NavigationLink(
            destination: HighScoresView(store: store.scope(
                state: { $0.highScores },
                action: AppAction.highScores
            )),
            label: {
                Text("🏆")
            }
        )
        .accessibility(label: Text("High Scores"))
    }

    private var gameOverView: some View {
        WithViewStore(store) { viewStore in
            if viewStore.game.isGameOver {
                VStack {
                    Text("⭐️ Bravo ⭐️").font(.largeTitle)
                    Button(action: { viewStore.send(.game(.new)) }) {
                        Text("New Game")
                    }
                }
                .padding(.top)
                .transition(
                    .asymmetric(insertion: .slide, removal: .opacity)
                )
            }
        }
    }

    @ViewBuilder
    private func stackOrScroll<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        switch (horizontalSizeClass, verticalSizeClass) {
        case (.regular, .regular): VStack { content() }
        default: ScrollView { content() }
        }
    }
}

struct FlippedUpsideDown: ViewModifier {
    func body(content: Content) -> some View {
        content
            .rotationEffect(.radians(.pi))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
}
extension View{
    func flippedUpsideDown() -> some View{
        self.modifier(FlippedUpsideDown())
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store<AppState, AppAction>(
            initialState: AppState(),
            reducer: appReducer,
            environment: .preview
        ))
    }
}

struct ContentViewGameOver_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store<AppState, AppAction>(
            initialState: .mocked {
                $0.game.isGameOver = true
                $0.game.discoveredSymbolTypes = SymbolType.allCases
                $0.game.moves = 42
                $0.game.symbols = .predictedGameSymbols(isCardsFaceUp: true)
            },
            reducer: appReducer,
            environment: .preview
        ))
    }
}

struct ContentViewAlmostFinished_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(
            initialState: .almostFinishedGame,
            reducer: appReducer,
            environment: .preview
        ))
    }
}

extension AppState {
    static func mocked(modifier: (inout Self) -> Void) -> Self {
        var state = AppState()
        modifier(&state)
        return state
    }

    static let almostFinishedGame: Self = .mocked {
        $0.game.isGameOver = false
        $0.game.discoveredSymbolTypes = SymbolType.allCases.filter({ $0 != .cave })
        $0.game.moves = 142
        $0.game.symbols = [Symbol].predictedGameSymbols(isCardsFaceUp: true).map {
            if $0.type == .cave {
                return Symbol(id: $0.id, type: $0.type, isFaceUp: false)
            }
            return $0
        }
    }
}

extension AnyScheduler where SchedulerTimeType == DispatchQueue.SchedulerTimeType, SchedulerOptions == DispatchQueue.SchedulerOptions {
    static var preview: Self { DispatchQueue.main.eraseToAnyScheduler() }
}

extension AppEnvironment {
    static let preview: Self = AppEnvironment(
        mainQueue: .preview,
        loadHighScores: { .preview },
        saveHighScores: { _ in }
    )
}
#endif
