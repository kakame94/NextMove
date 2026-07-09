import type { HTMLAttributes, ReactNode } from "react";

export interface StatusBarProps extends HTMLAttributes<HTMLDivElement> {
  /** Left-aligned items (e.g. domain, tagline). */
  left?: ReactNode;
  /** Right-aligned items (e.g. a LiveBadge, location). */
  right?: ReactNode;
}

/**
 * The thin utility bar that sits above the nav — monospace, muted, with a
 * left and right cluster. Feed it plain strings, <span>s, or a `LiveBadge`.
 */
export function StatusBar({ left, right, className, ...rest }: StatusBarProps) {
  return (
    <div className={["nm-statusbar", className].filter(Boolean).join(" ")} {...rest}>
      <div className="nm-statusbar__group">{left}</div>
      <div className="nm-statusbar__group">{right}</div>
    </div>
  );
}
