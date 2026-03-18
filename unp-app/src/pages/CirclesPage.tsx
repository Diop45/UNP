import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { Heart, MessageCircle, Share2, Lock, HelpCircle, Users, PlusCircle } from 'lucide-react';
import { FeatureGate } from '../components/FeatureGate';
import { useApp } from '../context/AppContext';
import { circles } from '../data/circles';
import type { CirclePost } from '../types';

const roleColors: Record<string, string> = {
  ambassador: 'text-purple-400 bg-purple-500/10 border-purple-500/20',
  paid: 'text-amber-400 bg-amber-500/10 border-amber-500/20',
  free: 'text-gray-400 bg-white/5 border-white/10',
  guest: 'text-gray-500 bg-white/5 border-white/10',
};

const roleLabels: Record<string, string> = {
  ambassador: 'AMB',
  paid: 'PRO',
  free: 'FREE',
  guest: 'GUEST',
};

const PostCard: React.FC<{ post: CirclePost }> = ({ post }) => {
  const [liked, setLiked] = useState(post.liked ?? false);
  const [likes, setLikes] = useState(post.likes);
  const [showComments, setShowComments] = useState(false);

  const handleLike = () => {
    setLiked(l => !l);
    setLikes(n => liked ? n - 1 : n + 1);
  };

  const timeAgo = (iso: string) => {
    const diff = Date.now() - new Date(iso).getTime();
    const h = Math.floor(diff / 3600000);
    if (h < 24) return `${h}h ago`;
    const d = Math.floor(h / 24);
    return `${d}d ago`;
  };

  return (
    <div className="rounded-2xl border border-white/10 bg-[#1A1628] overflow-hidden">
      {/* Author */}
      <div className="flex items-center gap-3 px-4 py-3">
        <img src={post.authorAvatar} alt={post.authorName} className="w-9 h-9 rounded-full border border-white/10 object-cover" />
        <div className="flex-1">
          <div className="flex items-center gap-2">
            <span className="text-white text-sm font-semibold">{post.authorName}</span>
            <span className={`text-[9px] px-1.5 py-0.5 rounded-full border font-bold ${roleColors[post.authorRole]}`}>
              {roleLabels[post.authorRole]}
            </span>
          </div>
          <p className="text-gray-500 text-[10px]">{timeAgo(post.createdAt)}</p>
        </div>
      </div>

      {/* Image */}
      {post.image && (
        <div className="relative overflow-hidden" style={{ height: '200px' }}>
          <img src={post.image} alt="" className="w-full h-full object-cover" />
        </div>
      )}

      {/* Content */}
      <div className="px-4 py-3">
        <p className="text-gray-200 text-sm leading-relaxed">{post.content}</p>

        {/* Cross links */}
        <div className="flex flex-wrap gap-2 mt-2">
          {post.beverageId && (
            <Link
              to={`/pour/${post.beverageId}`}
              className="text-[10px] px-2.5 py-1 rounded-full bg-amber-500/10 border border-amber-500/20 text-amber-400 hover:bg-amber-500/20 transition-colors"
            >
              🍹 View Pour
            </Link>
          )}
          {post.eventId && (
            <Link
              to={`/explore/${post.eventId}`}
              className="text-[10px] px-2.5 py-1 rounded-full bg-blue-500/10 border border-blue-500/20 text-blue-400 hover:bg-blue-500/20 transition-colors"
            >
              📍 View Event
            </Link>
          )}
        </div>
      </div>

      {/* Actions */}
      <div className="px-4 py-2 border-t border-white/5 flex items-center gap-4">
        <button
          onClick={handleLike}
          className={`flex items-center gap-1.5 text-xs transition-colors ${liked ? 'text-red-400' : 'text-gray-500 hover:text-gray-300'}`}
        >
          <Heart size={14} className={liked ? 'fill-red-400' : ''} />
          {likes}
        </button>
        <button
          onClick={() => setShowComments(s => !s)}
          className="flex items-center gap-1.5 text-xs text-gray-500 hover:text-gray-300 transition-colors"
        >
          <MessageCircle size={14} />
          {post.comments.length}
        </button>
        <button className="flex items-center gap-1.5 text-xs text-gray-500 hover:text-gray-300 transition-colors ml-auto">
          <Share2 size={14} />
        </button>
      </div>

      {/* Comments */}
      {showComments && post.comments.length > 0 && (
        <div className="px-4 pb-3 flex flex-col gap-2 border-t border-white/5 pt-3">
          {post.comments.map(c => (
            <div key={c.id} className="flex gap-2">
              <div className="w-6 h-6 rounded-full bg-white/10 flex items-center justify-center shrink-0">
                <span className="text-[9px] text-gray-400">{c.authorName[0]}</span>
              </div>
              <div className="flex-1 bg-white/5 rounded-xl px-3 py-2">
                <span className="text-amber-400 text-[10px] font-semibold">{c.authorName} </span>
                <span className="text-gray-300 text-xs">{c.content}</span>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
};

export const CirclesPage: React.FC = () => {
  const { user, startTour } = useApp();
  const isPaid = user?.role === 'paid' || user?.role === 'ambassador';
  const [activeCircle, setActiveCircle] = useState('circle-001');

  const currentCircle = circles.find(c => c.id === activeCircle) ?? circles[0];

  return (
    <div className="min-h-screen pb-10">
      {/* Header */}
      <div className="px-4 pt-6 pb-3">
        <div className="flex items-start justify-between mb-1">
          <h1 className="text-2xl font-bold text-white">Pour Circle</h1>
          <button onClick={() => startTour('circle')} className="text-gray-500 hover:text-amber-400 transition-colors">
            <HelpCircle size={20} />
          </button>
        </div>
        <p className="text-gray-400 text-sm">Your social layer for nightlife & pours</p>
      </div>

      {/* Circle selector */}
      <div className="flex gap-2 overflow-x-auto px-4 pb-4">
        {circles.map(c => (
          <button
            key={c.id}
            onClick={() => {
              if (c.isPrivate && !isPaid) return;
              setActiveCircle(c.id);
            }}
            className={`relative shrink-0 flex items-center gap-2 px-3 py-2 rounded-xl border text-xs font-medium transition-all ${
              activeCircle === c.id
                ? 'bg-amber-500/20 border-amber-500/40 text-amber-300'
                : c.isPrivate && !isPaid
                ? 'bg-white/3 border-white/5 text-gray-600 cursor-not-allowed'
                : 'bg-white/5 border-white/10 text-gray-400 hover:border-white/20'
            }`}
          >
            {c.isPrivate && <Lock size={10} className="shrink-0" />}
            <span className="truncate max-w-[100px]">{c.name}</span>
            <span className="shrink-0">({c.members.toLocaleString()})</span>
          </button>
        ))}
        <FeatureGate requiredRole="paid" label="" description="">
          <button className="shrink-0 flex items-center gap-1.5 px-3 py-2 rounded-xl border border-dashed border-white/15 text-gray-600 text-xs hover:border-white/25 hover:text-gray-400 transition-colors">
            <PlusCircle size={12} /> New Circle
          </button>
        </FeatureGate>
      </div>

      {/* Circle info */}
      <div className="mx-4 mb-4 p-3 rounded-xl border border-white/10 bg-[#1A1628] flex items-center gap-3">
        <div className="w-10 h-10 rounded-full overflow-hidden border border-white/10 shrink-0">
          <img src={currentCircle.image} alt={currentCircle.name} className="w-full h-full object-cover" />
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-white text-sm font-semibold truncate">{currentCircle.name}</p>
          <p className="text-gray-400 text-xs">{currentCircle.members.toLocaleString()} members</p>
        </div>
        <div className="flex items-center gap-1.5 text-xs text-gray-500">
          <Users size={12} />
          <span>{currentCircle.members}</span>
        </div>
      </div>

      {/* Pro gated features */}
      {!isPaid && (
        <div className="mx-4 mb-4 p-3 rounded-xl border border-amber-500/15 bg-amber-500/5 flex items-center gap-3">
          <Lock size={14} className="text-amber-400 shrink-0" />
          <div className="flex-1">
            <p className="text-amber-400 text-xs font-semibold">Upgrade for chat, planning & perks</p>
            <p className="text-gray-500 text-[10px]">Pro unlocks private circles, planning tools, and rewards display</p>
          </div>
          <Link
            to="/profile?upgrade=1"
            className="shrink-0 px-3 py-1.5 rounded-full bg-amber-500/20 border border-amber-500/30 text-amber-400 text-[10px] font-bold hover:bg-amber-500/30 transition-colors"
          >
            PRO
          </Link>
        </div>
      )}

      {/* Posts */}
      <div className="px-4 flex flex-col gap-4">
        {/* New post box — gated beyond free */}
        {user ? (
          <div className="flex items-center gap-3 p-3 rounded-2xl border border-white/10 bg-[#1A1628]">
            <img
              src={user.avatar ?? 'https://i.pravatar.cc/100?img=3'}
              alt={user.name}
              className="w-8 h-8 rounded-full border border-white/10 object-cover"
            />
            <div className="flex-1 bg-white/5 rounded-xl px-3 py-2 text-sm text-gray-500">
              Share a pour, check-in, or adventure...
            </div>
          </div>
        ) : (
          <div className="p-4 rounded-2xl border border-white/10 bg-[#1A1628] text-center">
            <p className="text-gray-400 text-sm mb-2">Join to post and interact with Pour Circle</p>
            <Link to="/onboarding" className="text-amber-400 text-sm font-semibold">Sign up free →</Link>
          </div>
        )}

        {currentCircle.posts.map(post => (
          <PostCard key={post.id} post={post} />
        ))}
      </div>

      {/* Pro perks section */}
      {isPaid && (
        <div className="mx-4 mt-6 p-4 rounded-2xl border border-amber-500/20 bg-amber-500/5">
          <p className="text-amber-400 font-semibold text-sm mb-2">🎁 Pro Perks This Week</p>
          <div className="flex flex-col gap-2">
            {[
              '20% off at The Copper Still — show Pro badge at door',
              'Early access: Mezcal Masterclass on March 23',
              'Free tasting at Agave & Smoke for Pro members',
            ].map((perk, i) => (
              <div key={i} className="flex items-start gap-2 text-xs text-gray-300">
                <span className="text-amber-500 mt-0.5">•</span>
                {perk}
              </div>
            ))}
          </div>
        </div>
      )}
    </div>
  );
};
