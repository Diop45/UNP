import React from 'react';
import { Link } from 'react-router-dom';
import { ArrowRight } from 'lucide-react';

interface HeroCardProps {
  to: string;
  label: string;
  title: string;
  subtitle: string;
  image: string;
  accent?: string;
  badge?: string;
}

export const HeroCard: React.FC<HeroCardProps> = ({
  to, label, title, subtitle, image, accent = 'amber', badge,
}) => {
  const accentClasses = accent === 'purple'
    ? 'border-purple-500/30 hover:border-purple-500/60 hover:shadow-[0_8px_32px_rgba(168,85,247,0.2)]'
    : accent === 'blue'
    ? 'border-blue-500/30 hover:border-blue-500/60 hover:shadow-[0_8px_32px_rgba(59,130,246,0.2)]'
    : 'border-amber-500/30 hover:border-amber-500/60 hover:shadow-[0_8px_32px_rgba(245,158,11,0.2)]';

  const labelClasses = accent === 'purple'
    ? 'text-purple-400 bg-purple-500/20 border-purple-500/30'
    : accent === 'blue'
    ? 'text-blue-400 bg-blue-500/20 border-blue-500/30'
    : 'text-amber-400 bg-amber-500/20 border-amber-500/30';

  return (
    <Link
      to={to}
      className={`group relative overflow-hidden rounded-2xl border bg-surface-800 transition-all duration-300 card-hover ${accentClasses}`}
    >
      <div className="relative h-44 overflow-hidden">
        <img
          src={image}
          alt={title}
          className="w-full h-full object-cover group-hover:scale-105 transition-transform duration-500"
        />
        <div className="absolute inset-0 bg-gradient-to-t from-[#13101E] via-transparent to-transparent" />
        {badge && (
          <span className="absolute top-3 right-3 text-[10px] px-2 py-0.5 rounded-full bg-black/60 border border-white/20 text-white/80">
            {badge}
          </span>
        )}
      </div>
      <div className="p-4">
        <span className={`inline-block text-[10px] font-semibold uppercase tracking-wider px-2 py-0.5 rounded-full border mb-2 ${labelClasses}`}>
          {label}
        </span>
        <h3 className="text-white font-bold text-base leading-tight mb-1">{title}</h3>
        <p className="text-gray-400 text-sm leading-relaxed line-clamp-2">{subtitle}</p>
        <div className={`flex items-center gap-1 mt-3 text-xs font-medium ${
          accent === 'purple' ? 'text-purple-400' : accent === 'blue' ? 'text-blue-400' : 'text-amber-400'
        }`}>
          <span>Explore</span>
          <ArrowRight size={12} className="group-hover:translate-x-1 transition-transform" />
        </div>
      </div>
    </Link>
  );
};
