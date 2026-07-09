import type { HTMLAttributes, ReactNode } from "react";

export interface ProductShotProps extends Omit<HTMLAttributes<HTMLDivElement>, "title"> {
  /** Image source (screenshot of the product). */
  src: string;
  /** Alt text — describe what the screenshot shows. */
  alt: string;
  /** Left title-bar label, e.g. "app.klaris.app". */
  title?: ReactNode;
  /** Right title-bar label, e.g. "● live". */
  status?: ReactNode;
  /** Optional monospace caption strip under the image. */
  caption?: ReactNode;
}

/**
 * A screenshot framed as a browser window: a title bar (label + status), the
 * image, and an optional caption. Use to show a real product UI on-brand.
 */
export function ProductShot({
  src,
  alt,
  title,
  status,
  caption,
  className,
  ...rest
}: ProductShotProps) {
  return (
    <div className={["nm-shot", className].filter(Boolean).join(" ")} {...rest}>
      {(title != null || status != null) && (
        <div className="nm-shot__head">
          <span>{title}</span>
          <span>{status}</span>
        </div>
      )}
      <img src={src} alt={alt} loading="lazy" />
      {caption != null && <div className="nm-shot__caption">{caption}</div>}
    </div>
  );
}
