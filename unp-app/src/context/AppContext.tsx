import React, { createContext, useContext, useState, useEffect } from 'react';
import type { User, UserRole } from '../types';
import { demoUsers } from '../data/users';

interface AppContextType {
  user: User | null;
  setUser: (user: User | null) => void;
  hasSeenOnboarding: boolean;
  completeOnboarding: () => void;
  tourStep: number | null;
  activeTour: string | null;
  startTour: (tourId: string) => void;
  nextTourStep: () => void;
  endTour: () => void;
  savedBeverageIds: string[];
  toggleSaveBeverage: (id: string) => void;
  loginAs: (role: UserRole) => void;
  logout: () => void;
}

const AppContext = createContext<AppContextType | null>(null);

export const useApp = () => {
  const ctx = useContext(AppContext);
  if (!ctx) throw new Error('useApp must be used within AppProvider');
  return ctx;
};

const TOUR_STEPS: Record<string, number> = {
  home: 5,
  pour: 4,
  explore: 3,
  circle: 4,
};

export const AppProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [user, setUserState] = useState<User | null>(null);
  const [hasSeenOnboarding, setHasSeenOnboarding] = useState(false);
  const [tourStep, setTourStep] = useState<number | null>(null);
  const [activeTour, setActiveTour] = useState<string | null>(null);
  const [savedBeverageIds, setSavedBeverageIds] = useState<string[]>([]);

  useEffect(() => {
    const stored = localStorage.getItem('unp_user');
    if (stored) {
      try { setUserState(JSON.parse(stored)); } catch {}
    }
    const seen = localStorage.getItem('unp_onboarding');
    if (seen) setHasSeenOnboarding(true);
    const saved = localStorage.getItem('unp_saved_bevs');
    if (saved) {
      try { setSavedBeverageIds(JSON.parse(saved)); } catch {}
    }
  }, []);

  const setUser = (u: User | null) => {
    setUserState(u);
    if (u) localStorage.setItem('unp_user', JSON.stringify(u));
    else localStorage.removeItem('unp_user');
  };

  const loginAs = (role: UserRole) => {
    const demo = demoUsers.find(u => u.role === role) ?? demoUsers[0];
    setUser(demo);
  };

  const logout = () => {
    setUser(null);
    localStorage.removeItem('unp_user');
  };

  const completeOnboarding = () => {
    setHasSeenOnboarding(true);
    localStorage.setItem('unp_onboarding', '1');
  };

  const startTour = (tourId: string) => {
    setActiveTour(tourId);
    setTourStep(0);
  };

  const nextTourStep = () => {
    if (activeTour && tourStep !== null) {
      const max = TOUR_STEPS[activeTour] ?? 3;
      if (tourStep >= max - 1) {
        endTour();
      } else {
        setTourStep(tourStep + 1);
      }
    }
  };

  const endTour = () => {
    setActiveTour(null);
    setTourStep(null);
  };

  const toggleSaveBeverage = (id: string) => {
    setSavedBeverageIds(prev => {
      const next = prev.includes(id) ? prev.filter(x => x !== id) : [...prev, id];
      localStorage.setItem('unp_saved_bevs', JSON.stringify(next));
      return next;
    });
  };

  return (
    <AppContext.Provider value={{
      user, setUser, hasSeenOnboarding, completeOnboarding,
      tourStep, activeTour, startTour, nextTourStep, endTour,
      savedBeverageIds, toggleSaveBeverage,
      loginAs, logout,
    }}>
      {children}
    </AppContext.Provider>
  );
};
