import type { HTMLAttributes, ReactNode } from "react";

export interface MetricProps extends HTMLAttributes<HTMLDivElement> {
  /** Small uppercase label above the value, e.g. "// Cycle MVP". */
  label: ReactNode;
  /** The headline value, e.g. "14". */
  value: ReactNode;
  /** Optional trailing unit rendered muted, e.g. "jours". */
  unit?: ReactNode;
  /** Optional accent sub-line under the value, e.g. "idée → production". */
  delta?: ReactNode;
}

/**
 * A single monospace stat cell: label, big value (+ optional unit), and an
 * accent delta line. Compose several inside `MetricRow` for the hero band.
 */
export function Metric({ label, value, unit, delta, className, ...rest }: MetricProps) {
  return (
    <div className={["nm-metric", className].filter(Boolean).join(" ")} {...rest}>
      <div className="nm-metric__k">{label}</div>
      <div className="nm-metric__v">
        {value}
        {unit != null && <span className="nm-metric__unit">{unit}</span>}
      </div>
      {delta != null && <div className="nm-metric__delta">{delta}</div>}
    </div>
  );
}

export interface MetricRowProps extends HTMLAttributes<HTMLDivElement> {
  /** Number of columns (defaults to 4). Cells are `Metric` elements. */
  columns?: number;
  children?: ReactNode;
}

/**
 * Grid wrapper for `Metric` cells with top/bottom rules — the four-up
 * stat band under the hero. Cells get vertical dividers automatically.
 */
export function MetricRow({ columns = 4, className, children, style, ...rest }: MetricRowProps) {
  return (
    <div
      className={["nm-metric-row", className].filter(Boolean).join(" ")}
      style={{ ["--nm-cols" as string]: String(columns), ...style }}
      {...rest}
    >
      {children}
    </div>
  );
}
