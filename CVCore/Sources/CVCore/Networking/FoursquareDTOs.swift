import Foundation

// Foursquare Data Transfer Objects
public enum FoursqareDTO {
    
    // MARK: - Venue
    
    public struct Venue: Codable, Equatable {
        public let id: String
        public let name: String
        public let location: Location
        public let categories: [Category]
        
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

extension FoursqareDTO.Venue {
    static var sample1: FoursqareDTO.Venue = {
        return FoursqareDTO.Venue(
            id: "1",
            name: "Coffee Shop",
            location: FoursqareDTO.Location(
                address: "123 Main St",
                formatted_address: "123 Main St, New York, NY 10001",
                locality: "New York",
                postcode: "10001",
                region: "New York",
                country: "US"
            ),
            categories: [
                FoursqareDTO.Category(
                    id: 13064,
                    name: "Pizzeria",
                    short_name: "Pizza",
                    icon: FoursqareDTO.Icon(
                        prefix: "https://ss3.4sqi.net/img/categories_v2/food/pizza_",
                        suffix: ".png"
                    )
                )
            ]
        )
    }()

    static var sample2: FoursqareDTO.Venue = {
        return FoursqareDTO.Venue(
            id: "2",
            name: "Burger Bar",
            location: FoursqareDTO.Location(
                address: "456 Main St",
                formatted_address: "456 Main St, New York, NY 10001",
                locality: "New York",
                postcode: "10001",
                region: "New York",
                country: "US"
            ),
            categories: [
                FoursqareDTO.Category(
                    id: 13064,
                    name: "Burger Joint",
                    short_name: "Burger",
                    icon: FoursqareDTO.Icon(
                        prefix: "https://ss3.4sqi.net/img/categories_v2/food/burger_",
                        suffix: ".png"
                    )
                )
            ]
        )
    }()

    static var sample3: FoursqareDTO.Venue = {
        return FoursqareDTO.Venue(
            id: "3",
            name: "Pizza Bar",
            location: FoursqareDTO.Location(
                address: "789 Main St",
                formatted_address: "789 Main St, New York, NY 10001",
                locality: "New York",
                postcode: "10001",
                region: "New York",
                country: "US"
            ),
            categories: [
                FoursqareDTO.Category(
                    id: 13064,
                    name: "Pizzeria",
                    short_name: "Pizza",
                    icon: FoursqareDTO.Icon(
                        prefix: "https://ss3.4sqi.net/img/categories_v2/food/pizza_",
                        suffix: ".png"
                    )
                )
            ]
        )
    }()
}

extension FoursqareDTO.VenueDetails {
    static var sample1: FoursqareDTO.VenueDetails = {
        return FoursqareDTO.VenueDetails(
            id: "1",
            name: "Pizza Bar",
            description: "The best pizza in town",
            location: FoursqareDTO.Location(
                address: "Bulevar Mihajla Pupina 165v",
                formatted_address: "Bulevar Mihajla Pupina 165v (Bulevar umetnosti), 11070 Београд",
                locality: "Београд",
                postcode: "11070",
                region: "Central Serbia",
                country: "RS"
            ),
            categories: [
                FoursqareDTO.Category(
                    id: 13064,
                    name: "Pizzeria",
                    short_name: "Pizza",
                    icon: FoursqareDTO.Icon(
                        prefix: "https://ss3.4sqi.net/img/categories_v2/food/pizza_",
                        suffix: ".png"
                    )
                )
            ],
            geocodes: FoursqareDTO.Geocodes(
                main: FoursqareDTO.Coordinate(
                    latitude: 44.821935,
                    longitude: 20.416514
                )
            )
        )
    }()

    static var sample2: FoursqareDTO.VenueDetails = {
        return FoursqareDTO.VenueDetails(
            id: "2",
            name: "Burger Bar",
            description: "The best burgers in town",
            location: FoursqareDTO.Location(
                address: "Bulevar Mihajla Pupina 165v",
                formatted_address: "Bulevar Mihajla Pupina 165v (Bulevar umetnosti), 11070 Београд",
                locality: "Београд",
                postcode: "11070",
                region: "Central Serbia",
                country: "RS"
            ),
            categories: [
                FoursqareDTO.Category(
                    id: 13064,
                    name: "Burger Joint",
                    short_name: "Burger",
                    icon: FoursqareDTO.Icon(
                        prefix: "https://ss3.4sqi.net/img/categories_v2/food/burger_",
                        suffix: ".png"
                    )
                )
            ],
            geocodes: FoursqareDTO.Geocodes(
                main: FoursqareDTO.Coordinate(
                    latitude: 44.821935,
                    longitude: 20.416514
                )
            )
        )
    }()

    static var sample3: FoursqareDTO.VenueDetails = {
        return FoursqareDTO.VenueDetails(
            id: "3",
            name: "Coffee Shop",
            description: "The best coffee in town",
            location: FoursqareDTO.Location(
                address: "Bulevar Mihajla Pupina 165v",
                formatted_address: "Bulevar Mihajla Pupina 165v (Bulevar umetnosti), 11070 Београд",
                locality: "Београд",
                postcode: "11070",
                region: "Central Serbia",
                country: "RS"
            ),
            categories: [
                FoursqareDTO.Category(
                    id: 13064,
                    name: "Coffee Shop",
                    short_name: "Coffee",
                    icon: FoursqareDTO.Icon(
                        prefix: "https://ss3.4sqi.net/img/categories_v2/food/coffeeshop_",
                        suffix: ".png"
                    )
                )
            ],
            geocodes: FoursqareDTO.Geocodes(
                main: FoursqareDTO.Coordinate(
                    latitude: 44.821935,
                    longitude: 20.416514
                )
            )
        )
    }()
}