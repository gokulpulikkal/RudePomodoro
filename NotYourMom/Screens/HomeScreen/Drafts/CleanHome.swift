//
//  CleanHome.swift
//  NotYourMom
//
//  Created by Gokul P on 1/28/25.
//

import RiveRuntime
import SwiftUI

@MainActor
struct CleanHome: View {
    @State var cleanViewModel = CleanViewModel()
    var body: some View {
        ZStack {
            Color(.gray)
                .ignoresSafeArea()
            VStack {
                rivAnimation
                    .frame(width: 300, height: 300)
                Button(action: {
                    cleanViewModel.changeState()
                }, label: {
                    Text("Change state")
                })

                Text(cleanViewModel.buttonText)
            }
        }
    }

    var rivAnimation: some View {
        cleanViewModel.rivAnimModel.view()
            .aspectRatio(contentMode: .fit)
    }
}

#Preview {
    CleanHome()
}
