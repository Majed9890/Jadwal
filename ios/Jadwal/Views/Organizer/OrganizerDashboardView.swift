import SwiftUI

struct OrganizerDashboardView: View {
    @State private var allEvents: [[String: Any]] = []
    @State private var selectedEventId: String = ""
    @State private var stats: [[String: Any]] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if !allEvents.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            Button(action: {
                                selectedEventId = ""
                                fetchDashboard(eventId: nil)
                            }) {
                                Text("All Events")
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(selectedEventId.isEmpty ? Color.blue : Color(.systemGray5))
                                    .foregroundColor(selectedEventId.isEmpty ? .white : .black)
                                    .cornerRadius(20)
                            }
                            
                            ForEach(0..<allEvents.count, id: \.self) { index in
                                let event = allEvents[index]
                                let eventId = event["event_id"] as? String ?? ""
                                let eventName = event["event_name"] as? String ?? ""
                                Button(action: {
                                    selectedEventId = eventId
                                    fetchDashboard(eventId: eventId)
                                }) {
                                    Text(eventName)
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 8)
                                        .background(selectedEventId == eventId ? Color.blue : Color(.systemGray5))
                                        .foregroundColor(selectedEventId == eventId ? .white : .black)
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                    }
                }
                
                Group {
                    if isLoading {
                        Spacer()
                        ProgressView("Loading dashboard...")
                        Spacer()
                    } else if stats.isEmpty {
                        Spacer()
                        Text("No data yet")
                            .foregroundColor(.gray)
                        Spacer()
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
            }
            .navigationTitle("Dashboard")
            .onAppear {
                fetchAllEvents()
            }
        }
    }
    
    func fetchAllEvents() {
        let url = URL(string: "http://localhost:3000/api/events/my-events")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let eventList = result["events"] as? [[String: Any]] {
                DispatchQueue.main.async {
                    allEvents = eventList
                    fetchDashboard(eventId: nil)
                }
            }
        }.resume()
    }
    
    func fetchDashboard(eventId: String?) {
        var urlString = "http://localhost:3000/api/events/dashboard"
        if let id = eventId {
            urlString += "?event_id=\(id)"
        }
        
        let url = URL(string: urlString)!
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
