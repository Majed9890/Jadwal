import SwiftUI

struct PurchaseSummaryView: View {
    let ticket: [String: Any]
    let event: [String: Any]

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.11, blue: 0.08)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 28) {
                    Spacer().frame(height: 40)

                    // Success icon
                    ZStack {
                        Circle()
                            .fill(Color(red: 0.6, green: 1.0, blue: 0.0).opacity(0.15))
                            .frame(width: 100, height: 100)
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 54))
                            .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                    }

                    // Title
                    VStack(spacing: 8) {
                        Text("Purchase Successful!")
                            .font(.system(size: 26, weight: .heavy))
                            .foregroundColor(.white)
                        Text("Your ticket has been confirmed")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.5))
                    }

                    // Ticket details card
                    VStack(spacing: 0) {

                        // Top section
                        VStack(spacing: 14) {
                            summaryRow(label: "Event", value: event["event_name"] as? String ?? "")
                            summaryRow(label: "Category", value: event["category"] as? String ?? "")
                            summaryRow(label: "City", value: event["city"] as? String ?? "")
                            summaryRow(label: "Tier", value: (ticket["tier"] as? String ?? "").uppercased())
                        }
                        .padding(16)

                        // Dashed divider
                        HStack(spacing: 4) {
                            ForEach(0..<30, id: \.self) { _ in
                                Rectangle()
                                    .fill(Color.white.opacity(0.15))
                                    .frame(width: 6, height: 1)
                            }
                        }

                        // Bottom section
                        VStack(spacing: 14) {
                            summaryRow(label: "Total Price", value: "SAR \(ticket["price"] as? Int ?? 0)", valueColor: Color(red: 0.6, green: 1.0, blue: 0.0))
                            summaryRow(label: "Status", value: (ticket["ticket_status"] as? String ?? "").capitalized, valueColor: Color(red: 0.6, green: 1.0, blue: 0.0))
                            summaryRow(label: "Ticket ID", value: ticket["ticket_id"] as? String ?? "", isSmall: true)
                        }
                        .padding(16)
                    }
                    .background(Color.white.opacity(0.07))
                    .cornerRadius(16)
                    .padding(.horizontal, 24)

                    // OTP notice
                    HStack(spacing: 12) {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                        Text("An OTP has been sent to your email to access your QR code.")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(14)
                    .background(Color(red: 0.6, green: 1.0, blue: 0.0).opacity(0.08))
                    .cornerRadius(12)
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 40)
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Order Summary")
    }

    func summaryRow(label: String, value: String, valueColor: Color = .white, isSmall: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
            Spacer()
            Text(value)
                .font(isSmall ? .caption : .subheadline)
                .fontWeight(.semibold)
                .foregroundColor(valueColor)
                .multilineTextAlignment(.trailing)
        }
    }
}

#Preview {
    PurchaseSummaryView(
        ticket: ["ticket_id": "abc-123", "tier": "vip", "price": 300, "ticket_status": "active"],
        event: ["event_name": "Rock Concert", "category": "Music", "city": "Riyadh"]
    )
}
