//
//  SuccessView.swift
//  survey-ios-app
//
//  Created by Andrii Ternovyi on 26.10.2022.
//

import SwiftUI

struct SuccessView: View {
    var height: CGFloat = 100
    var body: some View {
        HStack {
            Text("Success")
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: height)
        .background(Color.green)
    }
}
