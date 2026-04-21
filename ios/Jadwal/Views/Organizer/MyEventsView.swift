import SwiftUI

struct MyEventsView: View {
    @State private var events: [[String: Any]] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading events...")
                } else if events.isEmpty {
                    Text("No events yet")
                        .foregroundColor(.gray)
                } else {
                    List(0..<events.count, id: \.self) { index in
                        let event = events[index]
                        VStack(alignment: .leading, spacing: 5) {
                            Text(event["event_name"] as? String ?? "")
                                .font(.headline)
                            Text(event["category"] as? String ?? "")
                                .foregroundColor(.gray)
                            HStack {
                                Text(event["city"] as? String ?? "")
                                Spacer()
                                Text(event["event_status"] as? String ?? "")
                                    .font(.caption)
                                    .padding(5)
                                    .background(statusColor(event["event_status"] as? String ?? ""))
                                    .foregroundColor(.white)
                                    .cornerRadius(5)
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("My Events")
            .onAppear {
                fetchEvents()
            }
        }
    }
    
    func statusColor(_ status: String) -> Color {
        switch status {
        case "approved": return .green
        case "rejected": return .red
        default: return .orange
        }
    }
    
    func fetchEvents() {
        let url = URL(string: "http://localhost:3000/api/events/my-events")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let eventList = result["events"] as? [[String: Any]] {
                DispatchQueue.main.async {
                    events = eventList
                    isLoading = false
                }
            }
        }.resume()
    }
}

#Preview {
    MyEventsView()
}
