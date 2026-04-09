import { useMemo, useState, useEffect, useRef } from "react";
import { Link } from "@tanstack/react-router";
import { BEVERAGES, getBeverageById } from "@/data/seed";
import { useAppStore } from "@/data/store";
import { GuestGate } from "@/components/GuestGate";
import { Spinner } from "@/components/Spinner";
import type { Beverage } from "@/data/types";
import "./PourScreen.css";

export function PourScreen({ focusId }: { focusId?: string }) {
  const role = useAppStore((s) => s.role);
  const saved = useAppStore((s) => s.savedBeverageIds);
  const toggleSave = useAppStore((s) => s.toggleSaveBeverage);
  const runAsync = useAppStore((s) => s.runAsync);
  const pending = useAppStore((s) => s.pending);
  const addAmbassadorUpload = useAppStore((s) => s.addAmbassadorUpload);
  const uploads = useAppStore((s) => s.ambassadorUploads);
  const deleteUpload = useAppStore((s) => s.deleteAmbassadorUpload);

  const [q, setQ] = useState("");
  const [selected, setSelected] = useState<Beverage>(BEVERAGES[0]);
  const [uploadName, setUploadName] = useState("");
  const [showSuccess, setShowSuccess] = useState(false);
  const cardRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (focusId) {
      const b = getBeverageById(focusId);
      if (b) setSelected(b);
    }
  }, [focusId]);

  useEffect(() => {
    cardRef.current?.scrollIntoView({ behavior: "smooth", block: "nearest" });
  }, [selected.id]);

  const filtered = useMemo(() => {
    const t = q.trim().toLowerCase();
    if (!t) return BEVERAGES;
    return BEVERAGES.filter(
      (b) =>
        b.name.toLowerCase().includes(t) ||
        b.spiritTags.some((s) => s.includes(t)) ||
        b.ingredients.some((i) => i.name.toLowerCase().includes(t))
    );
  }, [q]);

  const paid = role === "paid" || role === "ambassador";
  const amb = role === "ambassador";

  const share = () => {
    runAsync("share", 600, () => {});
    void navigator.clipboard?.writeText(`${selected.name} — Until The Next Pour`);
  };

  if (role === "guest") {
    return (
      <div className="unp-page">
        <GuestGate title="Pour is for members">
          <div className="unp-card" style={{ padding: 16 }}>
            <p className="unp-muted">Preview — {BEVERAGES.map((b) => b.name).join(" · ")}</p>
          </div>
        </GuestGate>
      </div>
    );
  }

  if (showSuccess && amb) {
    return (
      <div className="unp-page unp-pour">
        <div className="unp-card" style={{ padding: 24, textAlign: "center" }}>
          <h2>Recipe published</h2>
          <p className="unp-muted">Detroit sees it in discovery + Similar pours.</p>
          <button type="button" className="unp-btn-primary" style={{ marginTop: 16 }} onClick={() => setShowSuccess(false)}>
            Back to Pour
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="unp-page unp-pour">
      <header className="unp-pour__head">
        <h1 style={{ margin: 0 }}>Pour</h1>
        {!paid && (
          <div className="unp-chip">
            Subscribe to unlock measurements &amp; steps
          </div>
        )}
      </header>

      <label className="unp-pour__search">
        <span className="unp-muted">Search name, spirit, tag</span>
        <input value={q} onChange={(e) => setQ(e.target.value)} placeholder="Try negroni, tequila…" />
      </label>

      <div className="unp-pour__list">
        {filtered.map((b) => (
          <button
            key={b.id}
            type="button"
            className={`unp-pour__pick ${selected.id === b.id ? "unp-pour__pick--on" : ""}`}
            onClick={() => setSelected(b)}
          >
            {b.name}
          </button>
        ))}
      </div>

      <article ref={cardRef} className="unp-card unp-pour__detail">
        {pending["share"] && <Spinner label="Sharing…" />}
        <div className="unp-pour__detail-head">
          <h2>{selected.name}</h2>
          <div className="unp-pour__tags">
            {selected.spiritTags.map((t) => (
              <span key={t} className="unp-chip">
                {t}
              </span>
            ))}
          </div>
          <p className="unp-muted">Glass: {selected.glassware}</p>
        </div>

        <section>
          <h3>Ingredients</h3>
          <ul>
            {selected.ingredients.map((i) => (
              <li key={i.name}>
                <strong>{i.name}</strong>
                {paid ? <span className="unp-muted"> — {i.amount}</span> : null}
              </li>
            ))}
          </ul>
          {!paid && (
            <p className="unp-pour__lock">
              <Link to="/profile" className="unp-link">
                Subscribe to unlock measurements &amp; full build
              </Link>
            </p>
          )}
        </section>

        {paid && (
          <>
            <section>
              <h3>Steps</h3>
              <ol>
                {selected.steps.map((s) => (
                  <li key={s}>{s}</li>
                ))}
              </ol>
            </section>
            <section>
              <h3>Pairings</h3>
              <p>{selected.pairings.join(" · ")}</p>
            </section>
            <section>
              <h3>Playlist</h3>
              <ul className="unp-muted">
                {selected.playlist.map((p) => (
                  <li key={p.title}>
                    {p.title} — {p.artist}
                  </li>
                ))}
              </ul>
            </section>
            <div className="unp-pour__actions">
              <button
                type="button"
                className="unp-btn-ghost"
                onClick={() =>
                  runAsync("save", 450, () => {
                    toggleSave(selected.id);
                  })
                }
                disabled={!!pending["save"]}
              >
                {pending["save"] ? "Saving…" : saved.includes(selected.id) ? "Saved" : "Save +10 pts"}
              </button>
              <button type="button" className="unp-btn-primary" onClick={share}>
                Share
              </button>
            </div>
          </>
        )}

        {paid && (
          <section>
            <h3>Similar beverages</h3>
            <div className="unp-pour__similar">
              {selected.similarIds.map((id) => {
                const o = getBeverageById(id);
                if (!o) return null;
                return (
                  <button key={id} type="button" className="unp-card unp-pour__sim" onClick={() => setSelected(o)}>
                    {o.name}
                  </button>
                );
              })}
            </div>
          </section>
        )}
      </article>

      {amb && (
        <>
          <h2 style={{ marginTop: 24 }}>Ambassador studio</h2>
          <div className="unp-card" style={{ padding: 16 }}>
            <p className="unp-muted">Upload (demo): name, photo, glassware, ingredients, steps, video URL — validated before publish.</p>
            <label className="unp-pour__field">
              Recipe name
              <input value={uploadName} onChange={(e) => setUploadName(e.target.value)} placeholder="House Ruby Manhattan" />
            </label>
            <button
              type="button"
              className="unp-btn-primary"
              disabled={uploadName.trim().length < 3 || !!pending["upload"]}
              onClick={() => {
                runAsync("upload", 800, () => {
                  addAmbassadorUpload(uploadName.trim());
                  setUploadName("");
                  setShowSuccess(true);
                });
              }}
            >
              {pending["upload"] ? "Publishing…" : "Publish recipe +50 pts"}
            </button>
          </div>

          <h3>Your uploads</h3>
          {uploads.map((u) => (
            <div key={u.id} className="unp-card unp-pour__dash" style={{ padding: 12 }}>
              <div>
                <strong>{u.name}</strong>
                <p className="unp-muted" style={{ margin: "4px 0 0" }}>
                  Views {u.views} · Saves {u.saves}
                </p>
              </div>
              <button type="button" className="unp-btn-ghost" onClick={() => deleteUpload(u.id)}>
                Delete
              </button>
            </div>
          ))}
        </>
      )}
    </div>
  );
}
