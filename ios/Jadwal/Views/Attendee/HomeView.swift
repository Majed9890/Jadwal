import SwiftUI

struct HomeView: View {
    @State private var searchText = ""
    @State private var events: [[String: Any]] = []
    @State private var isLoading = true
    @State private var selectedCategory = "All"
    let categories = ["All", "Music", "Sports", "Art", "Technology", "Food", "Travel", "Fashion", "Gaming"]

    var filteredEvents: [[String: Any]] {
        if selectedCategory == "All" {
            return events
        }
        return events.filter {
            ($0["category"] as? String ?? "").lowercased() == selectedCategory.lowercased()
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(red: 0.08, green: 0.11, blue: 0.08)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 20) {

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Welcome Back,")
                                .font(.system(size: 28, weight: .light))
                                .foregroundColor(.white)
                            Text("Hope You're Well")
                                .font(.system(size: 28, weight: .heavy))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white.opacity(0.4))
                            TextField("", text: $searchText, onCommit: {
                                searchEvents()
                            })
                            .placeholder(when: searchText.isEmpty) {
                                Text("Search events...").foregroundColor(.white.opacity(0.3))
                            }
                            .foregroundColor(.white)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(16)
                        .padding(.horizontal, 20)

                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(categories, id: \.self) { cat in
                                    Button(action: {
                                        selectedCategory = cat
                                    }) {
                                        Text(cat)
                                            .font(.subheadline)
                                            .fontWeight(.semibold)
                                            .padding(.horizontal, 18)
                                            .padding(.vertical, 10)
                                            .background(
                                                selectedCategory == cat ?
                                                Color(red: 0.6, green: 1.0, blue: 0.0) :
                                                Color.white.opacity(0.07)
                                            )
                                            .foregroundColor(
                                                selectedCategory == cat ?
                                                Color(red: 0.08, green: 0.11, blue: 0.08) :
                                                Color.white.opacity(0.7)
                                            )
                                            .cornerRadius(20)
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        HStack {
                            Text("Upcoming Events")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(filteredEvents.count) events")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding(.horizontal, 20)

                        if isLoading {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .tint(Color(red: 0.6, green: 1.0, blue: 0.0))
                                Spacer()
                            }
                            .padding(.top, 40)
                        } else if filteredEvents.isEmpty {
                            HStack {
                                Spacer()
                                VStack(spacing: 10) {
                                    Image(systemName: "calendar.badge.exclamationmark")
                                        .font(.system(size: 40))
                                        .foregroundColor(.white.opacity(0.3))
                                    Text("No events found")
                                        .foregroundColor(.white.opacity(0.3))
                                }
                                Spacer()
                            }
                            .padding(.top, 40)
                        } else {
                            VStack(spacing: 16) {
                                ForEach(0..<filteredEvents.count, id: \.self) { index in
                                    let event = filteredEvents[index]
                                    NavigationLink(destination: EventDetailsView(event: event)) {
                                        EventCardView(event: event)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding(.horizontal, 20)
                        }

                        Spacer().frame(height: 30)
                    }
                }
            }
            .navigationBarHidden(true)
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

struct EventCardView: View {
    let event: [String: Any]

    var body: some View {
        ZStack(alignment: .bottomLeading) {
            if let imageUrl = event["image_url"] as? String, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Color(red: 0.15, green: 0.18, blue: 0.15)
                }
                .frame(height: 220)
                .clipped()
            } else {
                ZStack {
                    Color(red: 0.15, green: 0.18, blue: 0.15)
                        .frame(height: 220)
                    Image(systemName: "calendar")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.2))
                }
            }

            LinearGradient(
                colors: [.clear, .black.opacity(0.85)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 220)

            VStack(alignment: .leading, spacing: 6) {
                Text(event["category"] as? String ?? "")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))

                Text(event["event_name"] as? String ?? "")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .lineLimit(2)

                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        Text(event["city"] as? String ?? "")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "tag.fill")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                        Text("SAR \(event["ticket_type1_price"] as? Int ?? 0)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .padding(16)
        }
        .cornerRadius(20)
    }
}

#Preview {
    HomeView()
}
