//
//  TypewriterView.swift
//  NotYourMom
//
//  Created by Gokul P on 1/23/25.
//

import SwiftUI

struct TypewriterView: View {
    var text: String
    var typingDelay: Duration = .milliseconds(50)

    @State private var animatedText: AttributedString = ""
    @State private var typingTask: Task<Void, Error>?

    var body: some View {
        Text(animatedText)
            .onChange(of: text) { animateText() }
            .onAppear { animateText() }
    }

    private func animateText() {
        typingTask?.cancel()

        typingTask = Task {
            let defaultAttributes = AttributeContainer()
            animatedText = AttributedString(
                text,
                attributes: defaultAttributes.foregroundColor(.clear)
            )

            var index = animatedText.startIndex
            while index < animatedText.endIndex {
                try Task.checkCancellation()

                // Update the style
                animatedText[animatedText.startIndex...index]
                    .setAttributes(defaultAttributes)

                // Wait
                try await Task.sleep(for: typingDelay)

                // Advance the index, character by character
                index = animatedText.index(afterCharacter: index)
            }
        }
    }
}

struct AnimatedStateChangeView_Previews: PreviewProvider {
    static var text = "Hello, Twitter! This is a typewriter animation."
    static var previews: some View {
        TypewriterView(text: text)
            .font(.system(size: 20, weight: .bold, design: .rounded))
            .padding()
    }
}
