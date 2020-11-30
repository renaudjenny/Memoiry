import SwiftUI
import ComposableArchitecture

struct CardView: View {
    let store: Store<GameState, GameAction>
    // FIXME: This should use a Card directly instead of an id
    let id: Int
    private static let turnCardAnimationDuration: Double = 2/5

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                if !viewStore.state.isCardValid(id: id) {
                    EmptyView()
                } else if !viewStore.cards[id].isFaceUp {
                    Button {
                        returnCard(store: viewStore)
                    } label: {
                        Color.red
                    }
                    .buttonStyle(PlainButtonStyle())
                    .transition(turnTransition)
                } else {
                    image.transition(turnTransition)
                }
            }
            .modifier(AddCardStyle())
            .rotation3DEffect(
                viewStore.state.isCardValid(id: id) && viewStore.cards[id].isFaceUp
                    ? .radians(.pi)
                    : .zero,
                axis: (x: 0.0, y: 1.0, z: 0.0),
                perspective: 1/3
            )
            .animation(.easeInOut(duration: Self.turnCardAnimationDuration))
            .rotation3DEffect(.radians(.pi), axis: (x: 0.0, y: 1.0, z: 0.0))
        }
    }

    private var image: some View {
        WithViewStore(store) { viewStore in
            viewStore.cards[id].art.image
                .renderingMode(.original)
                .resizable()
                .font(.largeTitle)
        }
    }

    private var turnTransition: AnyTransition {
        AnyTransition.opacity.animation(
            Animation
                .linear(duration: 0.01)
                .delay(Self.turnCardAnimationDuration/2)
        )
    }

    private func returnCard(store: ViewStore<GameState, GameAction>) {
        withAnimation(.spring()) { store.send(.cardReturned(id)) }
    }
}

#if DEBUG
struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        Preview()
    }

    private struct Preview: View {
        let store = Store<GameState, GameAction>(
            initialState: GameState(),
            reducer: gameReducer,
            environment: GameEnvironment(
                mainQueue: .preview,
                save: { _ in },
                load: { GameState() },
                clearBackup: { }
            )
        )

        var body: some View {
            WithViewStore(store) { viewStore in
                VStack {
                    Spacer()
                    VStack {
                        HStack {
                            CardView(store: store, id: 0)
                            CardView(store: store, id: 1)
                        }
                        HStack {
                            CardView(store: store, id: 2)
                            CardView(store: store, id: 3)
                        }
                        HStack {
                            CardView(store: store, id: 4)
                            CardView(store: store, id: 5)
                        }
                    }
                    Spacer()
                    Button(action: { viewStore.send(.new) }, label: {
                        Text("New game!")
                    })
                    .padding()
                }.padding()
            }
        }
    }
}
#endif
