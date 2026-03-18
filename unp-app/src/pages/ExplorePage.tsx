import React, { useState } from 'react';
import { Search, Map as MapIcon, List, HelpCircle } from 'lucide-react';
import { EventCard } from '../components/EventCard';
import { useApp } from '../context/AppContext';
import { events, searchEvents } from '../data/events';
import type { TimeSlot } from '../types';

const TIME_FILTERS: { value: TimeSlot | 'all'; label: string; emoji: string }[] = [
  { value: 'all', label: 'All', emoji: '🌐' },
  { value: 'day', label: 'Day', emoji: '☀️' },
  { value: 'night', label: 'Night', emoji: '🌙' },
  { value: 'late-night', label: 'Late Night', emoji: '🌃' },
];

// Simple map placeholder
const MapView: React.FC<{ filteredIds: string[] }> = ({ filteredIds }) => {
  const filtered = events.filter(e => filteredIds.includes(e.id));
  return (
    <div className="relative bg-[#0f0c18] rounded-2xl border border-white/10 overflow-hidden" style={{ height: '380px' }}>
      {/* Fake map grid */}
      <div className="absolute inset-0 opacity-10"
        style={{
          backgroundImage: 'linear-gradient(rgba(245,158,11,0.3) 1px, transparent 1px), linear-gradient(90deg, rgba(245,158,11,0.3) 1px, transparent 1px)',
          backgroundSize: '40px 40px',
        }}
      />
      <div className="absolute inset-0 flex items-center justify-center">
        <div className="text-center">
          <MapIcon size={32} className="text-amber-400/40 mx-auto mb-2" />
          <p className="text-gray-600 text-xs">Interactive map — {filtered.length} events</p>
        </div>
      </div>
      {/* Event pins */}
      {filtered.map((evt, i) => (
        <div
          key={evt.id}
          className="absolute flex flex-col items-center gap-1 cursor-pointer group"
          style={{
            left: `${15 + (i * 18) % 70}%`,
            top: `${20 + (i * 13) % 60}%`,
          }}
        >
          <div className={`w-8 h-8 rounded-full border-2 overflow-hidden transition-transform group-hover:scale-125 ${
            evt.timeSlot === 'day' ? 'border-yellow-400' :
            evt.timeSlot === 'night' ? 'border-blue-400' : 'border-purple-400'
          }`}>
            <img src={evt.image} alt={evt.title} className="w-full h-full object-cover" />
          </div>
          <div className="opacity-0 group-hover:opacity-100 transition-opacity absolute bottom-full mb-1 w-32 z-10">
            <div className="bg-black/90 border border-white/10 rounded-lg p-2 text-center">
              <p className="text-white text-[10px] font-medium leading-tight">{evt.title}</p>
              <p className="text-gray-400 text-[9px]">{evt.venue.name}</p>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
};

export const ExplorePage: React.FC = () => {
  const { startTour } = useApp();
  const [query, setQuery] = useState('');
  const [timeFilter, setTimeFilter] = useState<TimeSlot | 'all'>('all');
  const [viewMode, setViewMode] = useState<'list' | 'map'>('list');

  const filtered = (query ? searchEvents(query) : events).filter(e => {
    if (timeFilter !== 'all' && e.timeSlot !== timeFilter) return false;
    return true;
  });

  return (
    <div className="min-h-screen px-4 pt-6 pb-10">
      {/* Header */}
      <div className="flex items-start justify-between mb-4">
        <div>
          <h1 className="text-2xl font-bold text-white">Explore</h1>
          <p className="text-gray-400 text-sm mt-1">Events & venues near you</p>
        </div>
        <button onClick={() => startTour('explore')} className="text-gray-500 hover:text-amber-400 transition-colors">
          <HelpCircle size={20} />
        </button>
      </div>

      {/* Search */}
      <div className="relative mb-4">
        <Search size={16} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500" />
        <input
          type="text"
          placeholder="Search events, venues..."
          value={query}
          onChange={e => setQuery(e.target.value)}
          className="w-full bg-[#1A1628] border border-white/10 rounded-xl pl-9 pr-4 py-2.5 text-sm text-white placeholder-gray-500 focus:outline-none focus:border-blue-500/50 transition-colors"
        />
      </div>

      {/* Filters row */}
      <div className="flex items-center justify-between mb-4">
        <div className="flex gap-2 overflow-x-auto">
          {TIME_FILTERS.map(f => (
            <button
              key={f.value}
              onClick={() => setTimeFilter(f.value)}
              className={`shrink-0 flex items-center gap-1.5 px-3 py-1.5 rounded-full text-xs font-medium border transition-colors ${
                timeFilter === f.value
                  ? 'bg-blue-500 border-blue-500 text-white'
                  : 'bg-white/5 border-white/10 text-gray-400 hover:border-white/20'
              }`}
            >
              <span>{f.emoji}</span>
              {f.label}
            </button>
          ))}
        </div>
        <div className="flex items-center gap-1 ml-2 shrink-0 bg-white/5 rounded-full border border-white/10 p-0.5">
          <button
            onClick={() => setViewMode('list')}
            className={`p-1.5 rounded-full transition-colors ${viewMode === 'list' ? 'bg-white/10 text-white' : 'text-gray-500'}`}
          >
            <List size={14} />
          </button>
          <button
            onClick={() => setViewMode('map')}
            className={`p-1.5 rounded-full transition-colors ${viewMode === 'map' ? 'bg-white/10 text-white' : 'text-gray-500'}`}
          >
            <MapIcon size={14} />
          </button>
        </div>
      </div>

      {/* Map view */}
      {viewMode === 'map' && (
        <div className="mb-5">
          <MapView filteredIds={filtered.map(e => e.id)} />
        </div>
      )}

      {/* Count */}
      <p className="text-gray-500 text-xs mb-3">{filtered.length} events found</p>

      {/* Event grid */}
      {filtered.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-16 text-center">
          <div className="text-4xl mb-3">🗺️</div>
          <p className="text-gray-400 text-sm">No events found.</p>
          <button onClick={() => { setQuery(''); setTimeFilter('all'); }} className="text-blue-400 text-xs mt-2">
            Clear filters
          </button>
        </div>
      ) : (
        <div className="grid grid-cols-2 gap-3">
          {filtered.map(e => (
            <EventCard key={e.id} event={e} />
          ))}
        </div>
      )}
    </div>
  );
};
