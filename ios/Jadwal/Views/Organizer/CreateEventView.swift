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
    let cityOptions = ["Riyadh", "Jeddah", "Mecca", "Medina", "Dammam", "Khobar", "Dhahran", "Taif", "Tabuk", "Abha", "Khamis Mushait", "Buraidah", "Hail", "Najran", "Jubail", "Yanbu", "Al Ahsa", "Arar", "Sakaka", "Jazan"]
    let categoryOptions = ["Music", "Sports", "Art", "Technology", "Food", "Travel", "Fashion", "Gaming"]

    var body: some View {
        ZStack {
            Color(red: 0.08, green: 0.11, blue: 0.08)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    Spacer().frame(height: 10)

                    // Image picker
                    Button(action: { showImagePicker = true }) {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 200)
                                .frame(maxWidth: .infinity)
                                .clipped()
                                .cornerRadius(16)
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.07))
                                    .frame(height: 200)
                                VStack(spacing: 10) {
                                    Image(systemName: "photo.on.rectangle")
                                        .font(.system(size: 36))
                                        .foregroundColor(.white.opacity(0.3))
                                    Text("Tap to add event image")
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.3))
                                }
                            }
                        }
                    }
                    .sheet(isPresented: $showImagePicker) {
                        ImagePickerView(selectedImage: $selectedImage)
                    }
                    .padding(.horizontal, 24)

                    // Event Details
                    sectionHeader("Event Details")
                    VStack(spacing: 12) {
                        darkField(icon: "text.cursor", placeholder: "Event Name", text: $eventName)
                        dropdownField(icon: "tag.fill", placeholder: "Category", selection: $category, options: categoryOptions)
                        darkField(icon: "text.alignleft", placeholder: "Description", text: $description)
                    }
                    .padding(.horizontal, 24)

                    // Location
                    sectionHeader("Location")
                    VStack(spacing: 12) {
                        darkField(icon: "mappin.circle.fill", placeholder: "Location", text: $location)
                        dropdownField(icon: "building.2.fill", placeholder: "City", selection: $city, options: cityOptions)
                        darkField(icon: "map.fill", placeholder: "District", text: $district)
                        darkField(icon: "road.lanes", placeholder: "Road Name", text: $roadName)
                    }
                    .padding(.horizontal, 24)

                    // Date & Time
                    sectionHeader("Date & Time")
                    VStack(spacing: 12) {
                        darkField(icon: "calendar", placeholder: "Start Date (YYYY-MM-DD)", text: $startDate)
                        darkField(icon: "calendar.badge.checkmark", placeholder: "End Date (YYYY-MM-DD)", text: $endDate)
                        darkField(icon: "clock.fill", placeholder: "Time (HH:MM)", text: $time)
                        darkField(icon: "person.3.fill", placeholder: "Event Capacity", text: $eventCapacity, keyboard: .numberPad)
                    }
                    .padding(.horizontal, 24)

                    // Ticket Types
                    sectionHeader("Ticket Types")
                    VStack(spacing: 12) {
                        darkField(icon: "ticket.fill", placeholder: "Ticket Type 1 Name (e.g. General)", text: $ticket1Name)
                        darkField(icon: "banknote.fill", placeholder: "Ticket Type 1 Price (SAR)", text: $ticket1Price, keyboard: .numberPad)
                        darkField(icon: "number.circle.fill", placeholder: "Ticket Type 1 Quantity", text: $ticket1Capacity, keyboard: .numberPad)

                        HStack {
                            Text("Add a second ticket type?")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                            Spacer()
                            Toggle("", isOn: $addSecondType)
                                .tint(Color(red: 0.6, green: 1.0, blue: 0.0))
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 14)
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(14)

                        if addSecondType {
                            darkField(icon: "ticket.fill", placeholder: "Ticket Type 2 Name (e.g. VIP)", text: $ticket2Name)
                            darkField(icon: "banknote.fill", placeholder: "Ticket Type 2 Price (SAR)", text: $ticket2Price, keyboard: .numberPad)
                            darkField(icon: "number.circle.fill", placeholder: "Ticket Type 2 Quantity", text: $ticket2Capacity, keyboard: .numberPad)
                        }
                    }
                    .padding(.horizontal, 24)

                    // Error / Success
                    if !errorMessage.isEmpty {
                        HStack {
                            Image(systemName: "exclamationmark.circle.fill").foregroundColor(.red)
                            Text(errorMessage).font(.caption).foregroundColor(.red)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                    }

                    if !successMessage.isEmpty {
                        HStack {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                            Text(successMessage).font(.caption).foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                    }

                    // Submit button
                    Button(action: {
                        if let image = selectedImage {
                            isUploading = true
                            uploadImageAndSubmit(image: image)
                        } else {
                            submitEvent(imageUrl: "")
                        }
                    }) {
                        if isUploading {
                            HStack(spacing: 12) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.08, green: 0.11, blue: 0.08)))
                                Text("Uploading...")
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.08))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color(red: 0.6, green: 1.0, blue: 0.0).opacity(0.6))
                            .cornerRadius(16)
                        } else {
                            Text("Submit for Review")
                                .font(.headline).fontWeight(.bold)
                                .foregroundColor(Color(red: 0.08, green: 0.11, blue: 0.08))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color(red: 0.6, green: 1.0, blue: 0.0))
                                .cornerRadius(16)
                        }
                    }
                    .disabled(isUploading)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .navigationTitle("Create Event")
        .navigationBarTitleDisplayMode(.inline)
    }

    func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.caption).fontWeight(.semibold)
            .foregroundColor(.white.opacity(0.5))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
    }

    func darkField(icon: String, placeholder: String, text: Binding<String>, keyboard: UIKeyboardType = .default) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                .frame(width: 20)
            TextField("", text: text)
                .placeholder(when: text.wrappedValue.isEmpty) {
                    Text(placeholder).foregroundColor(.white.opacity(0.3))
                }
                .foregroundColor(.white)
                .keyboardType(keyboard)
                .autocapitalization(.none)
        }
        .padding(.horizontal, 18).padding(.vertical, 16)
        .background(Color.white.opacity(0.07)).cornerRadius(14)
    }

    func dropdownField(icon: String, placeholder: String, selection: Binding<String>, options: [String]) -> some View {
        Menu {
            ForEach(options, id: \.self) { option in
                Button(option) {
                    selection.wrappedValue = option
                }
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(Color(red: 0.6, green: 1.0, blue: 0.0))
                    .frame(width: 20)
                Text(selection.wrappedValue.isEmpty ? placeholder : selection.wrappedValue)
                    .foregroundColor(selection.wrappedValue.isEmpty ? .white.opacity(0.3) : .white)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(.white.opacity(0.5))
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .background(Color.white.opacity(0.07))
            .cornerRadius(14)
        }
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
        return "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InVtbW1idmFjZ2JkbnRobnZvZ2J0Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzEzNTA2MjUsImV4cCI6MjA4NjkyNjYyNX0.SEu9do-yDT2A3RjSPYLvrpLIuMKOPrqBn4TsGTh8p3o"
    }

    func submitEvent(imageUrl: String) {
        if category.isEmpty || city.isEmpty {
            errorMessage = "please select category and city"
            isUploading = false
            return
        }

        let url = URL(string: "http://192.168.3.10:3000/api/events/create")!
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
                        eventName = ""; category = ""; description = ""; location = ""
                        city = ""; district = ""; roadName = ""; startDate = ""; endDate = ""
                        time = ""; eventCapacity = ""; ticket1Name = ""; ticket1Price = ""
                        ticket1Capacity = ""; ticket2Name = ""; ticket2Price = ""
                        ticket2Capacity = ""; addSecondType = false; selectedImage = nil
                    } else if let err = result["error"] as? String {
                        errorMessage = err
                    }
                }
            }
        }.resume()
    }
}

#Preview { CreateEventView() }
