//
//  DrinkDetailView.swift
//  SIP SYNC
//

import SwiftUI

struct DrinkDetailView: View {
    let drink: Drink
    @Binding var cartItems: [OrderItem]
    @Binding var favoriteDrinks: [Drink]
    @Environment(\.dismiss) private var dismiss

    private var isFavorite: Bool {
        favoriteDrinks.contains(where: { $0.name == drink.name })
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerImage

                    VStack(alignment: .leading, spacing: 10) {
                        Text(drink.name)
                            .font(.largeTitle.weight(.bold))
                            .foregroundStyle(.white)

                        Text(drink.category.rawValue)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.yellow)

                        Text(drink.bio)
                            .font(.body)
                            .foregroundStyle(.gray)
                    }

                    detailSection(title: "Ingredients", items: drink.ingredients)
                    detailSection(title: "Steps", items: drink.steps.enumerated().map { "\($0.offset + 1). \($0.element)" })

                    Text("$\(String(format: "%.2f", drink.price))")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                }
                .padding(20)
                .padding(.bottom, 100)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.white)
                }
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    toggleFavorite()
                } label: {
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .foregroundStyle(isFavorite ? .red : .white)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button {
                cartItems.append(OrderItem(drink: drink, quantity: 1, price: drink.price))
                dismiss()
            } label: {
                Text("Add to Cart")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(
                        LinearGradient(
                            colors: [Color.yellow, Color.orange],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .padding(.horizontal, 20)
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                    .background(Color.black.opacity(0.85))
            }
            .buttonStyle(.plain)
        }
    }

    @ViewBuilder
    private var headerImage: some View {
        if UIImage(named: drink.image) != nil {
            Image(drink.image)
                .resizable()
                .scaledToFill()
                .frame(height: 240)
                .frame(maxWidth: .infinity)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        } else {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.gray.opacity(0.25))
                .frame(height: 240)
                .overlay(
                    Image(systemName: iconForCategory(drink.category))
                        .font(.system(size: 44))
                        .foregroundStyle(.white.opacity(0.85))
                )
        }
    }

    private func detailSection(title: String, items: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.white)

            ForEach(items, id: \.self) { item in
                Text("• \(item)")
                    .font(.subheadline)
                    .foregroundStyle(.gray)
            }
        }
    }

    private func iconForCategory(_ category: DrinkCategory) -> String {
        switch category {
        case .drinks: return "wineglass.fill"
        case .food: return "fork.knife"
        case .social: return "person.2"
        }
    }

    private func toggleFavorite() {
        if let index = favoriteDrinks.firstIndex(where: { $0.name == drink.name }) {
            favoriteDrinks.remove(at: index)
        } else {
            favoriteDrinks.append(drink)
        }
    }
}

#Preview {
    NavigationStack {
        DrinkDetailView(
            drink: SampleData.shared.sampleDrinks.first!,
            cartItems: .constant([]),
            favoriteDrinks: .constant([])
        )
    }
}
