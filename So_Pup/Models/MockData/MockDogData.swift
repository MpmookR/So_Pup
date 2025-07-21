import Foundation

struct MockDogData {
    static let dog1 = DogModel(
        id: "dog1",
        ownerId: "user1",
        name: "Bean",
        gender: .male,
        size: .small,
        weight: 14.0,
        breed: "Labrador",
        dob: Calendar.current.date(byAdding: .weekOfYear, value: -8, to: Date())!,
        coreVaccination1Date: Calendar.current.date(byAdding: .weekOfYear, value: -6, to: Date())!,
        coreVaccination2Date: Calendar.current.date(byAdding: .weekOfYear, value: -7, to: Date())!,
        mode: .puppy,
        status: .incomplete,
        imageURLs: [
            "https://placedog.net/800/600?id=19",
            "https://images.pexels.com/photos/20449895/pexels-photo-20449895.jpeg",
            "https://images.pexels.com/photos/16299037/pexels-photo-16299037.jpeg"
        ],
        bio: "Hey, I’m Bean! Small in size, huge in cuddles. I love belly rubs and sniffing leaves.",
        isMock: true
    )

    static let dog2 = DogModel(
        id: "dog2",
        ownerId: "user2",
        name: "Bella",
        gender: .female,
        size: .medium,
        weight: 22.2,
        breed: "Boxer",
        dob: Calendar.current.date(byAdding: .year, value: -4, to: Date())!,
        isNeutered: true,
        behavior: DogBehavior(
            playStyles: ["Explorer", "Gentle Player", "Ball-focused"],
            preferredPlayEnvironments: ["Open Fields", "Daycare"],
            triggersAndSensitivities: ["Loud noises", "Strangers"],
            customPlayStyle: nil,
            customPlayEnvironment: nil,
            customTriggerSensitivity: nil
        ),
        healthStatus: HealthStatus(
            fleaTreatmentDate: Calendar.current.date(byAdding: .weekOfYear, value: -3, to: Date())!,
            wormingTreatmentDate: Calendar.current.date(byAdding: .weekOfYear, value: -4, to: Date())!
        ),
        mode: .social,
        status: .ready,
        imageURLs: [
            "https://ik.imagekit.io/3vzopuoqs/soPup/202104iStock-1257560195-scaled-1.avif?updatedAt=1751894024122",
            "https://images.pexels.com/photos/1294062/pexels-photo-1294062.jpeg"
        ],
        bio: "Hi, I’m Bella! I’m all about zoomies and ball chasing. Let’s play at the park!",
        isMock: true
    )

    static let dog3 = DogModel(
        id: "dog3",
        ownerId: "user3",
        name: "Ryu",
        gender: .male,
        size: .medium,
        weight: 16.1,
        breed: "Border Collie",
        dob: Calendar.current.date(byAdding: .year, value: -3, to: Date())!,
        isNeutered: false,
        behavior: DogBehavior(
            playStyles: ["Mouthy", "Ball-focused", "Chaser"],
            preferredPlayEnvironments: ["Enclosed Parks", "Daycare"],
            triggersAndSensitivities: ["Cats", "Sudden movements"],
            customPlayStyle: nil,
            customPlayEnvironment: nil,
            customTriggerSensitivity: nil
        ),
        healthStatus: HealthStatus(
            fleaTreatmentDate: Calendar.current.date(byAdding: .weekOfYear, value: -3, to: Date())!,
            wormingTreatmentDate: Calendar.current.date(byAdding: .weekOfYear, value: -4, to: Date())!
        ),
        mode: .social,
        status: .incomplete,
        imageURLs: [
            "https://ik.imagekit.io/3vzopuoqs/soPup/907aa7439656710f3aeb351075b6decc.jpg?updatedAt=1751894023914"
        ],
        bio: "Speed and smarts! Ryu’s my name, and chasing things is my game.",
        isMock: true
    )

    static let dog4 = DogModel(
        id: "dog4",
        ownerId: "user4",
        name: "Kuma",
        gender: .male,
        size: .medium,
        weight: 12.4,
        breed: "Shiba Inu",
        dob: Calendar.current.date(byAdding: .year, value: -2, to: Date())!,
        isNeutered: true,
        behavior: DogBehavior(
            playStyles: ["Explorer", "Chaser", "Ball-focused"],
            preferredPlayEnvironments: ["Home Garden", "Flexible"],
            triggersAndSensitivities: ["Bicycles", "Loud noises"],
            customPlayStyle: nil,
            customPlayEnvironment: nil,
            customTriggerSensitivity: nil
        ),
        healthStatus: HealthStatus(
            fleaTreatmentDate: Calendar.current.date(byAdding: .weekOfYear, value: -3, to: Date())!,
            wormingTreatmentDate: Calendar.current.date(byAdding: .weekOfYear, value: -4, to: Date())!
        ),
        mode: .social,
        status: .ready,
        imageURLs: [
            "https://images.pexels.com/photos/1805164/pexels-photo-1805164.jpeg",
            "https://images.pexels.com/photos/16029611/pexels-photo-16029611.jpeg"
        ],
        bio: "Kuma here — majestic, mysterious, and ready to make new friends.",
        isMock: true
    )

    static let all: [DogModel] = [dog1, dog2, dog3, dog4]
}
