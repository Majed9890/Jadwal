import SwiftUI

struct GlobalAnalyticsView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack(spacing: 15) {
                    StatCardView(title: "Total Attendees", value: "1,250")
                    StatCardView(title: "Total Organizers", value: "45")
                }
                HStack(spacing: 15) {
                    StatCardView(title: "Tickets Sold", value: "3,800")
                    StatCardView(title: "Total Revenue", value: "SAR 570,000")
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Global Analytics")
        }
    }
}

struct StatCardView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    GlobalAnalyticsView()
}
