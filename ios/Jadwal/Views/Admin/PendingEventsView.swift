import SwiftUI

struct PendingEventsView: View {
    @State private var events: [[String: Any]] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading...")
                } else if events.isEmpty {
                    Text("No pending events")
                        .foregroundColor(.gray)
                } else {
                    List(0..<events.count, id: \.self) { index in
                        let event = events[index]
                        VStack(alignment: .leading, spacing: 8) {
                            Text(event["event_name"] as? String ?? "")
                                .font(.headline)
                            Text(event["category"] as? String ?? "")
                                .foregroundColor(.gray)
                            HStack {
                                Text(event["city"] as? String ?? "")
                                Spacer()
                                Text("SAR \(event["ticket_type1_price"] as? Int ?? 0)")
                                    .fontWeight(.bold)
                            }
                            .font(.caption)

                            HStack {
                                Button(action: {
                                    updateStatus(event_id: event["event_id"] as? String ?? "", status: "approved")
                                }) {
                                    Text("Approve")
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(8)
                                        .background(Color.green)
                                        .cornerRadius(8)
                                }

                                Button(action: {
                                    updateStatus(event_id: event["event_id"] as? String ?? "", status: "rejected")
                                }) {
                                    Text("Reject")
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(8)
                                        .background(Color.red)
                                        .cornerRadius(8)
                                }
                            }
                        }
                        .padding(.vertical, 5)
                    }
                }
            }
            .navigationTitle("Pending Events")
            .onAppear {
                fetchEvents()
            }
        }
    }

    func fetchEvents() {
        let url = URL(string: "http://localhost:3000/api/admin/events/pending")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }

            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let list = result["events"] as? [[String: Any]] {
                DispatchQueue.main.async {
                    events = list
                    isLoading = false
                }
            }
        }.resume()
    }

    func updateStatus(event_id: String, status: String) {
        let url = URL(string: "http://localhost:3000/api/admin/events/status")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = ["event_id": event_id, "status": status]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                fetchEvents()
            }
        }.resume()
    }
}

#Preview {
    PendingEventsView()
}
