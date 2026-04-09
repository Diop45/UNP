import { useNavigate } from "@tanstack/react-router";
import { useAppStore } from "@/data/store";
import "./Tour.css";

const STEPS = [
  { path: "/" as const, title: "Home", body: "Hero cards jump to Pour, Nudge, and Explore. City header stays ambient." },
  { path: "/explore" as const, title: "Explore", body: "Map + list, time filters, amber pins on Detroit. Events link to drinks & nudges." },
  { path: "/pour" as const, title: "Pour", body: "Recipes scale by role: Free sees names, Paid unlocks full builds, Ambassadors upload." },
  { path: "/nudge" as const, title: "Nudge", body: "Tonight’s Plan chains venue → drink → venue with mood and SMS-ready shares." },
  { path: "/circles" as const, title: "Circles", body: "Rewards, chats, and perks — upgrade prompts for Free, full suite for Paid." },
  { path: "/profile" as const, title: "Profile", body: "Tier, saves, subscription — restart the tour anytime from Settings." },
];

export function TourLauncher() {
  const tourCompleted = useAppStore((s) => s.tourCompleted);
  const tourSkipped = useAppStore((s) => s.tourSkipped);
  const tourIntroSeen = useAppStore((s) => s.tourIntroSeen);
  const skipTour = useAppStore((s) => s.skipTour);
  const restartTour = useAppStore((s) => s.restartTour);
  const setTourStep = useAppStore((s) => s.setTourStep);
  const navigate = useNavigate();

  if (tourCompleted) return null;

  const showIntro = !tourIntroSeen && !tourSkipped;

  if (showIntro) {
    return (
      <div className="unp-tour-modal" role="dialog" aria-modal="true" aria-labelledby="tour-intro-title">
        <div className="unp-card unp-tour-modal__inner">
          <div className="unp-tour-modal__logo">
            <img src="/unp-logo.png" alt="Until The Next Pour" decoding="async" />
          </div>
          <h2 id="tour-intro-title">Welcome to Until The Next Pour</h2>
          <p className="unp-muted">Ambient nights, warm amber accents, Detroit-first. Take a quick tour of all five tabs.</p>
          <div className="unp-tour-modal__actions">
            <button
              type="button"
              className="unp-btn-primary"
              onClick={() => {
                restartTour();
                setTourStep(0);
                navigate({ to: "/" });
              }}
            >
              Start Tour
            </button>
            <button type="button" className="unp-btn-ghost" onClick={() => skipTour()}>
              Skip
            </button>
          </div>
        </div>
      </div>
    );
  }

  return <TourCoach />;
}

function TourCoach() {
  const tourCompleted = useAppStore((s) => s.tourCompleted);
  const tourSkipped = useAppStore((s) => s.tourSkipped);
  const tourStep = useAppStore((s) => s.tourStep);
  const setTourStep = useAppStore((s) => s.setTourStep);
  const completeTour = useAppStore((s) => s.completeTour);
  const navigate = useNavigate();

  const step = STEPS[tourStep];
  const active = !tourCompleted && !tourSkipped && tourStep < STEPS.length && step;

  if (!active || !step) return null;

  return (
    <div className="unp-tour-coach" role="dialog" aria-modal="true">
      <div className="unp-tour-coach__backdrop" />
      <div className="unp-card unp-tour-coach__card">
        <div className="unp-chip">
          {tourStep + 1}/{STEPS.length}
        </div>
        <h3>{step.title}</h3>
        <p className="unp-muted">{step.body}</p>
        <div className="unp-tour-modal__actions">
          <button
            type="button"
            className="unp-btn-ghost"
            onClick={() => {
              if (tourStep === 0) {
                completeTour();
              } else {
                const next = tourStep - 1;
                setTourStep(next);
                navigate({ to: STEPS[next].path });
              }
            }}
          >
            {tourStep === 0 ? "End" : "Back"}
          </button>
          <button
            type="button"
            className="unp-btn-primary"
            onClick={() => {
              if (tourStep >= STEPS.length - 1) {
                completeTour();
              } else {
                const next = tourStep + 1;
                setTourStep(next);
                navigate({ to: STEPS[next].path });
              }
            }}
          >
            {tourStep >= STEPS.length - 1 ? "Finish" : "Next"}
          </button>
        </div>
      </div>
    </div>
  );
}
