import type { AnchorHTMLAttributes, ButtonHTMLAttributes, ReactNode } from "react";

type Variant = "default" | "accent";
type Size = "default" | "lg";

interface BaseProps {
  variant?: Variant;
  size?: Size;
  /** Append a "→" arrow after the label. */
  arrow?: boolean;
  children?: ReactNode;
}

export interface ButtonProps
  extends BaseProps,
    Omit<ButtonHTMLAttributes<HTMLButtonElement>, keyof BaseProps> {
  href?: undefined;
}

export interface ButtonLinkProps
  extends BaseProps,
    Omit<AnchorHTMLAttributes<HTMLAnchorElement>, keyof BaseProps> {
  /** When set, renders an <a> instead of a <button>. */
  href: string;
}

function classes(variant: Variant, size: Size, className?: string) {
  return [
    "nm-btn",
    variant === "accent" && "nm-btn--accent",
    size === "lg" && "nm-btn--lg",
    className,
  ]
    .filter(Boolean)
    .join(" ");
}

/**
 * Primary action control in the NextMove "Studio Engineering" style:
 * monospace label, hard edges. Renders an <a> when `href` is passed,
 * otherwise a <button>. Use `variant="accent"` for the vivid green CTA.
 */
export function Button(props: ButtonProps | ButtonLinkProps) {
  const inner = (
    <>
      {props.children}
      {props.arrow && (
        <span className="nm-btn__arrow" aria-hidden="true">
          →
        </span>
      )}
    </>
  );

  if (typeof props.href === "string") {
    const { variant = "default", size = "default", arrow: _arrow, className, children: _children, ...rest } =
      props;
    return (
      <a className={classes(variant, size, className)} {...rest}>
        {inner}
      </a>
    );
  }

  const { variant = "default", size = "default", arrow: _arrow, href: _href, className, children: _children, ...rest } =
    props;
  return (
    <button className={classes(variant, size, className)} {...rest}>
      {inner}
    </button>
  );
}
