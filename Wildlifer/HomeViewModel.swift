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
    @Published var lastUpdated: Date? = nil

    var parkPayload: DataFetcher.ParksResponse? = nil
    
    func loadData() async {
        let pull: DataFetcher = DataFetcher()
        self.lastUpdated = Date()
        do {
            let fetchedParks = try await pull.getParks()
            await print("succesful fetch")
            await print(fetchedParks)
            self.parkPayload = fetchedParks
            self.parkCount = Int(parkPayload?.total ?? "0")!

        }catch{
            print("could not get data")
        }
    }
}

public enum HomeError: Error {
    case networkError
}

// MARK: - Home Screen
struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @State private var natureMarkers: [NatureMarker] = []
    
    private let initialCamera = GMSCameraPosition.camera(
        withLatitude: 31.0545,  // Center of Texas
        longitude: -97.5635,
        zoom: 6.0  )
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                GoogleMapViewNature(markers: $natureMarkers,
                                    initialCamera: initialCamera,
                                    onMarkerTap: handleMarkerTap
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                Text("Texas Parks")
                    .font(.largeTitle)
                    .bold()
                
                Text("Parks in Texas: \(vm.parkCount)")
                
                if let date = vm.lastUpdated {
                    Text("Last Updated: \(date.formatted(.dateTime.hour().minute()))")
                        .font(.footnote)
                        .foregroundColor(.gray)
                }
                
                Button(action: {
                    //vm.loadData()
                }) {
                    Text("Refresh Data")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                Spacer()
            }
            .padding()
            .task {
                do{
                    try await vm.loadData()
                    updateNatureMarkers();
                } catch {
                    HomeError.networkError
                }
                
            }
        }
    }
    
    private func handleMarkerTap(marker: NatureMarker) -> Bool {
        print("Marker tapped: \(marker.title)")
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
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

