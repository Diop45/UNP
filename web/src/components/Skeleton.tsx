import "./Skeleton.css";

export function Skeleton({ className = "" }: { className?: string }) {
  return <div className={`unp-skeleton ${className}`.trim()} aria-hidden />;
}
