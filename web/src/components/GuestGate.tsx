import type { ReactNode } from "react";
import { Link } from "@tanstack/react-router";
import "./GuestGate.css";

export function GuestGate({ title, children }: { title: string; children?: ReactNode }) {
  return (
    <div className="unp-guest">
      <div className="unp-card unp-guest__banner">
        <h2 className="unp-guest__title">{title}</h2>
        <p className="unp-muted">
          Guests can browse the Home feed. Switch role to <strong>Free</strong> in Profile → Settings to demo the full
          experience.
        </p>
        <Link to="/profile" className="unp-btn-primary" style={{ display: "inline-block", marginTop: 12 }}>
          Open Profile &amp; role switcher
        </Link>
      </div>
      {children}
    </div>
  );
}
