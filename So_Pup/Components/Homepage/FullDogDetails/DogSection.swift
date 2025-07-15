import SwiftUI

struct DogSection: View {
    let dog: DogModel
    let owner: UserModel
    let userCoordinate: Coordinate
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text(dog.displayName)
                        .font(.title)
                        .bold()
                    HStack(spacing: 6) {
                        Text(owner.location)
                        Spacer()
                        Text(owner.coordinate.formattedDistance(from: userCoordinate))
                    }
                    .font(.subheadline)
                    .foregroundColor(.gray)
                }
                Spacer()
            }
            
            // Image Carousel
            TabView {
                ForEach(dog.imageURLs, id: \.self) { url in
                    AsyncImage(url: URL(string: url)) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        Rectangle().fill(Color.gray.opacity(0.3))
                    }
                }
            }
            .frame(height: 240)
            .tabViewStyle(PageTabViewStyle())
            .clipShape(RoundedRectangle(cornerRadius: 16))
            
            
            // Dog Tags
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 3), spacing: 4) {
                LabelTag(text: dog.breed, icon: Image(systemName: "pawprint"), mode: dog.mode)
                LabelTag(text: dog.gender.rawValue.capitalized, icon: Image(systemName: "person"), mode: dog.mode)
                LabelTag(text: dog.ageText, icon: Image(systemName: "birthday.cake"), mode: dog.mode)
                LabelTag(text: "\(Int(dog.weight)) kg", icon: Image(systemName: "scalemass"), mode: dog.mode)
                LabelTag(text: dog.healthStatus != nil ? "Verified" : "Unverified", icon: Image(systemName: "cross.case"), mode: dog.mode)
                LabelTag(text: dog.isNeutered == true ? "Neutered" : "Not Neutered", icon: dog.isNeutered == true ? Image(systemName: "shield.lefthalf.filled.badge.checkmark") : Image(systemName: "shield.lefthalf.fill.slash"), mode: dog.mode)
            }
            
            
            // About
        
            VStack(alignment: .leading, spacing: 8) {
                Text("About \(dog.name)")
                    .font(.headline)
                    .foregroundStyle(Color.socialText)
                Text(dog.bio ?? "This pup hasn't added a bio yet.")
                    .font(.body)
                    .foregroundStyle(Color.socialText)
                //allows text to grow vertically while wrapping within the parent width
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.leading)
            }
            .padding(.all, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(dog.mode == .puppy ? Color.puppyLight : Color.socialLight)
            .cornerRadius(21)
            
            // Behaviour
            VStack(alignment: .leading, spacing: 8) {
                Text("\(dog.name)’s Behaviour")
                    .font(.headline)
                    .foregroundStyle(Color.socialText)

                if let behavior = dog.behavior {
                    VStack(alignment: .leading, spacing: 8) {
                        if !behavior.playStyles.isEmpty {
                            Text("Play Style")
                                .font(.subheadline)
                                .foregroundStyle(Color.socialText)
                            FlexibleTagView(tags: behavior.playStyles, showSeeMore: false, onSeeMoreTapped: nil, mode: dog.mode)
                        }

                        if !behavior.preferredPlayEnvironments.isEmpty {
                            Text("Preferred Play Environment")
                                .font(.subheadline)
                                .foregroundStyle(Color.socialText)
                            FlexibleTagView(tags: behavior.preferredPlayEnvironments, showSeeMore: false, onSeeMoreTapped: nil, mode: dog.mode)
                        }

                        if !behavior.triggersAndSensitivities.isEmpty {
                            Text("Triggers & Sensitivities")
                                .font(.subheadline)
                                .foregroundStyle(Color.socialText)
                            FlexibleTagView(tags: behavior.triggersAndSensitivities, showSeeMore: false, onSeeMoreTapped: nil, mode: dog.mode)
                        }
                    }
                } else {
                    Text("This feature becomes available once \(dog.displayName) joins Social Mode.")
                        .font(.body)
                        .foregroundStyle(.gray)
                }
            }

            .padding(.all, 16)
            .background(dog.mode == .puppy ? Color.puppyLight : Color.socialLight)
            .cornerRadius(21)

        }
        
    }
}



struct DogSection_Previews: PreviewProvider {
    static var previews: some View {
        DogSection(
            dog: MockDogData.dog1,
            owner: MockUserData.user1,
            userCoordinate: MockUserData.user1.coordinate
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

