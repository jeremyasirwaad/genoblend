defmodule Genoblend.Const do
  @moduledoc false

  def get_default_genes() do
    Enum.take(get_gene_pool(), 10)
  end

  def get_gene_pool() do
    [
      %{
        name: "Bubbles McGillicuddy",
        traits: ["Angry", "Honest"],
        description:
          "Quick to anger when seeing injustice, brutally honest and always speaks the truth.",
        color: "#d04c56"
      },
      %{
        name: "Zigzag Thunderbolt",
        traits: ["Brave", "Curious", "Optimistic"],
        description:
          "Fearless in the face of danger, always asking questions and seeing the bright side of life.",
        color: "#d693b2"
      },
      %{
        name: "Pickles Whimsington",
        traits: ["Lazy", "Creative", "Stubborn"],
        description: "Prefers the easy route, thinks outside the box, and refuses to back down.",
        color: "#485993"
      },
      %{
        name: "Noodle Sparklebottom",
        traits: ["Energetic", "Impatient", "Generous"],
        description:
          "Full of boundless energy, wants things done quickly, and loves giving to others.",
        color: "#488e2b"
      },
      %{
        name: "Whiskers Bumblebee",
        traits: ["Kind", "Patient", "Cautious"],
        description:
          "Gentle and caring, willing to wait, and thinks things through before acting.",
        color: "#7f3484"
      },
      %{
        name: "Snuggles Moonbeam",
        traits: ["Logical", "Pessimistic", "Selfish"],
        description:
          "Analytical with facts over emotions, expects the worst, looks out for themselves first.",
        color: "#f6589f"
      },
      %{
        name: "Giggles Pepperoni",
        traits: ["Emotional", "Adventurous", "Brave"],
        description:
          "Wears heart on sleeve, seeks new experiences and thrills, fearless in danger.",
        color: "#00cba1"
      },
      %{
        name: "Twinkle Marshmallow",
        traits: ["Calm", "Angry"],
        description:
          "Usually peaceful but quick to anger when seeing injustice. A strange peaceful-angry mix.",
        color: "#b05c79"
      },
      %{
        name: "Sprinkles Jellybean",
        traits: ["Stubborn", "Generous", "Emotional"],
        description:
          "Refuses to back down, loves giving to others, deeply feeling with heart on sleeve.",
        color: "#01c698"
      },
      %{
        name: "Doodle Cupcake",
        traits: ["Creative", "Energetic", "Curious"],
        description:
          "Thinks outside the box with boundless energy, always asking questions and exploring.",
        color: "#017116"
      },
      %{
        name: "Waffles Pizzazz",
        traits: ["Witty", "Confident", "Playful"],
        description: "Quick with jokes, sure of themselves, and always ready to have fun.",
        color: "#ff6b35"
      },
      %{
        name: "Muffin Tornado",
        traits: ["Chaotic", "Loyal", "Optimistic"],
        description:
          "Unpredictable and wild, fiercely devoted to friends, always sees the silver lining.",
        color: "#f7931e"
      },
      %{
        name: "Pancake Thunder",
        traits: ["Strong", "Protective", "Serious"],
        description:
          "Physically powerful, guards loved ones fiercely, takes everything seriously.",
        color: "#c1272d"
      },
      %{
        name: "Cupcake Lightning",
        traits: ["Fast", "Impulsive", "Friendly"],
        description:
          "Moves at lightning speed, acts without thinking, and loves making new friends.",
        color: "#0071bc"
      },
      %{
        name: "Biscuit Starshine",
        traits: ["Dreamy", "Creative", "Quiet"],
        description:
          "Lost in thoughts and imagination, creates beautiful things, prefers listening over talking.",
        color: "#662d91"
      },
      %{
        name: "Tootsie Wobble",
        traits: ["Clumsy", "Cheerful", "Forgiving"],
        description:
          "Always tripping over things, maintains a sunny disposition, quick to forgive mistakes.",
        color: "#f9e547"
      },
      %{
        name: "Pumpernickel Jazz",
        traits: ["Sophisticated", "Arrogant", "Talented"],
        description:
          "Refined tastes and manners, thinks highly of themselves, genuinely skilled at many things.",
        color: "#8b4513"
      },
      %{
        name: "Butterscotch Zoom",
        traits: ["Hyperactive", "Friendly", "Scatterbrained"],
        description:
          "Never sits still, loves everyone they meet, frequently forgets what they were doing.",
        color: "#ffcc00"
      },
      %{
        name: "Cheddar Boom",
        traits: ["Explosive", "Passionate", "Dramatic"],
        description:
          "Intense reactions to everything, deeply cares about causes, makes everything theatrical.",
        color: "#ff6347"
      },
      %{
        name: "Pretzel Shimmer",
        traits: ["Flexible", "Adaptable", "Indecisive"],
        description:
          "Can bend to any situation, adjusts well to change, struggles to make choices.",
        color: "#daa520"
      },
      %{
        name: "Bagel Sparkle",
        traits: ["Wholesome", "Reliable", "Boring"],
        description:
          "Good-hearted and dependable, always there when needed, lacks exciting qualities.",
        color: "#d2691e"
      },
      %{
        name: "Croissant Moonlight",
        traits: ["Elegant", "Mysterious", "Aloof"],
        description: "Graceful in movement, keeps secrets close, maintains distance from others.",
        color: "#e6e6fa"
      },
      %{
        name: "Donut Glitter",
        traits: ["Sweet", "Popular", "Vain"],
        description: "Kind to everyone, loved by all, overly concerned with appearance.",
        color: "#ff69b4"
      },
      %{
        name: "Taco Rocket",
        traits: ["Spicy", "Bold", "Reckless"],
        description:
          "Has a fiery personality, takes daring risks, doesn't think about consequences.",
        color: "#ff4500"
      },
      %{
        name: "Nacho Supreme",
        traits: ["Generous", "Messy", "Fun-loving"],
        description:
          "Shares everything with others, leaves chaos in their wake, knows how to party.",
        color: "#ffa500"
      },
      %{
        name: "Burrito Blast",
        traits: ["Packed", "Efficient", "Stressed"],
        description: "Does many things at once, maximizes productivity, constantly overwhelmed.",
        color: "#8b4513"
      },
      %{
        name: "Sushi Rainbow",
        traits: ["Precise", "Artistic", "Perfectionist"],
        description:
          "Pays attention to detail, creates beautiful works, never satisfied with results.",
        color: "#ff1493"
      },
      %{
        name: "Ramen Thunder",
        traits: ["Comforting", "Warm", "Clingy"],
        description:
          "Makes others feel better, provides emotional warmth, has trouble letting go.",
        color: "#cd853f"
      },
      %{
        name: "Cookie Monster",
        traits: ["Hungry", "Determined", "Single-minded"],
        description:
          "Always seeking snacks, pursues goals relentlessly, focuses on one thing at a time.",
        color: "#4169e1"
      },
      %{
        name: "Brownie Delight",
        traits: ["Rich", "Indulgent", "Guilty"],
        description:
          "Lives luxuriously, enjoys pleasures without restraint, feels bad about excesses.",
        color: "#654321"
      },
      %{
        name: "Pudding Wiggle",
        traits: ["Soft", "Jiggly", "Unstable"],
        description: "Gentle and yielding, moves in amusing ways, lacks firm foundation.",
        color: "#fff8dc"
      },
      %{
        name: "Jellybean Dream",
        traits: ["Colorful", "Varied", "Unpredictable"],
        description:
          "Has many facets to personality, full of surprises, never know what you'll get.",
        color: "#ff00ff"
      },
      %{
        name: "Lollipop Swirl",
        traits: ["Sweet", "Dizzy", "Simple"],
        description: "Pleasant and kind, often confused, sees things in basic terms.",
        color: "#ff1493"
      },
      %{
        name: "Gummy Bear Hug",
        traits: ["Squishy", "Affectionate", "Sticky"],
        description: "Soft and huggable, shows love openly, hard to get rid of once attached.",
        color: "#32cd32"
      },
      %{
        name: "Chocolate Velvet",
        traits: ["Smooth", "Luxurious", "Melting"],
        description: "Suave and sophisticated, lives in comfort, can't handle pressure or heat.",
        color: "#3e2723"
      },
      %{
        name: "Caramel Cascade",
        traits: ["Smooth", "Flowing", "Overwhelming"],
        description: "Moves gracefully, adapts to any container, can smother with attention.",
        color: "#d2691e"
      },
      %{
        name: "Mint Breeze",
        traits: ["Refreshing", "Cool", "Distant"],
        description:
          "Brings new perspective, stays calm under pressure, emotionally unavailable.",
        color: "#98ff98"
      },
      %{
        name: "Vanilla Bean",
        traits: ["Classic", "Simple", "Underrated"],
        description:
          "Traditional and timeless, straightforward approach, overlooked but valuable.",
        color: "#f3e5ab"
      },
      %{
        name: "Strawberry Sunrise",
        traits: ["Fresh", "Optimistic", "Early"],
        description: "Full of new ideas, always hopeful, wakes up before everyone else.",
        color: "#ff6b9d"
      },
      %{
        name: "Blueberry Blast",
        traits: ["Tart", "Intense", "Healthy"],
        description: "Sharp and critical, approaches life with vigor, makes good choices.",
        color: "#4169e1"
      },
      %{
        name: "Raspberry Zing",
        traits: ["Tangy", "Sharp", "Memorable"],
        description: "Has a bite to their personality, quick-witted, leaves lasting impressions.",
        color: "#e30b5c"
      },
      %{
        name: "Peach Fuzz",
        traits: ["Soft", "Warm", "Fuzzy"],
        description: "Gentle and tender, radiates kindness, slightly unclear in communication.",
        color: "#ffdab9"
      },
      %{
        name: "Mango Tango",
        traits: ["Tropical", "Exotic", "Passionate"],
        description:
          "Brings excitement from faraway places, unique and different, loves with intensity.",
        color: "#ff8c00"
      },
      %{
        name: "Pineapple Express",
        traits: ["Tropical", "Fast", "Surprising"],
        description: "Brings vacation vibes, moves quickly, full of unexpected moments.",
        color: "#ffd700"
      },
      %{
        name: "Coconut Cruise",
        traits: ["Laid-back", "Tropical", "Hard-shelled"],
        description:
          "Relaxed and easy-going, island mentality, tough exterior hiding soft inside.",
        color: "#f5f5dc"
      },
      %{
        name: "Banana Split",
        traits: ["Split", "Indecisive", "Appealing"],
        description: "Torn between options, struggles with choices, attractive to others.",
        color: "#ffe135"
      },
      %{
        name: "Cherry Bomb",
        traits: ["Small", "Explosive", "Sweet"],
        description: "Tiny but mighty, sudden outbursts, genuinely kind underneath.",
        color: "#de3163"
      },
      %{
        name: "Watermelon Sugar",
        traits: ["Juicy", "Refreshing", "Heavy"],
        description: "Full of life and flavor, brings relief, can be a burden to carry.",
        color: "#fc6c85"
      },
      %{
        name: "Kiwi Twist",
        traits: ["Fuzzy", "Tart", "Unique"],
        description: "Slightly odd exterior, sharp personality, one of a kind.",
        color: "#8ee53f"
      },
      %{
        name: "Lemon Zest",
        traits: ["Sour", "Energizing", "Small"],
        description:
          "Critical and sharp, brings life to situations, makes big impact despite size.",
        color: "#fff44f"
      },
      %{
        name: "Lime Riot",
        traits: ["Sour", "Rebellious", "Green"],
        description:
          "Bitter about injustice, fights against authority, environmentally conscious.",
        color: "#32cd32"
      },
      %{
        name: "Orange Peel",
        traits: ["Vibrant", "Useful", "Discarded"],
        description:
          "Bright and energetic, has practical applications, often overlooked or thrown away.",
        color: "#ff9500"
      },
      %{
        name: "Grapefruit Sunshine",
        traits: ["Bitter", "Bright", "Misunderstood"],
        description: "Has sharp edges, radiates positivity, people don't appreciate them fully.",
        color: "#fd5e53"
      },
      %{
        name: "Plum Perfect",
        traits: ["Sweet", "Dark", "Sophisticated"],
        description: "Pleasant and agreeable, mysterious qualities, refined tastes.",
        color: "#8e4585"
      },
      %{
        name: "Apricot Breeze",
        traits: ["Gentle", "Rare", "Seasonal"],
        description: "Soft and subtle, not often encountered, only around at certain times.",
        color: "#fbceb1"
      },
      %{
        name: "Papaya Sunrise",
        traits: ["Tropical", "Soft", "Digestive"],
        description: "Exotic and warm, yielding nature, helps process difficult things.",
        color: "#ffefd5"
      },
      %{
        name: "Dragon Fruit Flame",
        traits: ["Exotic", "Flashy", "Mild"],
        description:
          "Unusual and striking, looks impressive, less intense than appearance suggests.",
        color: "#ff006e"
      },
      %{
        name: "Starfruit Sparkle",
        traits: ["Unique", "Star-shaped", "Underused"],
        description: "One of a kind, stands out visually, potential not fully realized.",
        color: "#e4d00a"
      },
      %{
        name: "Pomegranate Jewel",
        traits: ["Complex", "Precious", "Messy"],
        description: "Many layers to personality, valuable and treasured, creates chaos.",
        color: "#c54b6c"
      },
      %{
        name: "Fig Newton",
        traits: ["Scientific", "Sweet", "Old-fashioned"],
        description: "Logical thinker, kind-hearted, stuck in the past.",
        color: "#8b7355"
      },
      %{
        name: "Date Night",
        traits: ["Romantic", "Sweet", "Scheduled"],
        description: "Loves with passion, pleasant and agreeable, needs everything planned.",
        color: "#654321"
      },
      %{
        name: "Olive Branch",
        traits: ["Peaceful", "Extending", "Salty"],
        description: "Seeks harmony, offers reconciliation, has sharp opinions.",
        color: "#808000"
      },
      %{
        name: "Pickle Rick",
        traits: ["Sour", "Scientific", "Transformed"],
        description:
          "Bitter and sharp, brilliant mind, fundamentally changed from original self.",
        color: "#9acd32"
      },
      %{
        name: "Avocado Toast",
        traits: ["Trendy", "Expensive", "Millennial"],
        description: "Currently popular, costs too much, represents a generation.",
        color: "#568203"
      },
      %{
        name: "Hummus Among Us",
        traits: ["Smooth", "Suspicious", "Mediterranean"],
        description: "Blends in well, might be the impostor, brings Middle Eastern vibes.",
        color: "#c9a86a"
      },
      %{
        name: "Salsa Verde",
        traits: ["Spicy", "Green", "Fresh"],
        description: "Has a kick, environmentally aware, full of new ideas.",
        color: "#6b8e23"
      },
      %{
        name: "Queso Blanco",
        traits: ["Smooth", "White", "Privileged"],
        description: "Creamy and even, benefits from unearned advantages, generally pleasant.",
        color: "#f5f5f5"
      },
      %{
        name: "Tofu Scramble",
        traits: ["Versatile", "Bland", "Healthy"],
        description: "Adapts to any situation, lacks strong personality, makes good choices.",
        color: "#fffdd0"
      },
      %{
        name: "Tempeh Tantrum",
        traits: ["Fermented", "Angry", "Nutritious"],
        description: "Been through transformation, quick to rage, good for you.",
        color: "#8b7d6b"
      },
      %{
        name: "Seitan Worship",
        traits: ["Devoted", "Meaty", "Controversial"],
        description: "Deeply faithful, substantial presence, divides opinions.",
        color: "#8b4513"
      },
      %{
        name: "Quinoa Quest",
        traits: ["Adventurous", "Nutritious", "Trendy"],
        description: "Seeks new experiences, healthy lifestyle, follows current fashions.",
        color: "#f0e68c"
      },
      %{
        name: "Kale Yeah",
        traits: ["Enthusiastic", "Healthy", "Overrated"],
        description: "Excitable and positive, good for you, gets too much credit.",
        color: "#228b22"
      },
      %{
        name: "Spinach Popeye",
        traits: ["Strong", "Green", "Sailor"],
        description: "Physically powerful, environmentally conscious, nautical background.",
        color: "#4f7942"
      },
      %{
        name: "Broccoli Rob",
        traits: ["Talented", "Competitive", "Here-Comes-Treble"],
        description: "Skilled performer, wants to be the best, musical background.",
        color: "#6b8e23"
      },
      %{
        name: "Asparagus Gus",
        traits: ["Fancy", "Expensive", "Pungent"],
        description: "Sophisticated tastes, costs more than worth, leaves strong impression.",
        color: "#87a96b"
      },
      %{
        name: "Artichoke Heart",
        traits: ["Complicated", "Hidden", "Tender"],
        description:
          "Many layers to work through, keeps feelings deep inside, soft emotional core.",
        color: "#8f9779"
      },
      %{
        name: "Brussels Sprout",
        traits: ["Misunderstood", "Bitter", "Nutritious"],
        description: "People prejudge unfairly, sharp personality, actually good for you.",
        color: "#8ca171"
      },
      %{
        name: "Cabbage Patch",
        traits: ["Adopted", "Round", "Versatile"],
        description: "Came from unexpected origins, well-rounded, fits many situations.",
        color: "#daf0ce"
      },
      %{
        name: "Carrot Top",
        traits: ["Orange", "Comedic", "Prop-dependent"],
        description: "Stands out visually, tries to be funny, relies on external tools.",
        color: "#ff8c00"
      },
      %{
        name: "Celery Stick",
        traits: ["Crunchy", "Watery", "Diet"],
        description:
          "Has substance despite hollowness, mostly composed of emotions, trying to lose weight.",
        color: "#ace1af"
      },
      %{
        name: "Lettuce Pray",
        traits: ["Leafy", "Religious", "Base"],
        description: "Has many layers, spiritually devoted, foundation for other things.",
        color: "#90ee90"
      },
      %{
        name: "Tomato Debate",
        traits: ["Controversial", "Fruit", "Vegetable"],
        description: "Always causing arguments, scientifically one thing, socially another.",
        color: "#ff6347"
      },
      %{
        name: "Potato Couch",
        traits: ["Lazy", "Comfortable", "Starchy"],
        description: "Avoids physical activity, creates comfort, full of carbohydrates.",
        color: "#e2c1a8"
      },
      %{
        name: "Sweet Potato",
        traits: ["Kind", "Orange", "Better"],
        description: "Genuinely nice person, stands out, superior to regular version.",
        color: "#fd7a34"
      },
      %{
        name: "Onion Layers",
        traits: ["Complex", "Tearful", "Pungent"],
        description: "Many depths to personality, makes people cry, strong presence.",
        color: "#e5d8bd"
      },
      %{
        name: "Garlic Bread",
        traits: ["Popular", "Garlicky", "Improved"],
        description: "Everyone loves them, defines their personality, better than original.",
        color: "#f4e8c1"
      },
      %{
        name: "Pepper Shaker",
        traits: ["Spicy", "Dancing", "Paired"],
        description: "Has a kick, moves rhythmically, always with their salt partner.",
        color: "#000000"
      },
      %{
        name: "Salt Bae",
        traits: ["Dramatic", "Excessive", "Viral"],
        description: "Makes everything theatrical, goes overboard, famous on internet.",
        color: "#ffffff"
      },
      %{
        name: "Basil Brush",
        traits: ["Herbal", "British", "Boom-Boom"],
        description: "Fresh and aromatic, distinctly English, has catchphrase.",
        color: "#3f7d43"
      },
      %{
        name: "Rosemary Baby",
        traits: ["Aromatic", "Cursed", "Horror"],
        description: "Pleasant smell, born under dark circumstances, scary movie vibes.",
        color: "#7e9c76"
      },
      %{
        name: "Thyme Traveler",
        traits: ["Aromatic", "Temporal", "Lost"],
        description:
          "Fragrant presence, exists across different periods, confused about when they are.",
        color: "#b6d7a8"
      },
      %{
        name: "Sage Wisdom",
        traits: ["Wise", "Herbal", "Old"],
        description: "Full of knowledge, healing properties, been around long time.",
        color: "#9ca986"
      },
      %{
        name: "Parsley Garnish",
        traits: ["Decorative", "Ignored", "Useful"],
        description: "Makes things look better, nobody pays attention, actually has value.",
        color: "#3d5d3d"
      },
      %{
        name: "Cilantro Love",
        traits: ["Divisive", "Soapy", "Genetic"],
        description: "People either love or hate them, tastes wrong to some, it's in their DNA.",
        color: "#8fc73e"
      },
      %{
        name: "Dill Pickle",
        traits: ["Sour", "Herbal", "Brined"],
        description: "Sharp personality, fragrant qualities, been through preservation process.",
        color: "#6b8e23"
      },
      %{
        name: "Mint Condition",
        traits: ["Fresh", "Perfect", "Valuable"],
        description: "Like new, no flaws, worth a lot.",
        color: "#98ff98"
      },
      %{
        name: "Oregano Trail",
        traits: ["Herbal", "Historical", "Deadly"],
        description: "Italian flavoring, marks important journey, many died along the way.",
        color: "#7d805c"
      },
      %{
        name: "Cinnamon Roll",
        traits: ["Sweet", "Precious", "Swirled"],
        description: "Kind and adorable, must be protected, complicated layers.",
        color: "#d2691e"
      },
      %{
        name: "Nutmeg Football",
        traits: ["Spicy", "Athletic", "Skilled"],
        description: "Has a kick, plays sports, performs impressive tricks.",
        color: "#8b7355"
      },
      %{
        name: "Ginger Snap",
        traits: ["Spicy", "Crispy", "Breaking"],
        description: "Sharp personality, rigid structure, under pressure might crack.",
        color: "#d2691e"
      },
      %{
        name: "Vanilla Ice",
        traits: ["Smooth", "Rapper", "One-Hit"],
        description: "Cool and suave, musical talent, peaked early.",
        color: "#f3e5ab"
      },
      %{
        name: "Honey Bunny",
        traits: ["Sweet", "Cute", "Sticky"],
        description: "Pleasant and adorable, attracts others easily, hard to shake off.",
        color: "#ffb347"
      },
      %{
        name: "Maple Leaf",
        traits: ["Canadian", "Sweet", "Seasonal"],
        description: "Polite and apologetic, kind nature, beautiful in fall.",
        color: "#ff4500"
      },
      %{
        name: "Sugar Rush",
        traits: ["Hyperactive", "Sweet", "Crashing"],
        description: "Extremely energetic, pleasant initially, eventually exhausted.",
        color: "#ffccff"
      },
      %{
        name: "Butter Fingers",
        traits: ["Clumsy", "Smooth", "Dropping"],
        description: "Drops everything, has suave moments, can't hold onto things.",
        color: "#ffe5b4"
      },
      %{
        name: "Cream Dream",
        traits: ["Rich", "Smooth", "Luxurious"],
        description: "Lives in comfort, moves elegantly, indulgent lifestyle.",
        color: "#fffdd0"
      },
      %{
        name: "Cheese Louise",
        traits: ["Exclamatory", "Cheesy", "Surprised"],
        description: "Expresses shock often, corny sense of humor, easily amazed.",
        color: "#ffa500"
      },
      %{
        name: "Bacon Kevin",
        traits: ["Connected", "Savory", "Degrees"],
        description: "Knows everyone, delicious personality, links people together.",
        color: "#d2691e"
      },
      %{
        name: "Ham Sandwich",
        traits: ["Basic", "Filling", "Between"],
        description: "Simple and plain, satisfies needs, caught between two things.",
        color: "#ffb6c1"
      },
      %{
        name: "Turkey Lurkey",
        traits: ["Fowl", "Fearful", "Holiday"],
        description: "Bird-like qualities, scared of everything, special occasion.",
        color: "#cd853f"
      },
      %{
        name: "Chicken Little",
        traits: ["Paranoid", "Small", "Warning"],
        description: "Thinks sky is falling, tiny in size, tries to alert others.",
        color: "#fff8dc"
      },
      %{
        name: "Beef Wellington",
        traits: ["Fancy", "Wrapped", "Difficult"],
        description: "Sophisticated and elegant, protected by layers, hard to get right.",
        color: "#8b4513"
      },
      %{
        name: "Pork Chop",
        traits: ["Meaty", "Martial", "Cut"],
        description: "Substantial presence, karate expertise, separated from whole.",
        color: "#ffc0cb"
      },
      %{
        name: "Lamb Chop",
        traits: ["Cute", "Puppet", "Shari"],
        description: "Adorable appearance, controlled by another, entertainment background.",
        color: "#ffe4e1"
      },
      %{
        name: "Shrimp Boat",
        traits: ["Small", "Sailing", "Forrest"],
        description: "Tiny in stature, goes with the flow, simple wisdom.",
        color: "#ffc1c1"
      },
      %{
        name: "Tuna Melt",
        traits: ["Fishy", "Warm", "Gooey"],
        description: "Something suspicious, brings warmth, emotionally soft.",
        color: "#b0c4de"
      },
      %{
        name: "Salmon Rushdie",
        traits: ["Fishy", "Literary", "Fatwa"],
        description: "Swims upstream, writes controversial things, has price on head.",
        color: "#fa8072"
      },
      %{
        name: "Crab Apple",
        traits: ["Grouchy", "Sour", "Small"],
        description: "Always complaining, bitter personality, compact size.",
        color: "#dc143c"
      },
      %{
        name: "Lobster Thermidor",
        traits: ["Fancy", "Expensive", "Red"],
        description: "High-class and sophisticated, costs too much, turns red under heat.",
        color: "#ff4500"
      },
      %{
        name: "Clam Chowder",
        traits: ["Creamy", "Comforting", "Regional"],
        description: "Smooth and rich, makes people feel better, divides by geography.",
        color: "#fff8dc"
      },
      %{
        name: "Oyster Perpetual",
        traits: ["Luxurious", "Timeless", "Expensive"],
        description: "High-end lifestyle, lasts forever, costs fortune.",
        color: "#e5e4e2"
      },
      %{
        name: "Mussel Beach",
        traits: ["Strong", "Coastal", "Bodybuilding"],
        description: "Physically fit, lives by ocean, works out constantly.",
        color: "#483d8b"
      },
      %{
        name: "Scallop Hop",
        traits: ["Bouncing", "Delicate", "Musical"],
        description: "Moves in jumps, fragile nature, rhythmic motion.",
        color: "#f0e68c"
      },
      %{
        name: "Squid Ink",
        traits: ["Dark", "Artistic", "Defensive"],
        description: "Mysterious and obscure, creates beautiful things, protects by clouding.",
        color: "#1c1c1c"
      },
      %{
        name: "Octopus Garden",
        traits: ["Multi-talented", "Beatles", "Underwater"],
        description: "Can do many things at once, musical reference, lives below surface.",
        color: "#ff6ec7"
      },
      %{
        name: "Jellyfish Jam",
        traits: ["Stinging", "Flowing", "Musical"],
        description: "Hurts people accidentally, goes with current, loves making music.",
        color: "#ff69b4"
      },
      %{
        name: "Starfish Patrick",
        traits: ["Stupid", "Pink", "Best-Friend"],
        description: "Not very bright, stands out visually, loyal companion.",
        color: "#ff1493"
      },
      %{
        name: "Crab Rave",
        traits: ["Dancing", "Meme", "Gone"],
        description: "Celebrates rhythmically, internet famous, something has disappeared.",
        color: "#ff6347"
      },
      %{
        name: "Seaweed Salad",
        traits: ["Healthy", "Salty", "Trendy"],
        description: "Good for you, has sharp edge, currently fashionable.",
        color: "#2e8b57"
      }
    ]
    |> Enum.map(fn gene ->
      Map.merge(gene, %{
        id: Ecto.UUID.generate(),
        x_coordinate: Enum.random(0..200),
        y_coordinate: Enum.random(0..200),
        dead_at: nil,
        is_alive: true,
        user_id: "8dadde5c-1ce1-4d63-94cd-eb664a673927"
      })
    end)
  end
end
