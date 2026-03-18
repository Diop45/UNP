import React from 'react';
import { Link } from 'react-router-dom';
import { Lock, Star } from 'lucide-react';
import { useApp } from '../context/AppContext';
import type { UserRole } from '../types';

interface FeatureGateProps {
  requiredRole: UserRole;
  children?: React.ReactNode;
  preview?: React.ReactNode;
  label?: string;
  description?: string;
}

const ROLE_ORDER: UserRole[] = ['guest', 'free', 'paid', 'ambassador'];

const hasAccess = (userRole: UserRole | undefined, required: UserRole): boolean => {
  const userIdx = ROLE_ORDER.indexOf(userRole ?? 'guest');
  const reqIdx = ROLE_ORDER.indexOf(required);
  return userIdx >= reqIdx;
};

export const FeatureGate: React.FC<FeatureGateProps> = ({
  requiredRole,
  children,
  preview,
  label = 'Pro Feature',
  description = 'Upgrade to access this feature',
}) => {
  const { user } = useApp();
  const allowed = hasAccess(user?.role, requiredRole);

  if (allowed) return <>{children}</>;

  return (
    <div className="relative">
      {preview && (
        <div className="pointer-events-none select-none blur-sm opacity-50">
          {preview}
        </div>
      )}
      <div className={`${preview ? 'absolute inset-0' : ''} flex flex-col items-center justify-center gap-3 p-6 text-center`}>
        <div className="w-12 h-12 rounded-full bg-amber-500/10 border border-amber-500/20 flex items-center justify-center">
          <Lock size={20} className="text-amber-400" />
        </div>
        <div>
          <p className="text-white font-semibold mb-1">{label}</p>
          <p className="text-gray-400 text-sm">{description}</p>
        </div>
        {requiredRole === 'paid' && (
          <Link
            to="/profile?upgrade=1"
            className="flex items-center gap-2 px-4 py-2 rounded-full bg-gradient-to-r from-amber-600 to-amber-400 text-black font-semibold text-sm hover:opacity-90 transition-opacity"
          >
            <Star size={14} />
            Upgrade to Pro
          </Link>
        )}
        {requiredRole === 'ambassador' && (
          <Link
            to="/profile?ambassador=1"
            className="flex items-center gap-2 px-4 py-2 rounded-full bg-gradient-to-r from-purple-700 to-purple-500 text-white font-semibold text-sm hover:opacity-90 transition-opacity"
          >
            <Star size={14} />
            Apply as Ambassador
          </Link>
        )}
      </div>
    </div>
  );
};

export { hasAccess };
