import { useNavigate } from "react-router";
import { Host } from "../data/hosts";
import { FlagBadge } from "./FlagBadge";

interface HostCardProps {
  host: Host;
}

export function HostCard({ host }: HostCardProps) {
  const navigate = useNavigate();

  return (
    <div 
      className="flex flex-col cursor-pointer"
      onClick={() => navigate(`/profile/${host.id}`)}
    >
      <div className="relative">
        <img
          src={host.image}
          alt={host.name}
          className="w-full aspect-[3/4] object-cover rounded-2xl"
        />
        {host.isOnline && (
          <div className="absolute top-2 right-2 w-3 h-3 bg-green-500 rounded-full border-2 border-white"></div>
        )}
        <FlagBadge countryCode={host.country} size="sm" className="bottom-2 right-2" />
      </div>
      <div className="mt-2 text-center">
        <p className="font-semibold">{host.name}, {host.age}</p>
        {host.city && (
          <p className="text-xs text-gray-500">📍 {host.city}</p>
        )}
        <p className="text-sm text-gray-600">{host.description}</p>
        <p className="text-xs text-gray-500 mt-0.5">🪙 {host.pricePerMin} / Min</p>
      </div>
    </div>
  );
}