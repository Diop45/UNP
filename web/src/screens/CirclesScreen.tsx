import { Link } from "@tanstack/react-router";
import { REWARD_ITEMS, EVENTS } from "@/data/seed";
import { tierFromPoints, useAppStore } from "@/data/store";
import { GuestGate } from "@/components/GuestGate";
import "./CirclesScreen.css";

const CHATS = [
  { id: "c1", title: "Crew · Downtown", last: "See you at After Dark", unread: 2 },
  { id: "c2", title: "Mixology alumni", last: "Who’s bringing vermouth?", unread: 0 },
  { id: "c3", title: "Detroit Pour Society", last: "Funk & Bourbon RSVP", unread: 1 },
];

const THREADS = [
  { id: "t1", title: "Group plan · Friday", body: "Starting Speakeasy 9pm → espresso shots at Pulse" },
  { id: "t2", title: "Venue thread · Copper Still", body: "Bourbon flights still on?" },
];

export function CirclesScreen() {
  const role = useAppStore((s) => s.role);
  const points = useAppStore((s) => s.points);
  const vis = useAppStore((s) => s.circlesVisibility);
  const setVis = useAppStore((s) => s.setCirclesVisibility);

  const paid = role === "paid" || role === "ambassador";
  const tier = tierFromPoints(points);
  const goal = 500;
  const pct = Math.min(100, (points / goal) * 100);

  if (role === "guest") {
    return (
      <div className="unp-page">
        <GuestGate title="Circles is for members">
          <div className="unp-card" style={{ padding: 16 }}>
            <p className="unp-muted">Preview: chats, rewards, threads unlock on Free+.</p>
          </div>
        </GuestGate>
      </div>
    );
  }

  return (
    <div className="unp-page unp-circles">
      <h1 style={{ marginTop: 0 }}>Circles</h1>

      {!paid && (
        <div className="unp-card" style={{ padding: 14, marginBottom: 14 }}>
          <strong style={{ color: "var(--unp-accent-soft)" }}>Upgrade to Premium</strong>
          <p className="unp-muted" style={{ margin: "6px 0 0" }}>
            Visibility toggles below are live. Chats, planning threads, and full rewards bar unlock with Premium.
          </p>
          <ul className="unp-muted" style={{ paddingLeft: 18 }}>
            <li>Live crew chats</li>
            <li>Group planning threads</li>
            <li>Venue perks &amp; martini specials</li>
          </ul>
          <Link to="/profile" className="unp-btn-primary" style={{ display: "inline-block", marginTop: 10 }}>
            Upgrade to Premium
          </Link>
        </div>
      )}

      <section className="unp-circles__vis">
        <h2>Visibility</h2>
        {(["profile", "plans", "location"] as const).map((k) => (
          <label key={k} className="unp-circles__toggle">
            <span>Show {k}</span>
            <input type="checkbox" checked={vis[k]} onChange={(e) => setVis(k, e.target.checked)} />
          </label>
        ))}
      </section>

      {paid && (
        <>
          <section>
            <h2>Rewards</h2>
            <div className="unp-card" style={{ padding: 16 }}>
              <p>
                <strong>{tier}</strong> tier · {points} pts · monthly reset
              </p>
              <div className="unp-circles__bar">
                <div className="unp-circles__fill" style={{ width: `${pct}%` }} />
              </div>
              <p className="unp-muted" style={{ margin: "8px 0 0" }}>
                {points} / {goal} XP goal (demo)
              </p>
              <div className="unp-circles__rewards">
                {REWARD_ITEMS.map((r) => (
                  <span key={r.id} className="unp-chip">
                    {r.label}
                  </span>
                ))}
              </div>
            </div>
          </section>

          <section>
            <h2>Active chats</h2>
            {CHATS.map((c) => (
              <div key={c.id} className="unp-card unp-circles__chat">
                <div>
                  <strong>{c.title}</strong>
                  <p className="unp-muted" style={{ margin: "4px 0 0" }}>
                    {c.last}
                  </p>
                </div>
                {c.unread > 0 && <span className="unp-circles__badge">{c.unread}</span>}
              </div>
            ))}
          </section>

          <section>
            <h2>Planning &amp; venues</h2>
            {THREADS.map((t) => (
              <div key={t.id} className="unp-card" style={{ padding: 12, marginBottom: 8 }}>
                <strong>{t.title}</strong>
                <p className="unp-muted" style={{ margin: "6px 0 0" }}>
                  {t.body}
                </p>
              </div>
            ))}
            <p className="unp-muted">
              Linked events: {EVENTS.slice(0, 2).map((e) => e.title).join(", ")} — open in{" "}
              <Link to="/explore" className="unp-link">
                Explore
              </Link>
              .
            </p>
          </section>
        </>
      )}
    </div>
  );
}
