import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { Zap, Lock, ChevronRight, Check } from 'lucide-react';
import { useApp } from '../context/AppContext';
import { nudges } from '../data/nudges';
import type { NudgeCategory } from '../types';

const CATEGORY_LABELS: Record<NudgeCategory | 'all', string> = {
  all: 'All',
  social: 'Social',
  solo: 'Solo',
  date: 'Date Night',
  group: 'Group',
  adventure: 'Adventure',
};

export const NudgePage: React.FC = () => {
  const { user } = useApp();
  const [category, setCategory] = useState<NudgeCategory | 'all'>('all');
  const [pollAnswers, setPollAnswers] = useState<Record<string, string>>({});
  const isPaid = user?.role === 'paid' || user?.role === 'ambassador';

  const filtered = nudges.filter(n => category === 'all' || n.category === category);

  const answerPoll = (nudgeId: string, answer: string) => {
    setPollAnswers(prev => ({ ...prev, [nudgeId]: answer }));
  };

  return (
    <div className="min-h-screen px-4 pt-6 pb-10">
      <div className="mb-4">
        <div className="flex items-center gap-2 mb-1">
          <Zap size={18} className="text-purple-400" />
          <h1 className="text-2xl font-bold text-white">Nudge</h1>
        </div>
        <p className="text-gray-400 text-sm">Curated micro-adventures for tonight.</p>
      </div>

      {/* Category filter */}
      <div className="flex gap-2 overflow-x-auto pb-3 mb-5">
        {(Object.keys(CATEGORY_LABELS) as Array<NudgeCategory | 'all'>).map(c => (
          <button
            key={c}
            onClick={() => setCategory(c)}
            className={`shrink-0 px-3 py-1.5 rounded-full text-xs font-medium border transition-colors ${
              category === c
                ? 'bg-purple-500 border-purple-500 text-white'
                : 'bg-white/5 border-white/10 text-gray-400 hover:border-white/20'
            }`}
          >
            {CATEGORY_LABELS[c]}
          </button>
        ))}
      </div>

      <div className="flex flex-col gap-5">
        {filtered.map(nudge => {
          const locked = nudge.isPremium && !isPaid;
          return (
            <div key={nudge.id} className="rounded-2xl border border-white/10 bg-[#1A1628] overflow-hidden">
              {/* Image */}
              <div className="relative h-44 overflow-hidden">
                <img src={nudge.image} alt={nudge.title} className="w-full h-full object-cover" />
                <div className="absolute inset-0 bg-gradient-to-t from-[#1A1628] via-purple-900/10 to-transparent" />
                <div className="absolute top-2 left-2 flex gap-1.5">
                  <span className="text-[10px] px-2 py-0.5 rounded-full bg-purple-500/30 border border-purple-500/40 text-purple-300 font-medium capitalize">
                    {nudge.category}
                  </span>
                  {nudge.isPremium && (
                    <span className="text-[10px] px-2 py-0.5 rounded-full bg-amber-500/20 border border-amber-500/30 text-amber-400 font-semibold flex items-center gap-1">
                      PRO
                    </span>
                  )}
                </div>
                {locked && (
                  <div className="absolute inset-0 bg-black/40 flex items-center justify-center">
                    <Lock size={24} className="text-white/60" />
                  </div>
                )}
              </div>

              <div className="p-4">
                <h3 className="text-white font-bold text-base mb-1">{nudge.title}</h3>
                <p className="text-gray-400 text-xs italic mb-3">{nudge.tagline}</p>
                <p className="text-gray-300 text-sm leading-relaxed mb-4">{nudge.description}</p>

                {/* Tags */}
                <div className="flex flex-wrap gap-1 mb-4">
                  {nudge.tags.map(t => (
                    <span key={t} className="text-[10px] px-2 py-0.5 rounded-full bg-white/5 border border-white/10 text-gray-500">#{t}</span>
                  ))}
                </div>

                {/* Poll — free users can answer */}
                {nudge.poll && !locked && (
                  <div className="mb-4 p-3 rounded-xl bg-white/5 border border-white/10">
                    <p className="text-white text-xs font-semibold mb-2">{nudge.poll.question}</p>
                    <div className="flex flex-col gap-1.5">
                      {nudge.poll.options.map(opt => {
                        const selected = pollAnswers[nudge.id] === opt;
                        return (
                          <button
                            key={opt}
                            onClick={() => answerPoll(nudge.id, opt)}
                            className={`flex items-center gap-2 px-3 py-2 rounded-lg text-left text-xs transition-all ${
                              selected
                                ? 'bg-purple-500/20 border border-purple-500/40 text-purple-300'
                                : 'bg-white/5 border border-white/10 text-gray-400 hover:border-white/20'
                            }`}
                          >
                            {selected && <Check size={10} className="text-purple-400" />}
                            {opt}
                          </button>
                        );
                      })}
                    </div>
                  </div>
                )}

                {/* 3-step plan preview / lock */}
                {locked ? (
                  <div className="p-4 rounded-xl bg-amber-500/5 border border-amber-500/20 text-center">
                    <Lock size={16} className="text-amber-400 mx-auto mb-2" />
                    <p className="text-amber-400 text-xs font-semibold mb-1">Pro Adventure</p>
                    <p className="text-gray-400 text-xs mb-3">Unlock the personalized 3-step "Tonight's Plan" with cross-links to events and beverages.</p>
                    <Link
                      to="/profile?upgrade=1"
                      className="inline-flex items-center gap-1.5 px-4 py-1.5 rounded-full bg-amber-500/20 border border-amber-500/30 text-amber-400 text-xs font-semibold hover:bg-amber-500/30 transition-colors"
                    >
                      Upgrade to Pro
                    </Link>
                  </div>
                ) : (
                  <Link
                    to={`/nudge/${nudge.id}`}
                    className="flex items-center justify-between w-full px-4 py-2.5 rounded-xl bg-purple-500/20 border border-purple-500/30 text-purple-300 text-sm font-semibold hover:bg-purple-500/30 transition-colors"
                  >
                    <span>View {isPaid ? '3-Step Plan' : 'Adventure'}</span>
                    <ChevronRight size={16} />
                  </Link>
                )}
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};
