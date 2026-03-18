import React from 'react';
import { useParams, Link } from 'react-router-dom';
import { ArrowLeft, Zap, Wine, Map, ChevronRight, Lock } from 'lucide-react';
import { BeverageCard } from '../components/BeverageCard';
import { EventCard } from '../components/EventCard';
import { useApp } from '../context/AppContext';
import { getNudgeById } from '../data/nudges';
import { getBeverageById } from '../data/beverages';
import { getEventById } from '../data/events';

export const NudgeDetailPage: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const { user } = useApp();
  const nudge = getNudgeById(id ?? '');
  const isPaid = user?.role === 'paid' || user?.role === 'ambassador';

  if (!nudge) {
    return (
      <div className="flex flex-col items-center justify-center min-h-screen px-4 text-center">
        <p className="text-gray-400 mb-3">Nudge not found.</p>
        <Link to="/nudge" className="text-purple-400 text-sm">← Back to Nudges</Link>
      </div>
    );
  }

  const relBevs = nudge.relatedBeverageIds.map(id => getBeverageById(id)).filter(Boolean) as ReturnType<typeof getBeverageById>[];
  const relEvts = nudge.relatedEventIds.map(id => getEventById(id)).filter(Boolean) as ReturnType<typeof getEventById>[];

  return (
    <div className="min-h-screen">
      {/* Hero */}
      <div className="relative h-64 overflow-hidden">
        <img src={nudge.image} alt={nudge.title} className="w-full h-full object-cover" />
        <div className="absolute inset-0 bg-gradient-to-t from-[#0D0A14] via-purple-900/20 to-transparent" />
        <div className="absolute top-4 left-4">
          <Link to="/nudge" className="w-9 h-9 rounded-full bg-black/60 border border-white/10 flex items-center justify-center">
            <ArrowLeft size={16} className="text-white" />
          </Link>
        </div>
      </div>

      <div className="px-4 pt-4 pb-10">
        <div className="flex items-center gap-2 mb-2">
          <Zap size={16} className="text-purple-400" />
          <span className="text-purple-400 text-xs font-medium capitalize">{nudge.category} · Tonight's Nudge</span>
          {nudge.isPremium && (
            <span className="text-[10px] px-2 py-0.5 rounded-full bg-amber-500/20 border border-amber-500/30 text-amber-400 font-semibold">PRO</span>
          )}
        </div>

        <h1 className="text-2xl font-bold text-white mb-1">{nudge.title}</h1>
        <p className="text-gray-400 text-sm italic mb-3">{nudge.tagline}</p>
        <p className="text-gray-300 text-sm leading-relaxed mb-6">{nudge.description}</p>

        {/* Tags */}
        <div className="flex flex-wrap gap-1.5 mb-6">
          {nudge.tags.map(t => (
            <span key={t} className="text-[10px] px-2.5 py-1 rounded-full bg-white/5 border border-white/10 text-gray-500">#{t}</span>
          ))}
        </div>

        {/* 3-Step Plan */}
        <section className="mb-8">
          <h2 className="text-white font-bold text-lg mb-4">
            {isPaid ? "Tonight's 3-Step Plan" : 'Adventure Preview'}
          </h2>

          {nudge.isPremium && !isPaid ? (
            <div className="p-5 rounded-2xl border border-amber-500/20 bg-amber-500/5 text-center">
              <Lock size={24} className="text-amber-400 mx-auto mb-3" />
              <h3 className="text-white font-semibold mb-2">Pro Adventure</h3>
              <p className="text-gray-400 text-sm mb-4">
                Unlock the full 3-step personalized plan with cross-links to matching events and beverages.
              </p>
              <Link
                to="/profile?upgrade=1"
                className="inline-flex items-center gap-2 px-5 py-2.5 rounded-full bg-gradient-to-r from-amber-600 to-amber-400 text-black font-bold text-sm hover:opacity-90"
              >
                Upgrade to Pro
              </Link>
            </div>
          ) : (
            <div className="flex flex-col gap-4">
              {nudge.steps.map((step) => {
                const stepBev = step.beverageId ? getBeverageById(step.beverageId) : null;
                const stepEvt = step.eventId ? getEventById(step.eventId) : null;

                return (
                  <div key={step.step} className="rounded-2xl border border-white/10 bg-[#1A1628] overflow-hidden">
                    <div className="flex items-center gap-3 p-4 border-b border-white/5">
                      <div className="w-8 h-8 rounded-full bg-purple-500/20 border border-purple-500/30 flex items-center justify-center shrink-0">
                        <span className="text-purple-400 font-bold text-sm">{step.step}</span>
                      </div>
                      <div>
                        <h3 className="text-white font-semibold text-sm">{step.title}</h3>
                      </div>
                    </div>
                    <div className="p-4">
                      <p className="text-gray-300 text-sm leading-relaxed mb-3">{step.description}</p>
                      <div className="flex flex-col gap-2">
                        {stepBev && (
                          <Link
                            to={`/pour/${stepBev.id}`}
                            className="flex items-center gap-3 p-2.5 rounded-xl bg-amber-500/5 border border-amber-500/15 hover:border-amber-500/30 transition-colors"
                          >
                            <Wine size={14} className="text-amber-400" />
                            <div className="flex-1 min-w-0">
                              <p className="text-amber-300 text-xs font-medium truncate">{stepBev.name}</p>
                              <p className="text-gray-500 text-[10px]">Suggested pour</p>
                            </div>
                            <ChevronRight size={12} className="text-gray-600" />
                          </Link>
                        )}
                        {stepEvt && (
                          <Link
                            to={`/explore/${stepEvt.id}`}
                            className="flex items-center gap-3 p-2.5 rounded-xl bg-blue-500/5 border border-blue-500/15 hover:border-blue-500/30 transition-colors"
                          >
                            <Map size={14} className="text-blue-400" />
                            <div className="flex-1 min-w-0">
                              <p className="text-blue-300 text-xs font-medium truncate">{stepEvt.title}</p>
                              <p className="text-gray-500 text-[10px]">{stepEvt.venue.name}</p>
                            </div>
                            <ChevronRight size={12} className="text-gray-600" />
                          </Link>
                        )}
                      </div>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </section>

        {/* Related beverages */}
        {relBevs.length > 0 && (
          <section className="mb-8">
            <h2 className="text-white font-bold text-lg mb-3">Related Pours</h2>
            <div className="grid grid-cols-2 gap-3">
              {relBevs.slice(0, 4).map(b => b && <BeverageCard key={b.id} beverage={b} compact />)}
            </div>
          </section>
        )}

        {/* Related events */}
        {relEvts.length > 0 && (
          <section>
            <h2 className="text-white font-bold text-lg mb-3">Events for This Night</h2>
            <div className="grid grid-cols-2 gap-3">
              {relEvts.slice(0, 4).map(e => e && <EventCard key={e.id} event={e} compact />)}
            </div>
          </section>
        )}
      </div>
    </div>
  );
};
