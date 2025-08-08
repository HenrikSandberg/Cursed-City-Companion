import SwiftUI

struct HeroDetailView: View {
    @Binding var hero: Hero

    var body: some View {
        ZStack {
            Color.darkstone.edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading, spacing: 15) {
                    HStack(alignment: .top) {
                        Image(hero.imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.cursedGold, lineWidth: 2))
                        
                        VStack(alignment: .leading) {
                            Text(hero.name)
                                .font(.largeTitle)
                                .foregroundColor(.parchment)
                            Text("Level: \(hero.level)")
                                .font(.title2)
                                .foregroundColor(.cursedGold)
                            Text("Experience: \(experienceStatus)")
                                .font(.headline)
                                .foregroundColor(.yellow)
                        }
                    }
                    
                    Text(hero.description)
                        .foregroundColor(.parchment)
                        .italic()

                    // Items
                    Text("Items")
                        .font(.title2)
                        .foregroundColor(.cursedGold)
                    if hero.items.isEmpty {
                        Text("No items.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(hero.items) { item in
                            Text("- \(item.name)")
                                .foregroundColor(.parchment)
                        }
                    }

                    // Treasure Cards
                    Text("Treasure Cards")
                        .font(.title2)
                        .foregroundColor(.cursedGold)
                    if hero.treasureCards.isEmpty {
                        Text("No treasure cards.")
                            .foregroundColor(.gray)
                    } else {
                        ForEach(hero.treasureCards, id: \.self) { card in
                            Text("- \(card)")
                                .foregroundColor(.parchment)
                        }
                    }
                    
                    Toggle(isOn: $hero.isAlive) {
                        Text("Is Alive")
                            .foregroundColor(.parchment)
                    }
                    .tint(.cursedGold)

                }
                .padding()
            }
        }
        .navigationTitle(hero.name)
    }
    
    private var experienceStatus: String {
        switch hero.experience {
        case 1: return "Novice"
        default: return "None"
        }
    }
}

#if DEBUG
struct HeroDetailView_Previews: PreviewProvider {
    // This preview requires a wrapper to provide a @Binding
    struct PreviewWrapper: View {
        @State var hero: Hero
        
        init() {
            var mockHero = Hero.defaultHeroes[0]
            mockHero.level = 2
            mockHero.experience = 1
            mockHero.items = [Item(name: "Gheistsever", description: "A blade that thirsts for the ethereal."), Item(name: "Realmstone Locket", description: "Hums with a faint power.")]
            mockHero.treasureCards = ["Potion of Hysh"]
            _hero = State(initialValue: mockHero)
        }
        
        var body: some View {
            HeroDetailView(hero: $hero)
        }
    }
    
    static var previews: some View {
        NavigationView {
            PreviewWrapper()
        }
        .preferredColorScheme(.dark)
    }
}
#endif
