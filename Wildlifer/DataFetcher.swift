//
//  DataFetcher.swift
//  Wildlifer
//
//  Created by Benjamin Olea on 8/24/25.
//

import SwiftUI

class DataFetcher {
    
    func getParks() async throws -> ParksResponse {
        
        print("we are here 1")
        
        let endpoint = "https://developer.nps.gov/api/v1/parks?q=TX&api_key=" + npsKey
        guard let url = URL(string: endpoint) else {throw DataError.invalidURL}
        print("we are here 2")

        let (data, response) = try await URLSession.shared.data(from: url)
        print("we are here 3")

        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            print("inside guard")
            
            
            throw DataError.invalidResponse
        }
        //print(response)
        //see the raw JSON
        /*
        if let jsonString = String(data: data, encoding: .utf8) {
            print("Raw JSON Response:")
            print(jsonString)
        } else {
            print("Could not convert data to string")
        }
        */
        print("we are here 4")
        
        do {
            
            let decoder = JSONDecoder()
            let payload = try decoder.decode(ParksResponse.self, from: data)
            print("Decoding successful!")
            return payload

            //only use line below if response is in JSON format. In this case, response is single word
            //decoder.keyDecodingStrategy = .convertFromSnakeCase
        }catch let DecodingError.dataCorrupted(context) {
            print("Data corrupted: \(context)")
            if let underlyingError = context.underlyingError {
                print("Underlying error: \(underlyingError)")
            }
            throw DataError.invalidData
        } catch let DecodingError.keyNotFound(key, context) {
            print("Key '\(key)' not found: \(context.debugDescription)")
            print("codingPath: \(context.codingPath)")
            throw DataError.invalidData
        } catch let DecodingError.valueNotFound(value, context) {
            print("Value '\(value)' not found: \(context.debugDescription)")
            print("codingPath: \(context.codingPath)")
            throw DataError.invalidData
        } catch let DecodingError.typeMismatch(type, context) {
            print("Type '\(type)' mismatch: \(context.debugDescription)")
            print("codingPath: \(context.codingPath)")
            throw DataError.invalidData
        } catch {
            print("General decoding error: \(error.localizedDescription)")
            print("Full error: \(error)")
            throw DataError.invalidData
        }
        
    }
    
    public enum DataError: Error {
        case invalidURL
        case invalidResponse
        case invalidData
    }
    
    // MARK: - Main Response Model
    struct ParksResponse: Codable {
        let total: String
        let data: [Park]
        let limit: String
        let start: String
        
        enum CodingKeys: String, CodingKey {
            case total, data, limit, start
        }
    }
    
    // MARK: - Park Model
    struct Park: Codable {
        let activities: [Activity]
        let addresses: [Address]
        let contacts: Contact
        let description: String
        let designation: String
        let directionsInfo: String
        let directionsUrl: String
        let entranceFees: [EntranceFee]
        let entrancePasses: [EntrancePass]
        let fullName: String
        let id: String
        let images: [ParkImage]
        let latitude: String
        let longitude: String
        let multimedia: [Multimedia]
        let name: String
        let operatingHours: [OperatingHours]
        let parkCode: String
        let relevanceScore: Double
        let states: String
        let topics: [Topic]
        let url: String
        let weatherInfo: String
        
        enum CodingKeys: String, CodingKey {
            case activities, addresses, contacts, description, designation
            case directionsInfo = "directionsInfo"
            case directionsUrl = "directionsUrl"
            case entranceFees = "entranceFees"
            case entrancePasses = "entrancePasses"
            case fullName = "fullName"
            case id, images, latitude, longitude, multimedia, name
            case operatingHours = "operatingHours"
            case parkCode = "parkCode"
            case relevanceScore = "relevanceScore"
            case states, topics, url
            case weatherInfo = "weatherInfo"
        }
    }
    
    // MARK: - Supporting Models
    struct Activity: Codable {
        let id: String
        let name: String
    }

    struct Address: Codable {
        let line1: String
        let line2: String
        let line3: String
        let city: String
        let stateCode: String
        let countryCode: String
        let provinceTerritoryCode: String
        let postalCode: String
        let type: String
    }

    struct Contact: Codable {
        let phoneNumbers: [PhoneNumber]
        let emailAddresses: [EmailAddress]
    }

    struct PhoneNumber: Codable {
        let phoneNumber: String
        let description: String
        let phoneExtension: String
        let type: String
        
        enum CodingKeys: String, CodingKey {
            case phoneNumber
            case description
            case phoneExtension = "extension"  // Map JSON key to Swift property
            case type
        }
    }

    struct EmailAddress: Codable {
        let emailAddress: String
        let description: String
    }

    struct EntranceFee: Codable {
        let cost: String
        let description: String
        let title: String
    }

    struct EntrancePass: Codable {
        let cost: String
        let description: String
        let title: String
    }

    struct ParkImage: Codable {
        let credit: String
        let altText: String
        let title: String
        let id: Int?
        let caption: String
        let url: String
    }

    struct Multimedia: Codable {
        let title: String
        let id: String
        let type: String
        let url: String
    }

    struct OperatingHours: Codable {
        let name: String
        let description: String
        let standardHours: StandardHours?
        let exceptions: [Exception]?
    }

    struct StandardHours: Codable {
        let sunday: String?
        let monday: String?
        let tuesday: String?
        let wednesday: String?
        let thursday: String?
        let friday: String?
        let saturday: String?
    }

    struct Exception: Codable {
        let name: String
        let startDate: String
        let endDate: String
        let exceptionHours: StandardHours?
    }

    struct Topic: Codable {
        let id: String
        let name: String
    }
    
}
