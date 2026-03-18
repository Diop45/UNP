import React, { useState } from 'react';
import { Search, Filter, Upload, HelpCircle } from 'lucide-react';
import { BeverageCard } from '../components/BeverageCard';
import { useApp } from '../context/AppContext';
import { beverages, searchBeverages } from '../data/beverages';
import type { BeverageCategory } from '../types';
import { Link } from 'react-router-dom';

const CATEGORIES: { value: BeverageCategory | 'all'; label: string }[] = [
  { value: 'all', label: 'All' },
  { value: 'cocktail', label: 'Cocktails' },
  { value: 'mocktail', label: 'Mocktails' },
  { value: 'wine', label: 'Wine' },
  { value: 'spirit', label: 'Spirits' },
  { value: 'beer', label: 'Beer' },
  { value: 'shot', label: 'Shots' },
];

export const PourPage: React.FC = () => {
  const { user, startTour } = useApp();
  const [query, setQuery] = useState('');
  const [category, setCategory] = useState<BeverageCategory | 'all'>('all');
  const [showPremiumOnly, setShowPremiumOnly] = useState(false);

  const filtered = (query ? searchBeverages(query) : beverages).filter(b => {
    if (category !== 'all' && b.category !== category) return false;
    if (showPremiumOnly && !b.isPremium) return false;
    return true;
  });

  const isAmbassador = user?.role === 'ambassador';

  return (
    <div className="min-h-screen px-4 pt-6 pb-8">
      {/* Header */}
      <div className="flex items-start justify-between mb-4">
        <div>
          <h1 className="text-2xl font-bold text-white">Pour</h1>
          <p className="text-gray-400 text-sm mt-1">Recipes, pour cards & beverage discovery</p>
        </div>
        <div className="flex items-center gap-2">
          {isAmbassador && (
            <Link
              to="/pour/upload"
              className="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-purple-500/20 border border-purple-500/30 text-purple-400 text-xs font-semibold hover:bg-purple-500/30 transition-colors"
            >
              <Upload size={12} /> Upload
            </Link>
          )}
          <button
            onClick={() => startTour('pour')}
            className="text-gray-500 hover:text-amber-400 transition-colors"
          >
            <HelpCircle size={20} />
          </button>
        </div>
      </div>

      {/* Search */}
      <div className="relative mb-4">
        <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500" />
        <input
          type="text"
          placeholder="Search beverages, ingredients, moods..."
          value={query}
          onChange={e => setQuery(e.target.value)}
          className="w-full bg-[#1A1628] border border-white/10 rounded-xl pl-9 pr-4 py-2.5 text-sm text-white placeholder-gray-500 focus:outline-none focus:border-amber-500/50 transition-colors"
        />
        {query && (
          <button
            onClick={() => setQuery('')}
            className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-white"
          >
            ×
          </button>
        )}
      </div>

      {/* Category filter */}
      <div className="flex gap-2 overflow-x-auto pb-3 mb-4 no-scrollbar">
        {CATEGORIES.map(c => (
          <button
            key={c.value}
            onClick={() => setCategory(c.value)}
            className={`shrink-0 px-3 py-1.5 rounded-full text-xs font-medium border transition-colors ${
              category === c.value
                ? 'bg-amber-500 border-amber-500 text-black'
                : 'bg-white/5 border-white/10 text-gray-400 hover:border-white/20'
            }`}
          >
            {c.label}
          </button>
        ))}
        <button
          onClick={() => setShowPremiumOnly(v => !v)}
          className={`shrink-0 flex items-center gap-1 px-3 py-1.5 rounded-full text-xs font-medium border transition-colors ${
            showPremiumOnly
              ? 'bg-amber-500/20 border-amber-500/50 text-amber-400'
              : 'bg-white/5 border-white/10 text-gray-400 hover:border-white/20'
          }`}
        >
          <Filter size={10} /> Pro Only
        </button>
      </div>

      {/* Results */}
      {filtered.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-16 text-center">
          <div className="text-4xl mb-3">🍹</div>
          <p className="text-gray-400 text-sm">No beverages found.</p>
          <button onClick={() => { setQuery(''); setCategory('all'); }} className="text-amber-400 text-xs mt-2">
            Clear filters
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-2 gap-3">
          {filtered.map(b => (
            <BeverageCard key={b.id} beverage={b} />
          ))}
        </div>
      )}

      {/* Ambassador upload promo */}
      {!isAmbassador && (
        <div className="mt-6 rounded-2xl border border-purple-500/20 bg-purple-500/5 p-4 text-center">
          <p className="text-purple-400 font-semibold text-sm mb-1">Become a Beverage Ambassador</p>
          <p className="text-gray-400 text-xs mb-3">Upload your recipes, build your portfolio, and grow your audience on UNP.</p>
          <Link
            to="/profile?ambassador=1"
            className="inline-flex items-center gap-1.5 px-4 py-2 rounded-full bg-purple-500/20 border border-purple-500/30 text-purple-400 text-xs font-semibold hover:bg-purple-500/30 transition-colors"
          >
            <Upload size={12} /> Apply as Ambassador
          </Link>
        </div>
      )}
    </div>
  );
};
