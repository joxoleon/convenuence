import Foundation

public typealias VenueId = String

// MARK: - Venue
public struct Venue: Codable, Equatable {
    private let venueDto: FoursqareDTO.Venue
    
    public let id: VenueId
    public let name: String
    public let isFavorite: Bool

    public init(fsdto: FoursqareDTO.Venue, isFavorite: Bool) {
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
}

public struct VenueDetail: Codable, Equatable {
    private let venueDetailDto: FoursqareDTO.VenueDetails

    public let id: VenueId
    public let name: String
    public let description: String?
    public let isFavorite: Bool
    
    public init(fsdto: FoursqareDTO.VenueDetails, isFavorite: Bool) {
        self.venueDetailDto = fsdto
        self.id = fsdto.id
        self.name = fsdto.name
        self.description = fsdto.description
        self.isFavorite = isFavorite
    }

    public init(venueDetail: VenueDetail, isFavorite: Bool) {
        self.init(fsdto: venueDetail.venueDetailDto, isFavorite: isFavorite)
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