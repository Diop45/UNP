import "./Spinner.css";

export function Spinner({ label = "Loading" }: { label?: string }) {
  return (
    <div className="unp-spinner-wrap" role="status" aria-label={label}>
      <div className="unp-spinner" />
      <span className="unp-muted">{label}</span>
    </div>
  );
}
