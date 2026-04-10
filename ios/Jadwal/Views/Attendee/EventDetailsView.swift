import SwiftUI

struct EventDetailsView: View {
    let event: [String: String]
    @State private var isLiked = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // event image placeholder
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 200)
                    .overlay(
                        Text("Event Image")
                            .foregroundColor(.gray)
                    )
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(event["name"] ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Category: \(event["category"] ?? "")")
                        .foregroundColor(.gray)
                    
                    Text("City: \(event["city"] ?? "")")
                        .foregroundColor(.gray)
                    
                    Text("Price: SAR \(event["price"] ?? "")")
                        .font(.headline)
                    
                    // like button
                    Button(action: {
                        isLiked.toggle()
                        // TODO: connect to API
                    }) {
                        HStack {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .foregroundColor(isLiked ? .red : .gray)
                            Text(isLiked ? "Liked" : "Like")
                                .foregroundColor(isLiked ? .red : .gray)
                        }
                    }
                    
                    // buy ticket button
                    
                    NavigationLink(destination: PurchaseTicketView(event: event)) {
                                            Text("Buy Ticket")
                                                .foregroundColor(.white)
                                                .frame(maxWidth: .infinity)
                                                .padding()
                                                .background(Color.blue)
                                                .cornerRadius(10)
                                        }
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                            .navigationTitle("Event Details")
                            .navigationBarTitleDisplayMode(.inline)
                        }
                    }

                    #Preview {
                        EventDetailsView(event: ["name": "Rock Concert", "category": "music", "city": "Riyadh", "price": "150"])
                    }

