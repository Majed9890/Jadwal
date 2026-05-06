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
                    ScrollView {
                        VStack(spacing: 15) {
                            ForEach(0..<events.count, id: \.self) { index in
                                let event = events[index]
                                VStack(alignment: .leading, spacing: 8) {
                                    Text(event["event_name"] as? String ?? "")
                                        .font(.headline)
                                    Text(event["category"] as? String ?? "")
                                        .foregroundColor(.gray)
                                    Text("City: \(event["city"] as? String ?? "")")
                                        .font(.caption)
                                    Text("Location: \(event["location"] as? String ?? "")")
                                        .font(.caption)
                                    Text("District: \(event["district"] as? String ?? "")")
                                        .font(.caption)
                                    Text("Road: \(event["road_name"] as? String ?? "")")
                                        .font(.caption)
                                    Text("Start: \(event["start_date"] as? String ?? "")")
                                        .font(.caption)
                                    Text("End: \(event["end_date"] as? String ?? "")")
                                        .font(.caption)
                                    Text("Time: \(event["time"] as? String ?? "")")
                                        .font(.caption)
                                    Text("Capacity: \(event["event_capacity"] as? Int ?? 0)")
                                        .font(.caption)
                                    Text("Ticket 1: \(event["ticket_type1_name"] as? String ?? "") - SAR \(event["ticket_type1_price"] as? Int ?? 0)")
                                        .font(.caption)

                                    if let t2name = event["ticket_type2_name"] as? String, !t2name.isEmpty {
                                        Text("Ticket 2: \(t2name) - SAR \(event["ticket_type2_price"] as? Int ?? 0)")
                                            .font(.caption)
                                    }

                                    Text("Description: \(event["description"] as? String ?? "")")
                                        .font(.caption)
                                        .foregroundColor(.gray)

                                    HStack(spacing: 10) {
                                        Button {
                                            updateStatus(event_id: event["event_id"] as? String ?? "", status: "approved")
                                        } label: {
                                            Text("Approve")
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(10)
                                                .background(Color.green)
                                                .cornerRadius(8)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())

                                        Button {
                                            updateStatus(event_id: event["event_id"] as? String ?? "", status: "rejected")
                                        } label: {
                                            Text("Reject")
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding(10)
                                                .background(Color.red)
                                                .cornerRadius(8)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                                .padding(.horizontal, 16)
                            }
                        }
                        .padding(.vertical, 10)
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
        let url = URL(string: "http://192.168.3.10:3000/api/admin/events/pending")!
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
        let url = URL(string: "http://192.168.3.10:3000/api/admin/events/status")!
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
