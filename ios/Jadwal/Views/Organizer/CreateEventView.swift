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
                                
                                Button(action: {
                                    // TODO: connect to API
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
                }

                #Preview {
                    CreateEventView()
                }
