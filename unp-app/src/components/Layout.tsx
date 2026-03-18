import React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Home, Map, Wine, Users, User } from 'lucide-react';
import { useApp } from '../context/AppContext';

const NAV_ITEMS = [
  { path: '/', label: 'Home', icon: Home },
  { path: '/explore', label: 'Explore', icon: Map },
  { path: '/pour', label: 'Pour', icon: Wine },
  { path: '/circles', label: 'Circles', icon: Users },
  { path: '/profile', label: 'Profile', icon: User },
];

interface LayoutProps {
  children: React.ReactNode;
}

export const Layout: React.FC<LayoutProps> = ({ children }) => {
  const location = useLocation();
  const { user } = useApp();

  // Hide bottom nav on onboarding
  const hideNav = location.pathname === '/onboarding';

  return (
    <div className="flex flex-col min-h-screen bg-[#0D0A14]">
      {/* Top bar */}
      <header className="sticky top-0 z-40 glass border-b border-amber-500/10 px-4 py-3 flex items-center justify-between">
        <Link to="/" className="flex items-center gap-2">
          <span className="text-amber-400 font-bold text-lg tracking-tight">
            Until The Next <span className="text-gradient">Pour</span>
          </span>
        </Link>
        <div className="flex items-center gap-3">
          {user ? (
            <Link to="/profile" className="flex items-center gap-2">
              {user.avatar ? (
                <img src={user.avatar} alt={user.name} className="w-8 h-8 rounded-full border border-amber-500/30" />
              ) : (
                <div className="w-8 h-8 rounded-full bg-amber-500/20 border border-amber-500/30 flex items-center justify-center">
                  <span className="text-amber-400 text-xs font-bold">{user.name[0]}</span>
                </div>
              )}
              {user.role === 'paid' && (
                <span className="text-xs px-2 py-0.5 rounded-full bg-amber-500/20 text-amber-400 border border-amber-500/30">PRO</span>
              )}
              {user.role === 'ambassador' && (
                <span className="text-xs px-2 py-0.5 rounded-full bg-purple-500/20 text-purple-400 border border-purple-500/30">AMB</span>
              )}
            </Link>
          ) : (
            <Link
              to="/onboarding"
              className="text-xs px-3 py-1.5 rounded-full bg-amber-500 text-black font-semibold hover:bg-amber-400 transition-colors"
            >
              Get Started
            </Link>
          )}
        </div>
      </header>

      {/* Main content */}
      <main className="flex-1 pb-20">
        {children}
      </main>

      {/* Bottom navigation */}
      {!hideNav && (
        <nav className="fixed bottom-0 left-0 right-0 z-40 glass border-t border-amber-500/10">
          <div className="flex items-center justify-around px-2 py-2">
            {NAV_ITEMS.map(({ path, label, icon: Icon }) => {
              const active = path === '/'
                ? location.pathname === '/'
                : location.pathname.startsWith(path);
              return (
                <Link
                  key={path}
                  to={path}
                  className={`flex flex-col items-center gap-1 px-3 py-1 rounded-xl transition-all ${
                    active
                      ? 'text-amber-400'
                      : 'text-gray-500 hover:text-gray-300'
                  }`}
                >
                  <Icon size={20} strokeWidth={active ? 2.5 : 1.5} />
                  <span className="text-[10px] font-medium">{label}</span>
                </Link>
              );
            })}
          </div>
        </nav>
      )}
    </div>
  );
};
