import SwiftUI

struct OrganizerDashboardView: View {
    @State private var allEvents: [[String: Any]] = []
    @State private var selectedEventId: String = ""
    @State private var stats: [[String: Any]] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.11, blue: 0.08)
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    if !allEvents.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                Button(action: { selectedEventId = ""; fetchDashboard(eventId: nil) }) {
                                    Text("All Events")
                                        .font(.subheadline).fontWeight(.semibold)
                                        .padding(.horizontal, 16).padding(.vertical, 9)
                                        .background(selectedEventId.isEmpty ? Color(red: 0.6, green: 1.0, blue: 0.0) : Color.white.opacity(0.07))
                                        .foregroundColor(selectedEventId.isEmpty ? Color(red: 0.08, green: 0.11, blue: 0.08) : .white.opacity(0.7))
                                        .cornerRadius(20)
                                }
                                ForEach(0..<allEvents.count, id: \.self) { index in
                                    let event = allEvents[index]
                                    let eventId = event["event_id"] as? String ?? ""
                                    let eventName = event["event_name"] as? String ?? ""
                                    Button(action: { selectedEventId = eventId; fetchDashboard(eventId: eventId) }) {
                                        Text(eventName)
                                            .font(.subheadline).fontWeight(.semibold)
                                            .padding(.horizontal, 16).padding(.vertical, 9)
                                            .background(selectedEventId == eventId ? Color(red: 0.6, green: 1.0, blue: 0.0) : Color.white.opacity(0.07))
                                            .foregroundColor(selectedEventId == eventId ? Color(red: 0.08, green: 0.11, blue: 0.08) : .white.opacity(0.7))
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                        }
                    }

                    if isLoading {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.6, green: 1.0, blue: 0.0)))
                            .scaleEffect(1.4)
                        Spacer()
                    } else if stats.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "chart.bar.xaxis")
                                .font(.system(size: 50))
                                .foregroundColor(.white.opacity(0.15))
                            Text("No data yet")
                                .foregroundColor(.white.opacity(0.4))
                        }
                        Spacer()
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 16) {
                                ForEach(0..<stats.count, id: \.self) { index in
                                    let stat = stats[index]
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text(stat["event_name"] as? String ?? "")
                                            .font(.system(size: 16, weight: .bold))
                                            .foregroundColor(.white)

                                        HStack(spacing: 0) {
                                            statBox(title: "Sold", value: "\(stat["ticket_sold"] as? Int ?? 0)")
                                            Divider().background(Color.white.opacity(0.1))
                                            statBox(title: "Revenue", value: "SAR \(stat["sales"] as? Int ?? 0)")
                                            Divider().background(Color.white.opacity(0.1))
                                            statBox(title: "Capacity", value: "\(stat["event_capacity"] as? Int ?? 0)")
                                        }
                                        .frame(height: 60)
                                        .background(Color.white.opacity(0.05))
                                        .cornerRadius(12)

                                        let sold = stat["ticket_sold"] as? Int ?? 0
                                        let capacity = stat["event_capacity"] as? Int ?? 1
                                        let progress = Double(sold) / Double(capacity)

                                        VStack(alignment: .leading, spacing: 6) {
                                            HStack {
                                                Text("Tickets Sold")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.5))
                                                Spacer()
                                                Text("\(Int(progress * 100))%")
                                                    .font(.caption).fontWeight(.bold)
                                                    .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                                            }
                                            GeometryReader { geo in
                                                ZStack(alignment: .leading) {
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color.white.opacity(0.1))
                                                        .frame(height: 6)
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .fill(Color(red: 0.6, green: 1.0, blue: 0.0))
                                                        .frame(width: geo.size.width * CGFloat(min(progress, 1.0)), height: 6)
                                                }
                                            }
                                            .frame(height: 6)
                                        }
                                    }
                                    .padding(16)
                                    .background(Color.white.opacity(0.07))
                                    .cornerRadius(16)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { fetchAllEvents() }
        }
    }

    func statBox(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value).font(.system(size: 15, weight: .bold)).foregroundColor(.white)
            Text(title).font(.caption).foregroundColor(.white.opacity(0.4))
        }
        .frame(maxWidth: .infinity)
    }

    func fetchAllEvents() {
        let url = URL(string: "http://192.168.3.10:3000/api/events/my-events")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let eventList = result["events"] as? [[String: Any]] {
                DispatchQueue.main.async { allEvents = eventList; fetchDashboard(eventId: nil) }
            }
        }.resume()
    }

    func fetchDashboard(eventId: String?) {
        var urlString = "http://192.168.3.10:3000/api/events/dashboard"
        if let id = eventId { urlString += "?event_id=\(id)" }
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let dashboard = result["dashboard"] as? [[String: Any]] {
                DispatchQueue.main.async { stats = dashboard; isLoading = false }
            }
        }.resume()
    }
}

#Preview { OrganizerDashboardView() }
