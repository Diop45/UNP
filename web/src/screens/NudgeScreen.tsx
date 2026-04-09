import { useState } from "react";
import { Link } from "@tanstack/react-router";
import { NUDGES, EVENTS, getEventById, getBeverageById } from "@/data/seed";
import { useAppStore } from "@/data/store";
import { GuestGate } from "@/components/GuestGate";
import { Spinner } from "@/components/Spinner";
import "./NudgeScreen.css";

export function NudgeScreen() {
  const role = useAppStore((s) => s.role);
  const plan = useAppStore((s) => s.nudgePlan);
  const setPlan = useAppStore((s) => s.setNudgePlan);
  const pollSelections = useAppStore((s) => s.pollSelections);
  const setPoll = useAppStore((s) => s.setPollSelection);
  const runAsync = useAppStore((s) => s.runAsync);
  const pending = useAppStore((s) => s.pending);
  const addPoints = useAppStore((s) => s.addPoints);

  const paid = role === "paid" || role === "ambassador";
  const [smsOk, setSmsOk] = useState(false);

  const completePlan = () => {
    runAsync("plan", 700, () => {
      addPoints(15, "plan");
      setSmsOk(true);
    });
  };

  if (role === "guest") {
    return (
      <div className="unp-page">
        <GuestGate title="Nudges unlock with a free account">
          <div className="unp-card" style={{ padding: 16 }}>
            <p className="unp-muted">Preview polls: {NUDGES.map((n) => n.title).join(" · ")}</p>
          </div>
        </GuestGate>
      </div>
    );
  }

  return (
    <div className="unp-page unp-nudge">
      <h1 style={{ marginTop: 0 }}>Nudge</h1>
      {!paid && (
        <div className="unp-card" style={{ padding: 14, marginBottom: 14 }}>
          <strong style={{ color: "var(--unp-accent-soft)" }}>Upgrade</strong>
          <p className="unp-muted" style={{ margin: "6px 0 0" }}>
            Free tier shows cards + polls. Premium unlocks Tonight’s Plan with venue → drink → venue cross-links.
          </p>
          <Link to="/profile" className="unp-link">
            View subscription
          </Link>
        </div>
      )}

      <section>
        <h2>Featured nudges</h2>
        <div className="unp-nudge__cards">
          {NUDGES.map((n) => (
            <div key={n.id} className="unp-card unp-nudge__card">
              <h3>{n.title}</h3>
              <p className="unp-muted">{n.subtitle}</p>
              <p>{n.body}</p>
              <p className="unp-muted" style={{ fontWeight: 600 }}>
                {n.pollQuestion}
              </p>
              <div className="unp-nudge__poll">
                {n.pollOptions.map((opt, i) => (
                  <button
                    key={opt}
                    type="button"
                    className={`unp-nudge__opt ${pollSelections[n.id] === i ? "unp-nudge__opt--on" : ""}`}
                    onClick={() => {
                      setPoll(n.id, i);
                      runAsync(`poll-${n.id}`, 300, () => addPoints(5, "social"));
                    }}
                  >
                    {opt}
                  </button>
                ))}
              </div>
              <div className="unp-nudge__links">
                {n.linkedEventIds.map((eid) => {
                  const e = getEventById(eid);
                  if (!e) return null;
                  return (
                    <Link key={eid} to="/explore" className="unp-chip unp-link" style={{ textDecoration: "none" }}>
                      Event: {e.title}
                    </Link>
                  );
                })}
                {n.linkedBeverageIds.map((bid) => {
                  const b = getBeverageById(bid);
                  if (!b) return null;
                  return (
                    <Link key={bid} to="/pour" search={{ focus: bid }} className="unp-chip unp-link" style={{ textDecoration: "none" }}>
                      Drink: {b.name}
                    </Link>
                  );
                })}
              </div>
            </div>
          ))}
        </div>
      </section>

      {paid && (
        <section className="unp-nudge__plan">
          <h2>Tonight’s Plan</h2>
          {pending["plan"] && <Spinner label="Saving plan…" />}
          <div className="unp-card" style={{ padding: 16 }}>
            <Step
              n={1}
              title="Start venue"
              value={plan.venueId}
              options={EVENTS.map((e) => ({ id: e.id, label: `${e.title} @ ${e.startTime}` }))}
              onPick={(id) => setPlan({ venueId: id })}
            />
            <Step
              n={2}
              title="Beverage focus"
              value={plan.beverageId}
              options={[
                { id: "bev-negroni", label: "Negroni" },
                { id: "bev-margarita", label: "Margarita" },
                { id: "bev-espresso", label: "Espresso Martini" },
              ]}
              onPick={(id) => setPlan({ beverageId: id })}
            />
            <Step
              n={3}
              title="Late stop"
              value={plan.venueAfterId}
              options={EVENTS.map((e) => ({ id: e.id, label: `${e.title}` }))}
              onPick={(id) => setPlan({ venueAfterId: id })}
            />
            <label className="unp-nudge__mood">
              Mood / preference
              <input
                value={plan.mood}
                onChange={(e) => setPlan({ mood: e.target.value })}
                placeholder="High energy, jazz, rooftop…"
              />
            </label>
            <label className="unp-nudge__check">
              <input type="checkbox" checked readOnly /> Cross-link saved events &amp; drinks in Circles
            </label>
            <label className="unp-nudge__check">
              <input type="checkbox" defaultChecked /> Notify crew at T-2h
            </label>
            <div className="unp-nudge__actions">
              <button type="button" className="unp-btn-primary" onClick={completePlan} disabled={!!pending["plan"]}>
                Save &amp; share plan +15 pts
              </button>
              <button
                type="button"
                className="unp-btn-ghost"
                onClick={() => {
                  runAsync("sms", 500, () => {});
                  void navigator.clipboard?.writeText(`Tonight: ${plan.venueId} → ${plan.beverageId} → ${plan.venueAfterId}`);
                }}
              >
                {pending["sms"] ? "Copying…" : "SMS link"}
              </button>
            </div>
            {smsOk && <p className="unp-muted">Plan saved — points added. Crew ping scheduled.</p>}
          </div>
        </section>
      )}
    </div>
  );
}

function Step({
  n,
  title,
  value,
  options,
  onPick,
}: {
  n: number;
  title: string;
  value: string | null;
  options: { id: string; label: string }[];
  onPick: (id: string) => void;
}) {
  return (
    <div className="unp-nudge__step">
      <span className="unp-chip">Step {n}</span>
      <h4>{title}</h4>
      <div className="unp-nudge__opts">
        {options.map((o) => (
          <button key={o.id} type="button" className={value === o.id ? "unp-nudge__opt--on unp-nudge__mini" : "unp-nudge__mini"} onClick={() => onPick(o.id)}>
            {o.label}
          </button>
        ))}
      </div>
    </div>
  );
}
