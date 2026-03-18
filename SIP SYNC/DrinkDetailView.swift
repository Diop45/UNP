//
//  DrinkDetailView.swift
//  SIP SYNC
//
//  Created by Diop Shumake on 10/23/25.
//

import SwiftUI

struct DrinkDetailView: View {
    let drink: Drink
    @Binding var cartItems: [OrderItem]
    @Binding var favoriteDrinks: [Drink]
    @Environment(\.presentationMode) var presentationMode
    @State private var isFavorite = false
    @State private var searchText = ""
    @State private var selectedUserType: UserType? = nil
    
    private func getImageName(for drinkName: String) -> String? {
        switch drinkName {
        case "Negroni":
            return "Negroni"
        case "Scotch & Bourbon":
            return "Scotch"
        case "Spritzer":
            return "Spritzer"
        case "Martini":
            return "Dirty Martini"
        case "Red Wine":
            return "Red Wine"
        case "White Wine":
            return "White Wine"
        default:
            return nil
        }
    }
    
    private func getSystemIcon(for category: DrinkCategory) -> String {
        switch category {
        case .drinks:
            return "wineglass"
        case .food:
            return "fork.knife"
        case .social:
            return "person.2"
        }
    }
    
    var body: some View {
        ZStack {
            // Dark purple background
            Color(red: 0.1, green: 0.05, blue: 0.2)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    SSHeader(
                        logoText: "S",
                        location: drink.name,
                        onProfile: { presentationMode.wrappedValue.dismiss() }
                    )
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    
                    // Consistent global search + category chips
                    SearchPillField(text: $searchText)
                        .padding(.horizontal, 20)
                    UserTypeFilter(selectedType: $selectedUserType, types: UserType.allCases)
                        .padding(.bottom, 8)
                    
                    // Drink image
                    Group {
                        if let imageName = getImageName(for: drink.name) {
                            Image(imageName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } else {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.3))
                                .overlay(
                                    Image(systemName: getSystemIcon(for: drink.category))
                                        .font(.system(size: 60))
                                        .foregroundColor(.white)
                                )
                        }
                    }
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(16)
                        .padding(.horizontal, 20)
                    
                    // Drink name
                    Text(drink.name)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                    
                    // Action buttons
                    HStack(spacing: 16) {
                        Button(action: {}) {
                            Text("Sip")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.black)
                                .cornerRadius(20)
                        }
                        
                        Button(action: {}) {
                            Text("Sync")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(Color.clear)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.yellow, lineWidth: 2)
                                )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // About section
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "About")
                        
                        Text(getAboutText(for: drink))
                            .font(.body)
                            .foregroundColor(.gray)
                            .lineSpacing(4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    // Potential pairings section
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Potential Pairings")
                        
                        VStack(spacing: 8) {
                            ForEach(getPairings(for: drink), id: \.self) { pairing in
                                HStack {
                                    Text(pairing)
                                        .font(.body)
                                        .foregroundColor(.gray)
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                                
                                if pairing != getPairings(for: drink).last {
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
            }
            
            // Add to Cart button (fixed at bottom)
            VStack {
                Spacer()
                Button(action: {
                    let orderItem = OrderItem(drink: drink, quantity: 1, price: drink.price)
                    cartItems.append(orderItem)
                }) {
                    HStack {
                        Text("Add to Cart")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                        Spacer()
                        Text("$\(drink.price, specifier: "%.0f")")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal, 20)
                    .frame(height: 56)
                    .background(Color.yellow)
                    .cornerRadius(28)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
            }
        }
        .onAppear {
            isFavorite = favoriteDrinks.contains { $0.name == drink.name }
        }
    }
    
    private func getAboutText(for drink: Drink) -> String {
        switch drink.name {
        // Drinks Category
        case "Spritzer":
            return "A light, refreshing alcoholic beverage that combines wine with sparkling water or soda. Typical Ratio: 3 parts wine, 1 part sparkling water or soda. How It's Served: Over ice with citrus garnish."
        case "Negroni":
            return "A bold, complex classic cocktail that balances bitter, sweet, and herbal flavors. How It's Served: Stirred, not shaken, over a large ice cube (or served up)."
        case "Scotch & Bourbon":
            return "Premium whisky selections aged in oak barrels. Flavor Profile: Peaty & smoky (in Islay styles), Nutty, honeyed, and malty (in Speyside and Highlands), Notes of oak, heather, dried fruit, spice, brine, and citrus."
        case "Martini":
            return "The epitome of cocktail elegance—crisp, bold, and unapologetically minimal. Traditionally crafted with gin and dry vermouth, served over ice or up with a lemon twist or olive."
        
        // Food Category
        case "Truffle Pasta":
            return "Handcrafted pasta with black truffle shavings and parmesan cream sauce. Preparation: Fresh pasta cooked al dente, finished with truffle cream sauce and shaved parmesan. Served immediately for optimal flavor."
        case "Wagyu Steak":
            return "A5 Wagyu beef with truffle butter and seasonal vegetables. Cooking Method: Seared to perfection, rested, and sliced. Served with truffle butter and seasonal accompaniments."
        case "Lobster Risotto":
            return "Creamy arborio rice with fresh lobster and saffron. Cooking Process: Rice toasted, stock added gradually, finished with fresh lobster and saffron for authentic flavor."
        
        // Social Category
        case "Wine Tasting":
            return "Curated wine tasting experience with expert sommelier guidance. Duration: 2 hours. Includes: 6 premium wines, expert guidance, tasting notes, light appetizers."
        case "Mixology Class":
            return "Learn cocktail crafting techniques from professional mixologists. Duration: 3 hours. Includes: Premium spirits, professional instruction, take-home recipes, hands-on practice."
        case "Whiskey Masterclass":
            return "Deep dive into whiskey production, aging, and tasting techniques. Duration: 4 hours. Includes: Premium whiskeys, expert knowledge, tasting guide, educational materials."
        
        default:
            return drink.bio
        }
    }
    
    private func getPairings(for drink: Drink) -> [String] {
        switch drink.name {
        // Drinks Category
        case "Spritzer":
            return ["Tapas (marinated olives, crostini)", "Pasta primavera", "Berries and whipped cream", "Smoked salmon"]
        case "Negroni":
            return ["Grilled steak", "Duck or pork belly", "Mushroom risotto", "Spaghetti puttanesca"]
        case "Scotch & Bourbon":
            return ["Single Malt", "Blended Scotch", "Single Grain", "Islay"]
        case "Martini":
            return ["Sushi or sashimi", "Grilled white fish with lemon", "Roasted chicken with herbs", "Caviar with crème fraîche"]
        
        // Food Category
        case "Truffle Pasta":
            return ["Chianti Classico", "Barolo", "Pinot Noir", "Champagne"]
        case "Wagyu Steak":
            return ["Cabernet Sauvignon", "Malbec", "Bordeaux", "Scotch Whiskey"]
        case "Lobster Risotto":
            return ["Chardonnay", "Pinot Grigio", "Sauvignon Blanc", "Prosecco"]
        
        // Social Category
        case "Wine Tasting":
            return ["Cheese Pairings", "Charcuterie Board", "Artisanal Breads", "Chocolate Desserts"]
        case "Mixology Class":
            return ["Premium Spirits", "Fresh Ingredients", "Professional Tools", "Take-home Recipes"]
        case "Whiskey Masterclass":
            return ["Premium Whiskeys", "Tasting Notes", "Educational Materials", "Expert Guidance"]
        
        default:
            return ["Classic pairing", "Premium selection", "Artisanal choice"]
        }
    }
}


#Preview {
    DrinkDetailView(drink: SampleData.shared.sampleDrinks[0], cartItems: .constant([]), favoriteDrinks: .constant([]))
}
