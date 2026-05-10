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
        if let name = event["ticket_type1_name"] as? String, let price = event["ticket_type1_price"] as? Int {
            options.append((name, price))
        }
        if let name = event["ticket_type2_name"] as? String, let price = event["ticket_type2_price"] as? Int {
            options.append((name, price))
        }
        return options
    }

    var totalPrice: Int { return selectedPrice * quantity }

    var body: some View {
        if showSummary {
            PurchaseSummaryView(ticket: purchasedTicket, event: event)
        } else {
            ZStack {
                Color(red: 0.08, green: 0.11, blue: 0.08)
                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        Spacer().frame(height: 20)

                        // Event name header
                        VStack(spacing: 6) {
                            Text(event["event_name"] as? String ?? "")
                                .font(.system(size: 24, weight: .heavy))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            Text("Select your ticket")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.5))
                        }
                        .padding(.horizontal, 24)

                        // Ticket type selection
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Ticket Type")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal, 24)

                            VStack(spacing: 10) {
                                ForEach(0..<ticketOptions.count, id: \.self) { index in
                                    let option = ticketOptions[index]
                                    Button(action: {
                                        selectedTier = option.name
                                        selectedPrice = option.price
                                    }) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(option.name)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.white)
                                                Text("per ticket")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.4))
                                            }
                                            Spacer()
                                            Text("SAR \(option.price)")
                                                .fontWeight(.bold)
                                                .foregroundColor(selectedTier == option.name ? Color(red: 0.08, green: 0.11, blue: 0.08) : Color(red: 0.6, green: 1.0, blue: 0.0))

                                            if selectedTier == option.name {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.08))
                                                    .padding(.leading, 6)
                                            }
                                        }
                                        .padding(16)
                                        .background(selectedTier == option.name ? Color(red: 0.6, green: 1.0, blue: 0.0) : Color.white.opacity(0.07))
                                        .cornerRadius(14)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                        }

                        // Quantity
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Quantity")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal, 24)

                            HStack {
                                Text("Number of tickets")
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                                Spacer()
                                HStack(spacing: 16) {
                                    Button(action: { if quantity > 1 { quantity -= 1 } }) {
                                        ZStack {
                                            Circle()
                                                .fill(Color.white.opacity(0.1))
                                                .frame(width: 36, height: 36)
                                            Image(systemName: "minus")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(.white)
                                        }
                                    }
                                    Text("\(quantity)")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                        .frame(minWidth: 24)
                                    Button(action: { if quantity < 10 { quantity += 1 } }) {
                                        ZStack {
                                            Circle()
                                                .fill(Color(red: 0.6, green: 1.0, blue: 0.0).opacity(0.2))
                                                .frame(width: 36, height: 36)
                                            Image(systemName: "plus")
                                                .font(.system(size: 14, weight: .bold))
                                                .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                                        }
                                    }
                                }
                            }
                            .padding(16)
                            .background(Color.white.opacity(0.07))
                            .cornerRadius(14)
                            .padding(.horizontal, 24)
                        }

                        // Price summary
                        VStack(spacing: 12) {
                            HStack {
                                Text("Price per ticket")
                                    .foregroundColor(.white.opacity(0.5))
                                Spacer()
                                Text("SAR \(selectedPrice)")
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                            }
                            HStack {
                                Text("Quantity")
                                    .foregroundColor(.white.opacity(0.5))
                                Spacer()
                                Text("x\(quantity)")
                                    .foregroundColor(.white)
                                    .fontWeight(.medium)
                            }
                            Divider()
                                .background(Color.white.opacity(0.1))
                            HStack {
                                Text("Total")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("SAR \(totalPrice)")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                            }
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(14)
                        .padding(.horizontal, 24)

                        // Error
                        if !errorMessage.isEmpty {
                            HStack {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .foregroundColor(.red)
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 24)
                        }

                        // Confirm button
                        Button(action: {
                            if selectedTier.isEmpty {
                                errorMessage = "please select a ticket type"
                                return
                            }
                            purchaseTicket()
                        }) {
                            Text("Confirm Purchase")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.08))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color(red: 0.6, green: 1.0, blue: 0.0))
                                .cornerRadius(16)
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationTitle("Purchase Ticket")
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
        let url = URL(string: "http://192.168.3.10:3000/api/tickets/purchase")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        let body: [String: Any] = ["event_id": eventId, "tier": selectedTier, "price": selectedPrice, "quantity": quantity]
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
