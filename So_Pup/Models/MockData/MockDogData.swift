import Foundation

struct MockDogData {
    static let dog1 = DogModel(
        id: "dog1",
        name: "Bean",
        gender: .male,
        size: .small,
        weight: 14.0,
        breed: "Labrador",
        dob: Calendar.current.date(byAdding: .weekOfYear, value: -8, to: Date())!,
        isNeutered: nil,
        behavior: nil,
        fleaTreatmentDate: nil,
        wormingTreatmentDate: nil,
        coreVaccination1Date: Calendar.current.date(byAdding: .weekOfYear, value: -6, to: Date())!,
        coreVaccination2Date: Calendar.current.date(byAdding: .weekOfYear, value: -7, to: Date())!,
        mode: .puppy,
        status: .incomplete,
        imageURLs: ["https://ik.imagekit.io/3vzopuoqs/soPup/e24bfbd855cda99e303975f2bd2a1bf43079b320-800x600.webp?updatedAt=1751894023966"]
    )

    static let dog2 = DogModel(
        id: "dog2",
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
        fleaTreatmentDate: Calendar.current.date(byAdding: .weekOfYear, value: -3, to: Date())!,
        wormingTreatmentDate: Calendar.current.date(byAdding: .weekOfYear, value: -4, to: Date())!,
        coreVaccination1Date: nil,
        coreVaccination2Date: nil,
        mode: .social,
        status: .ready,
        imageURLs: ["https://ik.imagekit.io/3vzopuoqs/soPup/202104iStock-1257560195-scaled-1.avif?updatedAt=1751894024122"]
    )

    static let dog3 = DogModel(
        id: "dog3",
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
        fleaTreatmentDate: Calendar.current.date(byAdding: .weekOfYear, value: -3, to: Date())!,
        wormingTreatmentDate: Calendar.current.date(byAdding: .weekOfYear, value: -4, to: Date())!,
        coreVaccination1Date: nil,
        coreVaccination2Date: nil,
        mode: .social,
        status: .incomplete,
        imageURLs: ["https://ik.imagekit.io/3vzopuoqs/soPup/907aa7439656710f3aeb351075b6decc.jpg?updatedAt=1751894023914"]
    )

    static let dog4 = DogModel(
        id: "dog4",
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
        fleaTreatmentDate: Calendar.current.date(byAdding: .weekOfYear, value: -3, to: Date())!,
        wormingTreatmentDate: Calendar.current.date(byAdding: .weekOfYear, value: -4, to: Date())!,
        coreVaccination1Date: nil,
        coreVaccination2Date: nil,
        mode: .social,
        status: .ready,
        imageURLs: ["https://ik.imagekit.io/3vzopuoqs/soPup/IMG_9823.jpeg?updatedAt=1751894024537"]
    )

    static let all: [DogModel] = [dog1, dog2, dog3, dog4]
}


