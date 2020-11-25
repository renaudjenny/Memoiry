import XCTest
@testable import MemoArt
import ComposableArchitecture

class ConfigurationCoreTests: XCTestCase {
    let scheduler = DispatchQueue.testScheduler

    func testUnselectArt() {
        let store = TestStore(
            initialState: ConfigurationState(),
            reducer: configurationReducer,
            environment: ConfigurationEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                save: { _ in },
                load: { ConfigurationState() }
            )
        )
        store.assert(
            .send(.unselectArt(.cave)) {
                $0.selectedArts = Set(Art.allCases.filter({ $0 != .cave }))
            },
            .do { self.scheduler.advance(by: .seconds(2)) },
            .receive(.save)
        )
    }

    func testSelectArt() {
        let store = TestStore(
            initialState: .allArtsButCave,
            reducer: configurationReducer,
            environment: ConfigurationEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                save: { _ in },
                load: { ConfigurationState() }
            )
        )
        store.assert(
            .send(.selectArt(.cave)) {
                $0.selectedArts = Set(Art.allCases)
            },
            .do { self.scheduler.advance(by: .seconds(2)) },
            .receive(.save)
        )
    }

    func testUnselectArtWhenThereIsOnlyTenRemainingSelectedArts() {
        let store = TestStore(
            initialState: .onlyTenSelectedArts,
            reducer: configurationReducer,
            environment: ConfigurationEnvironment(
                mainQueue: scheduler.eraseToAnyScheduler(),
                save: { _ in },
                load: { ConfigurationState() }
            )
        )
        store.assert(
            .send(.unselectArt(.cave))
        )
        // Do not receive .save here, it's not necessary
    }
}

extension ConfigurationState {
    static var allArtsButCave: Self {
        ConfigurationState(
            selectedArts: Set(Art.allCases.filter({ $0 != .cave }))
        )
    }

    static var onlyTenSelectedArts: Self {
        ConfigurationState(
            selectedArts: Set(Art.allCases.prefix(10))
        )
    }
}