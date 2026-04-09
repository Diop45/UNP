import type { Beverage, MockUser, Nudge, RewardItem, VenueEvent } from "./types";

export const CITY = "Detroit";

export const MOCK_USERS: MockUser[] = [
  { id: "u1", name: "Jessica", role: "free", avatarColor: "#6b8cff" },
  { id: "u2", name: "Brandon", role: "paid", avatarColor: "#4ade80" },
  { id: "u3", name: "Lauren", role: "paid", avatarColor: "#f472b6" },
  { id: "u4", name: "Mason", role: "paid", avatarColor: "#fbbf24" },
  { id: "u5", name: "Alex (Ambassador)", role: "ambassador", avatarColor: "rgba(245, 230, 200, 0.55)" },
];

export const REWARD_ITEMS: RewardItem[] = [
  { id: "r1", label: "VIP Access", icon: "vip" },
  { id: "r2", label: "Free Beverage", icon: "martini" },
  { id: "r3", label: "Partner Promo", icon: "promo" },
];

const pl = (title: string, artist: string) => ({ title, artist });

export const BEVERAGES: Beverage[] = [
  {
    id: "bev-aperol",
    name: "Aperol Spritz",
    spiritTags: ["aperitif", "prosecco", "bitter"],
    glassware: "Large wine glass",
    ingredients: [
      { name: "Prosecco", amount: "3 oz" },
      { name: "Aperol", amount: "2 oz" },
      { name: "Soda water", amount: "1 oz splash" },
      { name: "Orange slice", amount: "1 wheel garnish" },
    ],
    steps: [
      "Fill glass with ice.",
      "Pour prosecco, then Aperol.",
      "Top with soda; stir gently.",
      "Garnish with orange wheel.",
    ],
    pairings: ["Olives", "Marcona almonds", "Citrus salad"],
    playlist: [pl("Midnight City", "M83"), pl("Electric Feel", "MGMT"), pl("Sun Models", "ODESZA")],
    similarIds: ["bev-negroni", "bev-margarita"],
  },
  {
    id: "bev-negroni",
    name: "Negroni",
    spiritTags: ["gin", "bitter", "classic"],
    glassware: "Rocks glass",
    ingredients: [
      { name: "London dry gin", amount: "1 oz" },
      { name: "Sweet vermouth", amount: "1 oz" },
      { name: "Campari", amount: "1 oz" },
      { name: "Orange peel", amount: "1 expressed peel" },
    ],
    steps: ["Stir all spirits with ice for 20s.", "Strain over a large cube.", "Express orange oils; drop peel."],
    pairings: ["Dark chocolate", "Charcuterie", "Aged cheese"],
    playlist: [pl("Black Gold", "Esperanza Spalding"), pl("Nights Over Egypt", "The Jones Girls")],
    similarIds: ["bev-manhattan", "bev-oldfashioned"],
  },
  {
    id: "bev-oldfashioned",
    name: "Old Fashioned",
    spiritTags: ["whiskey", "classic", "stirred"],
    glassware: "Rocks glass",
    ingredients: [
      { name: "Bourbon or rye", amount: "2 oz" },
      { name: "Demerara syrup", amount: "1 tsp" },
      { name: "Angostura bitters", amount: "2 dashes" },
      { name: "Orange + cherry", amount: "Garnish" },
    ],
    steps: ["Muddle syrup and bitters lightly.", "Add whiskey and ice; stir.", "Garnish with orange and cherry."],
    pairings: ["Smoked nuts", "Steak bites", "Maple dessert"],
    playlist: [pl("The Chain", "Fleetwood Mac"), pl("Redbone", "Childish Gambino")],
    similarIds: ["bev-manhattan", "bev-negroni"],
  },
  {
    id: "bev-margarita",
    name: "Margarita",
    spiritTags: ["tequila", "citrus", "shaken"],
    glassware: "Coupe or rocks with salt rim",
    ingredients: [
      { name: "Blanco tequila", amount: "2 oz" },
      { name: "Lime juice", amount: "1 oz" },
      { name: "Orange liqueur", amount: "¾ oz" },
      { name: "Agave syrup", amount: "¼ oz optional" },
    ],
    steps: ["Rim half the glass with salt.", "Shake all liquid with ice.", "Fine strain into glass."],
    pairings: ["Fish tacos", "Guacamole", "Jalapeño poppers"],
    playlist: [pl("Oye Como Va", "Santana"), pl("Mas Que Nada", "Sergio Mendes")],
    similarIds: ["bev-aperol", "bev-espresso"],
  },
  {
    id: "bev-manhattan",
    name: "Manhattan",
    spiritTags: ["whiskey", "vermouth", "classic"],
    glassware: "Coupe",
    ingredients: [
      { name: "Rye whiskey", amount: "2 oz" },
      { name: "Sweet vermouth", amount: "1 oz" },
      { name: "Angostura bitters", amount: "2 dashes" },
      { name: "Brandied cherry", amount: "1" },
    ],
    steps: ["Stir with ice until chilled.", "Strain into coupe.", "Cherry garnish."],
    pairings: ["Blue cheese", "Charred broccolini", "Dark fruit tart"],
    playlist: [pl("New York State of Mind", "Billy Joel"), pl("Moanin'", "Charles Mingus")],
    similarIds: ["bev-oldfashioned", "bev-negroni"],
  },
  {
    id: "bev-espresso",
    name: "Espresso Martini",
    spiritTags: ["vodka", "coffee", "dessert"],
    glassware: "Coupe",
    ingredients: [
      { name: "Vodka", amount: "1½ oz" },
      { name: "Coffee liqueur", amount: "¾ oz" },
      { name: "Fresh espresso", amount: "1 oz chilled" },
      { name: "Simple syrup", amount: "¼ oz to taste" },
    ],
    steps: ["Pull espresso; chill quickly.", "Shake all ingredients hard with ice.", "Double strain; float 3 coffee beans."],
    pairings: ["Tiramisu", "Chocolate mousse", "Bacon dates"],
    playlist: [pl("Coffee Cold", "Nathaniel Rateliff"), pl("Nightcall", "Kavinsky")],
    similarIds: ["bev-margarita", "bev-aperol"],
  },
];

export const NUDGES: Nudge[] = [
  {
    id: "nudge-barsak",
    title: "Visit Barsak",
    subtitle: "Tonight’s spotlight",
    body: "Detroit’s layered cocktail program with vinyl-only nights. Ask for the off-menu amaro flight.",
    pollQuestion: "What are you sipping first?",
    pollOptions: ["Spritz", "Negroni", "Zero-proof"],
    linkedEventIds: ["evt-speakeasy"],
    linkedBeverageIds: ["bev-aperol", "bev-negroni"],
  },
  {
    id: "nudge-mix",
    title: "Try a Mix 'n' Match",
    subtitle: "Build your lane",
    body: "Pair a base spirit with two modifiers — bartenders love riffing on Margarita and Manhattan templates.",
    pollQuestion: "Pick your base",
    pollOptions: ["Tequila", "Rye", "Gin"],
    linkedEventIds: ["evt-funk"],
    linkedBeverageIds: ["bev-margarita", "bev-manhattan"],
  },
  {
    id: "nudge-soma",
    title: "Have Soma Fun Tonight",
    subtitle: "Late energy",
    body: "Soma’s dance floor opens after the kitchen closes — espresso martinis on draft after 11.",
    pollQuestion: "Late snack?",
    pollOptions: ["Olives", "Fries", "Skip"],
    linkedEventIds: ["evt-afterdark"],
    linkedBeverageIds: ["bev-espresso"],
  },
];

export const EVENTS: VenueEvent[] = [
  {
    id: "evt-speakeasy",
    title: "Detroit Speakeasy",
    venue: "The Brushed Brass",
    address: "123 E Jefferson, Detroit, MI",
    startTime: "9:00 PM",
    filter: "night",
    dressCode: "Smart casual; collared shirts encouraged",
    doorPolicy: "21+ · ID scan · Limited walk-ins after 10pm",
    ticketsUrl: "https://example.com/tickets/speakeasy",
    beverageSpecials: "$12 Negroni / $10 Aperol Spritz until 10pm",
    rsvpCount: 186,
    attendingFriends: ["Brandon", "Lauren"],
    lat: 42.3314,
    lon: -83.0458,
    linkedBeverageIds: ["bev-negroni", "bev-aperol"],
    linkedNudgeIds: ["nudge-barsak"],
  },
  {
    id: "evt-afterdark",
    title: "After Dark",
    venue: "Pulse Hall",
    address: "400 Bagley St, Detroit, MI",
    startTime: "10:30 PM",
    filter: "late",
    dressCode: "Expressive; no athletic shorts",
    doorPolicy: "Guest list priority · Coat check $5",
    ticketsUrl: "https://example.com/tickets/afterdark",
    beverageSpecials: "Espresso Martini pitchers for tables of 4+",
    rsvpCount: 242,
    attendingFriends: ["Mason"],
    lat: 42.335,
    lon: -83.05,
    linkedBeverageIds: ["bev-espresso"],
    linkedNudgeIds: ["nudge-soma"],
  },
  {
    id: "evt-funk",
    title: "Funk & Bourbon",
    venue: "Copper Still",
    address: "800 Michigan Ave, Detroit, MI",
    startTime: "9:00 PM",
    filter: "night",
    dressCode: "Come as you are",
    doorPolicy: "First-come; booth reservations until 8pm",
    ticketsUrl: "https://example.com/tickets/funk",
    beverageSpecials: "Bourbon flights with funk vinyl pairings",
    rsvpCount: 98,
    attendingFriends: ["Jessica", "Brandon"],
    lat: 42.328,
    lon: -83.072,
    linkedBeverageIds: ["bev-oldfashioned", "bev-manhattan"],
    linkedNudgeIds: ["nudge-mix"],
  },
  {
    id: "evt-shots",
    title: "Shots & Scores",
    venue: "Arena Row Social",
    address: "200 Witherell St, Detroit, MI",
    startTime: "8:00 PM",
    filter: "day",
    dressCode: "Jerseys welcome",
    doorPolicy: "Family-friendly until 9pm · 21+ bar area",
    ticketsUrl: "https://example.com/tickets/shots",
    beverageSpecials: "$5 boilermaker pairings during games",
    rsvpCount: 412,
    attendingFriends: ["Lauren", "Mason", "Alex (Ambassador)"],
    lat: 42.341,
    lon: -83.055,
    linkedBeverageIds: ["bev-margarita"],
    linkedNudgeIds: ["nudge-mix"],
  },
];

export const DETROIT_CENTER = { lat: 42.3314, lon: -83.0458 };

export function getBeverageById(id: string) {
  return BEVERAGES.find((b) => b.id === id);
}

export function getEventById(id: string) {
  return EVENTS.find((e) => e.id === id);
}

export function getNudgeById(id: string) {
  return NUDGES.find((n) => n.id === id);
}
