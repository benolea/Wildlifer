//
//  DataFetcher.swift
//  Wildlifer
//
//  Created by Benjamin Olea on 8/24/25.
//

import SwiftUI

struct SenateTrade: Codable { //this is the model that conforms to Codable, meaning the looks exactly the same as the expected JSON
    let symbol: String
    let disclosureData: String
    let transactionData: String
    let firstName: String
    let lastName: String
    let office: String
    let district: String
    let owner: String
    let assetDescription: String
    let assetType: String
    let type: String
    let amount: String
    let comment: String
    let link: String
}

class DataFetcher {
    
    func getSenateTrades() async throws -> [SenateTrade] {
        
        print("we are here 1")
        
        //let endpoint = "https://financialmodelingprep.com/stable/senate-latest?page=0&limit=25&apikey=oBQGCakHXwfyAs65j9VqNMA4IYhWMMry"
        let endpoint = "https://financialmodelingprep.com/stable/crowdfunding-offerings-latest?page=0&limit=100&apikey=oBQGCakHXwfyAs65j9VqNMA4IYhWMMry"
        guard let url = URL(string: endpoint) else {throw DataError.invalidURL}
        print("we are here 2")

        let (data, response) = try await URLSession.shared.data(from: url)
        print("we are here 3")

        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            print("inside guard")
            
            
            throw DataError.invalidResponse
        }
        print(response)
        print(data)
        print("we are here 4")

        
        //print("we are here")
        
        do {
            let decoder = JSONDecoder()
            //only use line below if response is in JSON format. In this case, response is single word
            //decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode([SenateTrade].self, from: data)// the target is this current SenateTrade struct
        } catch {
            throw DataError.invalidData
        }
        
    }
    
    public enum DataError: Error {
        case invalidURL
        case invalidResponse
        case invalidData
    }
    
}



