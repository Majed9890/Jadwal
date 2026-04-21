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
                        HStack {
                            Spacer()
                            VStack {
                                Button(action: {
                                    isLiked.toggle()
                                    if isLiked {
                                        likeEvent()
                                    }
                                }) {
                                    Image(systemName: isLiked ? "heart.fill" : "heart")
                                        .foregroundColor(isLiked ? .red : .white)
                                        .font(.title)
                                        .padding()
                                }
                                Spacer()
                            }
                        }
                    )
                
                VStack(alignment: .leading, spacing: 10) {
                    Text(event["event_name"] as? String ?? "")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("Category: \(event["category"] as? String ?? "")")
                        .foregroundColor(.gray)
                    
                    Text("City: \(event["city"] as? String ?? "")")
                        .foregroundColor(.gray)
                    
                    Text("Location: \(event["location"] as? String ?? "")")
                        .foregroundColor(.gray)
                    
                    Text("Price: SAR \(event["base_price"] as? Int ?? 0)")
                        .font(.headline)
                    
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
        .onAppear {
            checkLike()
        }
    }
    
    func checkLike() {
        guard let eventId = event["event_id"] as? String else { return }
        
        let url = URL(string: "http://localhost:3000/api/attendee/check-like/\(eventId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    isLiked = result["liked"] as? Bool ?? false
                }
            }
        }.resume()
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
