export type UserRole = "guest" | "free" | "paid" | "ambassador";

export interface Ingredient {
  name: string;
  amount: string;
}

export interface Beverage {
  id: string;
  name: string;
  spiritTags: string[];
  glassware: string;
  ingredients: Ingredient[];
  steps: string[];
  pairings: string[];
  playlist: { title: string; artist: string }[];
  similarIds: string[];
}

export type TimeFilter = "day" | "night" | "late";

export interface VenueEvent {
  id: string;
  title: string;
  venue: string;
  address: string;
  startTime: string;
  filter: TimeFilter;
  dressCode: string;
  doorPolicy: string;
  ticketsUrl: string;
  beverageSpecials: string;
  rsvpCount: number;
  attendingFriends: string[];
  lat: number;
  lon: number;
  linkedBeverageIds: string[];
  linkedNudgeIds: string[];
}

export interface Nudge {
  id: string;
  title: string;
  subtitle: string;
  body: string;
  pollQuestion: string;
  pollOptions: string[];
  linkedEventIds: string[];
  linkedBeverageIds: string[];
}

export interface MockUser {
  id: string;
  name: string;
  role: Exclude<UserRole, "guest">;
  avatarColor: string;
}

export interface RewardItem {
  id: string;
  label: string;
  icon: "vip" | "martini" | "promo";
}

export interface AmbassadorUpload {
  id: string;
  name: string;
  createdAt: string;
  views: number;
  saves: number;
}
