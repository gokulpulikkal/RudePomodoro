import SwiftUI
import SwiftData

struct SessionHistoryView: View {
    @Bindable var viewModel: SessionHistoryViewModel
    
    var body: some View {
        VStack {
            Text("Session History")
                .font(.sourGummy(.bold, size: 24))
                .foregroundStyle(.white)
                .padding()
            
            if viewModel.sessions.isEmpty {
                ContentUnavailableView(
                    "No Sessions Yet",
                    systemImage: "clock.badge.xmark",
                    description: Text("Complete your first session to see it here")
                )
                .foregroundStyle(.white)
            } else {
                List {
                    ForEach(viewModel.sessions) { session in
                        SessionRowView(session: session)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RadialGradientView()
                .ignoresSafeArea()
        )
    }
}

struct SessionRowView: View {
    let session: PomodoroSession
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(session.formattedDate)
                    .font(.sourGummy(.regular, size: 16))
                Text(session.formattedDuration)
                    .font(.sourGummy(.medium, size: 14))
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: session.wasCompleted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(session.wasCompleted ? .green : .red)
        }
        .padding(.vertical, 8)
        .listRowBackground(Color.clear)
        .foregroundStyle(.white)
    }
} 

#Preview {
    
}
