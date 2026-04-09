import "./BrandLogo.css";

type Props = {
  /** Visual size of the logo */
  size?: "sm" | "md" | "lg";
  className?: string;
};

export function BrandLogo({ size = "md", className = "" }: Props) {
  return (
    <div className={`unp-brand unp-brand--${size} ${className}`.trim()}>
      <img
        src="/unp-logo.png"
        alt="Until The Next Pour"
        className="unp-brand__mark"
        decoding="async"
      />
    </div>
  );
}
