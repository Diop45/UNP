import { Link, useRouterState } from "@tanstack/react-router";

const tabs = [
  { to: "/", label: "Home", end: true },
  { to: "/explore", label: "Explore" },
  { to: "/pour", label: "Pour" },
  { to: "/nudge", label: "Nudge" },
  { to: "/circles", label: "Circles" },
  { to: "/profile", label: "Profile" },
] as const;

export function BottomTabBar() {
  const pathname = useRouterState({ select: (s) => s.location.pathname });

  return (
    <nav className="unp-tabbar" aria-label="Main">
      {tabs.map((t) => {
        const active = t.end ? pathname === "/" : pathname.startsWith(t.to);
        return (
          <Link
            key={t.to}
            to={t.to}
            className={`unp-tab ${active ? "unp-tab--active" : ""}`}
            aria-current={active ? "page" : undefined}
          >
            {t.label}
          </Link>
        );
      })}
    </nav>
  );
}
