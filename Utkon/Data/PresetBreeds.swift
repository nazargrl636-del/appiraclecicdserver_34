import Foundation

struct PresetBreed: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let category: PetCategory
}

struct PresetBreeds {
    static let cats: [PresetBreed] = [
        PresetBreed(name: "Persian", category: .cat),
        PresetBreed(name: "Maine Coon", category: .cat),
        PresetBreed(name: "Ragdoll", category: .cat),
        PresetBreed(name: "British Shorthair", category: .cat),
        PresetBreed(name: "Siamese", category: .cat),
        PresetBreed(name: "Bengal", category: .cat),
        PresetBreed(name: "Abyssinian", category: .cat),
        PresetBreed(name: "Scottish Fold", category: .cat),
        PresetBreed(name: "Sphynx", category: .cat),
        PresetBreed(name: "Russian Blue", category: .cat),
        PresetBreed(name: "Norwegian Forest Cat", category: .cat),
        PresetBreed(name: "Birman", category: .cat),
        PresetBreed(name: "Oriental Shorthair", category: .cat),
        PresetBreed(name: "Devon Rex", category: .cat),
        PresetBreed(name: "Cornish Rex", category: .cat),
        PresetBreed(name: "Burmese", category: .cat),
        PresetBreed(name: "American Shorthair", category: .cat),
        PresetBreed(name: "Exotic Shorthair", category: .cat),
        PresetBreed(name: "Tonkinese", category: .cat),
        PresetBreed(name: "Somali", category: .cat),
        PresetBreed(name: "Turkish Angora", category: .cat),
        PresetBreed(name: "Chartreux", category: .cat),
        PresetBreed(name: "Himalayan", category: .cat),
        PresetBreed(name: "Balinese", category: .cat),
        PresetBreed(name: "Manx", category: .cat),
        PresetBreed(name: "Savannah", category: .cat),
        PresetBreed(name: "Ocicat", category: .cat),
        PresetBreed(name: "Singapura", category: .cat),
        PresetBreed(name: "Egyptian Mau", category: .cat),
        PresetBreed(name: "Bombay", category: .cat)
    ]

    static let dogs: [PresetBreed] = [
        PresetBreed(name: "Labrador Retriever", category: .dog),
        PresetBreed(name: "German Shepherd", category: .dog),
        PresetBreed(name: "Golden Retriever", category: .dog),
        PresetBreed(name: "French Bulldog", category: .dog),
        PresetBreed(name: "Bulldog", category: .dog),
        PresetBreed(name: "Poodle", category: .dog),
        PresetBreed(name: "Beagle", category: .dog),
        PresetBreed(name: "Rottweiler", category: .dog),
        PresetBreed(name: "German Shorthaired Pointer", category: .dog),
        PresetBreed(name: "Dachshund", category: .dog),
        PresetBreed(name: "Yorkshire Terrier", category: .dog),
        PresetBreed(name: "Boxer", category: .dog),
        PresetBreed(name: "Siberian Husky", category: .dog),
        PresetBreed(name: "Great Dane", category: .dog),
        PresetBreed(name: "Doberman Pinscher", category: .dog),
        PresetBreed(name: "Australian Shepherd", category: .dog),
        PresetBreed(name: "Cavalier King Charles Spaniel", category: .dog),
        PresetBreed(name: "Miniature Schnauzer", category: .dog),
        PresetBreed(name: "Shih Tzu", category: .dog),
        PresetBreed(name: "Boston Terrier", category: .dog),
        PresetBreed(name: "Pomeranian", category: .dog),
        PresetBreed(name: "Havanese", category: .dog),
        PresetBreed(name: "Shetland Sheepdog", category: .dog),
        PresetBreed(name: "Bernese Mountain Dog", category: .dog),
        PresetBreed(name: "Brittany", category: .dog),
        PresetBreed(name: "English Springer Spaniel", category: .dog),
        PresetBreed(name: "Cocker Spaniel", category: .dog),
        PresetBreed(name: "Border Collie", category: .dog),
        PresetBreed(name: "Vizsla", category: .dog),
        PresetBreed(name: "Chihuahua", category: .dog)
    ]

    static let hamsters: [PresetBreed] = [
        PresetBreed(name: "Syrian Hamster", category: .hamster),
        PresetBreed(name: "Dwarf Campbell Russian", category: .hamster),
        PresetBreed(name: "Dwarf Winter White Russian", category: .hamster),
        PresetBreed(name: "Roborovski Dwarf", category: .hamster),
        PresetBreed(name: "Chinese Hamster", category: .hamster)
    ]

    static let guineaPigs: [PresetBreed] = [
        PresetBreed(name: "American Guinea Pig", category: .guineaPig),
        PresetBreed(name: "Abyssinian Guinea Pig", category: .guineaPig),
        PresetBreed(name: "Peruvian Guinea Pig", category: .guineaPig),
        PresetBreed(name: "Silkie Guinea Pig", category: .guineaPig),
        PresetBreed(name: "Teddy Guinea Pig", category: .guineaPig),
        PresetBreed(name: "Texel Guinea Pig", category: .guineaPig),
        PresetBreed(name: "Skinny Guinea Pig", category: .guineaPig)
    ]

    static let parrots: [PresetBreed] = [
        PresetBreed(name: "Budgerigar", category: .parrot),
        PresetBreed(name: "Cockatiel", category: .parrot),
        PresetBreed(name: "African Grey", category: .parrot),
        PresetBreed(name: "Amazon Parrot", category: .parrot),
        PresetBreed(name: "Macaw", category: .parrot),
        PresetBreed(name: "Cockatoo", category: .parrot),
        PresetBreed(name: "Conure", category: .parrot),
        PresetBreed(name: "Lovebird", category: .parrot),
        PresetBreed(name: "Eclectus", category: .parrot),
        PresetBreed(name: "Senegal Parrot", category: .parrot)
    ]

    static let rabbits: [PresetBreed] = [
        PresetBreed(name: "Holland Lop", category: .rabbit),
        PresetBreed(name: "Mini Rex", category: .rabbit),
        PresetBreed(name: "Netherland Dwarf", category: .rabbit),
        PresetBreed(name: "Lionhead", category: .rabbit),
        PresetBreed(name: "Flemish Giant", category: .rabbit),
        PresetBreed(name: "English Lop", category: .rabbit),
        PresetBreed(name: "French Lop", category: .rabbit),
        PresetBreed(name: "Dutch Rabbit", category: .rabbit)
    ]

    static let fish: [PresetBreed] = [
        PresetBreed(name: "Betta Fish", category: .fish),
        PresetBreed(name: "Goldfish", category: .fish),
        PresetBreed(name: "Guppy", category: .fish),
        PresetBreed(name: "Neon Tetra", category: .fish),
        PresetBreed(name: "Angelfish", category: .fish),
        PresetBreed(name: "Molly", category: .fish),
        PresetBreed(name: "Platy", category: .fish),
        PresetBreed(name: "Discus", category: .fish),
        PresetBreed(name: "Oscar", category: .fish),
        PresetBreed(name: "Koi", category: .fish)
    ]

    static let turtles: [PresetBreed] = [
        PresetBreed(name: "Red-Eared Slider", category: .turtle),
        PresetBreed(name: "Box Turtle", category: .turtle),
        PresetBreed(name: "Painted Turtle", category: .turtle),
        PresetBreed(name: "Russian Tortoise", category: .turtle),
        PresetBreed(name: "Greek Tortoise", category: .turtle),
        PresetBreed(name: "Sulcata Tortoise", category: .turtle)
    ]

    static let snakes: [PresetBreed] = [
        PresetBreed(name: "Ball Python", category: .snake),
        PresetBreed(name: "Corn Snake", category: .snake),
        PresetBreed(name: "King Snake", category: .snake),
        PresetBreed(name: "Boa Constrictor", category: .snake),
        PresetBreed(name: "Milk Snake", category: .snake),
        PresetBreed(name: "Garter Snake", category: .snake)
    ]

    static let lizards: [PresetBreed] = [
        PresetBreed(name: "Leopard Gecko", category: .lizard),
        PresetBreed(name: "Bearded Dragon", category: .lizard),
        PresetBreed(name: "Crested Gecko", category: .lizard),
        PresetBreed(name: "Blue-Tongued Skink", category: .lizard),
        PresetBreed(name: "Green Iguana", category: .lizard),
        PresetBreed(name: "Chameleon", category: .lizard)
    ]

    static let ferrets: [PresetBreed] = [
        PresetBreed(name: "Sable Ferret", category: .ferret),
        PresetBreed(name: "Albino Ferret", category: .ferret),
        PresetBreed(name: "Black Sable Ferret", category: .ferret),
        PresetBreed(name: "Cinnamon Ferret", category: .ferret),
        PresetBreed(name: "Champagne Ferret", category: .ferret)
    ]

    static let chinchillas: [PresetBreed] = [
        PresetBreed(name: "Standard Grey Chinchilla", category: .chinchilla),
        PresetBreed(name: "White Chinchilla", category: .chinchilla),
        PresetBreed(name: "Beige Chinchilla", category: .chinchilla),
        PresetBreed(name: "Black Velvet Chinchilla", category: .chinchilla),
        PresetBreed(name: "Ebony Chinchilla", category: .chinchilla)
    ]

    static func breeds(for category: PetCategory) -> [PresetBreed] {
        switch category {
        case .cat: return cats
        case .dog: return dogs
        case .hamster: return hamsters
        case .guineaPig: return guineaPigs
        case .parrot: return parrots
        case .rabbit: return rabbits
        case .fish: return fish
        case .turtle: return turtles
        case .snake: return snakes
        case .lizard: return lizards
        case .ferret: return ferrets
        case .chinchilla: return chinchillas
        case .custom: return []
        }
    }

    static var allBreeds: [PresetBreed] {
        cats + dogs + hamsters + guineaPigs + parrots + rabbits + fish + turtles + snakes + lizards + ferrets + chinchillas
    }
}
