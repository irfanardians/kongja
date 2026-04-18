interface FlagBadgeProps {
  countryCode?: string;
  size?: "sm" | "md" | "lg";
  className?: string;
}

const countryFlags: { [key: string]: string } = {
  US: "🇺🇸",
  GB: "🇬🇧",
  CA: "🇨🇦",
  AU: "🇦🇺",
  DE: "🇩🇪",
  FR: "🇫🇷",
  IT: "🇮🇹",
  ES: "🇪🇸",
  JP: "🇯🇵",
  KR: "🇰🇷",
  CN: "🇨🇳",
  BR: "🇧🇷",
  MX: "🇲🇽",
  IN: "🇮🇳",
  PH: "🇵🇭",
  SG: "🇸🇬",
  TH: "🇹🇭",
  VN: "🇻🇳",
  ID: "🇮🇩",
  RU: "🇷🇺",
};

export function FlagBadge({ countryCode = "US", size = "md", className = "" }: FlagBadgeProps) {
  const sizeClasses = {
    sm: "w-5 h-5 text-xs",
    md: "w-6 h-6 text-sm",
    lg: "w-7 h-7 text-base",
  };

  const flag = countryFlags[countryCode] || "🌍";

  return (
    <div
      className={`absolute bottom-0 right-0 ${sizeClasses[size]} bg-white rounded-full flex items-center justify-center shadow-md border-2 border-white ${className}`}
    >
      {flag}
    </div>
  );
}
