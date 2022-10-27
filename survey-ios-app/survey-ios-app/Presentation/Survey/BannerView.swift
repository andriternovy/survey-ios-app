//
//  BannerView.swift
//  survey-ios-app
//
//  Created by Andrii Ternovyi on 26.10.2022.
//

import SwiftUI

struct BannerModifier: ViewModifier {
    enum BannerType {
        case success
        case error

        var title: String {
            switch self {
            case .success:
                return "Success!"
            case .error:
                return "Failure!"
            }
        }

        var tintColor: Color {
            switch self {
            case .success:
                return .green
            case .error:
                return .red
            }
        }
    }

    var type: BannerType
    @Binding var show: Bool
    var retryAction: (() -> Void)?

    func body(content: Content) -> some View {
        ZStack {
            content
            if show {
                VStack {
                    HStack {
                        HStack {
                            Text(type.title)
                                .bold()
                            Spacer()
                            if type == .error {
                                Button(
                                    action: { retryAction?() },
                                    label: { Text("RETRY") }
                                )
                                .padding(5)
                                .border(.white)
                            }
                        }
                        Spacer()
                    }
                    .foregroundColor(Color.white)
                    .padding(12)
                    .background(type.tintColor)
                    .cornerRadius(8)
                    Spacer()
                }
                .padding()
                .transition(AnyTransition.move(edge: .top).combined(with: .opacity))
                .onTapGesture {
                    withAnimation {
                        self.show = false
                    }
                }
                .onAppear(perform: {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            self.show = false
                        }
                    }
                })
            }
        }
    }
}

extension View {
    func banner(
        type: BannerModifier.BannerType,
        show: Binding<Bool>,
        retryAction: (() -> Void)? = nil
    ) -> some View {
        self.modifier(BannerModifier(type: type, show: show, retryAction: retryAction))
    }
}
