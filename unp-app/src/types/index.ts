// ── User & Auth ────────────────────────────────────────────────────────────────
export type UserRole = 'guest' | 'free' | 'paid' | 'ambassador';

export interface User {
  id: string;
  name: string;
  email: string;
  role: UserRole;
  avatar?: string;
  bio?: string;
  joinedAt: string;
  rewardTier: 'bronze' | 'silver' | 'gold';
  rewardPoints: number;
  following: string[];
  followers: string[];
}

// ── Beverage / Pour ────────────────────────────────────────────────────────────
export type BeverageCategory = 'cocktail' | 'wine' | 'beer' | 'spirit' | 'mocktail' | 'shot';

export interface Ingredient {
  name: string;
  amount: string;
}

export interface Beverage {
  id: string;
  name: string;
  category: BeverageCategory;
  description: string;
  image: string;
  ingredients: Ingredient[];
  instructions: string[];
  pairing: string[];
  prepTime: number;      // minutes
  difficulty: 'easy' | 'medium' | 'hard';
  tags: string[];
  isPremium: boolean;
  uploadedBy?: string;   // ambassador user id
  likes: number;
  saves: number;
  similarIds: string[];
}

// ── Nudge / Micro-adventure ────────────────────────────────────────────────────
export type NudgeCategory = 'social' | 'solo' | 'date' | 'group' | 'adventure';

export interface NudgeStep {
  step: number;
  title: string;
  description: string;
  beverageId?: string;
  eventId?: string;
}

export interface Nudge {
  id: string;
  title: string;
  tagline: string;
  category: NudgeCategory;
  image: string;
  description: string;
  isPremium: boolean;
  steps: NudgeStep[];   // paid 3-step plan
  poll?: { question: string; options: string[] };
  tags: string[];
  relatedBeverageIds: string[];
  relatedEventIds: string[];
}

// ── Event / Explore ────────────────────────────────────────────────────────────
export type TimeSlot = 'day' | 'night' | 'late-night';

export interface Venue {
  id: string;
  name: string;
  address: string;
  lat: number;
  lng: number;
  image: string;
  type: string;
}

export interface Event {
  id: string;
  title: string;
  venue: Venue;
  date: string;
  startTime: string;
  endTime: string;
  timeSlot: TimeSlot;
  description: string;
  image: string;
  tags: string[];
  isPremium: boolean;
  price?: string;
  attendees: number;
  howToAttend?: string;  // paid detail
  relatedBeverageIds: string[];
}

// ── Pour Circle / Social ───────────────────────────────────────────────────────
export type CirclePostType = 'pour' | 'checkin' | 'nudge' | 'event' | 'media';

export interface CirclePost {
  id: string;
  authorId: string;
  authorName: string;
  authorAvatar: string;
  authorRole: UserRole;
  type: CirclePostType;
  content: string;
  image?: string;
  beverageId?: string;
  eventId?: string;
  likes: number;
  comments: CircleComment[];
  createdAt: string;
  liked?: boolean;
}

export interface CircleComment {
  id: string;
  authorName: string;
  content: string;
  createdAt: string;
}

export interface Circle {
  id: string;
  name: string;
  description: string;
  image: string;
  members: number;
  isPrivate: boolean;
  tags: string[];
  posts: CirclePost[];
}

// ── Rewards ────────────────────────────────────────────────────────────────────
export interface RewardActivity {
  id: string;
  type: 'save' | 'share' | 'attend' | 'upload' | 'plan' | 'social';
  description: string;
  points: number;
  date: string;
}

// ── App State ──────────────────────────────────────────────────────────────────
export interface AppState {
  user: User | null;
  hasSeenOnboarding: boolean;
  tourStep: number | null;
  activeTour: string | null;
}
