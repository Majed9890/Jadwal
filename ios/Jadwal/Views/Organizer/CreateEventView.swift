import SwiftUI

struct CreateEventView: View {
    @State private var eventName = ""
    @State private var category = ""
    @State private var description = ""
    @State private var location = ""
    @State private var city = ""
    @State private var district = ""
    @State private var roadName = ""
    @State private var startDate = ""
    @State private var endDate = ""
    @State private var time = ""
    @State private var eventCapacity = ""
    @State private var ticket1Name = ""
    @State private var ticket1Price = ""
    @State private var ticket1Capacity = ""
    @State private var addSecondType = false
    @State private var ticket2Name = ""
    @State private var ticket2Price = ""
    @State private var ticket2Capacity = ""
    @State private var errorMessage = ""
    @State private var successMessage = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker = false
    @State private var isUploading = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Create Event")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)

                Button(action: {
                    showImagePicker = true
                }) {
                    if let image = selectedImage {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 180)
                            .frame(maxWidth: .infinity)
                            .clipped()
                            .cornerRadius(10)
                    } else {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray5))
                            .frame(height: 180)
                            .overlay(
                                VStack {
                                    Image(systemName: "photo.on.rectangle")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                    Text("Tap to add event image")
                                        .foregroundColor(.gray)
                                }
                            )
                    }
                }
                .sheet(isPresented: $showImagePicker) {
                    ImagePickerView(selectedImage: $selectedImage)
                }

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

                TextField("District", text: $district)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                TextField("Road Name", text: $roadName)
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

                TextField("Event Capacity", text: $eventCapacity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .keyboardType(.numberPad)

                Divider()

                Text("Ticket Types")
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                TextField("Ticket Type 1 Name (e.g. General)", text: $ticket1Name)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                TextField("Ticket Type 1 Price (SAR)", text: $ticket1Price)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .keyboardType(.numberPad)

                TextField("Ticket Type 1 Quantity", text: $ticket1Capacity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .keyboardType(.numberPad)

                Toggle("Add a second ticket type?", isOn: $addSecondType)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)

                if addSecondType {
                    TextField("Ticket Type 2 Name (e.g. VIP)", text: $ticket2Name)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                    TextField("Ticket Type 2 Price (SAR)", text: $ticket2Price)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .keyboardType(.numberPad)

                    TextField("Ticket Type 2 Quantity", text: $ticket2Capacity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .keyboardType(.numberPad)
                }

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
                    if let image = selectedImage {
                        isUploading = true
                        uploadImageAndSubmit(image: image)
                    } else {
                        submitEvent(imageUrl: "")
                    }
                }) {
                    if isUploading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(10)
                    } else {
                        Text("Submit for Review")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .disabled(isUploading)

                Spacer()
            }
            .padding(.horizontal, 24)
        }
        .navigationTitle("Create Event")
        .navigationBarTitleDisplayMode(.inline)
    }

    func uploadImageAndSubmit(image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else {
            errorMessage = "failed to process image"
            isUploading = false
            return
        }

        let fileName = "\(UUID().uuidString).jpg"
        let urlString = "https://ummmbvacgbdnthnvogbt.supabase.co/storage/v1/object/event-images/\(fileName)"

        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("image/jpeg", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(getSupabaseAnonKey())", forHTTPHeaderField: "Authorization")
        request.setValue(getSupabaseAnonKey(), forHTTPHeaderField: "apikey")
        request.httpBody = imageData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    let publicUrl = "https://ummmbvacgbdnthnvogbt.supabase.co/storage/v1/object/public/event-images/\(fileName)"
                    isUploading = false
                    submitEvent(imageUrl: publicUrl)
                } else {
                    isUploading = false
                    submitEvent(imageUrl: "")
                }
            }
        }.resume()
    }

    func getSupabaseAnonKey() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "SUPABASE_ANON_KEY") as? String ?? ""
    }

    func submitEvent(imageUrl: String) {
        let url = URL(string: "http://localhost:3000/api/events/create")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(AuthManager.shared.token)", forHTTPHeaderField: "Authorization")

        var body: [String: Any] = [
            "event_name": eventName,
            "category": category,
            "description": description,
            "location": location,
            "city": city,
            "district": district,
            "road_name": roadName,
            "start_date": startDate,
            "end_date": endDate,
            "time": time,
            "event_capacity": Int(eventCapacity) ?? 0,
            "image_url": imageUrl,
            "ticket_type1_name": ticket1Name,
            "ticket_type1_price": Int(ticket1Price) ?? 0,
            "ticket_type1_capacity": Int(ticket1Capacity) ?? 0
        ]

        if addSecondType {
            body["ticket_type2_name"] = ticket2Name
            body["ticket_type2_price"] = Int(ticket2Price) ?? 0
            body["ticket_type2_capacity"] = Int(ticket2Capacity) ?? 0
        }

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
                        district = ""
                        roadName = ""
                        startDate = ""
                        endDate = ""
                        time = ""
                        eventCapacity = ""
                        ticket1Name = ""
                        ticket1Price = ""
                        ticket1Capacity = ""
                        ticket2Name = ""
                        ticket2Price = ""
                        ticket2Capacity = ""
                        addSecondType = false
                        selectedImage = nil
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
