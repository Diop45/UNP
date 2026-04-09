import { Link } from "@tanstack/react-router";
import { BrandLogo } from "@/components/BrandLogo";
import { CITY, EVENTS, NUDGES, BEVERAGES } from "@/data/seed";
import { useAppStore } from "@/data/store";
import "./HomeScreen.css";

export function HomeScreen() {
  const role = useAppStore((s) => s.role);
  const showUpgrade = role === "free" || role === "guest";

  return (
    <div className="unp-page unp-home">
      <header className="unp-home__header">
        <div className="unp-home__brandBlock">
          <BrandLogo size="sm" />
          <div>
            <p className="unp-muted" style={{ margin: 0 }}>
              Tonight in
            </p>
            <h1 className="unp-home__city">{CITY}</h1>
          </div>
        </div>
        <Link to="/profile" className="unp-home__avatar" aria-label="Profile">
          <span />
        </Link>
      </header>

      {showUpgrade && (
        <div className="unp-card unp-home__cta" style={{ padding: 14, marginBottom: 16 }}>
          <strong style={{ color: "var(--unp-accent-soft)" }}>Go Premium</strong>
          <p className="unp-muted" style={{ margin: "6px 0 0" }}>
            Unlock full recipes, RSVP depth, and Circles rewards. You’re on{" "}
            {role === "guest" ? "Guest" : "Free"} — switch role in Profile for demos.
          </p>
        </div>
      )}

      <section className="unp-home__heroes">
        <Link to="/pour" className="unp-card unp-home__hero unp-home__hero--pour">
          <span className="unp-chip">Pour</span>
          <h2>Recipe vault</h2>
          <p className="unp-muted">Six classics with playlists &amp; pairings — {BEVERAGES[0].name} to {BEVERAGES[5].name}.</p>
        </Link>
        <Link to="/nudge" className="unp-card unp-home__hero unp-home__hero--nudge">
          <span className="unp-chip">Nudge</span>
          <h2>{NUDGES[0].title}</h2>
          <p className="unp-muted">{NUDGES[0].subtitle} · polls + tonight’s plan.</p>
        </Link>
        <Link to="/explore" className="unp-card unp-home__hero unp-home__hero--explore">
          <span className="unp-chip">Explore</span>
          <h2>Events Near You</h2>
          <p className="unp-muted">{EVENTS[0].title} · {EVENTS[1].title} · map + list.</p>
        </Link>
      </section>

      <section style={{ marginTop: 20 }}>
        <h3 style={{ margin: "0 0 10px", fontSize: "1rem" }}>Live picks</h3>
        <div className="unp-home__grid">
          {BEVERAGES.slice(0, 3).map((b) => (
            <Link key={b.id} to="/pour" search={{ focus: b.id }} className="unp-card unp-home__mini">
              <strong>{b.name}</strong>
              <p className="unp-muted" style={{ margin: "6px 0 0", fontSize: "0.8rem" }}>
                {b.glassware}
              </p>
            </Link>
          ))}
        </div>
      </section>
    </div>
  );
}
