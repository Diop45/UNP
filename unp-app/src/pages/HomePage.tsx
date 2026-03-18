import React from 'react';
import { Link } from 'react-router-dom';
import { Compass, HelpCircle, ArrowRight, Zap } from 'lucide-react';
import { HeroCard } from '../components/HeroCard';
import { BeverageCard } from '../components/BeverageCard';
import { EventCard } from '../components/EventCard';
import { useApp } from '../context/AppContext';
import { beverages, getFeaturedBeverage } from '../data/beverages';
import { events, getFeaturedEvent } from '../data/events';
import { nudges } from '../data/nudges';

export const HomePage: React.FC = () => {
  const { user, startTour } = useApp();
  const featuredBev = getFeaturedBeverage();
  const featuredEvt = getFeaturedEvent();
  const featuredNudge = nudges[0];

  return (
    <div className="min-h-screen">
      {/* Hero section */}
      <section className="relative px-4 pt-8 pb-6">
        <div className="absolute inset-0 bg-gradient-to-b from-amber-500/5 to-transparent pointer-events-none" />
        <div className="flex items-start justify-between mb-2">
          <div>
            <p className="text-gray-400 text-sm">
              {user ? `Good evening, ${user.name.split(' ')[0]} 👋` : 'Good evening 👋'}
            </p>
            <h1 className="text-2xl font-bold text-white mt-1">
              Your Next <span className="text-gradient">Pour</span>
            </h1>
          </div>
          <button
            onClick={() => startTour('home')}
            className="text-gray-500 hover:text-amber-400 transition-colors p-1"
            title="Start tour"
          >
            <HelpCircle size={20} />
          </button>
        </div>
        <p className="text-gray-400 text-sm max-w-xs">
          Beverages, micro-adventures, and events — all in one place.
        </p>
      </section>

      {/* Three Hero Cards */}
      <section className="px-4 pb-6">
        <div className="grid grid-cols-1 gap-4">
          <HeroCard
            to={`/pour/${featuredBev.id}`}
            label="Beverage of the Day"
            title={featuredBev.name}
            subtitle={featuredBev.description}
            image={featuredBev.image}
            accent="amber"
            badge={featuredBev.isPremium ? 'PRO' : 'Free'}
          />
          <div className="grid grid-cols-2 gap-4">
            <HeroCard
              to="/nudge"
              label="Tonight's Nudge"
              title={featuredNudge.title.replace("Tonight's Nudge: ", '')}
              subtitle={featuredNudge.tagline}
              image={featuredNudge.image}
              accent="purple"
            />
            <HeroCard
              to="/explore"
              label="Events Near You"
              title={featuredEvt.title}
              subtitle={featuredEvt.venue.name}
              image={featuredEvt.image}
              accent="blue"
              badge={featuredEvt.price ?? undefined}
            />
          </div>
        </div>
      </section>

      {/* Quick access tiles */}
      <section className="px-4 pb-6">
        <div className="flex items-center justify-between mb-3">
          <h2 className="text-white font-semibold text-base">Quick Pour</h2>
          <Link to="/pour" className="text-amber-400 text-xs flex items-center gap-1 hover:text-amber-300">
            See all <ArrowRight size={12} />
          </Link>
        </div>
        <div className="grid grid-cols-2 gap-3">
          {beverages.slice(0, 4).map(b => (
            <BeverageCard key={b.id} beverage={b} compact />
          ))}
        </div>
      </section>

      {/* Nudge preview */}
      <section className="px-4 pb-6">
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-2">
            <Zap size={16} className="text-purple-400" />
            <h2 className="text-white font-semibold text-base">Tonight's Nudge</h2>
          </div>
          <Link to="/nudge" className="text-purple-400 text-xs flex items-center gap-1 hover:text-purple-300">
            All nudges <ArrowRight size={12} />
          </Link>
        </div>
        <div className="rounded-2xl border border-purple-500/20 bg-[#1A1628] overflow-hidden">
          <div className="relative h-36 overflow-hidden">
            <img src={featuredNudge.image} alt={featuredNudge.title} className="w-full h-full object-cover" />
            <div className="absolute inset-0 bg-gradient-to-t from-[#1A1628] via-purple-900/20 to-transparent" />
          </div>
          <div className="p-4">
            <h3 className="text-white font-bold text-sm">{featuredNudge.title}</h3>
            <p className="text-gray-400 text-xs mt-1 line-clamp-2">{featuredNudge.description}</p>
            <div className="flex items-center gap-3 mt-3">
              <Link
                to={`/nudge/${featuredNudge.id}`}
                className="flex-1 text-center py-2 rounded-xl bg-purple-500/20 border border-purple-500/30 text-purple-400 text-xs font-semibold hover:bg-purple-500/30 transition-colors"
              >
                View Nudge
              </Link>
              {featuredNudge.poll && (
                <Link
                  to={`/nudge/${featuredNudge.id}#poll`}
                  className="flex-1 text-center py-2 rounded-xl bg-white/5 border border-white/10 text-gray-300 text-xs font-semibold hover:bg-white/10 transition-colors"
                >
                  Take Poll
                </Link>
              )}
            </div>
          </div>
        </div>
      </section>

      {/* Events preview */}
      <section className="px-4 pb-8">
        <div className="flex items-center justify-between mb-3">
          <div className="flex items-center gap-2">
            <Compass size={16} className="text-blue-400" />
            <h2 className="text-white font-semibold text-base">Events Near You</h2>
          </div>
          <Link to="/explore" className="text-blue-400 text-xs flex items-center gap-1 hover:text-blue-300">
            See all <ArrowRight size={12} />
          </Link>
        </div>
        <div className="grid grid-cols-2 gap-3">
          {events.slice(0, 4).map(e => (
            <EventCard key={e.id} event={e} compact />
          ))}
        </div>
      </section>

      {/* CTA for non-users */}
      {!user && (
        <section className="px-4 pb-10">
          <div className="rounded-2xl border border-amber-500/20 bg-gradient-to-br from-amber-500/10 to-transparent p-6 text-center">
            <h3 className="text-white font-bold text-lg mb-2">Unlock the Full Pour</h3>
            <p className="text-gray-400 text-sm mb-4">
              Create your free account to save recipes, join Pour Circle, and unlock personalized adventures.
            </p>
            <Link
              to="/onboarding"
              className="inline-flex items-center gap-2 px-6 py-2.5 rounded-full bg-gradient-to-r from-amber-600 to-amber-400 text-black font-bold text-sm hover:opacity-90 transition-opacity"
            >
              Get Started Free <ArrowRight size={14} />
            </Link>
          </div>
        </section>
      )}
    </div>
  );
};
