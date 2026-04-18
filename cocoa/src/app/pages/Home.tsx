import { useState, useMemo } from "react";
import { Search, Bell, Wallet, MapPin } from "lucide-react";
import { hosts } from "../data/hosts";
import { HostCard } from "../components/HostCard";
import { BottomNav } from "../components/BottomNav";

export function Home() {
  const [activeFilter, setActiveFilter] = useState<string>("People");
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedCity, setSelectedCity] = useState<string>("All Cities");
  const [citySearchQuery, setCitySearchQuery] = useState("");
  const [showCityDropdown, setShowCityDropdown] = useState(false);

  // Get unique cities from hosts
  const cities = useMemo(() => {
    const uniqueCities = new Set<string>();
    hosts.forEach(host => {
      if (host.city) uniqueCities.add(host.city);
    });
    return ["All Cities", ...Array.from(uniqueCities).sort()];
  }, []);

  // Filter cities based on search query
  const filteredCities = useMemo(() => {
    if (!citySearchQuery) return cities;
    const query = citySearchQuery.toLowerCase();
    return cities.filter(city => city.toLowerCase().includes(query));
  }, [cities, citySearchQuery]);

  // Filter hosts based on search query and selected city
  const filteredHosts = useMemo(() => {
    let filtered = hosts;

    // Filter by city
    if (selectedCity !== "All Cities") {
      filtered = filtered.filter(host => host.city === selectedCity);
    }

    // Filter by search query (name or city)
    if (searchQuery) {
      const query = searchQuery.toLowerCase();
      filtered = filtered.filter(host => 
        host.name.toLowerCase().includes(query) ||
        (host.city && host.city.toLowerCase().includes(query))
      );
    }

    return filtered;
  }, [searchQuery, selectedCity]);

  const topHosts = filteredHosts.filter((h) => h.category === "top");
  const newHosts = filteredHosts.filter((h) => h.category === "new");

  return (
    <div className="min-h-screen bg-[#f5f1e8] flex justify-center items-center p-4">
      <div className="w-full max-w-md bg-[#f5f1e8] min-h-screen rounded-3xl overflow-hidden shadow-2xl relative pb-20">
        {/* Header */}
        <div className="px-6 pt-8 pb-4">
          <div className="flex items-center justify-between mb-6">
            <h1 className="text-2xl font-semibold">Attention</h1>
            <div className="flex items-center gap-3">
              {/* Coin Balance */}
              <div className="bg-white rounded-full px-4 py-2 flex items-center gap-2 shadow-sm">
                <Wallet className="w-4 h-4 text-amber-600" />
                <span className="font-semibold text-sm">🪙 1,250</span>
              </div>
              <button className="text-gray-700">
                <Bell className="w-6 h-6" />
              </button>
            </div>
          </div>
          <p className="text-gray-600 mb-4">Find Someone to Talk With</p>

          {/* Search */}
          <div className="relative mb-4">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input
              type="text"
              placeholder="Search by name or city..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2 bg-white rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-gray-300"
            />
          </div>

          {/* City Selector */}
          <div className="relative mb-4">
            <MapPin className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400 z-10" />
            <input
              type="text"
              placeholder="Search cities..."
              value={citySearchQuery}
              onChange={(e) => setCitySearchQuery(e.target.value)}
              onFocus={() => setShowCityDropdown(true)}
              onBlur={() => setTimeout(() => setShowCityDropdown(false), 200)}
              className="w-full pl-10 pr-4 py-2 bg-white rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-gray-300"
            />
            {showCityDropdown && filteredCities.length > 0 && (
              <div className="absolute left-0 right-0 top-full mt-1 bg-white border border-gray-200 rounded-lg shadow-lg z-20 max-h-60 overflow-y-auto">
                {filteredCities.map((city) => (
                  <button
                    key={city}
                    onMouseDown={(e) => {
                      e.preventDefault();
                      setSelectedCity(city);
                      setCitySearchQuery(city);
                      setShowCityDropdown(false);
                    }}
                    className={`w-full text-left px-4 py-2.5 hover:bg-gray-100 transition-colors border-b border-gray-100 last:border-b-0 ${
                      selectedCity === city ? "bg-amber-50 text-amber-700 font-semibold" : "text-gray-700"
                    }`}
                  >
                    <div className="flex items-center gap-2">
                      <MapPin className="w-3.5 h-3.5 text-gray-400" />
                      {city}
                    </div>
                  </button>
                ))}
              </div>
            )}
            {showCityDropdown && filteredCities.length === 0 && citySearchQuery && (
              <div className="absolute left-0 right-0 top-full mt-1 bg-white border border-gray-200 rounded-lg shadow-lg z-20 p-4 text-center">
                <p className="text-sm text-gray-500">No cities found matching "{citySearchQuery}"</p>
              </div>
            )}
          </div>

          {/* Filters */}
          <div className="flex gap-2 overflow-x-auto scrollbar-hide">
            {["People", "Online", "New", "VIP"].map((filter) => (
              <button
                key={filter}
                onClick={() => setActiveFilter(filter)}
                className={`px-4 py-1.5 rounded-full text-sm transition-colors whitespace-nowrap ${
                  activeFilter === filter
                    ? "bg-[#8B4513] text-white"
                    : "bg-white text-gray-700"
                }`}
              >
                {filter}
              </button>
            ))}
          </div>
        </div>

        {/* Top Hosts */}
        {topHosts.length > 0 && (
          <div className="px-6 mb-6">
            <div className="flex items-center justify-between mb-3">
              <h2 className="font-semibold">Top Hosts</h2>
              <button className="text-sm text-gray-500">See All &gt;</button>
            </div>
            <div className="grid grid-cols-3 gap-3">
              {topHosts.map((host) => (
                <HostCard key={host.id} host={host} />
              ))}
            </div>
          </div>
        )}

        {/* New Hosts */}
        {newHosts.length > 0 && (
          <div className="px-6 pb-8">
            <div className="flex items-center justify-between mb-3">
              <h2 className="font-semibold">New Hosts</h2>
              <button className="text-sm text-gray-500">See All &gt;</button>
            </div>
            <div className="grid grid-cols-3 gap-3">
              {newHosts.map((host) => (
                <HostCard key={host.id} host={host} />
              ))}
            </div>
          </div>
        )}

        {/* No Results */}
        {topHosts.length === 0 && newHosts.length === 0 && (
          <div className="px-6 py-12 text-center">
            <p className="text-gray-500">No hosts found matching your search</p>
          </div>
        )}

        {/* Bottom Navigation */}
        <BottomNav />
      </div>
    </div>
  );
}