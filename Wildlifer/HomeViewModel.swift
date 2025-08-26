//
//  HomeViewModel.swift
//  Wildlifer
//
//  Created by Benjamin Olea on 8/22/25.
//


import SwiftUI

// MARK: - ViewModel
class HomeViewModel: ObservableObject {
    @Published var politicianCount: Int = 0
    @Published var lastUpdated: Date? = nil
    
    var trades: [SenateTrade] = []
    
    func loadData() async {
        // Placeholder: you’d call your API here
        let pull: DataFetcher = DataFetcher()
        self.politicianCount = 25
        self.lastUpdated = Date()
        do {
            let fetchedTrades = try await pull.getSenateTrades()
            self.trades = fetchedTrades
            print(fetchedTrades)
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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                
                Text("Politician Portfolios")
                    .font(.largeTitle)
                    .bold()
                
                Text("Tracked Politicians: \(vm.politicianCount)")
                
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
            .navigationTitle("Home")
            .task {
                do{
                    try await vm.loadData()
                } catch {
                    HomeError.networkError
                }
            }
        }
    }
}

// MARK: - Preview
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}

