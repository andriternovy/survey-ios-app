//
//  FailureVire.swift
//  survey-ios-app
//
//  Created by Andrii Ternovyi on 26.10.2022.
//

import SwiftUI

struct FailureView: View {
    var height: CGFloat = 100
    var retryAction: () -> Void
    var body: some View {
        HStack {
            Text("Failure")
            Spacer()
            Button(
                action: { retryAction() },
                label: { Text("RETRY") }
            )
            .padding(5)
            .border(.white)
        }
        .foregroundColor(.white)
        .padding(20)
        .frame(height: height)
        .background(Color.red)
    }
}
