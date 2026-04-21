import SwiftUI

struct MyTicketsView: View {
    @State private var tickets: [[String: Any]] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView("Loading tickets...")
                } else if tickets.isEmpty {
                    Text("No tickets yet")
                        .foregroundColor(.gray)
                } else {
                    List(0..<tickets.count, id: \.self) { index in
                        let ticket = tickets[index]
                        let eventInfo = ticket["Event"] as? [String: Any]
                        NavigationLink(destination: QRCodeView(ticket: ticket)) {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(eventInfo?["event_name"] as? String ?? "Unknown Event")
                                    .font(.headline)
                                HStack {
                                    Text(ticket["tier"] as? String ?? "")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("SAR \(ticket["price"] as? Int ?? 0)")
                                        .fontWeight(.bold)
                                }
                                Text(ticket["ticket_status"] as? String ?? "")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
            .navigationTitle("My Tickets")
            .onAppear {
                fetchTickets()
            }
        }
    }
    func fetchTickets() {
            let url = URL(string: "http://localhost:3000/api/tickets/my-tickets")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else { return }
                
                if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let ticketList = result["tickets"] as? [[String: Any]] {
                    DispatchQueue.main.async {
                        tickets = ticketList
                        isLoading = false
                    }
                }
            }.resume()
        }
    }

    #Preview {
        MyTicketsView()
    }
