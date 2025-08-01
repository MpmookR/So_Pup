
struct ScoredDog: Codable, Identifiable {
    var id: String { dog.id }

    let dog: DogModel
    let score: Double // backend return score: filterScore + locationScore
}


// Swift will use DogModel.init(from decoder:) (automatically synthesized from Codable) to decode the nested "dog" field
