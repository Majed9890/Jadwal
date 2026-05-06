import SwiftUI

struct HomeView: View {
    @State private var searchText = ""
    @State private var events: [[String: Any]] = []
    @State private var isLoading = true

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                TextField("Search events...", text: $searchText, onCommit: {
                    searchEvents()
                })
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal, 16)
                .padding(.top, 10)

                if isLoading {
                    Spacer()
                    ProgressView("Loading events...")
                    Spacer()
                } else if events.isEmpty {
                    Spacer()
                    Text("No events found")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    List(0..<events.count, id: \.self) { index in
                        let event = events[index]
                        NavigationLink(destination: EventDetailsView(event: event)) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(event["event_name"] as? String ?? "")
                                    .font(.headline)
                                Text(event["category"] as? String ?? "")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                HStack {
                                    Text(event["city"] as? String ?? "")
                                    Spacer()
                                    Text("SAR \(event["ticket_type1_price"] as? Int ?? 0)")
                                        .fontWeight(.bold)
                                }
                                .font(.caption)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
            .navigationTitle("Jadwal")
            .onAppear {
                fetchEvents()
            }
        }
    }

    func fetchEvents() {
        let url = URL(string: "http://192.168.3.10:3000/api/events/search?keyword=")!
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

    func searchEvents() {
        let keyword = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let url = URL(string: "http://192.168.3.10:3000/api/events/search?keyword=\(keyword)")!
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
    HomeView()
}
