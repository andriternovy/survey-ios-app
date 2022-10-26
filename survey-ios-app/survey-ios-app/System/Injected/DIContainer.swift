//
//  DIContainer.swift
//  survey-ios-app
//
//  Created by Andrii Ternovyi on 18.10.2022.
//

import SwiftUI
import Combine

class DIContainer: ObservableObject {
    let interactors: Interactors

    init(interactors: Interactors) {
        self.interactors = interactors
    }
}
