import SwiftUI
import ComposableArchitecture

struct CardView: View {
    let store: Store<GameState, GameAction>
    let card: Card
    private static let turnCardAnimationDuration: Double = 2/5

    var body: some View {
        WithViewStore(store) { viewStore in
            ZStack {
                if !card.isFaceUp {
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
                card.isFaceUp
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
        card.art.image
            .renderingMode(.original)
            .resizable()
            .font(.largeTitle)
    }

    private var turnTransition: AnyTransition {
        AnyTransition.opacity.animation(
            Animation
                .linear(duration: 0.01)
                .delay(Self.turnCardAnimationDuration/2)
        )
    }

    private func returnCard(store: ViewStore<GameState, GameAction>) {
        withAnimation(.spring()) { store.send(.cardReturned(card.id)) }
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
                            CardView(store: store, card: card(store: viewStore, id: 0))
                            CardView(store: store, card: card(store: viewStore, id: 1))
                        }
                        HStack {
                            CardView(store: store, card: card(store: viewStore, id: 2))
                            CardView(store: store, card: card(store: viewStore, id: 3))
                        }
                        HStack {
                            CardView(store: store, card: card(store: viewStore, id: 4))
                            CardView(store: store, card: card(store: viewStore, id: 5))
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

        private func card(store: ViewStore<GameState, GameAction>, id: Int) -> Card {
            store.cards[id]
        }
    }
}
#endif
