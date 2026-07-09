import type { HTMLAttributes, ReactNode } from "react";

export interface SectionHeadProps extends HTMLAttributes<HTMLDivElement> {
  /** Monospace uppercase eyebrow in the left rail, e.g. "ce_quon_croit". */
  kicker: ReactNode;
  /** The section heading. Wrap emphasis in <span className="nm-accent">. */
  children: ReactNode;
}

/**
 * Two-column section header: a monospace kicker in a fixed left rail and a
 * large heading on the right, closed by a dashed rule. Stacks on mobile.
 * Highlight words with `<span className="nm-accent">…</span>`.
 */
export function SectionHead({ kicker, className, children, ...rest }: SectionHeadProps) {
  return (
    <div className={["nm-section-head", className].filter(Boolean).join(" ")} {...rest}>
      <span className="nm-section-head__kicker">{kicker}</span>
      <h2 className="nm-section-head__title">{children}</h2>
    </div>
  );
}
