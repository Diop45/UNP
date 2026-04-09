import { create } from "zustand";
import { persist, createJSONStorage } from "zustand/middleware";
import type { UserRole, AmbassadorUpload } from "./types";
import { BEVERAGES } from "./seed";

const MONTH_KEY = () => {
  const d = new Date();
  return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}`;
};

function tierFromPoints(p: number): "Bronze" | "Silver" | "Gold" {
  if (p >= 300) return "Gold";
  if (p >= 100) return "Silver";
  return "Bronze";
}

export interface AppState {
  role: UserRole;
  points: number;
  pointsMonthKey: string;
  savedBeverageIds: string[];
  notifications: { events: boolean; chat: boolean; rewards: boolean };
  circlesVisibility: { profile: boolean; plans: boolean; location: boolean };
  tourSkipped: boolean;
  tourCompleted: boolean;
  tourStep: number;
  /** After first Start/Skip, intro modal never reappears; coach can restart from Profile */
  tourIntroSeen: boolean;
  ambassadorUploads: AmbassadorUpload[];
  pollSelections: Record<string, number>;
  nudgePlan: {
    venueId: string | null;
    beverageId: string | null;
    venueAfterId: string | null;
    mood: string;
  };
  /** Simulated pending keys for spinners */
  pending: Record<string, boolean>;
  setRole: (r: UserRole) => void;
  addPoints: (delta: number, reason: string) => void;
  toggleSaveBeverage: (id: string) => void;
  setNotification: (k: keyof AppState["notifications"], v: boolean) => void;
  setCirclesVisibility: (k: keyof AppState["circlesVisibility"], v: boolean) => void;
  skipTour: () => void;
  completeTour: () => void;
  setTourStep: (n: number) => void;
  restartTour: () => void;
  setPollSelection: (pollId: string, optionIndex: number) => void;
  setNudgePlan: (partial: Partial<AppState["nudgePlan"]>) => void;
  addAmbassadorUpload: (name: string) => void;
  deleteAmbassadorUpload: (id: string) => void;
  runAsync: (key: string, ms: number, fn: () => void) => void;
  resetDemo: () => void;
}

function ensureMonthlyReset(state: AppState): AppState {
  const m = MONTH_KEY();
  if (state.pointsMonthKey === m) return state;
  return { ...state, points: 0, pointsMonthKey: m };
}

export const useAppStore = create<AppState>()(
  persist(
    (set, get) => ({
      role: "free",
      points: 350,
      pointsMonthKey: MONTH_KEY(),
      savedBeverageIds: [BEVERAGES[0].id, BEVERAGES[3].id],
      notifications: { events: true, chat: true, rewards: true },
      circlesVisibility: { profile: true, plans: true, location: false },
      tourSkipped: false,
      tourCompleted: false,
      tourStep: 0,
      tourIntroSeen: false,
      ambassadorUploads: [
        {
          id: "up-1",
          name: "House Spiced Old Fashioned",
          createdAt: new Date().toISOString(),
          views: 128,
          saves: 34,
        },
      ],
      pollSelections: {},
      nudgePlan: {
        venueId: "evt-speakeasy",
        beverageId: "bev-negroni",
        venueAfterId: "evt-afterdark",
        mood: "High energy",
      },
      pending: {},
      setRole: (role) => set({ role }),
      addPoints: (delta, _reason) =>
        set((s) => {
          const e = ensureMonthlyReset(s);
          return { ...e, points: Math.max(0, e.points + delta) };
        }),
      toggleSaveBeverage: (id) =>
        set((s) => {
          const has = s.savedBeverageIds.includes(id);
          const next = has ? s.savedBeverageIds.filter((x) => x !== id) : [...s.savedBeverageIds, id];
          if (!has) get().addPoints(10, "save");
          return { savedBeverageIds: next };
        }),
      setNotification: (k, v) => set((s) => ({ notifications: { ...s.notifications, [k]: v } })),
      setCirclesVisibility: (k, v) => set((s) => ({ circlesVisibility: { ...s.circlesVisibility, [k]: v } })),
      skipTour: () => set({ tourSkipped: true, tourCompleted: true, tourIntroSeen: true }),
      completeTour: () => set({ tourCompleted: true, tourSkipped: false, tourIntroSeen: true }),
      setTourStep: (n) => set({ tourStep: n }),
      restartTour: () => set({ tourCompleted: false, tourSkipped: false, tourStep: 0, tourIntroSeen: true }),
      setPollSelection: (pollId, optionIndex) =>
        set((s) => ({
          pollSelections: { ...s.pollSelections, [pollId]: optionIndex },
        })),
      setNudgePlan: (partial) => set((s) => ({ nudgePlan: { ...s.nudgePlan, ...partial } })),
      addAmbassadorUpload: (name) =>
        set((s) => {
          const id = `up-${Date.now()}`;
          const row: AmbassadorUpload = {
            id,
            name,
            createdAt: new Date().toISOString(),
            views: 0,
            saves: 0,
          };
          get().addPoints(50, "upload");
          return { ambassadorUploads: [row, ...s.ambassadorUploads] };
        }),
      deleteAmbassadorUpload: (id) =>
        set((s) => ({ ambassadorUploads: s.ambassadorUploads.filter((x) => x.id !== id) })),
      runAsync: (key, ms, fn) => {
        set((s) => ({ pending: { ...s.pending, [key]: true } }));
        window.setTimeout(() => {
          fn();
          set((s) => {
            const next = { ...s.pending };
            delete next[key];
            return { pending: next };
          });
        }, ms);
      },
      resetDemo: () =>
        set({
          points: 350,
          pointsMonthKey: MONTH_KEY(),
          savedBeverageIds: [BEVERAGES[0].id, BEVERAGES[3].id],
          tourSkipped: false,
          tourCompleted: false,
          tourStep: 0,
          tourIntroSeen: false,
        }),
    }),
    {
      name: "unp-app-v1",
      storage: createJSONStorage(() => localStorage),
      partialize: (s) => ({
        role: s.role,
        points: s.points,
        pointsMonthKey: s.pointsMonthKey,
        savedBeverageIds: s.savedBeverageIds,
        notifications: s.notifications,
        circlesVisibility: s.circlesVisibility,
        tourSkipped: s.tourSkipped,
        tourCompleted: s.tourCompleted,
        tourStep: s.tourStep,
        tourIntroSeen: s.tourIntroSeen,
        ambassadorUploads: s.ambassadorUploads,
        pollSelections: s.pollSelections,
        nudgePlan: s.nudgePlan,
      }),
    }
  )
);

export { tierFromPoints, MONTH_KEY };
