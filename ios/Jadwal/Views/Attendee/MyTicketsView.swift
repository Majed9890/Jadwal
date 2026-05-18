import SwiftUI

struct MyTicketsView: View {
    @State private var tickets: [[String: Any]] = []
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
                        Text("Loading tickets...")
                            .foregroundColor(.white.opacity(0.5))
                            .font(.subheadline)
                    }
                } else if tickets.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "ticket")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.15))
                        Text("No tickets yet")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.4))
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            ForEach(0..<tickets.count, id: \.self) { index in
                                let ticket = tickets[index]
                                let eventInfo = ticket["Event"] as? [String: Any]

                                NavigationLink(destination: QRCodeView(ticket: ticket)) {
                                    HStack(spacing: 16) {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color(red: 0.6, green: 1.0, blue: 0.0))
                                            .frame(width: 4)

                                        VStack(alignment: .leading, spacing: 8) {
                                            Text(eventInfo?["event_name"] as? String ?? "Unknown Event")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(.white)
                                                .multilineTextAlignment(.leading)

                                            HStack(spacing: 8) {
                                                Text(ticket["tier"] as? String ?? "")
                                                    .font(.caption)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 4)
                                                    .background(Color(red: 0.6, green: 1.0, blue: 0.0).opacity(0.15))
                                                    .cornerRadius(8)

                                                Text(ticket["ticket_status"] as? String ?? "")
                                                    .font(.caption)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.white.opacity(0.6))
                                                    .padding(.horizontal, 10)
                                                    .padding(.vertical, 4)
                                                    .background(Color.white.opacity(0.08))
                                                    .cornerRadius(8)
                                            }
                                        }

                                        Spacer()

                                        VStack(alignment: .trailing, spacing: 4) {
                                            Text("SAR \(ticket["price"] as? Int ?? 0)")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
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
            .navigationTitle("My Tickets")
            .navigationBarTitleDisplayMode(.large)
            .onAppear { fetchTickets() }
        }
    }

    func fetchTickets() {
        let url = URL(string: "\(APIConfig.baseURL)/api/tickets/my-tickets")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let ticketList = result["tickets"] as? [[String: Any]] {
                DispatchQueue.main.async { tickets = ticketList; isLoading = false }
            }
        }.resume()
    }
}

#Preview { MyTicketsView() }
