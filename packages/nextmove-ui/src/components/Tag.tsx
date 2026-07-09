import type { HTMLAttributes, ReactNode } from "react";

export interface TagProps extends HTMLAttributes<HTMLSpanElement> {
  /** Show a leading ● dot (used for status tags like "LIVE_EN_BÊTA"). */
  dot?: boolean;
  children?: ReactNode;
}

/**
 * Monospace bordered tag in the accent color. Use for product status
 * ("LIVE_EN_BÊTA"), category labels, or inline metadata chips.
 */
export function Tag({ dot = false, className, children, ...rest }: TagProps) {
  return (
    <span
      className={["nm-tag", dot && "nm-tag--dot", "nm-mono", className]
        .filter(Boolean)
        .join(" ")}
      {...rest}
    >
      {children}
    </span>
  );
}

export interface LiveBadgeProps extends HTMLAttributes<HTMLSpanElement> {
  children?: ReactNode;
}

/**
 * Monospace label preceded by a pulsing green dot — a "systems live"
 * indicator. Used in the status bar (e.g. "KLARIS LIVE · BÊTA").
 */
export function LiveBadge({ className, children, ...rest }: LiveBadgeProps) {
  return (
    <span
      className={["nm-badge", "nm-badge--live", "nm-mono", className]
        .filter(Boolean)
        .join(" ")}
      {...rest}
    >
      {children}
    </span>
  );
}
