import Foundation

class BeerDatabase {
    static let shared = BeerDatabase()

    let beers: [Beer] = [
        Beer(
            id: UUID(),
            name: "Heineken Lager",
            brand: "Heineken",
            manufacturer: "Heineken N.V.",
            country: "Netherlands",
            style: "Pale Lager",
            abv: 5.0,
            ibu: 23,
            volume: "330ml",
            calories: 142,
            ingredients: ["Water", "Barley Malt", "Hop Extract", "Heineken A-Yeast"],
            description: "A pale lager beer with 5% alcohol by volume. Heineken is brewed with purified water, malted barley, hops, and Heineken's unique A-yeast. First brewed in 1873 by Gerard Adriaan Heineken in Amsterdam.",
            flavorProfile: FlavorProfile(sweetness: 2, bitterness: 3, body: 2, hoppy: 2, malty: 2),
            servingTemperature: "3-5°C",
            pairings: ["Grilled chicken", "Fish tacos", "Light salads", "Mild cheese"]
        ),
        Beer(
            id: UUID(),
            name: "Guinness Draught",
            brand: "Guinness",
            manufacturer: "Diageo (Arthur Guinness Son & Co.)",
            country: "Ireland",
            style: "Irish Dry Stout",
            abv: 4.2,
            ibu: 45,
            volume: "440ml",
            calories: 125,
            ingredients: ["Water", "Barley", "Roast Malt Extract", "Hops", "Brewer's Yeast", "Nitrogen"],
            description: "A dark Irish dry stout that originated in the brewery of Arthur Guinness at St. James's Gate, Dublin, Ireland, in 1759. It's known for its distinctive dark color and creamy head created by nitrogen carbonation.",
            flavorProfile: FlavorProfile(sweetness: 2, bitterness: 4, body: 4, hoppy: 2, malty: 4),
            servingTemperature: "6-8°C",
            pairings: ["Oysters", "Beef stew", "Chocolate desserts", "Aged cheddar"]
        ),
        Beer(
            id: UUID(),
            name: "Corona Extra",
            brand: "Corona",
            manufacturer: "Grupo Modelo (AB InBev)",
            country: "Mexico",
            style: "Pale Lager",
            abv: 4.5,
            ibu: 18,
            volume: "355ml",
            calories: 148,
            ingredients: ["Water", "Barley Malt", "Non-malted Cereals", "Hops"],
            description: "A pale lager produced by Cervecería Modelo in Mexico. Corona Extra was first brewed in 1925 and is one of the top-selling beers worldwide. Traditionally served with a lime wedge.",
            flavorProfile: FlavorProfile(sweetness: 2, bitterness: 1, body: 1, hoppy: 1, malty: 2),
            servingTemperature: "1-3°C",
            pairings: ["Ceviche", "Tacos", "Grilled shrimp", "Lime-based dishes"]
        ),
        Beer(
            id: UUID(),
            name: "Budweiser",
            brand: "Budweiser",
            manufacturer: "Anheuser-Busch InBev",
            country: "United States",
            style: "American Lager",
            abv: 5.0,
            ibu: 12,
            volume: "355ml",
            calories: 145,
            ingredients: ["Water", "Barley Malt", "Rice", "Hops", "Yeast"],
            description: "An American-style pale lager introduced in 1876 by Carl Conrad & Co. It is brewed with up to 30% rice in addition to hops and barley malt. Known as 'The King of Beers'.",
            flavorProfile: FlavorProfile(sweetness: 2, bitterness: 1, body: 2, hoppy: 1, malty: 2),
            servingTemperature: "2-4°C",
            pairings: ["Burgers", "BBQ ribs", "Pizza", "Fried chicken"]
        ),
        Beer(
            id: UUID(),
            name: "Stella Artois",
            brand: "Stella Artois",
            manufacturer: "AB InBev",
            country: "Belgium",
            style: "Belgian Pilsner",
            abv: 5.2,
            ibu: 30,
            volume: "330ml",
            calories: 154,
            ingredients: ["Water", "Barley Malt", "Maize", "Hops", "Yeast"],
            description: "A Belgian pilsner of between 4.8% and 5.2% ABV. First brewed in Leuven, Belgium, in 1926 as a Christmas brew (Stella means 'star' in Latin). Now one of the world's best-selling beers.",
            flavorProfile: FlavorProfile(sweetness: 2, bitterness: 3, body: 2, hoppy: 2, malty: 3),
            servingTemperature: "3-5°C",
            pairings: ["Mussels", "Grilled fish", "Salads", "Light pasta"]
        ),
        Beer(
            id: UUID(),
            name: "Carlsberg Pilsner",
            brand: "Carlsberg",
            manufacturer: "Carlsberg Group",
            country: "Denmark",
            style: "Pilsner",
            abv: 5.0,
            ibu: 25,
            volume: "330ml",
            calories: 140,
            ingredients: ["Water", "Barley Malt", "Hops", "Yeast"],
            description: "A pale pilsner-style lager founded in 1847 by J.C. Jacobsen in Copenhagen. Known for its slogan 'Probably the best beer in the world'. Brewed using the original Carlsberg yeast strain.",
            flavorProfile: FlavorProfile(sweetness: 2, bitterness: 3, body: 2, hoppy: 3, malty: 2),
            servingTemperature: "4-6°C",
            pairings: ["Smoked salmon", "Roast pork", "Danish pastries", "Soft cheese"]
        ),
        Beer(
            id: UUID(),
            name: "IPA Punk",
            brand: "BrewDog",
            manufacturer: "BrewDog plc",
            country: "Scotland",
            style: "India Pale Ale (IPA)",
            abv: 5.4,
            ibu: 35,
            volume: "330ml",
            calories: 159,
            ingredients: ["Water", "Extra Pale Malt", "Caramalt", "Centennial Hops", "Chinook Hops", "Simcoe Hops", "Ahtanum Hops", "Yeast"],
            description: "A post-modern classic IPA. This light golden classic has been subverted with new world hops to create an explosion of tropical fruit and an all-out riot of grapefruit, pineapple, and lychee.",
            flavorProfile: FlavorProfile(sweetness: 2, bitterness: 4, body: 3, hoppy: 5, malty: 2),
            servingTemperature: "5-8°C",
            pairings: ["Spicy curry", "Blue cheese", "Grilled steak", "Citrus desserts"]
        ),
        Beer(
            id: UUID(),
            name: "Weihenstephaner Hefeweissbier",
            brand: "Weihenstephan",
            manufacturer: "Bayerische Staatsbrauerei Weihenstephan",
            country: "Germany",
            style: "Hefeweizen",
            abv: 5.4,
            ibu: 14,
            volume: "500ml",
            calories: 215,
            ingredients: ["Water", "Wheat Malt", "Barley Malt", "Hops", "Yeast"],
            description: "A golden, refreshing wheat beer from the world's oldest brewery (founded 1040 AD). Fruity and spicy with notes of banana and clove from the traditional Bavarian wheat beer yeast.",
            flavorProfile: FlavorProfile(sweetness: 3, bitterness: 1, body: 3, hoppy: 1, malty: 3),
            servingTemperature: "6-8°C",
            pairings: ["Weisswurst", "Pretzels", "Salads", "Seafood"]
        ),
        Beer(
            id: UUID(),
            name: "Pilsner Urquell",
            brand: "Pilsner Urquell",
            manufacturer: "Plzensky Prazdroj (Asahi Group)",
            country: "Czech Republic",
            style: "Czech Pilsner",
            abv: 4.4,
            ibu: 40,
            volume: "330ml",
            calories: 135,
            ingredients: ["Water", "Barley Malt", "Saaz Hops", "Yeast"],
            description: "The world's first pale lager, first brewed in 1842 in Pilsen. Using Saaz hops, Moravian barley, and the city's remarkably soft water, it created a new category of beer that inspired countless imitators.",
            flavorProfile: FlavorProfile(sweetness: 2, bitterness: 4, body: 3, hoppy: 4, malty: 3),
            servingTemperature: "4-7°C",
            pairings: ["Roast duck", "Svickova", "Grilled sausage", "Sharp cheese"]
        ),
        Beer(
            id: UUID(),
            name: "Sapporo Premium Beer",
            brand: "Sapporo",
            manufacturer: "Sapporo Breweries Ltd.",
            country: "Japan",
            style: "Japanese Rice Lager",
            abv: 4.9,
            ibu: 18,
            volume: "350ml",
            calories: 140,
            ingredients: ["Water", "Malt", "Corn Starch", "Rice", "Hops"],
            description: "Japan's oldest beer brand, first brewed in 1876. Sapporo Premium Beer features a crisp, clean, refreshing taste with a refined bitterness. Known for its iconic silver star can.",
            flavorProfile: FlavorProfile(sweetness: 2, bitterness: 2, body: 2, hoppy: 2, malty: 2),
            servingTemperature: "3-5°C",
            pairings: ["Sushi", "Ramen", "Tempura", "Yakitori"]
        ),
        Beer(
            id: UUID(),
            name: "Chimay Blue (Grande Réserve)",
            brand: "Chimay",
            manufacturer: "Bières de Chimay (Scourmont Abbey)",
            country: "Belgium",
            style: "Belgian Strong Dark Ale",
            abv: 9.0,
            ibu: 35,
            volume: "330ml",
            calories: 270,
            ingredients: ["Water", "Barley Malt", "Wheat Starch", "Sugar", "Hops", "Trappist Yeast"],
            description: "An authentic Trappist beer brewed within the walls of Scourmont Abbey. Chimay Blue is a dark, strong ale with complex flavors of dark fruit, caramel, and spice. It ages beautifully.",
            flavorProfile: FlavorProfile(sweetness: 4, bitterness: 3, body: 5, hoppy: 2, malty: 5),
            servingTemperature: "10-12°C",
            pairings: ["Game meats", "Strong cheese", "Chocolate", "Rich stews"]
        ),
        Beer(
            id: UUID(),
            name: "Peroni Nastro Azzurro",
            brand: "Peroni",
            manufacturer: "Birra Peroni (Asahi Group)",
            country: "Italy",
            style: "Italian Pilsner",
            abv: 5.1,
            ibu: 24,
            volume: "330ml",
            calories: 150,
            ingredients: ["Water", "Barley Malt", "Maize Grits", "Hops"],
            description: "An Italian lager first brewed in 1963. 'Nastro Azzurro' (Blue Ribbon) is brewed with a distinctive Italian style using soft-toasted Italian maize alongside barley malt for a crisp, refreshing taste.",
            flavorProfile: FlavorProfile(sweetness: 2, bitterness: 2, body: 2, hoppy: 2, malty: 2),
            servingTemperature: "3-5°C",
            pairings: ["Margherita pizza", "Antipasti", "Grilled seafood", "Bruschetta"]
        ),
        Beer(
            id: UUID(),
            name: "Duvel",
            brand: "Duvel",
            manufacturer: "Duvel Moortgat Brewery",
            country: "Belgium",
            style: "Belgian Strong Golden Ale",
            abv: 8.5,
            ibu: 32,
            volume: "330ml",
            calories: 255,
            ingredients: ["Water", "Barley Malt", "Sugar", "Saaz Hops", "Styrian Goldings Hops", "Yeast"],
            description: "A natural, golden Belgian ale with a subtle bitterness, refined palate, and a pleasant dry aftertaste. 'Duvel' means 'Devil' in Flemish dialect. It undergoes a 90-day brewing process.",
            flavorProfile: FlavorProfile(sweetness: 3, bitterness: 3, body: 3, hoppy: 3, malty: 3),
            servingTemperature: "4-8°C",
            pairings: ["Mussels", "Spicy Thai food", "Strong cheese", "Fruit tarts"]
        ),
        Beer(
            id: UUID(),
            name: "Asahi Super Dry",
            brand: "Asahi",
            manufacturer: "Asahi Breweries Ltd.",
            country: "Japan",
            style: "Japanese Dry Lager",
            abv: 5.0,
            ibu: 16,
            volume: "350ml",
            calories: 140,
            ingredients: ["Water", "Malt", "Rice", "Corn Starch", "Hops", "Yeast"],
            description: "Launched in 1987, Asahi Super Dry pioneered the 'karakuchi' (dry) beer style. Brewed with Asahi's proprietary yeast strain #318 for a clean, crisp, quick finish with minimal aftertaste.",
            flavorProfile: FlavorProfile(sweetness: 1, bitterness: 2, body: 2, hoppy: 1, malty: 1),
            servingTemperature: "2-4°C",
            pairings: ["Sashimi", "Edamame", "Grilled fish", "Gyoza"]
        ),
        Beer(
            id: UUID(),
            name: "Leffe Blonde",
            brand: "Leffe",
            manufacturer: "Abbaye de Leffe (AB InBev)",
            country: "Belgium",
            style: "Belgian Blonde Ale",
            abv: 6.6,
            ibu: 25,
            volume: "330ml",
            calories: 198,
            ingredients: ["Water", "Barley Malt", "Corn", "Sugar", "Hops", "Yeast"],
            description: "A Belgian abbey beer with origins dating to 1240. Leffe Blonde is a smooth, full-bodied blonde ale with notes of vanilla, clove, and banana. It's brewed following a tradition maintained for centuries.",
            flavorProfile: FlavorProfile(sweetness: 3, bitterness: 2, body: 3, hoppy: 1, malty: 3),
            servingTemperature: "5-8°C",
            pairings: ["Roast chicken", "Brie cheese", "Crème brûlée", "White fish"]
        ),
        Beer(
            id: UUID(),
            name: "Sierra Nevada Pale Ale",
            brand: "Sierra Nevada",
            manufacturer: "Sierra Nevada Brewing Co.",
            country: "United States",
            style: "American Pale Ale",
            abv: 5.6,
            ibu: 38,
            volume: "355ml",
            calories: 175,
            ingredients: ["Water", "Two-Row Pale Malt", "Caramel Malt", "Cascade Hops", "Perle Hops", "Yeast"],
            description: "The craft beer that started a revolution. First brewed in 1980, Sierra Nevada Pale Ale uses whole-cone Cascade hops for a distinctive pine and citrus aroma that defined American craft brewing.",
            flavorProfile: FlavorProfile(sweetness: 2, bitterness: 4, body: 3, hoppy: 4, malty: 3),
            servingTemperature: "6-8°C",
            pairings: ["Burgers", "Grilled chicken", "Sharp cheddar", "Nachos"]
        ),
        Beer(
            id: UUID(),
            name: "Hoegaarden White",
            brand: "Hoegaarden",
            manufacturer: "Brouwerij van Hoegaarden (AB InBev)",
            country: "Belgium",
            style: "Witbier",
            abv: 4.9,
            ibu: 14,
            volume: "330ml",
            calories: 149,
            ingredients: ["Water", "Barley Malt", "Wheat", "Oats", "Coriander", "Orange Peel", "Hops", "Yeast"],
            description: "A Belgian-style wheat beer revived by Pierre Celis in 1966. Brewed with coriander and orange peel following a centuries-old recipe from the town of Hoegaarden. Cloudy, refreshing, and citrusy.",
            flavorProfile: FlavorProfile(sweetness: 3, bitterness: 1, body: 2, hoppy: 1, malty: 2),
            servingTemperature: "3-5°C",
            pairings: ["Salads", "Seafood", "Light cheeses", "Fruit desserts"]
        ),
        Beer(
            id: UUID(),
            name: "Erdinger Weissbier",
            brand: "Erdinger",
            manufacturer: "Erdinger Weissbräu",
            country: "Germany",
            style: "Hefeweizen",
            abv: 5.3,
            ibu: 12,
            volume: "500ml",
            calories: 210,
            ingredients: ["Water", "Wheat Malt", "Barley Malt", "Hops", "Yeast"],
            description: "A classic Bavarian wheat beer from the Erdinger brewery in Erding, Bavaria. Fine-pored white foam and a fresh, sparkling character with distinctive banana and clove flavors from top-fermentation.",
            flavorProfile: FlavorProfile(sweetness: 3, bitterness: 1, body: 3, hoppy: 1, malty: 3),
            servingTemperature: "6-8°C",
            pairings: ["Weisswurst", "Obatzda", "Pretzels", "Grilled chicken"]
        ),
        Beer(
            id: UUID(),
            name: "Tiger Beer",
            brand: "Tiger",
            manufacturer: "Asia Pacific Breweries (Heineken)",
            country: "Singapore",
            style: "Pale Lager",
            abv: 5.0,
            ibu: 23,
            volume: "330ml",
            calories: 150,
            ingredients: ["Water", "Malted Barley", "Hops", "Yeast"],
            description: "First brewed in 1932 in Singapore. Tiger Beer is a tropical lager brewed for the heat. Winner of multiple international awards, it's known for its balanced taste with a clean, refreshing finish.",
            flavorProfile: FlavorProfile(sweetness: 2, bitterness: 2, body: 2, hoppy: 2, malty: 2),
            servingTemperature: "2-4°C",
            pairings: ["Satay", "Chili crab", "Stir-fry", "Dim sum"]
        ),
        Beer(
            id: UUID(),
            name: "Paulaner Salvator",
            brand: "Paulaner",
            manufacturer: "Paulaner Brauerei Gruppe",
            country: "Germany",
            style: "Doppelbock",
            abv: 7.9,
            ibu: 28,
            volume: "330ml",
            calories: 236,
            ingredients: ["Water", "Barley Malt", "Hops", "Yeast"],
            description: "The original Doppelbock, first brewed by Paulaner monks in the 17th century as 'liquid bread' for Lenten fasting. Dark amber with complex malty sweetness, notes of toffee, dark fruit, and bread crust.",
            flavorProfile: FlavorProfile(sweetness: 4, bitterness: 2, body: 5, hoppy: 1, malty: 5),
            servingTemperature: "8-10°C",
            pairings: ["Roast pork", "Smoked meats", "Pretzels", "Strong cheese"]
        ),
    ]

    func searchBeers(query: String) -> [Beer] {
        let lowered = query.lowercased()
        return beers.filter { beer in
            beer.name.lowercased().contains(lowered) ||
            beer.brand.lowercased().contains(lowered) ||
            beer.manufacturer.lowercased().contains(lowered) ||
            beer.style.lowercased().contains(lowered) ||
            beer.country.lowercased().contains(lowered)
        }
    }

    func findBeer(fromTexts texts: [String]) -> (beer: Beer, confidence: Double)? {
        var bestMatch: Beer?
        var bestScore: Double = 0

        let combinedText = texts.joined(separator: " ").lowercased()

        for beer in beers {
            var score: Double = 0

            // Check brand name match (highest weight)
            if combinedText.contains(beer.brand.lowercased()) {
                score += 50
            }

            // Check beer name match
            let nameWords = beer.name.lowercased().split(separator: " ")
            for word in nameWords {
                if combinedText.contains(word) {
                    score += 20
                }
            }

            // Check manufacturer match
            let mfrWords = beer.manufacturer.lowercased().split(separator: " ")
            for word in mfrWords where word.count > 3 {
                if combinedText.contains(word) {
                    score += 15
                }
            }

            // Check style match
            if combinedText.contains(beer.style.lowercased()) {
                score += 10
            }

            // Check country match
            if combinedText.contains(beer.country.lowercased()) {
                score += 5
            }

            // Check ABV match
            let abvString = String(format: "%.1f", beer.abv)
            if combinedText.contains(abvString) {
                score += 15
            }

            if score > bestScore {
                bestScore = score
                bestMatch = beer
            }
        }

        guard let match = bestMatch, bestScore >= 30 else {
            return nil
        }

        let confidence = min(bestScore / 100.0, 1.0)
        return (match, confidence)
    }
}
