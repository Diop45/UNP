import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { Wine, Map, Compass, Users, Star, ArrowRight, Check } from 'lucide-react';
import { useApp } from '../context/AppContext';
import type { UserRole } from '../types';

const STEPS = [
  {
    id: 'welcome',
    title: 'Until The Next Pour',
    subtitle: 'Your nightlife companion for beverages, adventures, and events.',
    icon: Wine,
  },
  {
    id: 'role',
    title: 'How would you like to explore?',
    subtitle: 'You can always change this later.',
    icon: Users,
  },
  {
    id: 'features',
    title: 'Here\'s what awaits',
    subtitle: 'Three journeys, one platform.',
    icon: Compass,
  },
  {
    id: 'done',
    title: 'You\'re all set',
    subtitle: 'Let\'s find your next pour.',
    icon: Star,
  },
];

const FEATURES = [
  { icon: Wine, title: 'Pour', desc: 'Recipes, pour cards, and beverage discovery' },
  { icon: Compass, title: 'Nudge', desc: 'Curated micro-adventures for your evening' },
  { icon: Map, title: 'Explore', desc: 'Events, venues, and what\'s happening tonight' },
];

export const OnboardingPage: React.FC = () => {
  const { completeOnboarding, loginAs } = useApp();
  const navigate = useNavigate();
  const [step, setStep] = useState(0);
  const [selectedRole, setSelectedRole] = useState<UserRole>('free');

  const handleRoleSelect = (role: UserRole) => setSelectedRole(role);

  const handleNext = () => {
    if (step < STEPS.length - 1) {
      setStep(s => s + 1);
    } else {
      loginAs(selectedRole);
      completeOnboarding();
      navigate('/');
    }
  };

  const handleSkip = () => {
    completeOnboarding();
    navigate('/');
  };

  const current = STEPS[step];
  const Icon = current.icon;

  return (
    <div className="min-h-screen bg-[#0D0A14] flex flex-col items-center justify-between px-6 py-12">
      {/* Progress */}
      <div className="flex items-center gap-2 w-full max-w-sm">
        {STEPS.map((_, i) => (
          <div
            key={i}
            className={`h-1 flex-1 rounded-full transition-all duration-300 ${
              i <= step ? 'bg-amber-500' : 'bg-white/10'
            }`}
          />
        ))}
      </div>

      {/* Content */}
      <div className="flex-1 flex flex-col items-center justify-center w-full max-w-sm gap-8 py-8">
        <div className="w-20 h-20 rounded-full bg-amber-500/10 border border-amber-500/20 flex items-center justify-center">
          <Icon size={36} className="text-amber-400" />
        </div>

        <div className="text-center">
          <h1 className="text-2xl font-bold text-white mb-2">{current.title}</h1>
          <p className="text-gray-400 text-sm leading-relaxed">{current.subtitle}</p>
        </div>

        {step === 1 && (
          <div className="flex flex-col gap-3 w-full">
            {[
              { role: 'free' as UserRole, label: 'Free Explorer', desc: 'Browse, discover, and preview the best of UNP', icon: '🧭' },
              { role: 'paid' as UserRole, label: 'Pro Member', desc: 'Unlock full recipes, personalized plans, and Pro Circle features', icon: '⭐' },
              { role: 'ambassador' as UserRole, label: 'Beverage Ambassador', desc: 'Upload recipes, build your portfolio, and grow your audience', icon: '🏅' },
            ].map(({ role, label, desc, icon }) => (
              <button
                key={role}
                onClick={() => handleRoleSelect(role)}
                className={`flex items-center gap-4 p-4 rounded-2xl border text-left transition-all ${
                  selectedRole === role
                    ? 'border-amber-500/60 bg-amber-500/10'
                    : 'border-white/10 bg-white/5 hover:border-white/20'
                }`}
              >
                <span className="text-2xl">{icon}</span>
                <div>
                  <p className="text-white font-semibold text-sm">{label}</p>
                  <p className="text-gray-400 text-xs mt-0.5">{desc}</p>
                </div>
                {selectedRole === role && (
                  <div className="ml-auto w-5 h-5 rounded-full bg-amber-500 flex items-center justify-center">
                    <Check size={12} className="text-black" />
                  </div>
                )}
              </button>
            ))}
          </div>
        )}

        {step === 2 && (
          <div className="flex flex-col gap-3 w-full">
            {FEATURES.map(({ icon: FIcon, title, desc }) => (
              <div key={title} className="flex items-center gap-4 p-4 rounded-2xl border border-white/10 bg-white/5">
                <div className="w-10 h-10 rounded-xl bg-amber-500/10 border border-amber-500/20 flex items-center justify-center">
                  <FIcon size={18} className="text-amber-400" />
                </div>
                <div>
                  <p className="text-white font-semibold text-sm">{title}</p>
                  <p className="text-gray-400 text-xs mt-0.5">{desc}</p>
                </div>
              </div>
            ))}
          </div>
        )}

        {step === 3 && (
          <div className="flex flex-col gap-4 w-full text-center">
            <div className="p-4 rounded-2xl border border-amber-500/20 bg-amber-500/5">
              <p className="text-amber-400 text-sm font-medium">Entering as</p>
              <p className="text-white font-bold text-lg mt-1 capitalize">{selectedRole} user</p>
              <p className="text-gray-400 text-xs mt-1">
                {selectedRole === 'free' && 'Explore beverages, nudges, and events. Upgrade anytime.'}
                {selectedRole === 'paid' && 'Full access to all recipes, personalized plans, and Pro features.'}
                {selectedRole === 'ambassador' && 'Upload recipes, build your brand, and earn Ambassador perks.'}
              </p>
            </div>
          </div>
        )}
      </div>

      {/* Actions */}
      <div className="flex flex-col gap-3 w-full max-w-sm">
        <button
          onClick={handleNext}
          className="flex items-center justify-center gap-2 w-full py-3.5 rounded-2xl bg-gradient-to-r from-amber-600 to-amber-400 text-black font-bold text-base hover:opacity-90 transition-opacity"
        >
          {step < STEPS.length - 1 ? (
            <>Continue <ArrowRight size={16} /></>
          ) : (
            <>Let\'s Pour! <Wine size={16} /></>
          )}
        </button>
        {step === 0 && (
          <button
            onClick={handleSkip}
            className="text-gray-500 text-sm py-2 hover:text-gray-300 transition-colors"
          >
            Continue as guest
          </button>
        )}
      </div>
    </div>
  );
};
