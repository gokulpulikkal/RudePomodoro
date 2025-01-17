//
//  ContentView.swift
//  NotYourMom
//
//  Created by Gokul P on 1/16/25.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ViewModel()
    @State private var selectedMinutes = 10.0
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Not Your Mom")
                .font(.largeTitle)
                .bold()
            
            if viewModel.isMonitoring {
                // Timer Display
                Text(viewModel.formattedRemainingTime)
                    .font(.system(size: 60, weight: .bold, design: .monospaced))
                    .foregroundColor(.blue)
                
                Button(action: {
                    viewModel.stopMonitoring()
                }) {
                    Text("Stop Monitoring")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(10)
                }
            } else {
                // Duration Selection
                VStack(alignment: .leading) {
                    Text("Monitoring Duration: \(Int(selectedMinutes)) minutes")
                        .font(.headline)
                    
                    Slider(value: $selectedMinutes, in: 1...60, step: 1)
                }
                .padding()
                
                Button(action: {
                    viewModel.selectedDuration = selectedMinutes * 60
                    viewModel.startMonitoring()
                }) {
                    Text("Start Monitoring")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

// End of file. No additional code.
