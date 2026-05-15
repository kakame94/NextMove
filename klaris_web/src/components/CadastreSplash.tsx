'use client';

import { useEffect, useRef, useState } from 'react';

const STORAGE_KEY = 'klaris.splash.seen';

type Dot = { id: string; x: number; y: number; c: string; temp: string };

const DOTS: Dot[] = [
  { id: 'P-001', x: 160, y: 360, c: '#6a8fbf', temp: '18°' },
  { id: 'P-002', x: 640, y: 290, c: '#6a8fbf', temp: '24°' },
  { id: 'P-003', x: 610, y: 640, c: '#93b1cc', temp: '22°' },
  { id: 'P-004', x: 300, y: 740, c: '#d4a574', temp: '31°' },
  { id: 'P-005', x: 200, y: 540, c: '#d4a574', temp: '33°' },
  { id: 'P-006', x: 520, y: 360, c: '#d77a4a', temp: '38°' },
  { id: 'P-007', x: 420, y: 340, c: '#d77a4a', temp: '41°' },
  { id: 'P-008', x: 430, y: 620, c: '#c2533a', temp: '47°' },
  { id: 'P-009', x: 368, y: 450, c: '#c2533a', temp: '52°' },
  { id: 'P-010', x: 455, y: 455, c: '#c2533a', temp: '58°' },
  { id: 'P-011', x: 440, y: 528, c: '#c2533a', temp: '54°' },
  { id: 'P-012', x: 350, y: 548, c: '#c2533a', temp: '49°' },
];

function ticks() {
  const cx = 400, cy = 480, rIn = 345, rOut = 362;
  const out: { x1: number; y1: number; x2: number; y2: number }[] = [];
  for (let i = 0; i < 32; i++) {
    const a = (i / 32) * Math.PI * 2 - Math.PI / 2;
    out.push({
      x1: cx + Math.cos(a) * rIn, y1: cy + Math.sin(a) * rIn,
      x2: cx + Math.cos(a) * rOut, y2: cy + Math.sin(a) * rOut,
    });
  }
  return out;
}

export function CadastreSplash() {
  const [skip, setSkip] = useState(true);
  const didRunRef = useRef(false);

  useEffect(() => {
    if (typeof window === 'undefined') return;
    if (didRunRef.current) return;
    didRunRef.current = true;
    const seen = sessionStorage.getItem(STORAGE_KEY) === '1';
    sessionStorage.setItem(STORAGE_KEY, '1');
    setSkip(seen);
  }, []);

  if (skip) return null;

  const tickLines = ticks();

  return (
    <div className="cad-splash" aria-hidden="true" role="presentation">
      <svg className="cad-svg" viewBox="0 0 800 900" xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid meet">
        <text className="coord" x="40" y="40" fontSize="10" letterSpacing="2" fill="#3b3128" opacity="0.7">45°30′12″N · 73°33′48″O</text>
        <g className="stamp" transform="translate(620,30)">
          <rect width="140" height="60" fill="none" stroke="#3b3128" strokeWidth="0.6" opacity="0.5" />
          <text x="70" y="20" textAnchor="middle" fontSize="9" letterSpacing="2" fill="#3b3128" opacity="0.75">CADASTRE</text>
          <text x="70" y="34" textAnchor="middle" fontSize="9" letterSpacing="2" fill="#3b3128" opacity="0.75">SOLITAIRE</text>
          <text x="70" y="50" textAnchor="middle" fontSize="9" letterSpacing="2" fill="#c25a36" fontWeight="600">LEVÉ N° 2026</text>
        </g>
        <text className="title" x="400" y="130" textAnchor="middle" fontFamily="Geist, serif" fontSize="54" letterSpacing="14" fill="#2a2521" fontWeight="300">CADASTRE  SOLITAIRE</text>
        <text className="subtitle" x="400" y="170" textAnchor="middle" fontSize="10" letterSpacing="6" fill="#c25a36">TERRITOIRE  ·  KLARIS  ·  SOLO  ·  QUÉBEC</text>

        <line className="axis" x1="400" y1="195" x2="400" y2="820" />
        <line className="axis" x1="55" y1="480" x2="745" y2="480" />

        <text className="label" x="400" y="215" textAnchor="middle" fontSize="8" letterSpacing="3" fill="#3b3128" opacity="0.7">FROID</text>
        <text className="label" x="400" y="838" textAnchor="middle" fontSize="8" letterSpacing="3" fill="#3b3128" opacity="0.7">CHAUD</text>

        <circle className="ring" cx="400" cy="480" r="60" />
        <circle className="ring" cx="400" cy="480" r="130" />
        <circle className="ring" cx="400" cy="480" r="200" />
        <circle className="ring" cx="400" cy="480" r="270" />
        <circle className="ring" cx="400" cy="480" r="340" />

        <g>
          {tickLines.map((t, i) => (
            <line key={i} className="tick" x1={t.x1} y1={t.y1} x2={t.x2} y2={t.y2} style={{ animationDelay: `${0.6 + i * 0.02}s` }} />
          ))}
        </g>

        <g>
          {DOTS.map((d, i) => (
            <g key={d.id} className="dot" style={{ animationDelay: `${1.3 + i * 0.06}s` }}>
              <circle cx={d.x} cy={d.y} r="4.5" fill={d.c} />
              <text x={d.x + 9} y={d.y - 6} fontSize="7" letterSpacing="1" fill="#3b3128" opacity="0.7">{d.id} · {d.temp}</text>
            </g>
          ))}
        </g>

        <g className="cad-K">
          <circle cx="400" cy="480" r="48" fill="none" stroke="#c25a36" strokeWidth="1.5" />
          <path d="M385 458 V502 M385 480 L412 458 M385 480 L412 502" stroke="#2a2521" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" fill="none" />
          <circle cx="418" cy="461" r="2.5" fill="#c25a36" />
        </g>

        <text className="tag" x="40" y="860" fontFamily="Geist, serif" fontStyle="italic" fontSize="16" fill="#3b3128">Où le silence</text>
        <text className="tag" x="40" y="882" fontFamily="Geist, serif" fontStyle="italic" fontSize="16" fill="#c25a36">devient territoire.</text>

        <g className="legend" transform="translate(620,820)">
          <text x="100" y="0" textAnchor="end" fontSize="8" letterSpacing="2" fill="#3b3128" opacity="0.8">BRÛLANT · 50°+</text><circle cx="112" cy="-3" r="3.5" fill="#c2533a" />
          <text x="100" y="14" textAnchor="end" fontSize="8" letterSpacing="2" fill="#3b3128" opacity="0.8">TRÈS CHAUD · 40°</text><circle cx="112" cy="11" r="3.5" fill="#d77a4a" />
          <text x="100" y="28" textAnchor="end" fontSize="8" letterSpacing="2" fill="#3b3128" opacity="0.8">CHAUD · 30°</text><circle cx="112" cy="25" r="3.5" fill="#d4a574" />
          <text x="100" y="42" textAnchor="end" fontSize="8" letterSpacing="2" fill="#3b3128" opacity="0.8">TIÈDE · 20°</text><circle cx="112" cy="39" r="3.5" fill="#93b1cc" />
          <text x="100" y="56" textAnchor="end" fontSize="8" letterSpacing="2" fill="#3b3128" opacity="0.8">FROID · 10°</text><circle cx="112" cy="53" r="3.5" fill="#6a8fbf" />
        </g>
      </svg>
    </div>
  );
}
