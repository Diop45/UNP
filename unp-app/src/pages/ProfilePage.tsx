import React, { useState } from 'react';
import { useSearchParams, Link } from 'react-router-dom';
import {
  Settings, Bookmark, Award, Star, LogOut, Camera,
  Trophy, TrendingUp, Gift, RefreshCw, Shield
} from 'lucide-react';
import { useApp } from '../context/AppContext';
import { rewardActivities, REWARD_TIERS } from '../data/users';
import { beverages } from '../data/beverages';
import { BeverageCard } from '../components/BeverageCard';

const REWARD_TYPE_ICONS: Record<string, string> = {
  save: '🔖',
  share: '📤',
  attend: '📍',
  upload: '🎤',
  plan: '✅',
  social: '💬',
};

export const ProfilePage: React.FC = () => {
  const { user, loginAs, logout, savedBeverageIds, startTour } = useApp();
  const [searchParams] = useSearchParams();
  const showUpgrade = searchParams.get('upgrade') === '1';
  const showAmbassador = searchParams.get('ambassador') === '1';
  const [activeTab, setActiveTab] = useState<'saves' | 'rewards' | 'settings'>(
    showUpgrade || showAmbassador ? 'settings' : 'saves'
  );

  const savedBevs = savedBeverageIds.map(id => beverages.find(b => b.id === id)).filter(Boolean) as typeof beverages;
  const tierData = user ? REWARD_TIERS[user.rewardTier] : REWARD_TIERS.bronze;
  const nextTier = user?.rewardTier === 'bronze' ? REWARD_TIERS.silver : user?.rewardTier === 'silver' ? REWARD_TIERS.gold : null;
  const progressPct = user && nextTier
    ? Math.min(100, ((user.rewardPoints - tierData.min) / (nextTier.min - tierData.min)) * 100)
    : 100;

  if (!user) {
    return (
      <div className="min-h-screen flex flex-col items-center justify-center px-6 text-center gap-6">
        <div className="w-20 h-20 rounded-full bg-white/5 border border-white/10 flex items-center justify-center">
          <Star size={32} className="text-gray-500" />
        </div>
        <div>
          <h2 className="text-white font-bold text-xl mb-2">Sign in to view your profile</h2>
          <p className="text-gray-400 text-sm">Track your saves, rewards, and personalized settings.</p>
        </div>
        <Link
          to="/onboarding"
          className="px-6 py-3 rounded-2xl bg-gradient-to-r from-amber-600 to-amber-400 text-black font-bold text-sm hover:opacity-90"
        >
          Get Started
        </Link>
        {/* Demo login buttons */}
        <div className="flex flex-col gap-2 w-full max-w-xs">
          <p className="text-gray-500 text-xs">Or demo as:</p>
          {(['free', 'paid', 'ambassador'] as const).map(role => (
            <button
              key={role}
              onClick={() => loginAs(role)}
              className="py-2.5 rounded-xl border border-white/10 bg-white/5 text-gray-300 text-sm hover:bg-white/10 hover:border-white/20 transition-all capitalize"
            >
              {role === 'free' ? 'Free User' : role === 'paid' ? 'Pro Member' : 'Ambassador'}
            </button>
          ))}
        </div>
      </div>
    );
  }

  const roleColor = user.role === 'ambassador'
    ? 'text-purple-400 bg-purple-500/10 border-purple-500/30'
    : user.role === 'paid'
    ? 'text-amber-400 bg-amber-500/10 border-amber-500/30'
    : 'text-gray-400 bg-white/5 border-white/10';

  const roleLabel = user.role === 'ambassador' ? '🏅 Ambassador' : user.role === 'paid' ? '⭐ Pro Member' : '🧭 Free';

  return (
    <div className="min-h-screen pb-10">
      {/* Profile hero */}
      <div className="relative pt-6 px-4 pb-4">
        <div className="flex items-start gap-4">
          <div className="relative">
            <div className="w-18 h-18 rounded-full overflow-hidden border-2 border-amber-500/30"
              style={{ width: '72px', height: '72px' }}>
              <img src={user.avatar ?? 'https://i.pravatar.cc/100?img=3'} alt={user.name} className="w-full h-full object-cover" />
            </div>
            <button className="absolute -bottom-1 -right-1 w-6 h-6 rounded-full bg-amber-500 flex items-center justify-center">
              <Camera size={11} className="text-black" />
            </button>
          </div>
          <div className="flex-1">
            <div className="flex items-start justify-between">
              <div>
                <h1 className="text-xl font-bold text-white">{user.name}</h1>
                <span className={`inline-flex items-center text-[10px] font-semibold px-2 py-0.5 rounded-full border mt-1 ${roleColor}`}>
                  {roleLabel}
                </span>
              </div>
              <div className="flex items-center gap-2">
                <button onClick={() => startTour('home')} title="Restart tour" className="text-gray-500 hover:text-amber-400 transition-colors">
                  <RefreshCw size={16} />
                </button>
              </div>
            </div>
            {user.bio && <p className="text-gray-400 text-xs mt-2">{user.bio}</p>}
          </div>
        </div>

        {/* Stats row */}
        <div className="grid grid-cols-3 gap-3 mt-4">
          {[
            { label: 'Saves', value: savedBevs.length },
            { label: 'Points', value: user.rewardPoints },
            { label: 'Tier', value: user.rewardTier.charAt(0).toUpperCase() + user.rewardTier.slice(1) },
          ].map(s => (
            <div key={s.label} className="flex flex-col items-center py-3 rounded-xl bg-white/5 border border-white/5">
              <span className="text-white font-bold text-lg">{s.value}</span>
              <span className="text-gray-500 text-xs">{s.label}</span>
            </div>
          ))}
        </div>
      </div>

      {/* Tabs */}
      <div className="flex gap-1 px-4 mb-4 border-b border-white/5 pb-0">
        {[
          { id: 'saves', label: 'Saves', icon: Bookmark },
          { id: 'rewards', label: 'Rewards', icon: Award },
          { id: 'settings', label: 'Settings', icon: Settings },
        ].map(tab => {
          const Icon = tab.icon;
          return (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id as typeof activeTab)}
              className={`flex items-center gap-1.5 px-4 py-3 text-xs font-medium border-b-2 transition-colors ${
                activeTab === tab.id
                  ? 'border-amber-500 text-amber-400'
                  : 'border-transparent text-gray-500 hover:text-gray-300'
              }`}
            >
              <Icon size={13} />{tab.label}
            </button>
          );
        })}
      </div>

      {/* Tab content */}
      <div className="px-4">
        {activeTab === 'saves' && (
          <div>
            {savedBevs.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-16 text-center">
                <Bookmark size={32} className="text-gray-600 mb-3" />
                <p className="text-gray-400 text-sm">No saved beverages yet.</p>
                <Link to="/pour" className="text-amber-400 text-xs mt-2">Browse Pour →</Link>
              </div>
            ) : (
              <div className="grid grid-cols-2 gap-3">
                {savedBevs.map(b => <BeverageCard key={b.id} beverage={b} compact />)}
              </div>
            )}
          </div>
        )}

        {activeTab === 'rewards' && (
          <div className="flex flex-col gap-5">
            {/* Tier card */}
            <div className="p-4 rounded-2xl border border-amber-500/20 bg-gradient-to-br from-amber-500/10 to-transparent">
              <div className="flex items-center justify-between mb-3">
                <div className="flex items-center gap-2">
                  <Trophy size={18} className="text-amber-400" />
                  <span className="text-white font-bold">{tierData.label} Tier</span>
                </div>
                <span className="text-amber-400 font-bold text-sm">{user.rewardPoints} pts</span>
              </div>
              {nextTier && (
                <>
                  <div className="h-1.5 rounded-full bg-white/10 overflow-hidden mb-1">
                    <div
                      className="h-full rounded-full bg-gradient-to-r from-amber-600 to-amber-400 transition-all"
                      style={{ width: `${progressPct}%` }}
                    />
                  </div>
                  <p className="text-gray-500 text-[10px]">
                    {nextTier.min - user.rewardPoints} pts to {nextTier.label}
                  </p>
                </>
              )}
              <div className="mt-3 flex flex-col gap-1">
                {tierData.perks.map(perk => (
                  <div key={perk} className="flex items-center gap-2 text-xs text-gray-300">
                    <span className="text-amber-500">✓</span> {perk}
                  </div>
                ))}
              </div>
            </div>

            {/* Activity feed */}
            <div>
              <div className="flex items-center gap-2 mb-3">
                <TrendingUp size={14} className="text-gray-400" />
                <h2 className="text-white font-semibold text-sm">Recent Activity</h2>
              </div>
              <div className="flex flex-col gap-2">
                {rewardActivities.map(a => (
                  <div key={a.id} className="flex items-center gap-3 p-3 rounded-xl border border-white/5 bg-white/3">
                    <span className="text-lg">{REWARD_TYPE_ICONS[a.type]}</span>
                    <div className="flex-1 min-w-0">
                      <p className="text-white text-xs truncate">{a.description}</p>
                      <p className="text-gray-500 text-[10px]">{a.date}</p>
                    </div>
                    <span className="text-amber-400 text-xs font-bold">+{a.points}</span>
                  </div>
                ))}
              </div>
            </div>

            {/* Monthly refresh note */}
            <div className="p-3 rounded-xl border border-white/5 bg-white/3 flex items-center gap-3">
              <Gift size={16} className="text-purple-400 shrink-0" />
              <p className="text-gray-400 text-xs">Points refresh monthly. Unused tier bonuses carry over for 30 days.</p>
            </div>
          </div>
        )}

        {activeTab === 'settings' && (
          <div className="flex flex-col gap-4">
            {/* Upgrade / role */}
            {user.role === 'free' && (
              <div className="p-4 rounded-2xl border border-amber-500/20 bg-amber-500/5">
                <p className="text-amber-400 font-bold mb-1">Upgrade to Pro</p>
                <p className="text-gray-400 text-xs mb-3">Unlock full recipes, personalized 3-step plans, private circles, and perks.</p>
                <button
                  onClick={() => loginAs('paid')}
                  className="w-full py-2.5 rounded-xl bg-gradient-to-r from-amber-600 to-amber-400 text-black font-bold text-sm hover:opacity-90 transition-opacity"
                >
                  Upgrade — Demo as Pro
                </button>
              </div>
            )}
            {user.role !== 'ambassador' && (
              <div className="p-4 rounded-2xl border border-purple-500/20 bg-purple-500/5">
                <p className="text-purple-400 font-bold mb-1">Become an Ambassador</p>
                <p className="text-gray-400 text-xs mb-3">Upload recipes, build your brand, and earn Ambassador-exclusive rewards.</p>
                <button
                  onClick={() => loginAs('ambassador')}
                  className="w-full py-2.5 rounded-xl bg-gradient-to-r from-purple-700 to-purple-500 text-white font-bold text-sm hover:opacity-90 transition-opacity flex items-center justify-center gap-2"
                >
                  <Shield size={14} /> Apply — Demo as Ambassador
                </button>
              </div>
            )}

            {/* Demo switcher */}
            <div className="p-4 rounded-2xl border border-white/10 bg-white/3">
              <p className="text-white font-semibold text-sm mb-3">Demo Role Switcher</p>
              <div className="flex flex-col gap-2">
                {(['free', 'paid', 'ambassador'] as const).map(role => (
                  <button
                    key={role}
                    onClick={() => loginAs(role)}
                    className={`py-2.5 rounded-xl border text-sm font-medium transition-all capitalize ${
                      user.role === role
                        ? 'bg-amber-500/10 border-amber-500/30 text-amber-400'
                        : 'bg-white/5 border-white/10 text-gray-400 hover:bg-white/10'
                    }`}
                  >
                    {role === 'free' ? '🧭 Free User' : role === 'paid' ? '⭐ Pro Member' : '🏅 Ambassador'}
                    {user.role === role && ' (current)'}
                  </button>
                ))}
              </div>
            </div>

            {/* Tour restart */}
            <div className="p-4 rounded-2xl border border-white/10 bg-white/3">
              <p className="text-white font-semibold text-sm mb-3">App Tour</p>
              <div className="flex flex-col gap-2">
                {['home', 'pour', 'explore', 'circle'].map(t => (
                  <button
                    key={t}
                    onClick={() => startTour(t)}
                    className="flex items-center justify-between py-2.5 px-3 rounded-xl border border-white/10 bg-white/5 text-gray-300 text-sm hover:bg-white/10 transition-colors"
                  >
                    <span className="capitalize">{t} Tour</span>
                    <span className="text-amber-400 text-xs">Restart →</span>
                  </button>
                ))}
              </div>
            </div>

            {/* Logout */}
            <button
              onClick={logout}
              className="flex items-center justify-center gap-2 w-full py-3 rounded-2xl border border-red-500/20 bg-red-500/5 text-red-400 text-sm font-semibold hover:bg-red-500/10 transition-colors"
            >
              <LogOut size={16} /> Sign Out
            </button>

            {/* Demo screenshots link */}
            <Link
              to="/demo"
              className="flex items-center justify-center gap-2 w-full py-3 rounded-2xl border border-white/10 bg-white/5 text-gray-400 text-sm font-medium hover:bg-white/10 transition-colors"
            >
              📸 Demo Screenshots Gallery
            </Link>
          </div>
        )}
      </div>
    </div>
  );
};
