import { Heart } from "lucide-react";
import { hosts } from "../data/hosts";
import { HostCard } from "../components/HostCard";
import { BottomNav } from "../components/BottomNav";

export function Favorites() {
  const favoriteHosts = hosts.filter((h) => [1, 3, 5].includes(h.id));

  return (
    <div className="min-h-screen bg-[#f5f1e8] flex justify-center items-center p-4">
      <div className="w-full max-w-md bg-[#f5f1e8] min-h-screen rounded-3xl overflow-hidden shadow-2xl relative pb-20">
        {/* Header */}
        <div className="px-6 pt-8 pb-4">
          <div className="flex items-center gap-2 mb-4">
            <Heart className="w-6 h-6 text-red-500 fill-red-500" />
            <h1 className="text-2xl font-semibold">Favorites</h1>
          </div>
          <p className="text-gray-600 mb-6">Your favorite hosts</p>
        </div>

        {/* Favorites Grid */}
        <div className="px-6 pb-8">
          <div className="grid grid-cols-3 gap-3">
            {favoriteHosts.map((host) => (
              <HostCard key={host.id} host={host} />
            ))}
          </div>
        </div>

        {/* Bottom Navigation */}
        <BottomNav />
      </div>
    </div>
  );
}
