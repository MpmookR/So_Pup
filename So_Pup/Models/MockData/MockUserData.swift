import Foundation

struct MockUserData {
    static let user1 = UserModel(
        id: "user1",
        name: "Kate S",
        gender: .female,
        profilePictureURL: "https://placedog.net/500/400?id=1",
        location: "London, United Kingdom",
        coordinate: Coordinate(latitude: 51.5074, longitude: -0.1278),
        bio: "Dog mum to Scooby, my 4-year-old partner in crime.",
        languages: ["English"],
        customLanguage: nil,
        dogId: "dog1",
        locationPermissionDenied: true,
        isMock: true

    )

    static let user2 = UserModel(
        id: "user2",
        name: "Tom R",
        gender: .male,
        profilePictureURL: "https://placedog.net/500/400?id=2",
        location: "Manchester, UK",
        coordinate: Coordinate(latitude: 53.4808, longitude: -2.2426),
        bio: "Weekend adventurer with my energetic lab, Bruno.",
        languages: ["English", "Spanish"],
        customLanguage: nil,
        dogId: "dog2",
        locationPermissionDenied: false,
        isMock: true

    )

    static let user3 = UserModel(
        id: "user3",
        name: "Linh N",
        gender: .female,
        profilePictureURL: "https://placedog.net/500/400?id=3",
        location: "Bristol, UK",
        coordinate: Coordinate(latitude: 51.4545, longitude: -2.5879),
        bio: "Love calm walks and puppy training classes.",
        languages: ["Vietnamese"],
        customLanguage: "French",
        dogId: "dog3",
        locationPermissionDenied: true,
        isMock: true

    )

    static let user4 = UserModel(
        id: "user4",
        name: "Alex J",
        gender: .other,
        profilePictureURL: "https://placedog.net/500/400?id=4",
        location: "Edinburgh, UK",
        coordinate: Coordinate(latitude: 55.9533, longitude: -3.1883),
        bio: nil,
        languages: ["English"],
        customLanguage: nil,
        dogId: "dog4",
        locationPermissionDenied: true,
        isMock: true
    )

    static let all: [UserModel] = [user1, user2, user3, user4]
}


