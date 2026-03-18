import React from 'react';
import { X, ArrowRight } from 'lucide-react';
import { useApp } from '../context/AppContext';

interface TourStep {
  title: string;
  description: string;
  position?: 'top' | 'center' | 'bottom';
}

const TOUR_CONTENT: Record<string, TourStep[]> = {
  home: [
    { title: 'Welcome to Until The Next Pour', description: 'Your nightlife companion. Discover beverages, plan adventures, and find events near you.', position: 'center' },
    { title: 'Beverage of the Day', description: 'Each day a new featured drink. Tap the card to see the full recipe and pour technique.', position: 'top' },
    { title: 'Tonight\'s Nudge', description: 'A curated micro-adventure for your evening. Free users get previews; Pro unlocks personalized 3-step plans.', position: 'top' },
    { title: 'Events Near You', description: 'Real-time events, from craft cocktail competitions to late-night speakeasies. Filter by Day, Night, or Late Night.', position: 'top' },
    { title: 'Bottom Navigation', description: 'Home → Explore → Pour → Circles → Profile. Everything is one tap away.', position: 'bottom' },
  ],
  pour: [
    { title: 'Pour — Your Beverage Library', description: 'Browse, search, and save recipes. Free users get previews; Pro unlocks full instructions and pairings.', position: 'center' },
    { title: 'Search & Discover', description: 'Search by name, category, mood, or ingredient. Similar beverages recommended automatically.', position: 'top' },
    { title: 'Save Pour Cards', description: 'Heart any beverage to save it. Access all saved pours from your Profile.', position: 'top' },
    { title: 'Ambassador Uploads', description: 'Recipes marked with AMB are verified Ambassador creations. Look for the purple badge.', position: 'top' },
  ],
  explore: [
    { title: 'Explore — Events & Venues', description: 'Find what\'s happening tonight. Filter by time of day and explore on the map or list view.', position: 'center' },
    { title: 'Time Filters', description: 'Day, Night, Late Night — filter events by when you\'re going out.', position: 'top' },
    { title: 'Event Details', description: 'Pro users unlock how-to-attend info, cross-links to beverages, and engagement actions.', position: 'top' },
  ],
  circle: [
    { title: 'Pour Circle — Your Social Layer', description: 'See what your community is pouring, attending, and planning. Join circles by interest.', position: 'center' },
    { title: 'Share Your Pour', description: 'Post a beverage photo, check into an event, or share a completed Nudge adventure.', position: 'top' },
    { title: 'Private Circles', description: 'Pro users can join and create private circles with planning tools and rewards display.', position: 'top' },
    { title: 'Perks & Promos', description: 'Pro members get exclusive promos shared through Pour Circle. Keep an eye on pinned posts.', position: 'top' },
  ],
};

export const TourOverlay: React.FC = () => {
  const { activeTour, tourStep, nextTourStep, endTour } = useApp();

  if (!activeTour || tourStep === null) return null;

  const steps = TOUR_CONTENT[activeTour] ?? [];
  const step = steps[tourStep];
  if (!step) return null;

  const total = steps.length;
  const positionClass = step.position === 'bottom'
    ? 'bottom-24 left-4 right-4'
    : step.position === 'top'
    ? 'top-20 left-4 right-4'
    : 'top-1/2 left-4 right-4 -translate-y-1/2';

  return (
    <div className="fixed inset-0 z-50 pointer-events-none">
      <div className="absolute inset-0 bg-black/60 pointer-events-auto" onClick={endTour} />
      <div className={`absolute ${positionClass} pointer-events-auto`}>
        <div className="glass rounded-2xl border border-amber-500/30 p-5 shadow-2xl">
          <div className="flex items-start justify-between mb-3">
            <div className="flex items-center gap-2">
              {Array.from({ length: total }).map((_, i) => (
                <div
                  key={i}
                  className={`h-1.5 rounded-full transition-all ${
                    i === tourStep ? 'w-6 bg-amber-400' : i < tourStep ? 'w-3 bg-amber-600' : 'w-3 bg-gray-600'
                  }`}
                />
              ))}
            </div>
            <button onClick={endTour} className="text-gray-400 hover:text-white transition-colors p-1">
              <X size={16} />
            </button>
          </div>
          <h3 className="text-white font-bold text-base mb-2">{step.title}</h3>
          <p className="text-gray-300 text-sm leading-relaxed mb-4">{step.description}</p>
          <div className="flex items-center justify-between">
            <span className="text-gray-500 text-xs">{tourStep + 1} of {total}</span>
            <button
              onClick={nextTourStep}
              className="flex items-center gap-2 px-4 py-2 rounded-full bg-amber-500 text-black font-semibold text-sm hover:bg-amber-400 transition-colors"
            >
              {tourStep < total - 1 ? (
                <>Next <ArrowRight size={14} /></>
              ) : (
                'Done!'
              )}
            </button>
          </div>
        </div>
      </div>
    </div>
  );
};
