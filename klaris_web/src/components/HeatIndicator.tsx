/** 5-level heat dot mirroring `klaris_ios/lib/core/widgets/heat_indicator.dart`. */
export function HeatDot({ score }: { score: number }) {
  const cls =
    score >= 8 ? 'bg-heat5 shadow-[0_0_8px_#D64C2E]' :
    score >= 6 ? 'bg-heat4 shadow-[0_0_6px_#E07A45]' :
    score >= 4 ? 'bg-heat3 shadow-[0_0_6px_#E0A836]' :
    score >= 2 ? 'bg-heat2' :
                 'bg-heat1';
  return <span className={`inline-block w-2 h-2 rounded-full ${cls}`} aria-hidden />;
}

export function HeatChip({ score }: { score: number }) {
  const tone =
    score >= 8 ? 'bg-[#D64C2E]/12 text-[#D64C2E]' :
    score >= 6 ? 'bg-[#E07A45]/12 text-[#E07A45]' :
    score >= 4 ? 'bg-[#E0A836]/12 text-[#B58112]' :
                 'bg-[#8AB4D0]/12 text-[#5C8BB0]';
  return (
    <span className={`font-mono text-xs font-bold px-2 py-0.5 rounded-sm ${tone}`}>
      {score}/10
    </span>
  );
}
