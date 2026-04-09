import { useMemo, useState } from "react";
import JSZip from "jszip";
import { Spinner } from "@/components/Spinner";
import "./DemoScreenshotsPage.css";

type Section = "home" | "pour" | "explore" | "nudge" | "circles" | "profile";
type DemoRole = "free" | "paid" | "ambassador";

const SECTIONS: { id: Section; label: string }[] = [
  { id: "home", label: "Home" },
  { id: "pour", label: "Pour" },
  { id: "explore", label: "Explore" },
  { id: "nudge", label: "Nudge" },
  { id: "circles", label: "Circles" },
  { id: "profile", label: "Profile" },
];

const ROLES: { id: DemoRole; label: string }[] = [
  { id: "free", label: "Free" },
  { id: "paid", label: "Paid" },
  { id: "ambassador", label: "Ambassador" },
];

const CAPTIONS: Record<Section, Record<DemoRole, string>> = {
  home: {
    free: "Hero CTAs + upgrade strip for Free tier.",
    paid: "Full hero routing to Pour / Nudge / Explore with live picks.",
    ambassador: "Same as Paid — ambassador tools live under Pour.",
  },
  pour: {
    free: "Ingredient names only; subscribe strip for measurements.",
    paid: "Full recipe, pairings, playlist, similar horizontal scroll.",
    ambassador: "Paid UI + upload studio + management dashboard.",
  },
  explore: {
    free: "Map/list + basic cards; upgrade for venue intel.",
    paid: "Dress code, door, tickets, RSVP +25, cross-links.",
    ambassador: "Paid-level intel — pins identical, upload elsewhere.",
  },
  nudge: {
    free: "Nudge cards + polls + upgrade for Tonight’s Plan.",
    paid: "3-step plan, SMS, mood, cross-links +15 completion.",
    ambassador: "Paid plan + ambassador analytics in Pour.",
  },
  circles: {
    free: "Visibility toggles + locked feature list + CTA.",
    paid: "Rewards bar 350/500, chats, threads, perk chips.",
    ambassador: "Paid circles — upload stats surface in profile.",
  },
  profile: {
    free: "Tier, saves, subscription, role switcher.",
    paid: "Premium badge, full rewards grid.",
    ambassador: "Ambassador badge + upload roster hints.",
  },
};

export function DemoScreenshotsPage() {
  const [tab, setTab] = useState<Section>("home");
  const [role, setRole] = useState<DemoRole>("paid");
  const [zoom, setZoom] = useState<Section | null>(null);
  const [pending, setPending] = useState(false);

  const caption = CAPTIONS[tab][role];

  const tiles = useMemo(
    () =>
      SECTIONS.map((s) => ({
        ...s,
        cap: CAPTIONS[s.id][role],
      })),
    [role]
  );

  const downloadOne = (id: Section) => {
    setPending(true);
    window.setTimeout(() => {
      const blob = new Blob([`Placeholder PNG for ${id} — ${role}\n`], { type: "text/plain" });
      const a = document.createElement("a");
      a.href = URL.createObjectURL(blob);
      a.download = `unp-${id}-${role}.txt`;
      a.click();
      URL.revokeObjectURL(a.href);
      setPending(false);
    }, 400);
  };

  const downloadZip = async () => {
    setPending(true);
    try {
      const zip = new JSZip();
      zip.file("README.txt", "Until The Next Pour — demo screenshot placeholders\n");
      for (const s of SECTIONS) {
        zip.file(
          `${s.id}-${role}.txt`,
          `Section: ${s.label}\nRole: ${role}\nCaption: ${CAPTIONS[s.id][role]}\n`
        );
      }
      const blob = await zip.generateAsync({ type: "blob" });
      const a = document.createElement("a");
      a.href = URL.createObjectURL(blob);
      a.download = `unp-demo-${role}.zip`;
      a.click();
      URL.revokeObjectURL(a.href);
    } finally {
      setPending(false);
    }
  };

  return (
    <div className="unp-page unp-demo" style={{ paddingBottom: 100 }}>
      <h1 style={{ marginTop: 0 }}>Demo screenshots</h1>
      <p className="unp-muted">Placeholders with captions — zoom on click. Bulk ZIP or single download.</p>

      {pending && <Spinner label="Preparing files…" />}

      <div className="unp-demo__tabs">
        {SECTIONS.map((s) => (
          <button key={s.id} type="button" className={tab === s.id ? "unp-btn-primary" : "unp-btn-ghost"} onClick={() => setTab(s.id)}>
            {s.label}
          </button>
        ))}
      </div>

      <div className="unp-demo__roles">
        {ROLES.map((r) => (
          <button key={r.id} type="button" className={role === r.id ? "unp-chip unp-demo__on" : "unp-chip"} onClick={() => setRole(r.id)}>
            {r.label}
          </button>
        ))}
      </div>

      <div className="unp-demo__actions">
        <button type="button" className="unp-btn-primary" onClick={() => void downloadZip()} disabled={pending}>
          Download ZIP (all sections)
        </button>
        <button type="button" className="unp-btn-ghost" onClick={() => downloadOne(tab)} disabled={pending}>
          Download this section
        </button>
      </div>

      <div className="unp-card unp-demo__hero" onClick={() => setZoom(tab)} role="presentation">
        <div className="unp-demo__placeholder">{tab.toUpperCase()}</div>
        <p style={{ margin: "12px 0 0" }}>{caption}</p>
      </div>

      <h2>All sections ({role})</h2>
      <div className="unp-demo__grid">
        {tiles.map((t) => (
          <button key={t.id} type="button" className="unp-card unp-demo__tile" onClick={() => setZoom(t.id)}>
            <div className="unp-demo__placeholder unp-demo__placeholder--sm">{t.label}</div>
            <p className="unp-muted" style={{ margin: "8px 0 0", fontSize: "0.8rem", textAlign: "left" }}>
              {t.cap}
            </p>
          </button>
        ))}
      </div>

      {zoom && (
        <div className="unp-demo__lightbox" role="dialog" aria-modal="true" onClick={() => setZoom(null)}>
          <div className="unp-card unp-demo__lightbox-inner" onClick={(e) => e.stopPropagation()}>
            <button type="button" className="unp-btn-ghost" onClick={() => setZoom(null)}>
              Close
            </button>
            <div className="unp-demo__placeholder unp-demo__placeholder--lg">{zoom.toUpperCase()}</div>
            <p>{CAPTIONS[zoom][role]}</p>
          </div>
        </div>
      )}
    </div>
  );
}
