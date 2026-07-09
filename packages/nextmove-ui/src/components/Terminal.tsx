import type { HTMLAttributes, ReactNode } from "react";

export type LogLevel = "info" | "warn" | "ok";

export interface TerminalLineProps {
  /** Left timestamp column, e.g. "J+00". */
  ts: ReactNode;
  /** Level pill label, e.g. "DIAG". */
  level: ReactNode;
  /** Pill color style. */
  levelKind?: LogLevel;
  /** The log message. Use <b> and <span className="nm-arg"> for emphasis. */
  children: ReactNode;
}

/**
 * One row of a `Terminal` log: timestamp, a colored level pill, and message.
 * Use inside `Terminal`. Emphasize values with `<span className="nm-arg">`.
 */
export function TerminalLine({ ts, level, levelKind = "info", children }: TerminalLineProps) {
  return (
    <div className="nm-termline">
      <span className="nm-termline__ts nm-mono">{ts}</span>
      <span className={`nm-termline__lvl nm-termline__lvl--${levelKind}`}>{level}</span>
      <span className="nm-termline__msg nm-mono">{children}</span>
    </div>
  );
}

export interface TerminalProps extends HTMLAttributes<HTMLDivElement> {
  /** Path shown in the window title bar, e.g. "~/nextmove/playbook.log". */
  path?: ReactNode;
  /** Right-aligned status in the title bar, e.g. "↻ live". */
  status?: ReactNode;
  /** `TerminalLine` children. */
  children?: ReactNode;
}

/**
 * A faux terminal window: three dots, a path + status title bar, and a body
 * of `TerminalLine`s. The signature NextMove device for methods/logs.
 */
export function Terminal({ path, status, className, children, ...rest }: TerminalProps) {
  return (
    <div className={["nm-terminal", className].filter(Boolean).join(" ")} {...rest}>
      <div className="nm-terminal__head">
        <div className="nm-terminal__dots" aria-hidden="true">
          <span />
          <span />
          <span />
        </div>
        {path != null && <div className="nm-mono">{path}</div>}
        {status != null && <div className="nm-mono">{status}</div>}
      </div>
      <div className="nm-terminal__body">{children}</div>
    </div>
  );
}
