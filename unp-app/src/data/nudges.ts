import type { Nudge } from '../types';

export const nudges: Nudge[] = [
  {
    id: 'nudge-001',
    title: "Tonight's Nudge: The Wandering Bar Crawl",
    tagline: 'Let the city guide your thirst.',
    category: 'social',
    image: 'https://images.unsplash.com/photo-1516997121675-4c2d1684aa3e?w=600&q=80',
    description: 'Skip the reservation. Let tonight be a spontaneous journey through three contrasting bars — each one a different chapter in the city\'s after-dark story.',
    isPremium: false,
    steps: [
      {
        step: 1,
        title: 'Start at a Dive',
        description: 'Find a no-frills bar where the jukebox is loud and the beer is cold. Order the cheapest draft, make a friend at the bar.',
        beverageId: 'bev-001',
      },
      {
        step: 2,
        title: 'Level Up — Craft Cocktail Bar',
        description: 'Move to a craft cocktail lounge. Order something you\'ve never had before. Ask the bartender what they\'d drink if they weren\'t working.',
        beverageId: 'bev-002',
        eventId: 'evt-001',
      },
      {
        step: 3,
        title: 'End at a Rooftop',
        description: 'Find a rooftop spot, order the last drink of the night slowly, and take a photo of the city lights. Send it to someone you\'ve been thinking about.',
        beverageId: 'bev-003',
        eventId: 'evt-002',
      },
    ],
    poll: {
      question: 'What kind of night are you looking for?',
      options: ['Chill vibes', 'Dancing', 'Deep conversations', 'New experiences'],
    },
    tags: ['bar-crawl', 'social', 'spontaneous', 'city-night'],
    relatedBeverageIds: ['bev-001', 'bev-002', 'bev-003'],
    relatedEventIds: ['evt-001', 'evt-002'],
  },
  {
    id: 'nudge-002',
    title: "Solo Ritual: The Perfect Night In",
    tagline: 'Your company is enough.',
    category: 'solo',
    image: 'https://images.unsplash.com/photo-1528360983277-13d401cdc186?w=600&q=80',
    description: 'Tonight is yours. Build the perfect solo evening with intention — a curated drink, a playlist, a book or film, and zero apologies for enjoying your own company.',
    isPremium: false,
    steps: [
      {
        step: 1,
        title: 'Set the Atmosphere',
        description: 'Dim the lights. Light a candle. Queue up a playlist that matches your mood. This is your theatre.',
        beverageId: 'bev-006',
      },
      {
        step: 2,
        title: 'Make Your Signature Drink',
        description: 'Make one of your saved pour cards, intentionally. Treat yourself as the bartender and as the guest.',
        beverageId: 'bev-005',
      },
      {
        step: 3,
        title: 'The Main Event',
        description: 'Read that chapter, watch that film, or start that project you\'ve been putting off. Pair with your drink and let time slow down.',
        beverageId: 'bev-002',
      },
    ],
    poll: {
      question: 'Best solo night activity?',
      options: ['Reading', 'Movie marathon', 'Creating something', 'Gaming'],
    },
    tags: ['solo', 'intentional', 'self-care', 'cozy'],
    relatedBeverageIds: ['bev-005', 'bev-006', 'bev-002'],
    relatedEventIds: [],
  },
  {
    id: 'nudge-003',
    title: "Date Night: The Slow Pour",
    tagline: 'Presence is the most intoxicating thing.',
    category: 'date',
    image: 'https://images.unsplash.com/photo-1424847651672-bf20a4b0982b?w=600&q=80',
    description: 'Phones away. Tonight is about attention, conversation, and the magic that happens when two people genuinely slow down together.',
    isPremium: true,
    steps: [
      {
        step: 1,
        title: 'Aperitivo Hour',
        description: 'Start with an aperitivo — something bitter and light to open the palate and the conversation. No agenda, just presence.',
        beverageId: 'bev-004',
        eventId: 'evt-003',
      },
      {
        step: 2,
        title: 'The Dinner Drink',
        description: 'Move to dinner. Order a wine or cocktail that pairs with your food. Learn one new thing about your date over the main course.',
        beverageId: 'bev-003',
      },
      {
        step: 3,
        title: 'Nightcap & Stars',
        description: 'Find somewhere with a view. Order something warm or complex. Don\'t check your phone once.',
        beverageId: 'bev-002',
        eventId: 'evt-004',
      },
    ],
    poll: {
      question: 'Best date night vibe?',
      options: ['Cozy restaurant', 'Rooftop cocktails', 'Live music', 'Walk + drinks'],
    },
    tags: ['date', 'romantic', 'slow', 'intentional'],
    relatedBeverageIds: ['bev-004', 'bev-003', 'bev-002'],
    relatedEventIds: ['evt-003', 'evt-004'],
  },
  {
    id: 'nudge-004',
    title: "Group Quest: The Tasting Tournament",
    tagline: 'Seven friends, seven opinions, one winner.',
    category: 'group',
    image: 'https://images.unsplash.com/photo-1543007631-283050bb3e8c?w=600&q=80',
    description: 'Host a blind tasting tournament with your crew. Everyone brings a bottle, no labels shown, and the group votes on their favorite. Drama guaranteed.',
    isPremium: false,
    steps: [
      {
        step: 1,
        title: 'The Setup',
        description: 'Each person brings a bottle (same category — e.g., all bourbons or all reds). Brown-bag or foil-wrap them. Number them 1-N.',
        beverageId: 'bev-005',
      },
      {
        step: 2,
        title: 'The Blind Tasting',
        description: 'Pour small pours of each. Score on aroma, taste, finish, and "would order at a bar" factor. Keep it blind until all votes are in.',
        beverageId: 'bev-002',
      },
      {
        step: 3,
        title: 'The Reveal',
        description: 'Unveil the winner. Toast the winning bottle. The person who brought it picks where you all go for the next round.',
        beverageId: 'bev-007',
        eventId: 'evt-001',
      },
    ],
    poll: {
      question: 'Best category for a blind tasting?',
      options: ['Bourbon/Whiskey', 'Red wine', 'Tequila', 'Craft beer'],
    },
    tags: ['group', 'game', 'tasting', 'competitive'],
    relatedBeverageIds: ['bev-005', 'bev-002', 'bev-007'],
    relatedEventIds: ['evt-001'],
  },
  {
    id: 'nudge-005',
    title: "Urban Adventure: Find the Hidden Bar",
    tagline: 'The best bars have no signs.',
    category: 'adventure',
    image: 'https://images.unsplash.com/photo-1572116469696-31de0f17cc34?w=600&q=80',
    description: 'Every city has secret bars — behind bookcase doors, under old hotels, through unmarked alleys. Tonight, your mission is to find one you\'ve never been to.',
    isPremium: true,
    steps: [
      {
        step: 1,
        title: 'The Research',
        description: 'Check Explore for hidden gems tagged "speakeasy" or "hidden bar" in your area. Pick one you\'ve never visited.',
        eventId: 'evt-005',
      },
      {
        step: 2,
        title: 'The Discovery',
        description: 'Go there without directions once you\'re in the neighborhood. Find the entrance the old-fashioned way: instinct and local knowledge.',
        beverageId: 'bev-007',
      },
      {
        step: 3,
        title: 'The House Recommendation',
        description: 'When you get there, order whatever the bartender recommends. No menu-browsing. Full trust. Share the experience to Pour Circle.',
        beverageId: 'bev-001',
        eventId: 'evt-006',
      },
    ],
    tags: ['adventure', 'discovery', 'speakeasy', 'hidden'],
    relatedBeverageIds: ['bev-007', 'bev-001'],
    relatedEventIds: ['evt-005', 'evt-006'],
  },
];

export const getNudgeById = (id: string) => nudges.find(n => n.id === id);
export const getFeaturedNudge = () => nudges[0];
export const getFreeNudges = () => nudges.filter(n => !n.isPremium);
export const getPremiumNudges = () => nudges.filter(n => n.isPremium);
