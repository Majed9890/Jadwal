import SwiftUI

struct PendingEventsView: View {
    @State private var events: [[String: Any]] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.11, blue: 0.08)
                    .ignoresSafeArea()

                if isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.6, green: 1.0, blue: 0.0)))
                            .scaleEffect(1.4)
                        Text("Loading...")
                            .foregroundColor(.white.opacity(0.5))
                            .font(.subheadline)
                    }
                } else if events.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.badge.questionmark")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.15))
                        Text("No pending events")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.4))
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            ForEach(0..<events.count, id: \.self) { index in
                                let event = events[index]
                                VStack(alignment: .leading, spacing: 14) {

                                    // Header
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(event["event_name"] as? String ?? "")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                            Text(event["category"] as? String ?? "")
                                                .font(.caption)
                                                .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                                        }
                                        Spacer()
                                        Text("Pending")
                                            .font(.caption).fontWeight(.semibold)
                                            .foregroundColor(.orange)
                                            .padding(.horizontal, 10).padding(.vertical, 4)
                                            .background(Color.orange.opacity(0.15))
                                            .cornerRadius(8)
                                    }

                                    // Details
                                    VStack(spacing: 8) {
                                        infoRow(label: "City", value: event["city"] as? String ?? "")
                                        infoRow(label: "Location", value: event["location"] as? String ?? "")
                                        infoRow(label: "District", value: event["district"] as? String ?? "")
                                        infoRow(label: "Road", value: event["road_name"] as? String ?? "")
                                        infoRow(label: "Start", value: event["start_date"] as? String ?? "")
                                        infoRow(label: "End", value: event["end_date"] as? String ?? "")
                                        infoRow(label: "Time", value: event["time"] as? String ?? "")
                                        infoRow(label: "Capacity", value: "\(event["event_capacity"] as? Int ?? 0)")
                                        infoRow(label: "Ticket 1", value: "\(event["ticket_type1_name"] as? String ?? "") — SAR \(event["ticket_type1_price"] as? Int ?? 0)")
                                        if let t2name = event["ticket_type2_name"] as? String, !t2name.isEmpty {
                                            infoRow(label: "Ticket 2", value: "\(t2name) — SAR \(event["ticket_type2_price"] as? Int ?? 0)")
                                        }
                                    }

                                    // Description
                                    if let desc = event["description"] as? String, !desc.isEmpty {
                                        Text(desc)
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.5))
                                            .lineSpacing(4)
                                            .fixedSize(horizontal: false, vertical: true)
                                    }

                                    // Buttons
                                    HStack(spacing: 10) {
                                        Button(action: {
                                            updateStatus(event_id: event["event_id"] as? String ?? "", status: "approved")
                                        }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: "checkmark.circle.fill")
                                                Text("Approve")
                                            }
                                            .font(.subheadline).fontWeight(.bold)
                                            .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.08))
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color(red: 0.6, green: 1.0, blue: 0.0))
                                            .cornerRadius(12)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())

                                        Button(action: {
                                            updateStatus(event_id: event["event_id"] as? String ?? "", status: "rejected")
                                        }) {
                                            HStack(spacing: 6) {
                                                Image(systemName: "xmark.circle.fill")
                                                Text("Reject")
                                            }
                                            .font(.subheadline).fontWeight(.bold)
                                            .foregroundColor(.red)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 12)
                                            .background(Color.red.opacity(0.1))
                                            .cornerRadius(12)
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                }
                                .padding(16)
                                .background(Color.white.opacity(0.07))
                                .cornerRadius(16)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("Pending Events")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { fetchEvents() }
        }
    }

    func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.4))
                .frame(width: 60, alignment: .leading)
            Text(value)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
            Spacer()
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
                DispatchQueue.main.async { events = list; isLoading = false }
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
        URLSession.shared.dataTask(with: request) { _, _, _ in
            DispatchQueue.main.async { fetchEvents() }
        }.resume()
    }
}

#Preview { PendingEventsView() }
