import SwiftUI

struct PurchaseSummaryView: View {
    let ticket: [String: Any]
    let event: [String: Any]
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.system(size: 70))
                .padding(.top, 40)
            
            Text("Purchase Successful!")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("Event:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(event["event_name"] as? String ?? "")
                        .fontWeight(.bold)
                }
                
                HStack {
                    Text("Category:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(event["category"] as? String ?? "")
                }
                
                HStack {
                    Text("City:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text(event["city"] as? String ?? "")
                }
                
                HStack {
                    Text("Tier:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text((ticket["tier"] as? String ?? "").uppercased())
                        .fontWeight(.bold)
                }
                
                HStack {
                    Text("Price:")
                        .foregroundColor(.gray)
                    Spacer()
                    Text("SAR \(ticket["price"] as? Int ?? 0)")
                        .fontWeight(.bold)
                }
                HStack {
                                    Text("Status:")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(ticket["ticket_status"] as? String ?? "")
                                        .foregroundColor(.green)
                                        .fontWeight(.bold)
                                }
                                
                                HStack {
                                    Text("Ticket ID:")
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text(ticket["ticket_id"] as? String ?? "")
                                        .font(.caption)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                            
                            Text("OTP has been sent to your email to access your QR code.")
                                .font(.caption)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        .navigationTitle("Order Summary")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                }

                #Preview {
                    PurchaseSummaryView(
                        ticket: ["ticket_id": "123", "tier": "vip", "price": 300, "ticket_status": "active"],
                        event: ["event_name": "Rock Concert", "category": "music", "city": "Riyadh"]
                    )
                }
