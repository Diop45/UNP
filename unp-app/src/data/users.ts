import type { User } from '../types';

export const demoUsers: User[] = [
  {
    id: 'user-free',
    name: 'Alex Rivera',
    email: 'alex@example.com',
    role: 'free',
    avatar: 'https://i.pravatar.cc/100?img=3',
    bio: 'Casual sipper. Weekend explorer.',
    joinedAt: '2026-01-15',
    rewardTier: 'bronze',
    rewardPoints: 120,
    following: ['amb-001', 'user-002'],
    followers: ['user-003'],
  },
  {
    id: 'user-paid',
    name: 'Jordan Westfall',
    email: 'jordan@example.com',
    role: 'paid',
    avatar: 'https://i.pravatar.cc/100?img=5',
    bio: 'Cocktail enthusiast. Always planning the next pour.',
    joinedAt: '2025-11-08',
    rewardTier: 'silver',
    rewardPoints: 580,
    following: ['amb-001', 'user-002', 'user-003'],
    followers: ['user-002', 'user-005'],
  },
  {
    id: 'amb-001',
    name: 'PourMaestro',
    email: 'maestro@example.com',
    role: 'ambassador',
    avatar: 'https://i.pravatar.cc/100?img=12',
    bio: 'Verified Beverage Ambassador. 12 years behind the bar. I teach what the bar schools won\'t.',
    joinedAt: '2025-09-01',
    rewardTier: 'gold',
    rewardPoints: 2840,
    following: [],
    followers: ['user-free', 'user-paid', 'user-002', 'user-003', 'user-004', 'user-005'],
  },
];

export const rewardActivities = [
  { id: 'ra-001', type: 'save' as const, description: 'Saved Velvet Noir recipe', points: 5, date: '2026-03-17' },
  { id: 'ra-002', type: 'attend' as const, description: 'RSVP\'d to Craft Cocktail Showdown', points: 15, date: '2026-03-16' },
  { id: 'ra-003', type: 'share' as const, description: 'Shared Midnight Mule to Pour Circle', points: 10, date: '2026-03-15' },
  { id: 'ra-004', type: 'plan' as const, description: 'Completed "The Wandering Bar Crawl" nudge', points: 25, date: '2026-03-14' },
  { id: 'ra-005', type: 'social' as const, description: 'Made a connection in Pour Circle', points: 5, date: '2026-03-13' },
];

export const REWARD_TIERS = {
  bronze: { min: 0, max: 299, label: 'Bronze', color: '#CD7F32', perks: ['Early access to new pours', 'Weekly Nudge email'] },
  silver: { min: 300, max: 999, label: 'Silver', color: '#C0C0C0', perks: ['Bronze perks', 'Monthly surprise recipe', 'Circle badge'] },
  gold: { min: 1000, max: Infinity, label: 'Gold', color: '#FFD700', perks: ['Silver perks', 'Exclusive ambassador invites', 'VIP event access', 'Priority support'] },
};
