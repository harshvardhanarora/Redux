//
//  Store.swift
//
//  Created by Harshvardhan Arora on 28/10/2023.
//

import Foundation
import Combine
import SwiftUI

public class Store<State, Action, Environment>: ObservableObject {

    @Published public private(set) var state: State
    
    public private(set) var environment: Environment

    private let reducer: Reducer<State, Action>
    private let middleware: Middleware<State, Action, Environment>

    public var subscriptions: Set<AnyCancellable> = []

    public init(initial: State,
                reducer: @escaping Reducer<State, Action>,
                environment: Environment,
                middleware: @escaping Middleware<State, Action, Environment>,
                subscriber: Subscribers<Store> = { _ in }) {
        self.state = initial
        self.reducer = reducer
        self.environment = environment
        self.middleware = middleware
        
        subscriber(self)
    }

    public func dispatch(_ action: Action) {
        DispatchQueue.main.async {
            self.dispatch(self.state, action)
        }
    }

    private func dispatch(_ currentState: State, _ action: Action) {
        let newState = self.reducer(currentState, action)
        self.state = newState
        Task {
            guard let newAction = await middleware(newState, action, environment) else {
                return
            }
            dispatch(newAction)
        }
    }
}

