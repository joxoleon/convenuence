import Foundation

// Foursquare Data Transfer Objects
public enum FoursqareDTO {
    
    // MARK: - Venue
    
    public struct Venue: Codable {
        public let id: String
        public let name: String
        public let location: Location
        
        enum CodingKeys: String, CodingKey {
            case id = "fsq_id"
            case name
            case location
        }
    }
    
    // MARK: - Location
    
    public struct Location: Codable {
        public let address: String
        public let formatted_address: String
        public let locality: String
        public let postcode: String
        public let region: String
        public let country: String
    }
    
    // MARK: - VenueDetails
    
    public struct VenueDetails: Codable {
        public let id: String
        public let name: String
        public let description: String?
        public let location: Location
        public let categories: [Category]
        public let geocodes: Geocodes
        
        enum CodingKeys: String, CodingKey {
            case id = "fsq_id"
            case name
            case description
            case location
            case categories
            case geocodes
        }
    }
    
    // MARK: - Category
    
    public struct Category: Codable {
        public let id: Int
        public let name: String
        public let short_name: String
        public let icon: Icon
    }
    
    // MARK: - Geocodes
    
    public struct Geocodes: Codable {
        public let main: Coordinate
    }
    
    // MARK: - Coordinate
    
    public struct Coordinate: Codable {
        public let latitude: Double
        public let longitude: Double
    }
    
    // MARK: - Icon
    
    public struct Icon: Codable {
        public let prefix: String
        public let suffix: String
    }
    
    
    // MARK: - SearchResponse
    
    public struct SearchResponse: Codable {
        public let results: [Venue]
    }
}
