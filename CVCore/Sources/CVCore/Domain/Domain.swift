import Foundation
import CoreLocation

public typealias VenueId = String

// MARK: - Venue
public struct Venue: Codable, Equatable {
    private let venueDto: FoursquareDTO.Venue
    
    public let id: VenueId
    public let name: String
    public let isFavorite: Bool

    public init(fsdto: FoursquareDTO.Venue, isFavorite: Bool) {
        self.venueDto = fsdto
        self.id = fsdto.id
        self.name = fsdto.name
        self.isFavorite = isFavorite
    }

    public init(venue: Venue, isFavorite: Bool) {
        self.init(fsdto: venue.venueDto, isFavorite: isFavorite)
    }

    public func categoryIconUrl(resolution: Int) -> URL? {
        return URL(string: (venueDto.categories.first?.icon.prefix ?? "") + "\(resolution)" + (venueDto.categories.first?.icon.suffix ?? ""))
    }

    public func distance(from location: CLLocation) -> Double? {
        guard let geocodes = venueDto.geocodes else { return nil }
        return calculateDistanceMeters(from: location, to: geocodes.main)
    }

    public func distanceString(from location: CLLocation) -> String? {
        guard let distance = distance(from: location) else { return nil }
        return formatDistance(distance)
    }
}

public struct VenueDetail: Codable, Equatable {
    private let venueDetailDto: FoursquareDTO.VenueDetails

    public let id: VenueId
    public let name: String
    public let description: String?
    public let isFavorite: Bool
    
    public init(fsdto: FoursquareDTO.VenueDetails, isFavorite: Bool) {
        self.venueDetailDto = fsdto
        self.id = fsdto.id
        self.name = fsdto.name
        self.description = fsdto.description
        self.isFavorite = isFavorite
    }

    public init(venueDetail: VenueDetail, isFavorite: Bool) {
        self.init(fsdto: venueDetail.venueDetailDto, isFavorite: isFavorite)
    }

    public func distance(from location: CLLocation) -> Double {
        return calculateDistanceMeters(from: location, to: venueDetailDto.geocodes.main)
    }

    public func distanceString(from location: CLLocation) -> String {
        return formatDistance(distance(from: location))
    }
}

// MARK: - Utility Functions

private func calculateDistanceMeters(from location: CLLocation, to coordinate: FoursquareDTO.Coordinate) -> Double {
    let venueLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    return location.distance(from: venueLocation)
}

private func formatDistance(_ distance: Double) -> String {
    if distance < 1000 {
        return String(format: "%.0fm", distance) // distance in meters
    } else {
        return String(format: "%.1fkm", distance / 1000.0) // distance in kilometers
    }
}

// MARK: - Public extensions for sample data

public extension Venue {
    static var sample1: Venue {
        return Venue(fsdto: .sample1, isFavorite: false)
    }

    static var sample2: Venue {
        return Venue(fsdto: .sample2, isFavorite: true)
    }

    static var sample3: Venue {
        return Venue(fsdto: .sample3, isFavorite: false)
    }
}

public extension VenueDetail {
    static var sample1: VenueDetail {
        return VenueDetail(fsdto: .sample1, isFavorite: false)
    }

    static var sample2: VenueDetail {
        return VenueDetail(fsdto: .sample2, isFavorite: true)
    }

    static var sample3: VenueDetail {
        return VenueDetail(fsdto: .sample3, isFavorite: false)
    }
}