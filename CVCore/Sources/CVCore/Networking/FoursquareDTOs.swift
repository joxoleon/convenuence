import Foundation

// Foursquare Data Transfer Objects
public enum FoursquareDTO {
    
    // MARK: - Venue
    
    public struct Venue: Codable, Equatable {
        public let id: String
        public let name: String
        public let location: Location
        public let categories: [Category]
        public let geocodes: Geocodes?
        
        enum CodingKeys: String, CodingKey {
            case id = "fsq_id"
            case name
            case location
            case categories
        }
    }
    
    // MARK: - Location
    
    public struct Location: Codable, Equatable {
        public let address: String
        public let formatted_address: String
        public let locality: String
        public let postcode: String
        public let region: String
        public let country: String
    }
    
    // MARK: - VenueDetails
    
    public struct VenueDetails: Codable, Equatable {
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
    
    public struct Category: Codable, Equatable {
        public let id: Int
        public let name: String
        public let short_name: String
        public let icon: Icon
    }
    
    // MARK: - Geocodes
    
    public struct Geocodes: Codable, Equatable {
        public let main: Coordinate
    }
    
    // MARK: - Coordinate
    
    public struct Coordinate: Codable, Equatable {
        public let latitude: Double
        public let longitude: Double
    }
    
    // MARK: - Icon
    
    public struct Icon: Codable, Equatable {
        public let prefix: String
        public let suffix: String
    }
    
    
    // MARK: - SearchResponse
    
    public struct SearchResponse: Codable {
        public let results: [Venue]
    }
}


// MARK: - Public extensions for sample data

extension FoursquareDTO.Venue {
    static var sample1: FoursquareDTO.Venue = {
        return FoursquareDTO.Venue(
            id: "1",
            name: "Coffee Shop",
            location: FoursquareDTO.Location(
                address: "123 Main St",
                formatted_address: "123 Main St, New York, NY 10001",
                locality: "New York",
                postcode: "10001",
                region: "New York",
                country: "US"
            ),
            categories: [
                FoursquareDTO.Category(
                    id: 13064,
                    name: "Pizzeria",
                    short_name: "Pizza",
                    icon: FoursquareDTO.Icon(
                        prefix: "https://ss3.4sqi.net/img/categories_v2/food/pizza_",
                        suffix: ".png"
                    )
                )
            ]
        )
    }()

    static var sample2: FoursquareDTO.Venue = {
        return FoursquareDTO.Venue(
            id: "2",
            name: "Burger Bar",
            location: FoursquareDTO.Location(
                address: "456 Main St",
                formatted_address: "456 Main St, New York, NY 10001",
                locality: "New York",
                postcode: "10001",
                region: "New York",
                country: "US"
            ),
            categories: [
                FoursquareDTO.Category(
                    id: 13064,
                    name: "Burger Joint",
                    short_name: "Burger",
                    icon: FoursquareDTO.Icon(
                        prefix: "https://ss3.4sqi.net/img/categories_v2/food/burger_",
                        suffix: ".png"
                    )
                )
            ]
        )
    }()

    static var sample3: FoursquareDTO.Venue = {
        return FoursquareDTO.Venue(
            id: "3",
            name: "Pizza Bar",
            location: FoursquareDTO.Location(
                address: "789 Main St",
                formatted_address: "789 Main St, New York, NY 10001",
                locality: "New York",
                postcode: "10001",
                region: "New York",
                country: "US"
            ),
            categories: [
                FoursquareDTO.Category(
                    id: 13064,
                    name: "Pizzeria",
                    short_name: "Pizza",
                    icon: FoursquareDTO.Icon(
                        prefix: "https://ss3.4sqi.net/img/categories_v2/food/pizza_",
                        suffix: ".png"
                    )
                )
            ]
        )
    }()
}

extension FoursquareDTO.VenueDetails {
    static var sample1: FoursquareDTO.VenueDetails = {
        return FoursquareDTO.VenueDetails(
            id: "1",
            name: "Pizza Bar",
            description: "The best pizza in town",
            location: FoursquareDTO.Location(
                address: "Bulevar Mihajla Pupina 165v",
                formatted_address: "Bulevar Mihajla Pupina 165v (Bulevar umetnosti), 11070 Београд",
                locality: "Београд",
                postcode: "11070",
                region: "Central Serbia",
                country: "RS"
            ),
            categories: [
                FoursquareDTO.Category(
                    id: 13064,
                    name: "Pizzeria",
                    short_name: "Pizza",
                    icon: FoursquareDTO.Icon(
                        prefix: "https://ss3.4sqi.net/img/categories_v2/food/pizza_",
                        suffix: ".png"
                    )
                )
            ],
            geocodes: FoursquareDTO.Geocodes(
                main: FoursquareDTO.Coordinate(
                    latitude: 44.821935,
                    longitude: 20.416514
                )
            )
        )
    }()

    static var sample2: FoursquareDTO.VenueDetails = {
        return FoursquareDTO.VenueDetails(
            id: "2",
            name: "Burger Bar",
            description: "The best burgers in town",
            location: FoursquareDTO.Location(
                address: "Bulevar Mihajla Pupina 165v",
                formatted_address: "Bulevar Mihajla Pupina 165v (Bulevar umetnosti), 11070 Београд",
                locality: "Београд",
                postcode: "11070",
                region: "Central Serbia",
                country: "RS"
            ),
            categories: [
                FoursquareDTO.Category(
                    id: 13064,
                    name: "Burger Joint",
                    short_name: "Burger",
                    icon: FoursquareDTO.Icon(
                        prefix: "https://ss3.4sqi.net/img/categories_v2/food/burger_",
                        suffix: ".png"
                    )
                )
            ],
            geocodes: FoursquareDTO.Geocodes(
                main: FoursquareDTO.Coordinate(
                    latitude: 44.821935,
                    longitude: 20.416514
                )
            )
        )
    }()

    static var sample3: FoursquareDTO.VenueDetails = {
        return FoursquareDTO.VenueDetails(
            id: "3",
            name: "Coffee Shop",
            description: "The best coffee in town",
            location: FoursquareDTO.Location(
                address: "Bulevar Mihajla Pupina 165v",
                formatted_address: "Bulevar Mihajla Pupina 165v (Bulevar umetnosti), 11070 Београд",
                locality: "Београд",
                postcode: "11070",
                region: "Central Serbia",
                country: "RS"
            ),
            categories: [
                FoursquareDTO.Category(
                    id: 13064,
                    name: "Coffee Shop",
                    short_name: "Coffee",
                    icon: FoursquareDTO.Icon(
                        prefix: "https://ss3.4sqi.net/img/categories_v2/food/coffeeshop_",
                        suffix: ".png"
                    )
                )
            ],
            geocodes: FoursquareDTO.Geocodes(
                main: FoursquareDTO.Coordinate(
                    latitude: 44.821935,
                    longitude: 20.416514
                )
            )
        )
    }()
}