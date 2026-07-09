import type { HTMLAttributes, ReactNode } from "react";

export interface CardProps extends HTMLAttributes<HTMLDivElement> {
  /** Tint the background on hover (default true). */
  hover?: boolean;
  /** Turn the border accent-green on hover (for clickable/CTA cards). */
  accentOnHover?: boolean;
  children?: ReactNode;
}

/**
 * Hard-edged bordered container — the base surface for beliefs, columns,
 * and join cards. Reads `--nm-line` / `--nm-bg`; no rounded corners by design.
 */
export function Card({
  hover = true,
  accentOnHover = false,
  className,
  children,
  ...rest
}: CardProps) {
  return (
    <div
      className={[
        "nm-card",
        hover && "nm-card--hover",
        accentOnHover && "nm-card--accent",
        className,
      ]
        .filter(Boolean)
        .join(" ")}
      {...rest}
    >
      {children}
    </div>
  );
}
