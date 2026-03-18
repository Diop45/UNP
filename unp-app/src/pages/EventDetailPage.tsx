import React from 'react';
import { useParams, Link } from 'react-router-dom';
import { ArrowLeft, MapPin, Clock, Users, DollarSign, Share2, CalendarPlus } from 'lucide-react';
import { FeatureGate } from '../components/FeatureGate';
import { BeverageCard } from '../components/BeverageCard';
import { getEventById } from '../data/events';
import { getBeverageById } from '../data/beverages';

const TIME_SLOT_STYLES = {
  day: { bg: 'bg-yellow-500/10 border-yellow-500/20', text: 'text-yellow-400', label: '☀️ Day' },
  night: { bg: 'bg-blue-500/10 border-blue-500/20', text: 'text-blue-400', label: '🌙 Night' },
  'late-night': { bg: 'bg-purple-500/10 border-purple-500/20', text: 'text-purple-400', label: '🌃 Late Night' },
};

export const EventDetailPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const event = getEventById(id ?? '');

  if (!event) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen px-4 text-center">
        <p className="text-gray-400 mb-3">Event not found.</p>
        <Link to="/explore" className="text-blue-400 text-sm">← Back to Explore</Link>
      </div>
    );
  }

  const ts = TIME_SLOT_STYLES[event.timeSlot];
  const relBevs = event.relatedBeverageIds.map(id => getBeverageById(id)).filter(Boolean) as ReturnType<typeof getBeverageById>[];

  return (
    <div className="min-h-screen">
      {/* Hero */}
      <div className="relative h-72 overflow-hidden">
        <img src={event.image} alt={event.title} className="w-full h-full object-cover" />
        <div className="absolute inset-0 bg-gradient-to-t from-[#0D0A14] via-transparent to-transparent" />
        <div className="absolute top-4 left-4 right-4 flex items-center justify-between">
          <Link to="/explore" className="w-9 h-9 rounded-full bg-black/60 border border-white/10 flex items-center justify-center">
            <ArrowLeft size={16} className="text-white" />
          </Link>
          <button className="w-9 h-9 rounded-full bg-black/60 border border-white/10 flex items-center justify-center">
            <Share2 size={16} className="text-white" />
          </button>
        </div>
        <div className="absolute bottom-4 left-4 flex gap-2">
          <span className={`text-[10px] px-2.5 py-1 rounded-full border font-semibold ${ts.bg} ${ts.text}`}>
            {ts.label}
          </span>
          {event.isPremium && (
            <span className="text-[10px] px-2.5 py-1 rounded-full bg-amber-500/20 border border-amber-500/30 text-amber-400 font-semibold">
              PRO Details
            </span>
          )}
        </div>
      </div>

      <div className="px-4 pt-4 pb-10">
        <h1 className="text-2xl font-bold text-white mb-1">{event.title}</h1>
        <p className="text-gray-300 text-sm leading-relaxed mb-4">{event.description}</p>

        {/* Event meta */}
        <div className="grid grid-cols-2 gap-3 mb-6">
          <div className="flex items-start gap-2.5 p-3 rounded-xl bg-white/5 border border-white/5">
            <MapPin size={14} className="text-blue-400 mt-0.5 shrink-0" />
            <div>
              <p className="text-white text-xs font-medium">{event.venue.name}</p>
              <p className="text-gray-500 text-[10px] mt-0.5">{event.venue.address}</p>
            </div>
          </div>
          <div className="flex items-start gap-2.5 p-3 rounded-xl bg-white/5 border border-white/5">
            <Clock size={14} className="text-amber-400 mt-0.5 shrink-0" />
            <div>
              <p className="text-white text-xs font-medium">{event.date}</p>
              <p className="text-gray-500 text-[10px] mt-0.5">{event.startTime} – {event.endTime}</p>
            </div>
          </div>
          <div className="flex items-start gap-2.5 p-3 rounded-xl bg-white/5 border border-white/5">
            <Users size={14} className="text-green-400 mt-0.5 shrink-0" />
            <div>
              <p className="text-white text-xs font-medium">{event.attendees} going</p>
              <p className="text-gray-500 text-[10px] mt-0.5">Attendees</p>
            </div>
          </div>
          <div className="flex items-start gap-2.5 p-3 rounded-xl bg-white/5 border border-white/5">
            <DollarSign size={14} className="text-amber-400 mt-0.5 shrink-0" />
            <div>
              <p className="text-white text-xs font-medium">{event.price ?? 'Free'}</p>
              <p className="text-gray-500 text-[10px] mt-0.5">Entry price</p>
            </div>
          </div>
        </div>

        {/* Tags */}
        <div className="flex flex-wrap gap-1.5 mb-6">
          {event.tags.map(t => (
            <span key={t} className="text-[10px] px-2.5 py-1 rounded-full bg-white/5 border border-white/10 text-gray-400">#{t}</span>
          ))}
        </div>

        {/* How to Attend — paid gated */}
        <section className="mb-6">
          <h2 className="text-white font-bold text-lg mb-3">How to Attend</h2>
          {event.isPremium ? (
            <FeatureGate
              requiredRole="paid"
              label="Pro Event Details"
              description="Upgrade to see how to attend, venue tips, and engagement actions"
              preview={
                <div className="p-4 rounded-xl bg-white/5 border border-white/5">
                  <p className="text-gray-400 text-sm blur-sm select-none">
                    {event.howToAttend?.slice(0, 60)}...
                  </p>
                </div>
              }
            />
          ) : (
            <div className="p-4 rounded-xl bg-white/5 border border-white/5">
              <p className="text-gray-300 text-sm leading-relaxed">{event.howToAttend}</p>
            </div>
          )}
        </section>

        {/* Actions */}
        <div className="flex gap-3 mb-8">
          <button className="flex-1 flex items-center justify-center gap-2 py-3 rounded-xl bg-blue-500/20 border border-blue-500/30 text-blue-400 text-sm font-semibold hover:bg-blue-500/30 transition-colors">
            <CalendarPlus size={16} /> RSVP
          </button>
          <button className="flex-1 flex items-center justify-center gap-2 py-3 rounded-xl bg-white/5 border border-white/10 text-gray-300 text-sm font-semibold hover:bg-white/10 transition-colors">
            <Share2 size={16} /> Share
          </button>
        </div>

        {/* Related beverages */}
        {relBevs.length > 0 && (
          <section>
            <h2 className="text-white font-bold text-lg mb-3">Pours for This Night</h2>
            <div className="grid grid-cols-2 gap-3">
              {relBevs.map(b => b && <BeverageCard key={b.id} beverage={b} compact />)}
            </div>
          </section>
        )}
      </div>
    </div>
  );
};
