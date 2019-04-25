/**
 * This defines a basic set of data for our Star Wars Schema.
 *
 * This data is hard coded for the sake of the demo, but you could imagine
 * fetching this data from a backend service rather than from hardcoded
 * values in a more complex demo.
 */

enum Episode : String {
    case newHope = "NEWHOPE"
    case empire = "EMPIRE"
    case jedi = "JEDI"

    init?(_ string: String?) {
        guard let string = string else {
            return nil
        }

        self.init(rawValue: string)
    }
}

protocol Character {
    var id: String { get }
    var name: String { get }
    var friends: [String] { get }
    var appearsIn: [Episode] { get }
}

struct Planet {
    let id: String
    let name: String
    let diameter: Int
    let rotationPeriod: Int
    let orbitalPeriod: Int
    var residents: [Human]
}

struct Human : Character {
    let id: String
    let name: String
    let friends: [String]
    let appearsIn: [Episode]
    let homePlanet: Planet

    init(id: String, name: String, friends: [String], appearsIn: [Episode], homePlanet: Planet) {
        self.id = id
        self.name = name
        self.friends = friends
        self.appearsIn = appearsIn
        self.homePlanet = homePlanet
    }
}

struct Droid : Character {
    let id: String
    let name: String
    let friends: [String]
    let appearsIn: [Episode]
    let primaryFunction: String
}

protocol SearchResult {}
extension Planet: SearchResult {}
extension Human: SearchResult {}
extension Droid: SearchResult {}

var tatooine = Planet(id:"10001", name: "Tatooine", diameter: 10465, rotationPeriod: 23, orbitalPeriod: 304,residents: [Human]() )
var alderaan = Planet(id: "10002", name: "Alderaan", diameter: 12500, rotationPeriod: 24, orbitalPeriod: 364, residents: [Human]())

let planetData: [String: Planet] = [
    "10001": tatooine,
    "10002": alderaan,
]

let luke = Human(
    id: "1000",
    name: "Luke Skywalker",
    friends: ["1002", "1003", "2000", "2001"],
    appearsIn: [.newHope, .empire, .jedi],
    homePlanet: tatooine
)


let vader = Human(
    id: "1001",
    name: "Darth Vader",
    friends: [ "1004" ],
    appearsIn: [.newHope, .empire, .jedi],
    homePlanet: tatooine
)

let han = Human(
    id: "1002",
    name: "Han Solo",
    friends: ["1000", "1003", "2001"],
    appearsIn: [.newHope, .empire, .jedi],
    homePlanet: alderaan
)

let leia = Human(
    id: "1003",
    name: "Leia Organa",
    friends: ["1000", "1002", "2000", "2001"],
    appearsIn: [.newHope, .empire, .jedi],
    homePlanet: alderaan
)

let tarkin = Human(
    id: "1004",
    name: "Wilhuff Tarkin",
    friends: ["1001"],
    appearsIn: [.newHope],
    homePlanet: alderaan
)

let humanData: [String: Human] = [
    "1000": luke,
    "1001": vader,
    "1002": han,
    "1003": leia,
    "1004": tarkin,
]

let c3po = Droid(
    id: "2000",
    name: "C-3PO",
    friends: ["1000", "1002", "1003", "2001"],
    appearsIn: [.newHope, .empire, .jedi],
    primaryFunction: "Protocol"
)

let r2d2 = Droid(
    id: "2001",
    name: "R2-D2",
    friends: [ "1000", "1002", "1003" ],
    appearsIn: [.newHope, .empire, .jedi],
    primaryFunction: "Astromech"
)

let droidData: [String: Droid] = [
    "2000": c3po,
    "2001": r2d2,
]

/**
 * Helper function to get a character by ID.
 */
func getCharacter(id: String) -> Character? {
    return humanData[id] ?? droidData[id]
}

/**
 * Allows us to query for a character"s friends.
 */
func getFriends(character: Character) -> [Character] {
    return character.friends.reduce([]) { friends, friendID in
        var friends = friends

        guard let friend = getCharacter(id: friendID) else {
            return friends
        }

        friends.append(friend)
        return friends
    }
}

/**
 * Allows us to fetch the undisputed hero of the Star Wars trilogy, R2-D2.
 */
func getHero(episode: Episode?) -> Character {
    if episode == .empire {
        // Luke is the hero of Episode V.
        return luke
    }
    // R2-D2 is the hero otherwise.
    return r2d2
}

/**
 * Allows us to query for the human with the given id.
 */
func getHuman(id: String) -> Human? {
    return humanData[id]
}

/**
 * Allows us to query for the droid with the given id.
 */
func getDroid(id: String) -> Droid? {
    return droidData[id]
}

/**
 * Allows us to query for the droid with the given id.
 */
func getSecretBackStory() throws -> String? {
    struct Secret : Error, CustomStringConvertible {
        let description: String
    }

    throw Secret(description: "secretBackstory is secret.")
}

/**
 * Allos us to query for either a Human, Droid, or Planet.
 */
func search(for value: String) -> [SearchResult] {
    let value = value.lowercased()
    var result: [SearchResult] = []

    // Due to randomness of hash values introduced by https://github.com/apple/swift-evolution/blob/master/proposals/0206-hashable-enhancements.md
    // we should iterate over sorted keys here otherwise the order of output is random and the tests sometimes fails.
    
    planetData.keys.sorted().forEach {
        if planetData[$0]?.name.lowercased().range(of:value) != nil {
            result.append(planetData[$0]!)
        }
    }
    
    humanData.keys.sorted().forEach {
        if humanData[$0]?.name.lowercased().range(of:value) != nil {
           result.append(humanData[$0]!)
        }
    }
    
    droidData.keys.sorted().forEach {
        if droidData[$0]?.name.lowercased().range(of:value) != nil {
            result.append(droidData[$0]!)
        }
    }

    return result
}
