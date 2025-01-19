////
////  TestView.swift
////  NotYourMom
////
////  Created by Gokul P on 1/19/25.
////
//
//import SwiftUI
//
//struct TestView: View {
//    @Namespace var namespace
//
//    var body: some View {
//        NavigationStack {
//            NavigationLink {
//                Text("Detail View")
//                    .navigationTransition(.zoom(sourceID: "icon", in: namespace))
//            } label: {
//                Image(systemName: "house")
//                    .font(.largeTitle)
//                    .foregroundColor(.white)
//                    .padding(30)
//                    .background(.blue)
//                    .cornerRadius(30)
//                    .matchedTransitionSource(id: "icon", in: namespace)
//            }
//        }
//    }
//}
//
//#Preview {
//    TestView()
//}
