import type { HTMLAttributes } from "react";

export interface BrandMarkProps extends HTMLAttributes<HTMLSpanElement> {
  /** Brand wordmark shown next to the ▲ glyph. Defaults to "NEXTMOVE". */
  label?: string;
  /** Render only the glyph box, no wordmark. */
  glyphOnly?: boolean;
}

/**
 * NextMove brand lockup: a bordered ▲ glyph followed by the monospace
 * wordmark. Use in nav bars, footers, and status headers.
 */
export function BrandMark({
  label = "NEXTMOVE",
  glyphOnly = false,
  className,
  ...rest
}: BrandMarkProps) {
  return (
    <span className={["nm-brand", className].filter(Boolean).join(" ")} {...rest}>
      <span className="nm-brand__glyph" aria-hidden="true" />
      {!glyphOnly && <span>{label}</span>}
    </span>
  );
}
