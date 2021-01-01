import SwiftUI
import ComposableArchitecture

struct NewGameButton: View {
    let store: Store<GameState, GameAction>

    var body: some View {
        WithViewStore(store) { viewStore in
            Button { viewStore.send(.alertUserBeforeNewGame) } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
            }
            .accessibility(label: Text("New Game"))
            .disabled(!viewStore.isGameInProgress)
        }
    }
}
