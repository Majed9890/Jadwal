import SwiftUI

struct MyTicketsView: View {
    let dummyTickets = [
        ["event": "Rock Concert", "tier": "VIP", "price": "150", "status": "active"],
        ["event": "Art Exhibition", "tier": "General", "price": "50", "status": "active"],
    ]
    
    var body: some View {
        NavigationView {
            List(dummyTickets, id: \.self) { ticket in
                NavigationLink(destination: QRCodeView(ticket: ticket)) {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(ticket["event"] ?? "")
                            .font(.headline)
                        HStack {
                            Text(ticket["tier"] ?? "")
                                .foregroundColor(.gray)
                            Spacer()
                            Text("SAR \(ticket["price"] ?? "")")
                                .fontWeight(.bold)
                        }
                        Text(ticket["status"] ?? "")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 5)
                }
            }
            .navigationTitle("My Tickets")
        }
    }
}

#Preview {
    MyTicketsView()
}
