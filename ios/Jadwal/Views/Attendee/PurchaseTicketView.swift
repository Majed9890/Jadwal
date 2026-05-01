import SwiftUI

struct PurchaseTicketView: View {
    let event: [String: Any]
    @State private var selectedTier = ""
    @State private var selectedPrice = 0
    @State private var quantity = 1
    @State private var errorMessage = ""
    @State private var showSummary = false
    @State private var purchasedTicket: [String: Any] = [:]

    var ticketOptions: [(name: String, price: Int)] {
        var options: [(String, Int)] = []

        if let name = event["ticket_type1_name"] as? String,
           let price = event["ticket_type1_price"] as? Int {
            options.append((name, price))
        }

        if let name = event["ticket_type2_name"] as? String,
           let price = event["ticket_type2_price"] as? Int {
            options.append((name, price))
        }

        return options
    }

    var totalPrice: Int {
        return selectedPrice * quantity
    }

    var body: some View {
        if showSummary {
            PurchaseSummaryView(ticket: purchasedTicket, event: event)
        } else {
            VStack(spacing: 20) {
                Text(event["event_name"] as? String ?? "")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.top, 40)

                Text("Select Ticket Type")
                    .foregroundColor(.gray)

                VStack(spacing: 10) {
                    ForEach(0..<ticketOptions.count, id: \.self) { index in
                        let option = ticketOptions[index]
                        Button(action: {
                            selectedTier = option.name
                            selectedPrice = option.price
                        }) {
                            HStack {
                                Text(option.name)
                                    .fontWeight(.medium)
                                Spacer()
                                Text("SAR \(option.price)")
                                    .fontWeight(.bold)
                            }
                            .padding()
                            .background(selectedTier == option.name ? Color.blue : Color(.systemGray6))
                            .foregroundColor(selectedTier == option.name ? .white : .black)
                            .cornerRadius(10)
                        }
                    }
                }

                HStack {
                    Text("Quantity")
                    Spacer()
                    Stepper("\(quantity)", value: $quantity, in: 1...10)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Price per ticket: SAR \(selectedPrice)")
                        .foregroundColor(.gray)
                    Text("Total: SAR \(totalPrice)")
                        .font(.headline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)

                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button(action: {
                    if selectedTier.isEmpty {
                        errorMessage = "please select a ticket type"
                        return
                    }
                    purchaseTicket()
                }) {
                    Text("Confirm Purchase")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }

                Spacer()
            }
            .padding(.horizontal, 24)
            .navigationTitle("Purchase Ticket")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let first = ticketOptions.first {
                    selectedTier = first.name
                    selectedPrice = first.price
                }
            }
        }
    }

    func purchaseTicket() {
        guard let eventId = event["event_id"] as? String else { return }

        let url = URL(string: "http://localhost:3000/api/tickets/purchase")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "event_id": eventId,
            "tier": selectedTier,
            "price": selectedPrice,
            "quantity": quantity
        ]

        request.httpBody = try? JSONSerialization.data(withJSONObject: body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }

            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    if let ticket = result["ticket"] as? [String: Any] {
                        purchasedTicket = ticket
                        showSummary = true
                    } else if let err = result["error"] as? String {
                        errorMessage = err
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    PurchaseTicketView(event: ["event_name": "Rock Concert", "ticket_type1_name": "General", "ticket_type1_price": 150])
}
