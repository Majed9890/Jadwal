import SwiftUI

struct MyEventsView: View {
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
                        Text("Loading events...")
                            .foregroundColor(.white.opacity(0.5))
                            .font(.subheadline)
                    }
                } else if events.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.15))
                        Text("No events yet")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.4))
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            ForEach(0..<events.count, id: \.self) { index in
                                let event = events[index]
                                NavigationLink(destination: OrganizerEventDetailView(event: event)) {
                                    HStack(spacing: 14) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(statusColor(event["event_status"] as? String ?? ""))
                                            .frame(width: 4)

                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(event["event_name"] as? String ?? "")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.leading)

                                            HStack(spacing: 8) {
                                                Text(event["category"] as? String ?? "")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.5))
                                                Text("•")
                                                    .foregroundColor(.white.opacity(0.3))
                                                Text(event["city"] as? String ?? "")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.5))
                                            }
                                        }

                                        Spacer()

                                        VStack(alignment: .trailing, spacing: 6) {
                                            Text(event["event_status"] as? String ?? "")
                                                .font(.caption).fontWeight(.semibold)
                                                .foregroundColor(statusColor(event["event_status"] as? String ?? ""))
                                                .padding(.horizontal, 10).padding(.vertical, 4)
                                                .background(statusColor(event["event_status"] as? String ?? "").opacity(0.15))
                                                .cornerRadius(8)
                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 12))
                                                .foregroundColor(.white.opacity(0.3))
                                        }
                                    }
                                    .padding(16)
                                    .background(Color.white.opacity(0.07))
                                    .cornerRadius(16)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationTitle("My Events")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { fetchEvents() }
        }
    }

    func statusColor(_ status: String) -> Color {
        switch status {
        case "approved": return Color(red: 0.6, green: 1.0, blue: 0.0)
        case "rejected": return .red
        default: return .orange
        }
    }

    func fetchEvents() {
        let url = URL(string: "http://192.168.3.10:3000/api/events/my-events")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let eventList = result["events"] as? [[String: Any]] {
                DispatchQueue.main.async { events = eventList; isLoading = false }
            }
        }.resume()
    }
}

#Preview { MyEventsView() }
