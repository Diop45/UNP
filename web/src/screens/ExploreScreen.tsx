import { useMemo, useState } from "react";
import { Link } from "@tanstack/react-router";
import { EVENTS, DETROIT_CENTER, getBeverageById } from "@/data/seed";
import type { TimeFilter } from "@/data/types";
import { useAppStore } from "@/data/store";
import { GuestGate } from "@/components/GuestGate";
import { Spinner } from "@/components/Spinner";
import "./ExploreScreen.css";

function projectPin(lat: number, lon: number) {
  const minLat = 42.322,
    maxLat = 42.345;
  const minLon = -83.08,
    maxLon = -83.04;
  const x = ((lon - minLon) / (maxLon - minLon)) * 100;
  const y = 100 - ((lat - minLat) / (maxLat - minLat)) * 100;
  return { x: Math.min(96, Math.max(4, x)), y: Math.min(92, Math.max(8, y)) };
}

export function ExploreScreen() {
  const role = useAppStore((s) => s.role);
  const runAsync = useAppStore((s) => s.runAsync);
  const pending = useAppStore((s) => s.pending);
  const addPoints = useAppStore((s) => s.addPoints);

  const [view, setView] = useState<"map" | "list">("map");
  const [filter, setFilter] = useState<TimeFilter | "all">("all");
  const [openId, setOpenId] = useState<string | null>(EVENTS[0].id);

  const paid = role === "paid" || role === "ambassador";

  const filtered = useMemo(() => {
    if (filter === "all") return EVENTS;
    return EVENTS.filter((e) => e.filter === filter);
  }, [filter]);

  const rsvp = (id: string) => {
    runAsync(`rsvp-${id}`, 600, () => {
      addPoints(25, "event");
    });
  };

  if (role === "guest") {
    return (
      <div className="unp-page">
        <GuestGate title="Explore is for members">
          <div className="unp-card" style={{ padding: 16 }}>
            <p className="unp-muted">Preview events: {EVENTS.map((e) => e.title).join(" · ")}</p>
          </div>
        </GuestGate>
      </div>
    );
  }

  const detail = openId ? EVENTS.find((e) => e.id === openId) : null;

  return (
    <div className="unp-page unp-explore">
      <header className="unp-explore__head">
        <h1 style={{ margin: 0 }}>Explore</h1>
        <p className="unp-muted" style={{ margin: "4px 0 0" }}>
          Map centered {DETROIT_CENTER.lat.toFixed(2)}, {DETROIT_CENTER.lon.toFixed(2)} · Detroit, MI
        </p>
      </header>

      {!paid && (
        <div className="unp-card" style={{ padding: 14, marginBottom: 12 }}>
          <strong style={{ color: "var(--unp-accent-soft)" }}>See full venue intel</strong>
          <p className="unp-muted" style={{ margin: "6px 0 0" }}>
            Free shows cards. Premium unlocks dress code, door policy, tickets, RSVP, attendance, beverage specials.
          </p>
        </div>
      )}

      <div className="unp-explore__toggle">
        <button type="button" className={view === "map" ? "unp-btn-primary" : "unp-btn-ghost"} onClick={() => setView("map")}>
          Map
        </button>
        <button type="button" className={view === "list" ? "unp-btn-primary" : "unp-btn-ghost"} onClick={() => setView("list")}>
          List
        </button>
      </div>

      <div className="unp-explore__time">
        {(["all", "day", "night", "late"] as const).map((t) => (
          <button key={t} type="button" className={filter === t ? "unp-chip unp-explore__tf--on" : "unp-chip"} onClick={() => setFilter(t)}>
            {t === "all" ? "All" : t === "day" ? "Day" : t === "night" ? "Night" : "Late Night"}
          </button>
        ))}
      </div>

      {view === "map" ? (
        <div className="unp-explore__map unp-card">
          <div className="unp-explore__map-inner">
            {filtered.map((e) => {
              const p = projectPin(e.lat, e.lon);
              return (
                <button
                  key={e.id}
                  type="button"
                  className="unp-explore__pin"
                  style={{ left: `${p.x}%`, top: `${p.y}%` }}
                  title={e.title}
                  onClick={() => setOpenId(e.id)}
                >
                  <span />
                </button>
              );
            })}
          </div>
          <p className="unp-muted" style={{ margin: "10px 0 0", fontSize: "0.8rem" }}>
            Amber pins · tap to focus · list toggle for full copy
          </p>
        </div>
      ) : (
        <div className="unp-explore__list">
          {filtered.map((e) => (
            <button key={e.id} type="button" className="unp-card unp-explore__row" onClick={() => setOpenId(e.id)}>
              <strong>{e.title}</strong>
              <p className="unp-muted" style={{ margin: "4px 0 0" }}>
                {e.venue} · {e.startTime}
              </p>
            </button>
          ))}
        </div>
      )}

      {detail && (
        <article className="unp-card unp-explore__detail">
          {pending[`rsvp-${detail.id}`] && <Spinner label="RSVP…" />}
          <h2>{detail.title}</h2>
          <p className="unp-muted">
            {detail.venue} · {detail.address}
          </p>
          <p>Starts {detail.startTime}</p>
          {paid ? (
            <>
              <section>
                <h3>Venue intel</h3>
                <ul className="unp-muted">
                  <li>Dress code: {detail.dressCode}</li>
                  <li>Door: {detail.doorPolicy}</li>
                  <li>Tickets: {detail.ticketsUrl}</li>
                  <li>Specials: {detail.beverageSpecials}</li>
                  <li>
                    RSVP’d {detail.rsvpCount}+ · Friends: {detail.attendingFriends.join(", ")}
                  </li>
                </ul>
              </section>
              <div className="unp-explore__links">
                {detail.linkedBeverageIds.map((bid) => {
                  const b = getBeverageById(bid);
                  if (!b) return null;
                  return (
                    <Link key={bid} to="/pour" search={{ focus: bid }} className="unp-chip unp-link" style={{ textDecoration: "none" }}>
                      Pour: {b.name}
                    </Link>
                  );
                })}
                {detail.linkedNudgeIds.map((nid) => (
                  <Link key={nid} to="/nudge" className="unp-chip unp-link" style={{ textDecoration: "none" }}>
                    Nudge link
                  </Link>
                ))}
              </div>
              <button type="button" className="unp-btn-primary" disabled={!!pending[`rsvp-${detail.id}`]} onClick={() => rsvp(detail.id)}>
                RSVP +25 pts
              </button>
            </>
          ) : (
            <p className="unp-explore__tease">
              <Link to="/profile" className="unp-link">
                Upgrade for dress code, door policy, tickets, specials, RSVP, stats.
              </Link>
            </p>
          )}
        </article>
      )}
    </div>
  );
}
