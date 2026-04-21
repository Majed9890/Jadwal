import SwiftUI

struct OrganizerDashboardView: View {
    @State private var stats: [[String: Any]] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading dashboard...")
                } else if stats.isEmpty {
                    Text("No data yet")
                        .foregroundColor(.gray)
                } else {
                    List(0..<stats.count, id: \.self) { index in
                        let stat = stats[index]
                        VStack(alignment: .leading, spacing: 8) {
                            Text(stat["event_name"] as? String ?? "")
                                .font(.headline)
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Tickets Sold")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("\(stat["ticket_sold"] as? Int ?? 0)")
                                        .fontWeight(.bold)
                                }
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("Revenue")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("SAR \(stat["sales"] as? Int ?? 0)")
                                        .fontWeight(.bold)
                                }
                                Spacer()
                                VStack(alignment: .leading) {
                                    Text("Capacity")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("\(stat["event_capacity"] as? Int ?? 0)")
                                        .fontWeight(.bold)
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("Dashboard")
            .onAppear {
                fetchDashboard()
            }
        }
    }
    
    func fetchDashboard() {
        let url = URL(string: "http://localhost:3000/api/events/dashboard")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dashboard = result["dashboard"] as? [[String: Any]] {
                DispatchQueue.main.async {
                    stats = dashboard
                    isLoading = false
                }
            }
        }.resume()
    }
}

#Preview {
    OrganizerDashboardView()
}
