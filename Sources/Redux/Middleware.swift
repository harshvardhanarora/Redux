//
//  Middleware.swift
//
//  Created by Harshvardhan Arora on 28/10/2023.
//

import Foundation

public typealias Middleware<State, Action, Environment> = (State, Action, Environment) async -> Action?
