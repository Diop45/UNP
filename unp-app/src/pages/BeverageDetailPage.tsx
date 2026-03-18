import React from 'react';
import { useParams, Link } from 'react-router-dom';
import { ArrowLeft, Bookmark, Share2, Clock, Star, Shield, Heart, ChevronRight } from 'lucide-react';
import { FeatureGate } from '../components/FeatureGate';
import { BeverageCard } from '../components/BeverageCard';
import { useApp } from '../context/AppContext';
import { getBeverageById, beverages } from '../data/beverages';

export const BeverageDetailPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const { savedBeverageIds, toggleSaveBeverage } = useApp();
  const bev = getBeverageById(id ?? '');

  if (!bev) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen px-4 text-center">
        <p className="text-gray-400 mb-3">Beverage not found.</p>
        <Link to="/pour" className="text-amber-400 text-sm">← Back to Pour</Link>
      </div>
    );
  }

  const isSaved = savedBeverageIds.includes(bev.id);
  const similar = bev.similarIds.map(sid => beverages.find(b => b.id === sid)).filter(Boolean) as typeof beverages;
  const difficultyColor = { easy: 'text-green-400', medium: 'text-amber-400', hard: 'text-red-400' }[bev.difficulty];

  return (
    <div className="min-h-screen">
      {/* Hero image */}
      <div className="relative h-72 overflow-hidden">
        <img src={bev.image} alt={bev.name} className="w-full h-full object-cover" />
        <div className="absolute inset-0 bg-gradient-to-t from-[#0D0A14] via-transparent to-transparent" />
        <div className="absolute top-4 left-4 right-4 flex items-center justify-between">
          <Link to="/pour" className="w-9 h-9 rounded-full bg-black/60 border border-white/10 flex items-center justify-center">
            <ArrowLeft size={16} className="text-white" />
          </Link>
          <div className="flex items-center gap-2">
            <button
              onClick={() => toggleSaveBeverage(bev.id)}
              className="w-9 h-9 rounded-full bg-black/60 border border-white/10 flex items-center justify-center"
            >
              <Bookmark size={16} className={isSaved ? 'text-amber-400 fill-amber-400' : 'text-white'} />
            </button>
            <button className="w-9 h-9 rounded-full bg-black/60 border border-white/10 flex items-center justify-center">
              <Share2 size={16} className="text-white" />
            </button>
          </div>
        </div>
        {/* Badges on image */}
        <div className="absolute bottom-4 left-4 flex gap-2">
          {bev.isPremium && (
            <span className="flex items-center gap-1 text-xs px-2.5 py-1 rounded-full bg-amber-500/30 border border-amber-500/50 text-amber-300 font-semibold">
              <Star size={10} /> PRO
            </span>
          )}
          {bev.uploadedBy && (
            <span className="flex items-center gap-1 text-xs px-2.5 py-1 rounded-full bg-purple-500/30 border border-purple-500/50 text-purple-300 font-semibold">
              <Shield size={10} /> Ambassador Recipe
            </span>
          )}
        </div>
      </div>

      {/* Content */}
      <div className="px-4 pt-4 pb-8">
        <div className="flex items-start justify-between gap-3 mb-3">
          <h1 className="text-2xl font-bold text-white leading-tight">{bev.name}</h1>
          <span className="shrink-0 text-xs capitalize text-gray-400 bg-white/5 border border-white/10 px-2.5 py-1 rounded-full">
            {bev.category}
          </span>
        </div>

        <p className="text-gray-300 text-sm leading-relaxed mb-4">{bev.description}</p>

        {/* Stats row */}
        <div className="flex items-center gap-4 pb-4 border-b border-white/5 mb-4">
          <div className="flex items-center gap-1.5 text-sm">
            <Clock size={14} className="text-gray-500" />
            <span className="text-gray-300">{bev.prepTime} min</span>
          </div>
          <div className={`text-sm capitalize font-medium ${difficultyColor}`}>{bev.difficulty}</div>
          <div className="flex items-center gap-1.5 text-sm">
            <Heart size={14} className="text-gray-500" />
            <span className="text-gray-300">{bev.likes} likes</span>
          </div>
          <div className="flex items-center gap-1.5 text-sm">
            <Bookmark size={14} className="text-gray-500" />
            <span className="text-gray-300">{bev.saves}</span>
          </div>
        </div>

        {/* Tags */}
        <div className="flex flex-wrap gap-1.5 mb-6">
          {bev.tags.map(tag => (
            <span key={tag} className="text-[10px] px-2.5 py-1 rounded-full bg-white/5 border border-white/10 text-gray-400">
              #{tag}
            </span>
          ))}
        </div>

        {/* Ingredients — always visible */}
        <section className="mb-6">
          <h2 className="text-white font-bold text-lg mb-3">Ingredients</h2>
          <div className="flex flex-col gap-2">
            {bev.ingredients.map((ing, i) => (
              <div key={i} className="flex items-center justify-between py-2 border-b border-white/5">
                <span className="text-white text-sm">{ing.name}</span>
                <span className="text-amber-400 text-sm font-medium">{ing.amount}</span>
              </div>
            ))}
          </div>
        </section>

        {/* Instructions — premium gated */}
        <section className="mb-6">
          <h2 className="text-white font-bold text-lg mb-3">Instructions</h2>
          {bev.isPremium ? (
            <FeatureGate
              requiredRole="paid"
              label="Pro Recipe"
              description="Upgrade to see the full step-by-step instructions and technique notes"
              preview={
                <div className="flex flex-col gap-2">
                  {bev.instructions.slice(0, 1).map((step, i) => (
                    <div key={i} className="flex gap-3 p-3 rounded-xl bg-white/5">
                      <span className="w-5 h-5 rounded-full bg-amber-500/20 text-amber-400 text-xs flex items-center justify-center shrink-0">{i + 1}</span>
                      <p className="text-gray-300 text-sm">{step}</p>
                    </div>
                  ))}
                  <div className="py-2 text-center text-gray-500 text-xs">... {bev.instructions.length - 1} more steps</div>
                </div>
              }
            />
          ) : (
            <div className="flex flex-col gap-2">
              {bev.instructions.map((step, i) => (
                <div key={i} className="flex gap-3 p-3 rounded-xl bg-white/5 border border-white/5">
                  <span className="w-5 h-5 rounded-full bg-amber-500/20 text-amber-400 text-xs flex items-center justify-center shrink-0 mt-0.5">{i + 1}</span>
                  <p className="text-gray-300 text-sm leading-relaxed">{step}</p>
                </div>
              ))}
            </div>
          )}
        </section>

        {/* Pairings — premium gated */}
        <section className="mb-8">
          <h2 className="text-white font-bold text-lg mb-3">Pairings</h2>
          {bev.isPremium ? (
            <FeatureGate
              requiredRole="paid"
              label="Pro Pairings"
              description="Upgrade to see food and experience pairings for this beverage"
              preview={
                <div className="flex flex-wrap gap-2">
                  <span className="blur-sm text-xs px-3 py-1 rounded-full bg-white/10 border border-white/10 text-gray-300">???</span>
                  <span className="blur-sm text-xs px-3 py-1 rounded-full bg-white/10 border border-white/10 text-gray-300">???</span>
                </div>
              }
            />
          ) : (
            <div className="flex flex-wrap gap-2">
              {bev.pairing.map(p => (
                <span key={p} className="text-xs px-3 py-1 rounded-full bg-amber-500/10 border border-amber-500/20 text-amber-300">
                  {p}
                </span>
              ))}
            </div>
          )}
        </section>

        {/* Similar beverages */}
        {similar.length > 0 && (
          <section>
            <div className="flex items-center justify-between mb-3">
              <h2 className="text-white font-bold text-lg">Similar Pours</h2>
              <Link to="/pour" className="text-amber-400 text-xs flex items-center gap-1">
                See all <ChevronRight size={12} />
              </Link>
            </div>
            <div className="grid grid-cols-2 gap-3">
              {similar.slice(0, 4).map(b => (
                <BeverageCard key={b.id} beverage={b} compact />
              ))}
            </div>
          </section>
        )}
      </div>
    </div>
  );
};
