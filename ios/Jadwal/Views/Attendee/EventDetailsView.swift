import SwiftUI

struct EventDetailsView: View {
    let event: [String: Any]
    @State private var isLiked = false
    @State private var viewTimer: Timer?
    @State private var didRecordView = false
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.11, blue: 0.08)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {

                    ZStack(alignment: .top) {
                        if let imageUrl = event["image_url"] as? String, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color(red: 0.15, green: 0.18, blue: 0.15)
                            }
                            .frame(width: UIScreen.main.bounds.width, height: 300)
                            .clipped()
                        } else {
                            ZStack {
                                Color(red: 0.15, green: 0.18, blue: 0.15)
                                    .frame(height: 300)
                                Image(systemName: "calendar")
                                    .font(.system(size: 60))
                                    .foregroundColor(.white.opacity(0.2))
                            }
                        }

                        LinearGradient(
                            colors: [.black.opacity(0.5), .clear, .clear, Color(red: 0.08, green: 0.11, blue: 0.08)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 300)

                        HStack {
                            Button(action: {
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.4))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: "chevron.left")
                                        .foregroundColor(.white)
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                            Spacer()
                            Button(action: {
                                isLiked.toggle()
                                likeEvent()
                            }) {
                                ZStack {
                                    Circle()
                                        .fill(Color.black.opacity(0.4))
                                        .frame(width: 40, height: 40)
                                    Image(systemName: isLiked ? "heart.fill" : "heart")
                                        .foregroundColor(isLiked ? .red : .white)
                                        .font(.system(size: 16, weight: .semibold))
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 60)
                    }

                    VStack(alignment: .leading, spacing: 20) {

                        // Category badge + event name
                        VStack(alignment: .leading, spacing: 8) {
                            Text(event["category"] as? String ?? "")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 5)
                                .background(Color(red: 0.6, green: 1.0, blue: 0.0).opacity(0.15))
                                .cornerRadius(8)

                            Text(event["event_name"] as? String ?? "")
                                .font(.system(size: 26, weight: .heavy))
                                .foregroundColor(.white)
                                .fixedSize(horizontal: false, vertical: true)
                        }

                        // Info rows
                        VStack(spacing: 12) {
                            locationRow()
                            infoRow(icon: "calendar", title: "Date", value: "\(event["start_date"] as? String ?? "") → \(event["end_date"] as? String ?? "")")
                            infoRow(icon: "clock.fill", title: "Time", value: event["time"] as? String ?? "")
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)

                        // Description
                        if let desc = event["description"] as? String, !desc.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("About")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(desc)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.6))
                                    .lineSpacing(5)
                            }
                        }

                        // Tickets
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tickets")
                                .font(.headline)
                                .foregroundColor(.white)

                            if let t1name = event["ticket_type1_name"] as? String,
                               let t1price = event["ticket_type1_price"] as? Int {
                                HStack {
                                    Text(t1name)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("SAR \(t1price)")
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                                }
                                .padding(14)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                            }

                            if let t2name = event["ticket_type2_name"] as? String,
                               let t2price = event["ticket_type2_price"] as? Int,
                               !t2name.isEmpty {
                                HStack {
                                    Text(t2name)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Text("SAR \(t2price)")
                                        .fontWeight(.bold)
                                        .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                                }
                                .padding(14)
                                .background(Color.white.opacity(0.05))
                                .cornerRadius(12)
                            }
                        }

                        // Buy button
                        NavigationLink(destination: PurchaseTicketView(event: event)) {
                            Text("Buy Ticket")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.08))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color(red: 0.6, green: 1.0, blue: 0.0))
                                .cornerRadius(16)
                        }
                        .padding(.top, 8)

                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            checkLike()
            startViewTimer()
        }
        .onDisappear {
            viewTimer?.invalidate()
        }
    }

    func locationRow() -> some View {
        let locationString = event["location"] as? String ?? ""
        let cityString = event["city"] as? String ?? ""
        let displayValue = "\(locationString), \(cityString)"
        let isURL = locationString.lowercased().hasPrefix("http")

        return HStack(spacing: 12) {
            Image(systemName: "mappin.circle.fill")
                .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text("Location")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
                if isURL, let url = URL(string: locationString) {
                    Link(destination: url) {
                        HStack(spacing: 6) {
                            Text("Open in Maps")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                            Image(systemName: "arrow.up.right")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                        }
                    }
                } else {
                    Text(displayValue)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
            }
            Spacer()
        }
    }

    func infoRow(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                .frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            Spacer()
        }
    }

    func checkLike() {
        guard let eventId = event["event_id"] as? String else { return }

        let url = URL(string: "\(APIConfig.baseURL)/api/attendee/check-like/\(eventId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }

            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    isLiked = result["liked"] as? Bool ?? false
                }
            }
        }.resume()
    }

    func likeEvent() {
        guard let eventId = event["event_id"] as? String else { return }

        let url = URL(string: "\(APIConfig.baseURL)/api/attendee/like-event")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = ["event_id": eventId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, _, _ in }.resume()
    }

    func startViewTimer() {
        viewTimer?.invalidate()
        didRecordView = false
        viewTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) { _ in
            recordEventView()
        }
    }

    func recordEventView() {
        guard !didRecordView, let eventId = event["event_id"] as? String else { return }
        didRecordView = true

        let url = URL(string: "\(APIConfig.baseURL)/api/attendee/event-view")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = ["event_id": eventId, "duration_seconds": 10]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { _, _, _ in }.resume()
    }
}

#Preview {
    EventDetailsView(event: ["event_name": "Rock Concert", "category": "Music", "city": "Riyadh"])
}
