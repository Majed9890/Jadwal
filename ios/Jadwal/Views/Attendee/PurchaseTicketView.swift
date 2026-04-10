import SwiftUI

struct PurchaseTicketView: View {
    let event: [String: String]
    @State private var selectedTier = "general"
    @State private var quantity = 1
    let tiers = ["general", "vip"]
    
    var body: some View {
        VStack(spacing: 20) {
            Text(event["name"] ?? "")
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
            
            Text("Total: SAR \((Int(event["price"] ?? "0") ?? 0) * quantity)")
                .font(.headline)
            
            Button(action: {
                // TODO: connect to API
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

#Preview {
    PurchaseTicketView(event: ["name": "Rock Concert", "category": "music", "city": "Riyadh", "price": "150"])
}
