//
//  HomeViewModel.swift
//  Wildlifer
//
//  Created by Benjamin Olea on 8/22/25.
//


import SwiftUI
import GoogleMaps

// MARK: - ViewModel
class HomeViewModel: ObservableObject {
    @Published var parkCount: Int = 0
    @Published var isLoading: Bool = false
    @Published var selectedState: String = "TX"
    @Published var selectedStateName: String = "Texas"

    var parkPayload: DataFetcher.ParksResponse? = nil
    
    // US States with park systems
      let stateOptions: [(code: String, name: String)] = [
          ("AL", "Alabama"), ("AK", "Alaska"), ("AZ", "Arizona"), ("AR", "Arkansas"),
          ("CA", "California"), ("CO", "Colorado"), ("CT", "Connecticut"), ("FL", "Florida"),
          ("GA", "Georgia"), ("HI", "Hawaii"), ("ID", "Idaho"), ("IL", "Illinois"),
          ("IN", "Indiana"), ("IA", "Iowa"), ("KS", "Kansas"), ("KY", "Kentucky"),
          ("LA", "Louisiana"), ("ME", "Maine"), ("MD", "Maryland"), ("MA", "Massachusetts"),
          ("MI", "Michigan"), ("MN", "Minnesota"), ("MS", "Mississippi"), ("MO", "Missouri"),
          ("MT", "Montana"), ("NE", "Nebraska"), ("NV", "Nevada"), ("NH", "New Hampshire"),
          ("NJ", "New Jersey"), ("NM", "New Mexico"), ("NY", "New York"), ("NC", "North Carolina"),
          ("ND", "North Dakota"), ("OH", "Ohio"), ("OK", "Oklahoma"), ("OR", "Oregon"),
          ("PA", "Pennsylvania"), ("RI", "Rhode Island"), ("SC", "South Carolina"), ("SD", "South Dakota"),
          ("TN", "Tennessee"), ("TX", "Texas"), ("UT", "Utah"), ("VT", "Vermont"),
          ("VA", "Virginia"), ("WA", "Washington"), ("WV", "West Virginia"), ("WI", "Wisconsin"), ("WY", "Wyoming")
      ]
    
    func loadData() async {
        
        await MainActor.run {
            isLoading = true
        }
        // Add small delay for better UX
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        let pull: DataFetcher = DataFetcher()
        do {
            let fetchedParks = try await pull.getParks()
            await print("succesful fetch")
            await print(fetchedParks)
            
            await MainActor.run {
                self.parkPayload = fetchedParks
                self.parkCount = Int(parkPayload?.total ?? "0") ?? 0
                self.isLoading = false
            }


        }catch{
            await MainActor.run {
                print("Error loading parks: \(error)")
                self.isLoading = false
            }
        }
    }
    
    func updateSelectedState(code: String) {
        selectedState = code
        selectedStateName = stateOptions.first(where: { $0.code == code })?.name ?? code
    }
}

public enum HomeError: Error {
    case networkError
}

// MARK: - Home Screen
struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @State private var natureMarkers: [NatureMarker] = []
    @State private var showingStatePicker = false
    
    var initialCamera: GMSCameraPosition {
        getStateCamera(for: vm.selectedState)
    }
    
    var body: some View {
        
        ZStack{
            // Full-screen Google Map
            GoogleMapViewNature(
                markers: $natureMarkers,
                initialCamera: initialCamera,
                onMarkerTap: handleMarkerTap
            )
            .ignoresSafeArea()
            
            VStack{// Floating UI Elements
                HStack{// Top Controls
                    Button(action: { showingStatePicker =  true}){
                        HStack(spacing: 8){
                            Text(vm.selectedStateName)
                                .fontWeight(.semibold)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                        .foregroundColor(.primary)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .background(.ultraThinMaterial, in: Capsule())
                        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                    }
                    
                    Spacer()
                    
                    // Park Count
                    HStack(spacing: 6) {
                        Text("\(vm.parkCount)")
                            .fontWeight(.bold)
                        Text("Parks")
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.green.opacity(0.9), in: Capsule())
                    .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)
                
                Spacer()
                
                Button(action: {
                                   Task {
                                       await vm.loadData()
                                       updateNatureMarkers()
                                   }
                               }) {
                                   Image(systemName: vm.isLoading ? "arrow.clockwise" : "arrow.clockwise")
                                       .font(.title2)
                                       .fontWeight(.medium)
                                       .foregroundColor(.green)
                                       .frame(width: 60, height: 60)
                                       .background(.ultraThinMaterial, in: Circle())
                                       .shadow(color: .black.opacity(0.2), radius: 15, x: 0, y: 8)
                                       .rotationEffect(.degrees(vm.isLoading ? 360 : 0))
                                       .animation(
                                           vm.isLoading ?
                                           Animation.linear(duration: 1).repeatForever(autoreverses: false) :
                                           .default,
                                           value: vm.isLoading
                                       )
                               }
                               .disabled(vm.isLoading)
                               .padding(.bottom, 50)
            }
            // Loading Overlay
                        if vm.isLoading {
                            ZStack {
                                Color.black.opacity(0.3)
                                    .ignoresSafeArea()
                                
                                VStack(spacing: 20) {
                                    ProgressView()
                                        .scaleEffect(1.2)
                                        .tint(.green)
                                    
                                    Text("Loading Parks...")
                                        .font(.headline)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(.white)
                                .padding(30)
                                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                            }
                        }
                    }
                    .sheet(isPresented: $showingStatePicker) {
                    NavigationView {
                        List(vm.stateOptions, id: \.code) { state in
                            Button(action: {
                                vm.updateSelectedState(code: state.code)
                                showingStatePicker = false
                                Task {
                                    await vm.loadData()
                                    updateNatureMarkers()
                                }
                            }) {
                                HStack {
                                    Text(state.name)
                                        .foregroundColor(.primary)
                                    Spacer()
                                    if state.code == vm.selectedState {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                        }
                        .navigationTitle("Select State")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Cancel") {
                                    showingStatePicker = false
                                }
                            }
                        }
                    }
                    .presentationDetents([.medium, .large])
                }
                    .task {
                        await vm.loadData()
                        updateNatureMarkers()
                    }
                    .onChange(of: vm.selectedState) { _ in
                        // Update camera position when state changes
                        // camera animation here
                    }
        }
    
    private func handleMarkerTap(marker: NatureMarker) -> Bool {
        print("Marker tapped: \(marker.title)")
        //Google Maps API return false to default to google api behavior
        return false
    }
    
    private func updateNatureMarkers() {
        var result: [NatureMarker] = []
        
        print("inside updateNatureMarkers")
        print("parkCount: \(vm.parkCount)")
        print("actual data count: \(vm.parkPayload?.data.count ?? 0)")
        
        guard let parkData = vm.parkPayload?.data else {
            print("No park data available")
            return
        }
        
        
        for i in 0..<min(vm.parkCount, parkData.count){
            
            print("Processing park \(i)")
                   
            let latString = parkData[i].latitude ?? "null"
            let longString = parkData[i].longitude ?? "null"
            
            print("lat = \(latString)")
            print("long = \(longString)")
            
            let latitude: Double = Double(vm.parkPayload?.data[i].latitude ?? "0") ?? 0
            let longitude: Double = Double(vm.parkPayload?.data[i].longitude ?? "0") ?? 0
            let coord: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            let title: String = vm.parkPayload?.data[i].fullName ?? "No Name"
            let snippet: String = vm.parkPayload?.data[i].description ?? "No Description"
            let color: UIColor = .blue
            
            print("lat2 = \(latitude)")
            print("long2 = \(longitude)")
            
            
            let marker = NatureMarker(coordinate: coord, title: title, snippet: snippet, color: color)
            
            result.append(marker)
        }
        
        natureMarkers = result
    }
    
    private func getStateCamera(for stateCode: String) -> GMSCameraPosition {
        switch stateCode {
        case "CA":
            return GMSCameraPosition.camera(withLatitude: 36.7783, longitude: -119.4179, zoom: 6.0)
        case "FL":
            return GMSCameraPosition.camera(withLatitude: 27.7663, longitude: -82.6404, zoom: 6.5)
        case "NY":
            return GMSCameraPosition.camera(withLatitude: 42.1657, longitude: -74.9481, zoom: 6.5)
        case "AZ":
            return GMSCameraPosition.camera(withLatitude: 34.0489, longitude: -111.0937, zoom: 6.5)
        case "CO":
            return GMSCameraPosition.camera(withLatitude: 39.0598, longitude: -105.3111, zoom: 6.5)
        case "WA":
            return GMSCameraPosition.camera(withLatitude: 47.0379, longitude: -121.3017, zoom: 6.5)
        case "UT":
            return GMSCameraPosition.camera(withLatitude: 39.3210, longitude: -111.0937, zoom: 6.5)
        case "TX":
            return GMSCameraPosition.camera(withLatitude: 31.0545, longitude: -97.5635, zoom: 6.0)
        default:
            return GMSCameraPosition.camera(withLatitude: 31.0545, longitude: -97.5635, zoom: 6.0)
        }
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

