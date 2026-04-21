import SwiftUI

struct CreateEventView: View {
    @State private var eventName = ""
    @State private var category = ""
    @State private var description = ""
    @State private var location = ""
    @State private var city = ""
    @State private var startDate = ""
    @State private var endDate = ""
    @State private var time = ""
    @State private var basePrice = ""
    @State private var eventCapacity = ""
    @State private var errorMessage = ""
    @State private var successMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Create Event")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                
                TextField("Event Name", text: $eventName)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                TextField("Category", text: $category)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                TextField("Description", text: $description)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                TextField("Location", text: $location)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                TextField("City", text: $city)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                TextField("Start Date (YYYY-MM-DD)", text: $startDate)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                TextField("End Date (YYYY-MM-DD)", text: $endDate)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                TextField("Time (HH:MM)", text: $time)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                
                TextField("Base Price (SAR)", text: $basePrice)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .keyboardType(.numberPad)
                
                TextField("Event Capacity", text: $eventCapacity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .keyboardType(.numberPad)
                
                if !errorMessage.isEmpty {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                if !successMessage.isEmpty {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .font(.caption)
                }
                
                Button(action: {
                    createEvent()
                }) {
                    Text("Submit for Review")
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Create Event")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    func createEvent() {
        let url = URL(string: "http://localhost:3000/api/events/create")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")
        
        let body: [String: Any] = [
            "event_name": eventName,
            "category": category,
            "description": description,
            "location": location,
            "city": city,
            "start_date": startDate,
            "end_date": endDate,
            "time": time,
            "base_price": Int(basePrice) ?? 0,
            "event_capacity": Int(eventCapacity) ?? 0,
            "image_url": ""
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            
            if let result = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                DispatchQueue.main.async {
                    if result["event"] != nil {
                        successMessage = "event submitted for admin review!"
                        eventName = ""
                        category = ""
                        description = ""
                        location = ""
                        city = ""
                        startDate = ""
                        endDate = ""
                        time = ""
                        basePrice = ""
                        eventCapacity = ""
                    } else if let err = result["error"] as? String {
                        errorMessage = err
                    }
                }
            }
        }.resume()
    }
}

#Preview {
    CreateEventView()
}
