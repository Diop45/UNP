import React from 'react';
import { Link } from 'react-router-dom';
import { MapPin, Clock, Users, DollarSign, Star } from 'lucide-react';
import type { Event } from '../types';

interface EventCardProps {
  event: Event;
  compact?: boolean;
}

const TIME_SLOT_COLORS = {
  day: 'text-yellow-400 bg-yellow-500/10 border-yellow-500/20',
  night: 'text-blue-400 bg-blue-500/10 border-blue-500/20',
  'late-night': 'text-purple-400 bg-purple-500/10 border-purple-500/20',
};

const TIME_SLOT_LABELS = {
  day: 'Day',
  night: 'Night',
  'late-night': 'Late Night',
};

export const EventCard: React.FC<EventCardProps> = ({ event, compact = false }) => {
  return (
    <Link
      to={`/explore/${event.id}`}
      className="group relative flex flex-col rounded-2xl border border-white/5 bg-[#1A1628] overflow-hidden card-hover transition-all"
    >
      <div className="relative overflow-hidden" style={{ height: compact ? '130px' : '170px' }}>
        <img
          src={event.image}
          alt={event.title}
          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-[#1A1628] via-transparent to-transparent" />

        <div className="absolute top-2 left-2 flex gap-1.5">
          <span className={`text-[10px] px-2 py-0.5 rounded-full border font-semibold ${TIME_SLOT_COLORS[event.timeSlot]}`}>
            {TIME_SLOT_LABELS[event.timeSlot]}
          </span>
          {event.isPremium && (
            <span className="text-[10px] px-2 py-0.5 rounded-full bg-amber-500/20 border border-amber-500/30 text-amber-400 font-semibold flex items-center gap-1">
              <Star size={8} /> PRO
            </span>
          )}
        </div>

        {event.price && (
          <div className="absolute bottom-2 right-2 flex items-center gap-1 text-xs font-semibold text-white bg-black/60 rounded-full px-2 py-0.5">
            <DollarSign size={10} />
            {event.price}
          </div>
        )}
      </div>

      <div className="p-3 flex flex-col gap-1.5">
        <h3 className="text-white font-semibold text-sm leading-tight">{event.title}</h3>
        {!compact && (
          <p className="text-gray-400 text-xs leading-relaxed line-clamp-2">{event.description}</p>
        )}
        <div className="flex items-center gap-1 text-xs text-gray-500 mt-1">
          <MapPin size={10} />
          <span className="truncate">{event.venue.name}</span>
        </div>
        <div className="flex items-center justify-between text-xs text-gray-500">
          <span className="flex items-center gap-1"><Clock size={10} /> {event.startTime}</span>
          <span className="flex items-center gap-1"><Users size={10} /> {event.attendees} going</span>
        </div>
      </div>
    </Link>
  );
};
