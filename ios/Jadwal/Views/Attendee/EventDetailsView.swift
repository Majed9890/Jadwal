import SwiftUI

struct EventDetailsView: View {
    let event: [String: Any]
    @State private var isLiked = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Rectangle()
                    .fill(Color(.systemGray5))
                    .frame(height: 200)
                    .overlay(
                        Text("Event Image")
                            .foregroundColor(.gray)
                    )
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(event["event_name"] as? String ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Category: \(event["category"] as? String ?? "")")
                        .foregroundColor(.gray)
                    
                    Text("City: \(event["city"] as? String ?? "")")
                        .foregroundColor(.gray)
                    
                    Text("Price: SAR \(event["base_price"] as? Int ?? 0)")
                        .font(.headline)
                    
                    Button(action: {
                        isLiked.toggle()
                        likeEvent()
                    }) {
                        HStack {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .foregroundColor(isLiked ? .red : .gray)
                            Text(isLiked ? "Liked" : "Like")
                                .foregroundColor(isLiked ? .red : .gray)
                        }
                    }
                    
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
    
    func likeEvent() {
        guard let eventId = event["event_id"] as? String else { return }
        
        let url = URL(string: "http://localhost:3000/api/attendee/like-event")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = ["event_id": eventId]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { _, _, _ in }.resume()
    }
}

#Preview {
    EventDetailsView(event: ["event_name": "Rock Concert", "category": "music", "city": "Riyadh", "base_price": 150])
}
