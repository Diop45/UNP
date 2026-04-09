import { Link, useNavigate } from "@tanstack/react-router";
import { BrandLogo } from "@/components/BrandLogo";
import { BEVERAGES, MOCK_USERS, REWARD_ITEMS } from "@/data/seed";
import { tierFromPoints, useAppStore } from "@/data/store";
import type { UserRole } from "@/data/types";
import "./ProfileScreen.css";

const ROLES: UserRole[] = ["guest", "free", "paid", "ambassador"];

export function ProfileScreen() {
  const navigate = useNavigate();
  const role = useAppStore((s) => s.role);
  const setRole = useAppStore((s) => s.setRole);
  const points = useAppStore((s) => s.points);
  const saved = useAppStore((s) => s.savedBeverageIds);
  const notifications = useAppStore((s) => s.notifications);
  const setNotification = useAppStore((s) => s.setNotification);
  const restartTour = useAppStore((s) => s.restartTour);
  const setTourStep = useAppStore((s) => s.setTourStep);

  const tier = tierFromPoints(points);
  const paid = role === "paid" || role === "ambassador";

  return (
    <div className="unp-page unp-profile">
      <header className="unp-profile__head">
        <BrandLogo size="sm" className="unp-profile__logo" />
        <div>
          <span className="unp-chip">{roleLabel(role)}</span>
          <h1 style={{ margin: "8px 0 0" }}>Profile</h1>
          <p className="unp-muted">
            {tier} · {points} pts · rewards reset monthly
          </p>
        </div>
      </header>

      <section className="unp-card" style={{ padding: 16 }}>
        <h2 style={{ marginTop: 0 }}>Subscription</h2>
        <p className="unp-muted">
          {paid ? "Premium active — full Pour, Explore RSVP, Circles, Ambassador tools." : "Free — upgrade prompts on locked surfaces."}
        </p>
        {!paid && (
          <button type="button" className="unp-btn-primary" style={{ marginTop: 10 }} onClick={() => setRole("paid")}>
            Demo: switch to Paid
          </button>
        )}
      </section>

      <section>
        <h2>Saved beverages</h2>
        <div className="unp-profile__grid">
          {saved.map((id) => {
            const b = BEVERAGES.find((x) => x.id === id);
            if (!b) return null;
            return (
              <Link key={id} to="/pour" search={{ focus: id }} className="unp-card unp-profile__cell">
                {b.name}
              </Link>
            );
          })}
        </div>
      </section>

      <section>
        <h2>Reward items</h2>
        <div className="unp-profile__rewards">
          {REWARD_ITEMS.map((r) => (
            <div key={r.id} className="unp-card" style={{ padding: 12 }}>
              <strong>{r.label}</strong>
              <p className="unp-muted" style={{ margin: "6px 0 0", fontSize: "0.85rem" }}>
                Demo inventory
              </p>
            </div>
          ))}
        </div>
      </section>

      <section>
        <h2>Mock roster</h2>
        <ul className="unp-muted">
          {MOCK_USERS.map((u) => (
            <li key={u.id}>
              {u.name} — {u.role}
            </li>
          ))}
        </ul>
      </section>

      <section className="unp-card" style={{ padding: 16 }}>
        <h2 style={{ marginTop: 0 }}>Settings</h2>
        <label className="unp-profile__set">
          Event notifications
          <input type="checkbox" checked={notifications.events} onChange={(e) => setNotification("events", e.target.checked)} />
        </label>
        <label className="unp-profile__set">
          Chat notifications
          <input type="checkbox" checked={notifications.chat} onChange={(e) => setNotification("chat", e.target.checked)} />
        </label>
        <label className="unp-profile__set">
          Rewards notifications
          <input type="checkbox" checked={notifications.rewards} onChange={(e) => setNotification("rewards", e.target.checked)} />
        </label>

        <label className="unp-profile__set unp-profile__set--col">
          <span>Role switcher (demo)</span>
          <select value={role} onChange={(e) => setRole(e.target.value as UserRole)}>
            {ROLES.map((r) => (
              <option key={r} value={r}>
                {roleLabel(r)}
              </option>
            ))}
          </select>
        </label>

        <button
          type="button"
          className="unp-btn-ghost"
          style={{ marginTop: 12, width: "100%" }}
          onClick={() => {
            restartTour();
            setTourStep(0);
            navigate({ to: "/" });
          }}
        >
          Restart guided tour
        </button>

        <Link to="/demo-screenshots" className="unp-link" style={{ display: "block", marginTop: 14 }}>
          Demo screenshots &amp; ZIP export
        </Link>
      </section>
    </div>
  );
}

function roleLabel(r: UserRole) {
  switch (r) {
    case "guest":
      return "Guest";
    case "free":
      return "Free";
    case "paid":
      return "Paid";
    case "ambassador":
      return "Beverage Ambassador";
  }
}
