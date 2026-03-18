//
//  Models.swift
//  SIP SYNC
//
//  Created by Diop Shumake on 10/23/25.
//

import Foundation
import CoreLocation

// MARK: - User Models
struct User: Identifiable, Codable {
    let id = UUID()
    var name: String
    var email: String
    var profileImage: String?
    var location: String
    var userType: UserType = .consumer
    var bio: String? // Professional description/bio
    var profession: String? // Professional title (e.g., "Digital Product Designer, Motion Designer")
    var languages: [String] = [] // Languages spoken
    var interests: Set<DrinkInterest> = [] // User interests
    var headerImage: String? // Header banner image
    var instagramHandle: String?
    var twitterHandle: String?
    var likedPostIds: Set<UUID> = [] // Posts the user has liked
}

// MARK: - Drink Models
struct Drink: Identifiable, Codable {
    let id = UUID()
    var name: String
    var category: DrinkCategory
    var image: String
    var bio: String
    var ingredients: [String]
    var steps: [String]
    var price: Double
    var tags: [String]
    var isFavorite: Bool = false
}

enum DrinkCategory: String, CaseIterable, Codable {
    case drinks = "Drinks"
    case food = "Food"
    case social = "Social"
}

// MARK: - Order Models
struct Order: Identifiable, Codable {
    let id = UUID()
    var items: [OrderItem]
    var total: Double
    var status: OrderStatus
    var deliveryAddress: String
    var estimatedDelivery: String
    var createdAt: Date = Date()
}

struct OrderItem: Identifiable, Codable {
    let id = UUID()
    var drink: Drink
    var quantity: Int
    var price: Double
}

enum OrderStatus: String, Codable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case preparing = "Preparing"
    case ready = "Ready"
    case delivered = "Delivered"
}

// MARK: - Payment Models
struct PaymentMethod: Identifiable, Codable {
    let id = UUID()
    var type: PaymentType
    var lastFour: String
    var isDefault: Bool = false
}

enum PaymentType: String, Codable {
    case creditCard = "Credit Card"
    case applePay = "Apple Pay"
    case paypal = "PayPal"
}

// MARK: - Discovery Models
enum DrinkInterest: String, CaseIterable, Codable, Hashable {
    // Spirits
    case whiskey = "Whiskey"
    case bourbon = "Bourbon"
    case scotch = "Scotch"
    case gin = "Gin"
    case tequila = "Tequila"
    case rum = "Rum"
    case vodka = "Vodka"
    // Cocktails
    case negroni = "Negroni"
    case martini = "Martini"
    case oldFashioned = "Old Fashioned"
    case spritz = "Spritz"
    case margarita = "Margarita"
    case manhattan = "Manhattan"
    // Wine & Beer & NA
    case redWine = "Red Wine"
    case whiteWine = "White Wine"
    case sparkling = "Sparkling"
    case ipa = "IPA"
    case lager = "Lager"
    case stout = "Stout"
    case mocktails = "Mocktails"
}

struct UserPreferences: Codable {
    var selectedInterests: Set<DrinkInterest> = []
}

// MARK: - Social Models
enum UserType: String, CaseIterable, Codable {
    case consumer = "Consumer"
    case bartender = "Bartender"
    case venue = "Venue Provider"
}

struct SocialPost: Identifiable, Codable {
    let id = UUID()
    var author: SocialUser
    var content: String
    var image: String?
    var tags: [String]
    var createdAt: Date
    var likes: Int
    var comments: Int
    var syncs: Int
    var isLiked: Bool = false
    var isSynced: Bool = false
    var postType: PostType
    var commentsList: [Comment] = [] // List of comments on this post
    var repostedBy: SocialUser? // User who reposted (nil if original post)
    var originalPostId: UUID? // ID of original post if this is a repost
}

struct SocialUser: Identifiable, Codable {
    let id = UUID()
    var name: String
    var username: String
    var profileImage: String?
    var userType: UserType
    var location: String?
    var verified: Bool = false
}

// MARK: - Comment Model
struct Comment: Identifiable, Codable {
    let id = UUID()
    var author: SocialUser
    var text: String
    var createdAt: Date
    var likes: Int = 0
    var isLiked: Bool = false
}

// MARK: - Location Models
struct Location: Identifiable {
    let id = UUID()
    var name: String
    var subtitle: String
    var address: String? // Full address
    var latitude: Double
    var longitude: Double
    var locationType: LocationType
    var stories: [SocialPost]
    var image: String?
    var sipSyncBartenders: [SocialUser] = [] // Sip Sync bartenders at this location
    var phone: String?
    var website: String?
    var hours: String? // Operating hours
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var hasSipSyncBartender: Bool {
        !sipSyncBartenders.isEmpty
    }
}

enum LocationType: String, Codable {
    case bartender = "bartender"
    case venue = "venue"
}

enum PostType: String, CaseIterable, Codable {
    case cocktail = "Cocktail"
    case venue = "Venue"
    case event = "Event"
    case training = "Training"
    case tip = "Tip"
    case experience = "Experience"
}

// MARK: - Review Models (Stories as Reviews)
struct Story: Identifiable {
    let id = UUID()
    var image: String?
    var reviewText: String?
    var rating: Int? // 1-5 stars
    var textColor: String = "white"
    var createdAt: Date
    var author: SocialUser? // Review author
    var locationId: UUID? // Associated location/venue
    
    // Keep expiration for backward compatibility, but make it optional for reviews
    var expiresAt: Date? // Optional - reviews don't expire
    
    // Legacy support
    var text: String? {
        get { reviewText }
        set { reviewText = newValue }
    }
    
    var isExpired: Bool {
        guard let expiresAt = expiresAt else { return false } // Reviews don't expire
        return Date() > expiresAt
    }
    
    var timeRemaining: TimeInterval {
        guard let expiresAt = expiresAt else { return .infinity }
        return max(0, expiresAt.timeIntervalSinceNow)
    }
    
    var isEditable: Bool {
        // Reviews are editable by their author
        return true
    }
}

struct StorySet: Identifiable {
    let id = UUID()
    var author: SocialUser
    var stories: [Story]
    var viewedStories: Set<UUID> = [] // Track which stories have been viewed
    
    var hasUnviewedStories: Bool {
        !stories.filter { !viewedStories.contains($0.id) && !$0.isExpired }.isEmpty
    }
    
    var activeStories: [Story] {
        stories.filter { !$0.isExpired }
    }
}

// MARK: - Bartender Profile Models (SipSync Originals)
struct BartenderProfile: Identifiable {
    let id = UUID()
    var author: SocialUser
    var profileImage: String
    var bio: String
    var followers: Int
    var following: Int
    var comments: Int
    var contentCategories: [String] // Hashtags/categories
    var contentGallery: [ContentItem] // Gallery of content images
    var isFollowed: Bool = false
}

struct ContentItem: Identifiable {
    let id = UUID()
    var image: String
    var title: String?
}

// MARK: - Bartender Class Models (Locked Classes)
struct BartenderClass: Identifiable {
    let id = UUID()
    var title: String
    var bartender: SocialUser
    var date: Date
    var time: String
    var location: String
    var image: String
    var isLocked: Bool = true
    var isGoing: Bool = false
    var attendees: [SocialUser] = []
    var description: String
    var price: Double?
}

// MARK: - Sample Data
class SampleData {
    static let shared = SampleData()
    
    let sampleDrinks: [Drink] = [
        // Drinks Category
        Drink(name: "Negroni", category: .drinks, image: "negroni", bio: "A bold, complex classic cocktail that balances bitter, sweet, and herbal flavors", ingredients: ["Gin", "Campari", "Sweet Vermouth", "Orange Peel"], steps: ["Combine ingredients", "Stir with ice", "Strain into glass", "Garnish with orange peel"], price: 22.00, tags: ["Classic", "Italian"]),
        Drink(name: "Scotch & Bourbon", category: .drinks, image: "scotch", bio: "Premium whisky selections aged in oak barrels", ingredients: ["Scotch Whiskey", "Bourbon", "Ice"], steps: ["Pour whiskey", "Add ice", "Serve"], price: 30.00, tags: ["Premium", "Whiskey"]),
        Drink(name: "Spritzer", category: .drinks, image: "spritzer", bio: "A light, refreshing alcoholic beverage that combines wine with sparkling water or soda", ingredients: ["White Wine", "Soda Water", "Lemon"], steps: ["Mix wine and soda", "Add lemon", "Serve chilled"], price: 18.00, tags: ["Light", "Refreshing"]),
        Drink(name: "Martini", category: .drinks, image: "martini", bio: "The epitome of cocktail elegance—crisp, bold, and unapologetically minimal", ingredients: ["Gin", "Dry Vermouth", "Olive"], steps: ["Stir gin and vermouth", "Strain into glass", "Garnish with olive"], price: 20.00, tags: ["Classic", "Gin"]),
        Drink(name: "Red Wine", category: .drinks, image: "Red Wine", bio: "Rich, full-bodied red wine with notes of dark fruit, oak, and spice. Perfect for pairing with hearty meals or enjoying on its own", ingredients: ["Red Wine Grapes", "Oak Aging"], steps: ["Select wine", "Decant if needed", "Serve at room temperature"], price: 35.00, tags: ["Premium", "Wine", "Red"]),
        Drink(name: "White Wine", category: .drinks, image: "White Wine", bio: "Crisp, refreshing white wine with bright citrus and floral notes. Ideal for light meals, seafood, or casual sipping", ingredients: ["White Wine Grapes", "Cool Climate"], steps: ["Select wine", "Chill to 45-50°F", "Serve in white wine glass"], price: 32.00, tags: ["Light", "Wine", "White"]),
        
        // Food Category
        Drink(name: "Truffle Pasta", category: .food, image: "truffle_pasta", bio: "Handcrafted pasta with black truffle shavings and parmesan cream sauce", ingredients: ["Fresh Pasta", "Black Truffle", "Parmesan", "Cream"], steps: ["Cook pasta al dente", "Prepare truffle cream sauce", "Combine and garnish"], price: 28.00, tags: ["Premium", "Italian"]),
        Drink(name: "Wagyu Steak", category: .food, image: "wagyu", bio: "A5 Wagyu beef with truffle butter and seasonal vegetables", ingredients: ["A5 Wagyu", "Truffle Butter", "Seasonal Vegetables"], steps: ["Sear to perfection", "Rest and slice", "Plate with vegetables"], price: 85.00, tags: ["Premium", "Japanese"]),
        Drink(name: "Lobster Risotto", category: .food, image: "lobster_risotto", bio: "Creamy arborio rice with fresh lobster and saffron", ingredients: ["Arborio Rice", "Fresh Lobster", "Saffron", "Parmesan"], steps: ["Toast rice", "Add stock gradually", "Finish with lobster"], price: 42.00, tags: ["Seafood", "Italian"]),
        
        // Social Category
        Drink(name: "Wine Tasting", category: .social, image: "wine_tasting", bio: "Curated wine tasting experience with expert sommelier guidance", ingredients: ["Premium Wines", "Expert Guidance", "Tasting Notes"], steps: ["Arrive at venue", "Meet sommelier", "Taste and learn"], price: 75.00, tags: ["Educational", "Premium"]),
        Drink(name: "Mixology Class", category: .social, image: "mixology", bio: "Learn cocktail crafting techniques from professional mixologists", ingredients: ["Premium Spirits", "Professional Instruction", "Take-home recipes"], steps: ["Register for class", "Learn techniques", "Practice and enjoy"], price: 95.00, tags: ["Educational", "Hands-on"]),
        Drink(name: "Whiskey Masterclass", category: .social, image: "whiskey_class", bio: "Deep dive into whiskey production, aging, and tasting techniques", ingredients: ["Premium Whiskeys", "Expert Knowledge", "Tasting Guide"], steps: ["Join masterclass", "Learn about whiskey", "Taste and compare"], price: 120.00, tags: ["Educational", "Premium"])
    ]
    
    let sampleUser = User(
        name: "Alex Mixwell",
        email: "alex@example.com",
        profileImage: nil, // Will use system icon if no image
        location: "Detroit, Michigan",
        userType: .consumer,
        bio: "Passionate about craft cocktails, premium spirits, and discovering unique flavor combinations.",
        profession: "Cocktail Enthusiast, Mixology Explorer, Spirit Connoisseur",
        languages: ["English", "Spanish"],
        interests: [.negroni, .martini, .whiskey, .gin, .oldFashioned, .spritz],
        headerImage: nil,
        instagramHandle: "alexmixwell",
        twitterHandle: "alexmixwell"
    )
    
        let sampleSocialUsers: [SocialUser]
        let sampleSocialPosts: [SocialPost]
        let sampleLocations: [Location]
        let sampleStorySets: [StorySet]
        let sampleBartenderProfiles: [BartenderProfile]
        let sampleBartenderClasses: [BartenderClass]

        private init() {
        self.sampleSocialUsers = [
            SocialUser(name: "Miranda Lrouge", username: "miranda.Lrouge", userType: .bartender, location: "PORT", verified: true),
            SocialUser(name: "Chef André William", username: "chef_andre", userType: .bartender, location: "Detroit", verified: true),
            SocialUser(name: "Maddy R", username: "maddy_mixologist", userType: .bartender, location: "Nelson Cocktail Lounge"),
            SocialUser(name: "Antonio Ruiz", username: "antonio_ruiz", userType: .venue, location: "The Nest Bar", verified: true),
            SocialUser(name: "Sarah Chen", username: "sarah_chen", userType: .consumer, location: "Detroit"),
            SocialUser(name: "Marcus Johnson", username: "marcus_j", userType: .consumer, location: "Detroit")
        ]
        
        self.sampleSocialPosts = [
            SocialPost(
                author: sampleSocialUsers[0],
                content: "Perfect pour technique for the classic Negroni. The key is in the ice and the stir! 🍸",
                image: "Negroni",
                tags: ["#negroni", "#mixology", "#classic"],
                createdAt: Date().addingTimeInterval(-3600),
                likes: 24,
                comments: 8,
                syncs: 12,
                postType: .cocktail
            ),
            SocialPost(
                author: sampleSocialUsers[1],
                content: "Tonight's special: Detroit Sour with house-made sour mix and a perfect egg white foam. Come taste the difference!",
                image: "Spritzer",
                tags: ["#detroitsour", "#specials", "#craftcocktails"],
                createdAt: Date().addingTimeInterval(-7200),
                likes: 18,
                comments: 5,
                syncs: 7,
                postType: .cocktail
            ),
            SocialPost(
                author: sampleSocialUsers[2],
                content: "Premium Scotch selection tonight! Aged to perfection with notes of oak and smoke.",
                image: "Scotch",
                tags: ["#scotch", "#whiskey", "#premium"],
                createdAt: Date().addingTimeInterval(-10800),
                likes: 32,
                comments: 12,
                syncs: 15,
                postType: .cocktail
            ),
            SocialPost(
                author: sampleSocialUsers[3],
                content: "Classic Martini service - stirred, not shaken. The epitome of cocktail elegance.",
                image: "Dirty Martini",
                tags: ["#martini", "#gin", "#classic"],
                createdAt: Date().addingTimeInterval(-14400),
                likes: 45,
                comments: 18,
                syncs: 22,
                postType: .cocktail
            ),
            SocialPost(
                author: sampleSocialUsers[4],
                content: "Amazing experience at The Nest Bar! The atmosphere and cocktails are unmatched. Highly recommend!",
                image: "Negroni",
                tags: ["#recommendation", "#experience", "#thenestbar"],
                createdAt: Date().addingTimeInterval(-18000),
                likes: 12,
                comments: 3,
                syncs: 4,
                postType: .experience
            ),
            SocialPost(
                author: sampleSocialUsers[5],
                content: "Pro tip: Always taste your cocktail before serving. The customer's first sip sets the entire experience!",
                image: "Scotch",
                tags: ["#protip", "#hospitality", "#service"],
                createdAt: Date().addingTimeInterval(-21600),
                likes: 28,
                comments: 9,
                syncs: 11,
                postType: .tip
            )
        ]
        
        // Sample locations with stories (Detroit area) - Actual venues and bartender locations
        sampleLocations = [
            Location(
                name: "PORT",
                subtitle: "Detroit's Premier Bar",
                address: "456 Woodward Ave, Detroit, MI 48226",
                latitude: 42.3350,
                longitude: -83.0500,
                locationType: .venue,
                stories: [
                    sampleSocialPosts[0],
                    SocialPost(
                        author: sampleSocialUsers[0],
                        content: "Tonight's special: Craft cocktails with a twist!",
                        image: "Negroni",
                        tags: ["#craftcocktails", "#special"],
                        createdAt: Date().addingTimeInterval(-1800),
                        likes: 15,
                        comments: 3,
                        syncs: 5,
                        postType: .cocktail
                    )
                ],
                image: "Negroni",
                sipSyncBartenders: [sampleSocialUsers[0]], // Miranda Lrouge
                phone: "(313) 555-0456",
                website: "portdetroit.com",
                hours: "Tue-Sun: 6 PM - 2 AM, Closed Mondays"
            ),
            Location(
                name: "The Nest Bar",
                subtitle: "Premium Cocktail Lounge",
                address: "123 Main St, Detroit, MI 48201",
                latitude: 42.3500,
                longitude: -83.0600,
                locationType: .venue,
                stories: [
                    sampleSocialPosts[3],
                    SocialPost(
                        author: sampleSocialUsers[3],
                        content: "Join us for live jazz and premium spirits tonight!",
                        image: "Scotch",
                        tags: ["#jazz", "#premium"],
                        createdAt: Date().addingTimeInterval(-3600),
                        likes: 22,
                        comments: 7,
                        syncs: 10,
                        postType: .event
                    )
                ],
                image: "Scotch",
                sipSyncBartenders: [sampleSocialUsers[3]], // Antonio Ruiz
                phone: "(313) 555-0123",
                website: "thenestbar.com",
                hours: "Mon-Thu: 5 PM - 2 AM, Fri-Sat: 4 PM - 3 AM, Sun: 6 PM - 12 AM"
            ),
            Location(
                name: "Nelson Cocktail Lounge",
                subtitle: "Mixology Excellence",
                address: "789 River Rd, Detroit, MI 48207",
                latitude: 42.3600,
                longitude: -83.0700,
                locationType: .venue,
                stories: [sampleSocialPosts[2]],
                image: "Dirty Martini",
                sipSyncBartenders: [sampleSocialUsers[1], sampleSocialUsers[2]], // Chef André & Maddy R
                phone: "(313) 555-0789",
                website: "nelsoncocktail.com",
                hours: "Daily: 5 PM - 2 AM"
            ),
            Location(
                name: "Miranda Lrouge",
                subtitle: "Sip Sync Bartender",
                address: "PORT - 456 Woodward Ave, Detroit, MI 48226",
                latitude: 42.3350,
                longitude: -83.0500,
                locationType: .bartender,
                stories: [sampleSocialPosts[0]],
                image: "Negroni",
                sipSyncBartenders: [sampleSocialUsers[0]],
                phone: "(313) 555-0456",
                website: nil,
                hours: "Tue-Sun: 6 PM - 2 AM"
            ),
            Location(
                name: "Chef André William",
                subtitle: "Sip Sync Bartender",
                address: "Nelson Cocktail Lounge - 789 River Rd, Detroit, MI 48207",
                latitude: 42.3600,
                longitude: -83.0700,
                locationType: .bartender,
                stories: [sampleSocialPosts[1]],
                image: "Spritzer",
                sipSyncBartenders: [sampleSocialUsers[1]],
                phone: "(313) 555-0789",
                website: nil,
                hours: "Daily: 5 PM - 2 AM"
            ),
            Location(
                name: "Maddy R",
                subtitle: "Sip Sync Bartender",
                address: "Nelson Cocktail Lounge - 789 River Rd, Detroit, MI 48207",
                latitude: 42.3600,
                longitude: -83.0700,
                locationType: .bartender,
                stories: [],
                image: "Scotch",
                sipSyncBartenders: [sampleSocialUsers[2]],
                phone: "(313) 555-0789",
                website: nil,
                hours: "Daily: 5 PM - 2 AM"
            )
        ]
        
        // Sample Story Sets (Reviews - no expiration)
        let now = Date()
        self.sampleStorySets = [
            StorySet(
                author: sampleSocialUsers[0],
                stories: [
                    Story(image: "Negroni", reviewText: "Perfect Negroni pour 🍸", rating: 5, textColor: "white", createdAt: now.addingTimeInterval(-3600), author: sampleSocialUsers[0], locationId: nil, expiresAt: nil),
                    Story(image: "Spritzer", reviewText: "New cocktail special tonight!", rating: 4, textColor: "white", createdAt: now.addingTimeInterval(-7200), author: sampleSocialUsers[0], locationId: nil, expiresAt: nil)
                ]
            ),
            StorySet(
                author: sampleSocialUsers[1],
                stories: [
                    Story(image: "Spritzer", reviewText: "Detroit Sour special", rating: 5, textColor: "white", createdAt: now.addingTimeInterval(-1800), author: sampleSocialUsers[1], locationId: nil, expiresAt: nil),
                    Story(image: "Scotch", reviewText: "Premium selection", rating: 5, textColor: "white", createdAt: now.addingTimeInterval(-5400), author: sampleSocialUsers[1], locationId: nil, expiresAt: nil)
                ]
            ),
            StorySet(
                author: sampleSocialUsers[2],
                stories: [
                    Story(image: "Scotch", reviewText: "Aged to perfection", rating: 4, textColor: "white", createdAt: now.addingTimeInterval(-2700), author: sampleSocialUsers[2], locationId: nil, expiresAt: nil)
                ]
            ),
            StorySet(
                author: sampleSocialUsers[3],
                stories: [
                    Story(image: "Dirty Martini", reviewText: "Classic elegance", rating: 5, textColor: "white", createdAt: now.addingTimeInterval(-4500), author: sampleSocialUsers[3], locationId: nil, expiresAt: nil),
                    Story(image: "Negroni", reviewText: "Live jazz tonight!", rating: 4, textColor: "white", createdAt: now.addingTimeInterval(-6300), author: sampleSocialUsers[3], locationId: nil, expiresAt: nil)
                ]
            ),
            StorySet(
                author: sampleSocialUsers[4],
                stories: [
                    Story(image: "Negroni", reviewText: "Amazing experience!", rating: 5, textColor: "white", createdAt: now.addingTimeInterval(-900), author: sampleSocialUsers[4], locationId: nil, expiresAt: nil)
                ]
            ),
            StorySet(
                author: sampleSocialUsers[5],
                stories: [
                    Story(image: "Scotch", reviewText: "Pro tip: Always taste first", rating: 4, textColor: "white", createdAt: now.addingTimeInterval(-3600), author: sampleSocialUsers[5], locationId: nil, expiresAt: nil)
                ]
            )
        ]
        
        // Sample Bartender Profiles (SipSync Originals)
        self.sampleBartenderProfiles = [
            BartenderProfile(
                author: SocialUser(
                    name: "Jane Mayhem",
                    username: "janemayhem",
                    userType: .bartender,
                    verified: true
                ),
                profileImage: "Bartender 1",
                bio: "\"You only live once, but if you do it right, once is enough.\" - Mae West",
                followers: 521,
                following: 345,
                comments: 566,
                contentCategories: ["#bookworm", "#foodie", "#nomad", "#wellness", "#80'smusic"],
                contentGallery: [
                    ContentItem(image: "Spritzer", title: "Greek Salad Recipe"),
                    ContentItem(image: "Negroni", title: "Butterfly Garden"),
                    ContentItem(image: "Scotch", title: "Craft Cocktail")
                ]
            ),
            BartenderProfile(
                author: sampleSocialUsers[0],
                profileImage: "Bartender 2",
                bio: "Master mixologist crafting perfection one cocktail at a time. Join me on this journey.",
                followers: 842,
                following: 201,
                comments: 1203,
                contentCategories: ["#mixology", "#classic", "#premium", "#craft"],
                contentGallery: [
                    ContentItem(image: "Dirty Martini", title: "Classic Martini"),
                    ContentItem(image: "Negroni", title: "Perfect Negroni"),
                    ContentItem(image: "Spritzer", title: "Detroit Special")
                ]
            ),
            BartenderProfile(
                author: sampleSocialUsers[1],
                profileImage: "Bartender 3",
                bio: "Detroit's finest craft cocktails. Every pour tells a story, every sip is an experience.",
                followers: 673,
                following: 289,
                comments: 892,
                contentCategories: ["#detroit", "#craftcocktails", "#specials", "#hospitality"],
                contentGallery: [
                    ContentItem(image: "Scotch", title: "Premium Selection"),
                    ContentItem(image: "Spritzer", title: "House Special"),
                    ContentItem(image: "Negroni", title: "Detroit Sour")
                ]
            )
        ]
        
        // Sample Bartender Classes (Locked Classes)
        let calendar = Calendar.current
        let classDateNow = Date()
        self.sampleBartenderClasses = [
            BartenderClass(
                title: "Sunrise Yoga Mixology",
                bartender: sampleSocialUsers[0],
                date: calendar.date(byAdding: .day, value: 5, to: classDateNow) ?? classDateNow,
                time: "6:00 AM",
                location: "South Lake Tahoe, CA",
                image: "Spritzer",
                isLocked: true,
                isGoing: false,
                attendees: [sampleSocialUsers[4], sampleSocialUsers[5]],
                description: "Start your day with mindful movements and craft cocktails",
                price: 85.00
            ),
            BartenderClass(
                title: "Advanced Cocktail Techniques",
                bartender: sampleSocialUsers[1],
                date: calendar.date(byAdding: .day, value: 7, to: classDateNow) ?? classDateNow,
                time: "7:00 PM",
                location: "Detroit, MI",
                image: "Negroni",
                isLocked: true,
                isGoing: true,
                attendees: [sampleSocialUsers[2], sampleSocialUsers[4]],
                description: "Master the art of advanced mixology techniques",
                price: 120.00
            ),
            BartenderClass(
                title: "Whiskey Tasting Masterclass",
                bartender: sampleSocialUsers[2],
                date: calendar.date(byAdding: .day, value: 10, to: classDateNow) ?? classDateNow,
                time: "8:00 PM",
                location: "Nelson Cocktail Lounge",
                image: "Scotch",
                isLocked: true,
                isGoing: false,
                attendees: [sampleSocialUsers[0], sampleSocialUsers[3]],
                description: "Deep dive into premium whiskey selection and tasting",
                price: 150.00
            ),
            BartenderClass(
                title: "Classic Martini Workshop",
                bartender: sampleSocialUsers[0],
                date: calendar.date(byAdding: .day, value: 12, to: classDateNow) ?? classDateNow,
                time: "6:30 PM",
                location: "PORT",
                image: "Dirty Martini",
                isLocked: true,
                isGoing: true,
                attendees: [sampleSocialUsers[1], sampleSocialUsers[5]],
                description: "Learn the secrets of the perfect classic martini",
                price: 95.00
            ),
            BartenderClass(
                title: "Detroit Sour Special",
                bartender: sampleSocialUsers[1],
                date: calendar.date(byAdding: .day, value: 14, to: classDateNow) ?? classDateNow,
                time: "5:00 PM",
                location: "Detroit, MI",
                image: "Spritzer",
                isLocked: true,
                isGoing: false,
                attendees: [sampleSocialUsers[2]],
                description: "Exclusive Detroit Sour recipe and technique",
                price: 75.00
            ),
            BartenderClass(
                title: "Negroni Perfection Class",
                bartender: sampleSocialUsers[0],
                date: calendar.date(byAdding: .day, value: 16, to: classDateNow) ?? classDateNow,
                time: "7:30 PM",
                location: "PORT",
                image: "Negroni",
                isLocked: true,
                isGoing: false,
                attendees: [sampleSocialUsers[3], sampleSocialUsers[4], sampleSocialUsers[5]],
                description: "Perfect your Negroni technique with expert guidance",
                price: 110.00
            )
        ]
    }
}
