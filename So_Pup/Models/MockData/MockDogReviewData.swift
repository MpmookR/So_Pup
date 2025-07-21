import Foundation

struct MockDogReviewData {
    static let review1 = DogReview(
        id: "review1",
        meetupId: "meetup1",
        reviewedDogId: MockDogData.dog3.id, // Ryu
        reviewerDogId: MockDogData.dog4.id, // Kuma
        reviewerDogName: MockDogData.dog4.name,
        reviewerDogImageURL: MockDogData.dog4.imageURLs.first ?? "",
        date: Calendar.current.date(byAdding: .day, value: -3, to: Date())!,
        reviewText: "Ryu was so gentle with Kuma! They had a lovely time sniffing around the park together.",
        isMock: true
    )

    static let review2 = DogReview(
        id: "review2",
        meetupId: "meetup2",
        reviewedDogId: MockDogData.dog3.id, // Ryu
        reviewerDogId: MockDogData.dog2.id, // Bella
        reviewerDogName: MockDogData.dog2.name,
        reviewerDogImageURL: MockDogData.dog2.imageURLs.first ?? "",
        date: Calendar.current.date(byAdding: .day, value: -7, to: Date())!,
        reviewText: "Ryu was full of energy! Bella enjoyed chasing him around—non-stop action.",
        isMock: true
    )

    static let review3 = DogReview(
        id: "review3",
        meetupId: "meetup3",
        reviewedDogId: MockDogData.dog4.id, // Kuma
        reviewerDogId: MockDogData.dog2.id, // Bella
        reviewerDogName: MockDogData.dog2.name,
        reviewerDogImageURL: MockDogData.dog2.imageURLs.first ?? "",
        date: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
        reviewText: "Kuma was polite and calm. Bella really appreciated the chill vibes during their garden walk.",
        isMock: true
    )

    static let all: [DogReview] = [review1, review2, review3]
}

