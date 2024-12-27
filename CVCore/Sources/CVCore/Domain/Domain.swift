import Foundation

public typealias VenueId = String

public struct Venue: Codable, Equatable, Hashable {
    public let id: VenueId
    public let name: String
    public let isFavorite: Bool

    public init(id: VenueId, name: String, isFavorite: Bool) {
        self.id = id
        self.name = name
        self.isFavorite = isFavorite
    }

    public init(fsdto: FoursqareDTO.Venue, isFavorite: Bool) {
        self.id = fsdto.id
        self.name = fsdto.name
        self.isFavorite = isFavorite
    }
}

public struct VenueDetail: Codable, Hashable, Equatable {
    public let id: VenueId
    public let name: String
    public let description: String?
    public let isFavorite: Bool
    public let photoUrls: [URL]

    public init(id: VenueId, name: String, description: String?, isFavorite: Bool, photoUrls: [URL]) {
        self.id = id
        self.name = name
        self.description = description
        self.isFavorite = isFavorite
        self.photoUrls = photoUrls
    }
    
    public init(fsdto: FoursqareDTO.VenueDetails, isFavorite: Bool, photoUrls: [URL]) {
        self.id = fsdto.id
        self.name = fsdto.name
        self.description = fsdto.description
        self.isFavorite = isFavorite
        self.photoUrls = photoUrls
    }
}

