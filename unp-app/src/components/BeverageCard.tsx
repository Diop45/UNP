import React from 'react';
import { Link } from 'react-router-dom';
import { Heart, Bookmark, Clock, Star, Shield } from 'lucide-react';
import type { Beverage } from '../types';
import { useApp } from '../context/AppContext';

interface BeverageCardProps {
  beverage: Beverage;
  compact?: boolean;
}

export const BeverageCard: React.FC<BeverageCardProps> = ({ beverage, compact = false }) => {
  const { savedBeverageIds, toggleSaveBeverage } = useApp();
  const isSaved = savedBeverageIds.includes(beverage.id);

  const handleSave = (e: React.MouseEvent) => {
    e.preventDefault();
    e.stopPropagation();
    toggleSaveBeverage(beverage.id);
  };

  const difficultyColor = {
    easy: 'text-green-400',
    medium: 'text-amber-400',
    hard: 'text-red-400',
  }[beverage.difficulty];

  return (
    <Link
      to={`/pour/${beverage.id}`}
      className="group relative flex flex-col rounded-2xl border border-white/5 bg-[#1A1628] overflow-hidden card-hover transition-all"
    >
      <div className="relative overflow-hidden" style={{ height: compact ? '140px' : '180px' }}>
        <img
          src={beverage.image}
          alt={beverage.name}
          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-[#1A1628] via-transparent to-transparent" />

        {/* Badges */}
        <div className="absolute top-2 left-2 flex gap-1.5">
          {beverage.isPremium && (
            <span className="text-[10px] px-2 py-0.5 rounded-full bg-amber-500/20 border border-amber-500/30 text-amber-400 font-semibold flex items-center gap-1">
              <Star size={8} /> PRO
            </span>
          )}
          {beverage.uploadedBy && (
            <span className="text-[10px] px-2 py-0.5 rounded-full bg-purple-500/20 border border-purple-500/30 text-purple-400 font-semibold flex items-center gap-1">
              <Shield size={8} /> AMB
            </span>
          )}
        </div>

        {/* Save button */}
        <button
          onClick={handleSave}
          className="absolute top-2 right-2 w-7 h-7 rounded-full bg-black/50 border border-white/10 flex items-center justify-center hover:bg-black/70 transition-colors"
        >
          <Bookmark
            size={13}
            className={isSaved ? 'text-amber-400 fill-amber-400' : 'text-white/70'}
          />
        </button>
      </div>

      <div className="p-3 flex flex-col gap-1.5">
        <div className="flex items-start justify-between gap-2">
          <h3 className="text-white font-semibold text-sm leading-tight">{beverage.name}</h3>
          <span className="text-xs text-gray-500 capitalize shrink-0">{beverage.category}</span>
        </div>
        {!compact && (
          <p className="text-gray-400 text-xs leading-relaxed line-clamp-2">{beverage.description}</p>
        )}
        <div className="flex items-center justify-between mt-1">
          <div className="flex items-center gap-3 text-xs text-gray-500">
            <span className="flex items-center gap-1"><Clock size={10} /> {beverage.prepTime}m</span>
            <span className={`capitalize ${difficultyColor}`}>{beverage.difficulty}</span>
          </div>
          <div className="flex items-center gap-1 text-xs text-gray-500">
            <Heart size={10} />
            <span>{beverage.likes}</span>
          </div>
        </div>
      </div>
    </Link>
  );
};
