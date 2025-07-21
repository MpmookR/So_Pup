import Foundation

struct MockUserData {
    static let user1 = UserModel(
        id: "user1",
        name: "Catelyn Stark",
        gender: .female,
        profilePictureURL: "https://images.pexels.com/photos/712513/pexels-photo-712513.jpeg",
        location: "London, United Kingdom",
        coordinate: Coordinate(latitude: 51.5074, longitude: -0.1278),
        locationPermissionDenied: true,
        bio: "Proud puppy mum to Bean. Still figuring out toilet training and chew-proofing my shoes.",
        languages: ["English", "French"],
        customLanguage: nil,
        dogId: "dog1",
        isMock: true

    )

    static let user2 = UserModel(
        id: "user2",
        name: "Jon Snow",
        gender: .male,
        profilePictureURL: "https://images.pexels.com/photos/33000902/pexels-photo-33000902.jpeg",
        location: "Manchester, UK",
        coordinate: Coordinate(latitude: 53.4808, longitude: -2.2426),
        locationPermissionDenied: false,
        bio: "Weekend adventurer with Bella, my 4-year-old zoom queen and park buddy.",
        languages: ["English", "Spanish"],
        customLanguage: nil,
        dogId: "dog2",
        isMock: true

    )

    static let user3 = UserModel(
        id: "user3",
        name: "Linh Ng Weng",
        gender: .female,
        profilePictureURL: "https://images.pexels.com/photos/33000902/pexels-photo-33000902.jpeg",
        location: "Bristol, UK",
        coordinate: Coordinate(latitude: 51.4545, longitude: -2.5879),
        locationPermissionDenied: true,
        bio: "Trying to keep up with Ryu’s energy! Training, chasing, and lots of fetch in Bristol.",
        languages: ["English", "Vietnamese"],
        customLanguage: nil,
        dogId: "dog3",
        isMock: true

    )

    static let user4 = UserModel(
        id: "user4",
        name: "Khal Drogo",
        gender: .other,
        profilePictureURL: "https://images.pexels.com/photos/5464923/pexels-photo-5464923.jpeg",
        location: "Edinburgh, UK",
        coordinate: Coordinate(latitude: 55.9533, longitude: -3.1883),
        locationPermissionDenied: true,
        bio: nil,
        languages: ["English", "Italian"],
        customLanguage: nil,
        dogId: "dog4",
        isMock: true
    )

    static let all: [UserModel] = [user1, user2, user3, user4]
}


