import SwiftUI

struct GlobalAnalyticsView: View {
    @State private var totalAttendees = 0
    @State private var totalOrganizers = 0
    @State private var totalTickets = 0
    @State private var totalRevenue = 0.0
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading analytics...")
                } else {
                    VStack(spacing: 20) {
                        HStack(spacing: 15) {
                            StatCardView(title: "Total Attendees", value: "\(totalAttendees)")
                            StatCardView(title: "Total Organizers", value: "\(totalOrganizers)")
                        }
                        HStack(spacing: 15) {
                            StatCardView(title: "Tickets Sold", value: "\(totalTickets)")
                            StatCardView(title: "Total Revenue", value: "SAR \(Int(totalRevenue))")
                        }
                        Spacer()
                    }
                    .padding()
                }
            }
            .navigationTitle("Global Analytics")
            .onAppear {
                fetchAnalytics()
            }
        }
    }
    
    func fetchAnalytics() {
        let url = URL(string: "http://localhost:3000/api/admin/analytics")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    totalAttendees = result["total_attendees"] as? Int ?? 0
                    totalOrganizers = result["total_organizers"] as? Int ?? 0
                    totalTickets = result["total_tickets_sold"] as? Int ?? 0
                    totalRevenue = result["total_revenue"] as? Double ?? 0.0
                    isLoading = false
                }
            }
        }.resume()
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
