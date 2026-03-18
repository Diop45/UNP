import React, { useState } from 'react';
import { Link } from 'react-router-dom';
import { ArrowLeft, Download } from 'lucide-react';

type RoleFilter = 'all' | 'free' | 'paid' | 'ambassador';
type SectionFilter = 'all' | 'home' | 'pour' | 'nudge' | 'explore' | 'circles' | 'profile';

interface Screenshot {
  id: string;
  title: string;
  description: string;
  section: Exclude<SectionFilter, 'all'>;
  roles: Exclude<RoleFilter, 'all'>[];
  image: string;
  route: string;
}

const SCREENSHOTS: Screenshot[] = [
  {
    id: 's-001',
    title: 'Home — Guest View',
    description: 'Default landing page with 3 hero cards visible to all users.',
    section: 'home',
    roles: ['free'],
    image: 'https://images.unsplash.com/photo-1514362545857-3bc16c4c7d1b?w=800&q=80',
    route: '/',
  },
  {
    id: 's-002',
    title: 'Home — Pro User',
    description: 'Home with Pro badge, personalized greeting, and all features accessible.',
    section: 'home',
    roles: ['paid'],
    image: 'https://images.unsplash.com/photo-1551024709-8f23befc6f87?w=800&q=80',
    route: '/',
  },
  {
    id: 's-003',
    title: 'Pour — Beverage Library',
    description: 'Full beverage grid with search, category filters, and Pro/Free indicators.',
    section: 'pour',
    roles: ['free', 'paid', 'ambassador'],
    image: 'https://images.unsplash.com/photo-1470337458703-46ad1756a187?w=800&q=80',
    route: '/pour',
  },
  {
    id: 's-004',
    title: 'Beverage Detail — Free Preview',
    description: 'Free view: ingredients visible, instructions and pairings locked behind Pro.',
    section: 'pour',
    roles: ['free'],
    image: 'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80',
    route: '/pour/bev-002',
  },
  {
    id: 's-005',
    title: 'Beverage Detail — Full Pro Recipe',
    description: 'Pro view: full step-by-step instructions, technique notes, and pairings.',
    section: 'pour',
    roles: ['paid', 'ambassador'],
    image: 'https://images.unsplash.com/photo-1527281400683-1aae777175f8?w=800&q=80',
    route: '/pour/bev-002',
  },
  {
    id: 's-006',
    title: 'Ambassador Upload Tool',
    description: 'Recipe submission form with photo/video upload — Ambassador exclusive.',
    section: 'pour',
    roles: ['ambassador'],
    image: 'https://images.unsplash.com/photo-1571867424488-4565932edb41?w=800&q=80',
    route: '/pour/upload',
  },
  {
    id: 's-007',
    title: 'Nudge — Adventure Library',
    description: 'All micro-adventures with category filters and free/pro indicators.',
    section: 'nudge',
    roles: ['free', 'paid'],
    image: 'https://images.unsplash.com/photo-1516997121675-4c2d1684aa3e?w=800&q=80',
    route: '/nudge',
  },
  {
    id: 's-008',
    title: 'Nudge Detail — 3-Step Plan',
    description: 'Pro view of a full personalized plan with beverage and event cross-links.',
    section: 'nudge',
    roles: ['paid'],
    image: 'https://images.unsplash.com/photo-1424847651672-bf20a4b0982b?w=800&q=80',
    route: '/nudge/nudge-003',
  },
  {
    id: 's-009',
    title: 'Explore — Events List',
    description: 'Event grid with time-of-day filters (Day/Night/Late Night) and search.',
    section: 'explore',
    roles: ['free', 'paid'],
    image: 'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=800&q=80',
    route: '/explore',
  },
  {
    id: 's-010',
    title: 'Explore — Map View',
    description: 'Visual event map with colored pins by time slot.',
    section: 'explore',
    roles: ['free', 'paid'],
    image: 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=800&q=80',
    route: '/explore',
  },
  {
    id: 's-011',
    title: 'Event Detail — Pro How-To-Attend',
    description: 'Full event detail with attendance instructions, tips, and beverage cross-links.',
    section: 'explore',
    roles: ['paid'],
    image: 'https://images.unsplash.com/photo-1559628233-100c798642d8?w=800&q=80',
    route: '/explore/evt-004',
  },
  {
    id: 's-012',
    title: 'Pour Circle — Community Feed',
    description: 'Social feed with ambassador posts, check-ins, and interactions.',
    section: 'circles',
    roles: ['free', 'paid', 'ambassador'],
    image: 'https://images.unsplash.com/photo-1528360983277-13d401cdc186?w=800&q=80',
    route: '/circles',
  },
  {
    id: 's-013',
    title: 'Pour Circle — Pro Perks',
    description: 'Pro member view with private circles, planning tools, and weekly perks.',
    section: 'circles',
    roles: ['paid'],
    image: 'https://images.unsplash.com/photo-1543007631-283050bb3e8c?w=800&q=80',
    route: '/circles',
  },
  {
    id: 's-014',
    title: 'Profile — Free User',
    description: 'Free user profile showing saves, Bronze tier rewards, and upgrade CTA.',
    section: 'profile',
    roles: ['free'],
    image: 'https://images.unsplash.com/photo-1525268771113-32d9e9021a97?w=800&q=80',
    route: '/profile',
  },
  {
    id: 's-015',
    title: 'Profile — Pro Member',
    description: 'Pro member profile with Silver/Gold rewards, activity feed, and perks.',
    section: 'profile',
    roles: ['paid'],
    image: 'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800&q=80',
    route: '/profile',
  },
  {
    id: 's-016',
    title: 'Profile — Ambassador Dashboard',
    description: 'Ambassador profile with Gold tier, uploaded recipes management, and analytics.',
    section: 'profile',
    roles: ['ambassador'],
    image: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=800&q=80',
    route: '/profile',
  },
  {
    id: 's-017',
    title: 'Onboarding — Role Selection',
    description: 'First-run onboarding with Free/Pro/Ambassador role picker.',
    section: 'home',
    roles: ['free', 'paid', 'ambassador'],
    image: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&q=80',
    route: '/onboarding',
  },
];

const SECTIONS: { value: SectionFilter; label: string }[] = [
  { value: 'all', label: 'All' },
  { value: 'home', label: 'Home' },
  { value: 'pour', label: 'Pour' },
  { value: 'nudge', label: 'Nudge' },
  { value: 'explore', label: 'Explore' },
  { value: 'circles', label: 'Circles' },
  { value: 'profile', label: 'Profile' },
];

const ROLES: { value: RoleFilter; label: string }[] = [
  { value: 'all', label: 'All Roles' },
  { value: 'free', label: 'Free' },
  { value: 'paid', label: 'Pro' },
  { value: 'ambassador', label: 'Ambassador' },
];

const roleColors: Record<string, string> = {
  free: 'text-gray-400 bg-white/5 border-white/10',
  paid: 'text-amber-400 bg-amber-500/10 border-amber-500/20',
  ambassador: 'text-purple-400 bg-purple-500/10 border-purple-500/20',
};

export const DemoPage: React.FC = () => {
  const [roleFilter, setRoleFilter] = useState<RoleFilter>('all');
  const [sectionFilter, setSectionFilter] = useState<SectionFilter>('all');
  const [selected, setSelected] = useState<string[]>([]);

  const filtered = SCREENSHOTS.filter(s => {
    if (roleFilter !== 'all' && !s.roles.includes(roleFilter)) return false;
    if (sectionFilter !== 'all' && s.section !== sectionFilter) return false;
    return true;
  });

  const toggleSelect = (id: string) => {
    setSelected(prev => prev.includes(id) ? prev.filter(x => x !== id) : [...prev, id]);
  };

  const handleBulkExport = () => {
    alert(`Export ZIP: ${selected.length || filtered.length} screenshots selected.\n(In production, this would trigger a ZIP download of the selected screenshots.)`);
  };

  return (
    <div className="min-h-screen px-4 pt-6 pb-10">
      {/* Header */}
      <div className="flex items-center gap-3 mb-4">
        <Link to="/profile" className="w-9 h-9 rounded-full bg-white/5 border border-white/10 flex items-center justify-center">
          <ArrowLeft size={16} className="text-white" />
        </Link>
        <div>
          <h1 className="text-xl font-bold text-white">Demo Screenshots</h1>
          <p className="text-gray-400 text-xs mt-0.5">{SCREENSHOTS.length} screens · All roles & journeys</p>
        </div>
        <button
          onClick={handleBulkExport}
          className="ml-auto flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-amber-500/20 border border-amber-500/30 text-amber-400 text-xs font-semibold hover:bg-amber-500/30 transition-colors"
        >
          <Download size={12} />
          Export ZIP
        </button>
      </div>

      {/* Role filter */}
      <div className="flex gap-2 overflow-x-auto pb-2 mb-3">
        {ROLES.map(r => (
          <button
            key={r.value}
            onClick={() => setRoleFilter(r.value)}
            className={`shrink-0 px-3 py-1.5 rounded-full text-xs font-medium border transition-colors ${
              roleFilter === r.value
                ? 'bg-amber-500 border-amber-500 text-black'
                : 'bg-white/5 border-white/10 text-gray-400 hover:border-white/20'
            }`}
          >
            {r.label}
          </button>
        ))}
      </div>

      {/* Section tabs */}
      <div className="flex gap-2 overflow-x-auto pb-3 mb-4">
        {SECTIONS.map(s => (
          <button
            key={s.value}
            onClick={() => setSectionFilter(s.value)}
            className={`shrink-0 px-3 py-1.5 rounded-full text-xs font-medium border transition-colors ${
              sectionFilter === s.value
                ? 'bg-blue-500 border-blue-500 text-white'
                : 'bg-white/5 border-white/10 text-gray-400 hover:border-white/20'
            }`}
          >
            {s.label}
          </button>
        ))}
      </div>

      {/* Selection summary */}
      {selected.length > 0 && (
        <div className="flex items-center gap-3 p-3 rounded-xl border border-amber-500/20 bg-amber-500/5 mb-4">
          <span className="text-amber-400 text-sm font-semibold">{selected.length} selected</span>
          <button
            onClick={handleBulkExport}
            className="flex items-center gap-1.5 px-3 py-1 rounded-full bg-amber-500/20 border border-amber-500/30 text-amber-400 text-xs font-semibold"
          >
            <Download size={11} /> Export Selected
          </button>
          <button onClick={() => setSelected([])} className="text-gray-500 text-xs ml-auto">Clear</button>
        </div>
      )}

      <p className="text-gray-500 text-xs mb-4">{filtered.length} screenshots</p>

      {/* Screenshot grid */}
      <div className="grid grid-cols-2 gap-3">
        {filtered.map(s => {
          const isSelected = selected.includes(s.id);
          return (
            <div
              key={s.id}
              className={`rounded-2xl border overflow-hidden cursor-pointer transition-all ${
                isSelected ? 'border-amber-500/60 shadow-[0_0_12px_rgba(245,158,11,0.2)]' : 'border-white/10 bg-[#1A1628]'
              }`}
              onClick={() => toggleSelect(s.id)}
            >
              <div className="relative overflow-hidden" style={{ height: '130px' }}>
                <img src={s.image} alt={s.title} className="w-full h-full object-cover" />
                <div className="absolute inset-0 bg-gradient-to-t from-[#1A1628] via-transparent to-transparent" />
                {isSelected && (
                  <div className="absolute top-2 right-2 w-5 h-5 rounded-full bg-amber-500 flex items-center justify-center">
                    <span className="text-black text-[10px] font-bold">✓</span>
                  </div>
                )}
                <div className="absolute top-2 left-2">
                  <span className="text-[9px] px-1.5 py-0.5 rounded-full bg-black/60 border border-white/10 text-gray-300 capitalize">
                    {s.section}
                  </span>
                </div>
              </div>
              <div className="p-2.5">
                <p className="text-white text-[11px] font-semibold leading-tight mb-1">{s.title}</p>
                <p className="text-gray-500 text-[10px] line-clamp-2 mb-1.5">{s.description}</p>
                <div className="flex flex-wrap gap-1">
                  {s.roles.map(r => (
                    <span key={r} className={`text-[9px] px-1.5 py-0.5 rounded-full border font-medium capitalize ${roleColors[r]}`}>
                      {r}
                    </span>
                  ))}
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Select all */}
      <div className="flex gap-3 mt-6">
        <button
          onClick={() => setSelected(filtered.map(s => s.id))}
          className="flex-1 py-2.5 rounded-xl border border-white/10 bg-white/5 text-gray-300 text-sm hover:bg-white/10 transition-colors"
        >
          Select All
        </button>
        <button
          onClick={handleBulkExport}
          className="flex-1 py-2.5 rounded-xl bg-gradient-to-r from-amber-600 to-amber-400 text-black font-bold text-sm hover:opacity-90 transition-opacity flex items-center justify-center gap-2"
        >
          <Download size={14} /> Export ZIP
        </button>
      </div>
    </div>
  );
};
