import SwiftUI

struct PurchaseTicketView: View {
    let event: [String: Any]
    @State private var selectedTier = "general"
    @State private var quantity = 1
    @State private var errorMessage = ""
    @State private var showSummary = false
    @State private var purchasedTicket: [String: Any] = [:]
    let tiers = ["general", "vip"]
    
    var basePrice: Int {
        return event["base_price"] as? Int ?? 0
    }
    
    var tierPrice: Int {
        return selectedTier == "vip" ? basePrice * 2 : basePrice
    }
    
    var totalPrice: Int {
        return tierPrice * quantity
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
                
                Text("Select Ticket Tier")
                    .foregroundColor(.gray)
                
                Picker("Tier", selection: $selectedTier) {
                    ForEach(tiers, id: \.self) { tier in
                        Text(tier.uppercased())
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                HStack {
                    Text("Quantity")
                    Spacer()
                    Stepper("\(quantity)", value: $quantity, in: 1...10)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Price per ticket: SAR \(tierPrice)")
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
    PurchaseTicketView(event: ["event_name": "Rock Concert", "category": "music", "city": "Riyadh", "base_price": 150])
}
