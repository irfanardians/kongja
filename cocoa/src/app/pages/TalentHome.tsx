import { useState } from "react";
import { useNavigate } from "react-router";
import {
  DollarSign,
  MessageCircle,
  Eye,
  Star,
  TrendingUp,
  Calendar,
  CalendarCheck,
  Bell,
  Users,
  Clock,
  Award,
  LogOut,
  Coins,
  History,
  Trophy,
  Crown,
  ChevronRight,
} from "lucide-react";
import { TalentBottomNav } from "../components/TalentBottomNav";
import { FlagBadge } from "../components/FlagBadge";
import { AvailabilityModal } from "../components/AvailabilityModal";

export function TalentHome() {
  const navigate = useNavigate();
  const [isOnline, setIsOnline] = useState(true);
  const [showTierDetails, setShowTierDetails] = useState(false);
  const [isAvailabilityModalOpen, setIsAvailabilityModalOpen] = useState(false);
  const [unavailableDates, setUnavailableDates] = useState<Date[]>([]);

  // Sample data for current talent
  const currentRating = 4.8;
  const monthlyEarnings = 12500; // Coins earned this month

  // Tier system configuration
  interface TierConfig {
    name: string;
    minCoins: number;
    maxCoins: number | null;
    minRating: number | null;
    color: string;
    bgGradient: string;
    icon: any;
    iconColor: string;
    badge: string;
  }

  const tiers: TierConfig[] = [
    {
      name: "Bronze",
      minCoins: 0,
      maxCoins: 4999,
      minRating: null,
      color: "text-amber-700",
      bgGradient: "from-amber-600 to-amber-700",
      icon: Award,
      iconColor: "text-amber-600",
      badge: "🥉",
    },
    {
      name: "Silver",
      minCoins: 5000,
      maxCoins: 9999,
      minRating: null,
      color: "text-gray-600",
      bgGradient: "from-gray-400 to-gray-500",
      icon: Award,
      iconColor: "text-gray-500",
      badge: "🥈",
    },
    {
      name: "Gold",
      minCoins: 10000,
      maxCoins: 19999,
      minRating: null,
      color: "text-yellow-600",
      bgGradient: "from-yellow-400 to-yellow-600",
      icon: Trophy,
      iconColor: "text-yellow-500",
      badge: "🥇",
    },
    {
      name: "Platinum",
      minCoins: 20000,
      maxCoins: 34999,
      minRating: 4.7,
      color: "text-cyan-600",
      bgGradient: "from-cyan-400 to-cyan-600",
      icon: Crown,
      iconColor: "text-cyan-500",
      badge: "💎",
    },
    {
      name: "Diamond",
      minCoins: 35000,
      maxCoins: null,
      minRating: 4.7,
      color: "text-purple-600",
      bgGradient: "from-purple-500 to-indigo-600",
      icon: Crown,
      iconColor: "text-purple-500",
      badge: "👑",
    },
  ];

  // Calculate current tier based on earnings and rating
  const getCurrentTier = (): TierConfig => {
    let eligibleTier = tiers[0]; // Default to Bronze

    for (const tier of tiers) {
      const meetsCoinsRequirement =
        monthlyEarnings >= tier.minCoins && (tier.maxCoins === null || monthlyEarnings <= tier.maxCoins);

      if (meetsCoinsRequirement) {
        // Check if rating requirement exists
        if (tier.minRating !== null) {
          // For Platinum and Diamond, need minimum rating
          if (currentRating >= tier.minRating) {
            eligibleTier = tier;
          } else {
            // If rating is too low, cap at Gold tier
            const goldTier = tiers.find((t) => t.name === "Gold");
            if (goldTier && monthlyEarnings >= goldTier.minCoins) {
              eligibleTier = goldTier;
            }
            break; // Stop checking higher tiers
          }
        } else {
          eligibleTier = tier;
        }
      }
    }

    return eligibleTier;
  };

  const currentTier = getCurrentTier();

  // Get next tier
  const getNextTier = (): TierConfig | null => {
    const currentIndex = tiers.findIndex((t) => t.name === currentTier.name);
    if (currentIndex === tiers.length - 1) return null; // Already at highest tier
    return tiers[currentIndex + 1];
  };

  const nextTier = getNextTier();

  // Calculate progress to next tier
  const getProgress = (): number => {
    if (!nextTier) return 100; // Already at max tier

    const currentMin = currentTier.minCoins;
    const nextMin = nextTier.minCoins;
    const range = nextMin - currentMin;
    const progress = ((monthlyEarnings - currentMin) / range) * 100;

    return Math.min(Math.max(progress, 0), 100);
  };

  const progress = getProgress();

  const handleLogout = () => {
    navigate("/");
  };

  const handleQuickAction = (action: string) => {
    if (action === "Schedule") {
      navigate("/talent-schedule");
    } else if (action === "Analytics") {
      navigate("/talent-analytics");
    } else if (action === "Achievements") {
      navigate("/talent-reviews");
    } else if (action === "Availability") {
      setIsAvailabilityModalOpen(true);
    }
  };

  const handleSaveAvailability = (dates: Date[]) => {
    setUnavailableDates(dates);
    console.log("Unavailable dates saved:", dates);
  };

  const stats = [
    { label: "Profile Views", value: "234", icon: Eye, color: "bg-purple-500", suffix: "" },
    { label: "Rating", value: "4.8", icon: Star, color: "bg-amber-500", suffix: "⭐" },
  ];

  const recentChats = [
    {
      id: 1,
      name: "Sarah Johnson",
      message: "Thank you for the chat!",
      time: "2 min ago",
      avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100",
      unread: 2,
    },
    {
      id: 2,
      name: "Mike Chen",
      message: "Are you available now?",
      time: "15 min ago",
      avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100",
      unread: 1,
    },
    {
      id: 3,
      name: "Emma Wilson",
      message: "Great conversation!",
      time: "1 hr ago",
      avatar: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100",
      unread: 0,
    },
  ];

  const quickActions = [
    { icon: Calendar, label: "Schedule", color: "bg-blue-100 text-blue-600" },
    { icon: TrendingUp, label: "Analytics", color: "bg-purple-100 text-purple-600" },
    { icon: Award, label: "Achievements", color: "bg-amber-100 text-amber-600" },
    { icon: CalendarCheck, label: "Availability", color: "bg-green-100 text-green-600" },
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-amber-100">
      <div className="max-w-md mx-auto bg-white min-h-screen shadow-2xl">
        {/* Header */}
        <div className="bg-gradient-to-br from-amber-700 to-amber-600 px-6 pt-8 pb-6 rounded-b-3xl shadow-lg">
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center gap-3">
              <div className="relative">
                <img
                  src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100"
                  alt="Talent"
                  className="w-14 h-14 rounded-full border-3 border-white shadow-md object-cover"
                />
                <FlagBadge countryCode="MX" size="md" />
              </div>
              <div>
                <div className="flex items-center gap-2">
                  <h1 className="text-xl font-semibold text-white">Welcome Back!</h1>
                  {/* Tier Badge */}
                  <div className={`bg-gradient-to-r ${currentTier.bgGradient} px-2.5 py-0.5 rounded-full flex items-center gap-1 shadow-md border border-white/30`}>
                    <span className="text-base">{currentTier.badge}</span>
                    <span className="text-xs font-bold text-white">{currentTier.name}</span>
                  </div>
                </div>
                <p className="text-amber-100 text-sm">Jessica Martinez</p>
              </div>
            </div>
            <button
              onClick={() => navigate("/talent-messages")}
              className="relative text-white"
            >
              <Bell className="w-6 h-6" />
              <div className="absolute -top-1 -right-1 w-4 h-4 bg-red-500 rounded-full flex items-center justify-center text-xs">
                3
              </div>
            </button>
          </div>

          {/* Online Status Toggle */}
          <div className="bg-white/20 backdrop-blur-sm rounded-2xl p-4 flex items-center justify-between">
            <div className="flex items-center gap-2">
              <div className={`w-3 h-3 rounded-full ${isOnline ? "bg-green-400" : "bg-gray-400"}`}></div>
              <span className="text-white font-medium">
                {isOnline ? "You're Online" : "You're Offline"}
              </span>
            </div>
            <button
              onClick={() => setIsOnline(!isOnline)}
              className={`relative w-14 h-7 rounded-full transition-colors ${
                isOnline ? "bg-green-500" : "bg-gray-400"
              }`}
            >
              <div
                className={`absolute top-1 w-5 h-5 bg-white rounded-full transition-transform ${
                  isOnline ? "translate-x-8" : "translate-x-1"
                }`}
              ></div>
            </button>
          </div>
        </div>

        {/* Tier Status Card - AT THE VERY TOP */}
        <div className="px-6 mt-6 mb-6">
          <h2 className="text-lg font-semibold mb-3 flex items-center gap-2">
            <Trophy className="w-5 h-5 text-amber-600" />
            Your Tier Status
          </h2>

          {/* Current Tier Display */}
          <div
            className={`bg-gradient-to-r ${currentTier.bgGradient} rounded-2xl p-5 text-white shadow-lg mb-4`}
          >
            <div className="flex items-center justify-between mb-4">
              <div className="flex items-center gap-3">
                <div className="text-4xl">{currentTier.badge}</div>
                <div>
                  <p className="text-sm text-white/80">Current Tier</p>
                  <p className="text-2xl font-bold">{currentTier.name}</p>
                </div>
              </div>
              <button
                onClick={() => setShowTierDetails(!showTierDetails)}
                className="bg-white/20 backdrop-blur-sm rounded-full p-2 hover:bg-white/30 transition-colors"
              >
                <ChevronRight
                  className={`w-5 h-5 transition-transform ${showTierDetails ? "rotate-90" : ""}`}
                />
              </button>
            </div>

            {/* Monthly Stats */}
            <div className="grid grid-cols-2 gap-3">
              <div className="bg-white/20 backdrop-blur-sm rounded-xl p-3">
                <p className="text-xs text-white/80 mb-1">This Month</p>
                <p className="text-lg font-bold">🪙 {monthlyEarnings.toLocaleString()}</p>
              </div>
              <div className="bg-white/20 backdrop-blur-sm rounded-xl p-3">
                <p className="text-xs text-white/80 mb-1">Rating</p>
                <p className="text-lg font-bold">⭐ {currentRating}</p>
              </div>
            </div>

            {/* Progress to Next Tier */}
            {nextTier && (
              <div className="mt-4">
                <div className="flex items-center justify-between text-sm mb-2">
                  <span className="text-white/90">Progress to {nextTier.name}</span>
                  <span className="font-semibold">{progress.toFixed(0)}%</span>
                </div>
                <div className="w-full bg-white/30 rounded-full h-2.5 overflow-hidden">
                  <div
                    className="bg-white h-full rounded-full transition-all duration-500"
                    style={{ width: `${progress}%` }}
                  ></div>
                </div>
                <div className="flex items-center justify-between text-xs mt-2 text-white/80">
                  <span>🪙 {monthlyEarnings.toLocaleString()}</span>
                  <span>🪙 {nextTier.minCoins.toLocaleString()} needed</span>
                </div>

                {/* Rating Warning for Platinum/Diamond */}
                {nextTier.minRating !== null && currentRating < nextTier.minRating && (
                  <div className="mt-3 bg-red-500/30 backdrop-blur-sm border border-red-300/30 rounded-xl p-3">
                    <p className="text-xs text-white font-semibold mb-1">⚠️ Rating Requirement</p>
                    <p className="text-xs text-white/90">
                      You need a minimum rating of {nextTier.minRating} to unlock {nextTier.name} tier.
                      Current rating: {currentRating}
                    </p>
                  </div>
                )}
              </div>
            )}

            {/* Max Tier Achieved */}
            {!nextTier && (
              <div className="mt-4 bg-white/20 backdrop-blur-sm rounded-xl p-3 text-center">
                <p className="text-sm font-semibold">🎉 Congratulations!</p>
                <p className="text-xs text-white/90 mt-1">You've reached the highest tier!</p>
              </div>
            )}
          </div>

          {/* Tier Details Dropdown */}
          {showTierDetails && (
            <div className="bg-white rounded-2xl shadow-lg overflow-hidden">
              <div className="bg-gradient-to-r from-amber-500 to-orange-500 px-4 py-3">
                <h3 className="font-semibold text-white">All Tier Requirements</h3>
              </div>

              <div className="divide-y divide-gray-100">
                {tiers.map((tier, index) => {
                  const isCurrentTier = tier.name === currentTier.name;
                  const TierIcon = tier.icon;

                  return (
                    <div
                      key={tier.name}
                      className={`p-4 ${isCurrentTier ? "bg-amber-50 border-l-4 border-amber-500" : ""}`}
                    >
                      <div className="flex items-center gap-3 mb-2">
                        <div className="text-2xl">{tier.badge}</div>
                        <div className="flex-1">
                          <div className="flex items-center gap-2">
                            <h4 className={`font-semibold ${tier.color}`}>{tier.name}</h4>
                            {isCurrentTier && (
                              <span className="text-xs bg-amber-500 text-white px-2 py-0.5 rounded-full">
                                CURRENT
                              </span>
                            )}
                          </div>
                        </div>
                      </div>

                      <div className="ml-11 space-y-1">
                        <p className="text-sm text-gray-600">
                          💰 Earn: <span className="font-semibold">
                            🪙 {tier.minCoins.toLocaleString()}
                            {tier.maxCoins ? ` - ${tier.maxCoins.toLocaleString()}` : "+"} / month
                          </span>
                        </p>
                        {tier.minRating !== null && (
                          <p className="text-sm text-gray-600">
                            ⭐ Rating: <span className="font-semibold">Minimum {tier.minRating}</span>
                          </p>
                        )}
                        {tier.minRating === null && index >= 3 && (
                          <p className="text-xs text-gray-500 italic">No rating requirement</p>
                        )}
                      </div>

                      {/* Special Note for Gold Tier */}
                      {tier.name === "Gold" && (
                        <div className="ml-11 mt-2 text-xs text-amber-700 bg-amber-100 rounded-lg p-2">
                          💡 <span className="font-semibold">Note:</span> If you earn enough for
                          Platinum/Diamond but your rating is below 4.7, you'll stay at Gold tier.
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            </div>
          )}
        </div>

        {/* Today's Earnings & Active Chats - Below Tier Status */}
        <div className="px-6 mb-6">
          <div className="grid grid-cols-2 gap-3">
            <div className="bg-white rounded-2xl shadow-lg p-4">
              <div className="flex items-center gap-2 mb-2">
                <div className="w-8 h-8 rounded-full bg-green-500 flex items-center justify-center">
                  <Coins className="w-4 h-4 text-white" />
                </div>
              </div>
              <p className="text-sm text-gray-600">Today's Earnings</p>
              <p className="text-xl font-bold text-gray-800">🪙 450</p>
            </div>
            <div className="bg-white rounded-2xl shadow-lg p-4">
              <div className="flex items-center gap-2 mb-2">
                <div className="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center">
                  <MessageCircle className="w-4 h-4 text-white" />
                </div>
              </div>
              <p className="text-sm text-gray-600">Active Chats</p>
              <p className="text-xl font-bold text-gray-800">12</p>
            </div>
          </div>
        </div>

        {/* Stats Grid */}
        <div className="px-6 relative z-10">
          <div className="grid grid-cols-2 gap-3 mb-6">
            {stats.map((stat, index) => (
              <div key={index} className="bg-white rounded-2xl shadow-lg p-4">
                <div className="flex items-center gap-2 mb-2">
                  <div className={`w-8 h-8 rounded-full ${stat.color} flex items-center justify-center`}>
                    <stat.icon className="w-4 h-4 text-white" />
                  </div>
                </div>
                <p className="text-sm text-gray-600">{stat.label}</p>
                <p className="text-xl font-bold text-gray-800">
                  {stat.value} {stat.suffix}
                </p>
              </div>
            ))}
          </div>
        </div>

        {/* Quick Actions */}
        <div className="px-6 mb-6">
          <h2 className="text-lg font-semibold mb-3">Quick Actions</h2>
          <div className="grid grid-cols-4 gap-3">
            {quickActions.map((action, index) => (
              <button
                key={index}
                onClick={() => handleQuickAction(action.label)}
                className="flex flex-col items-center gap-2 bg-white rounded-xl p-3 shadow-sm hover:shadow-md transition-shadow"
              >
                <div className={`w-12 h-12 rounded-full ${action.color} flex items-center justify-center`}>
                  <action.icon className="w-6 h-6" />
                </div>
                <span className="text-xs text-gray-600">{action.label}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Earnings This Week */}
        <div className="px-6 mb-6">
          <div className="bg-gradient-to-r from-green-500 to-emerald-600 rounded-2xl p-5 text-white shadow-lg">
            <div className="flex items-center justify-between mb-3">
              <h3 className="font-semibold">This Week's Earnings</h3>
              <Coins className="w-5 h-5" />
            </div>
            <p className="text-3xl font-bold mb-1">🪙 2,450 Coins</p>
            <p className="text-green-100 text-sm">↑ 23% from last week</p>
            <div className="mt-4 flex items-center gap-2">
              <Clock className="w-4 h-4" />
              <span className="text-sm">Total hours: 34.5h</span>
            </div>
          </div>
        </div>

        {/* Recent Chats */}
        <div className="px-6 mb-6">
          <div className="flex items-center justify-between mb-3">
            <h2 className="text-lg font-semibold">Recent Chats</h2>
            <button className="text-amber-700 text-sm font-medium">View All</button>
          </div>
          <div className="bg-white rounded-2xl shadow-sm divide-y divide-gray-100">
            {recentChats.map((chat) => (
              <button
                key={chat.id}
                onClick={() => navigate(`/talent-chat/${chat.id}`)}
                className="w-full flex items-center gap-3 p-4 hover:bg-gray-50 transition-colors"
              >
                <div className="relative">
                  <img
                    src={chat.avatar}
                    alt={chat.name}
                    className="w-12 h-12 rounded-full object-cover"
                  />
                  <FlagBadge countryCode="US" size="sm" />
                  {chat.unread > 0 && (
                    <div className="absolute -top-1 -right-1 w-5 h-5 bg-red-500 rounded-full flex items-center justify-center text-xs text-white">
                      {chat.unread}
                    </div>
                  )}
                </div>
                <div className="flex-1 text-left">
                  <p className="font-semibold text-gray-800">{chat.name}</p>
                  <p className="text-sm text-gray-500 truncate">{chat.message}</p>
                </div>
                <span className="text-xs text-gray-400">{chat.time}</span>
              </button>
            ))}
          </div>
        </div>

        {/* Today's Schedule */}
        <div className="px-6 mb-6">
          <h2 className="text-lg font-semibold mb-3">Today's Schedule</h2>
          <div className="bg-white rounded-2xl shadow-sm p-4">
            <div className="flex items-center gap-3 mb-3">
              <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                <Users className="w-5 h-5 text-blue-600" />
              </div>
              <div>
                <p className="font-medium">Peak Hours (6PM - 10PM)</p>
                <p className="text-sm text-gray-500">Best time to go online</p>
              </div>
            </div>
            <div className="bg-blue-50 rounded-xl p-3">
              <p className="text-sm text-blue-700">
                💡 Tip: Most users are active during evening hours. Going online now can boost your
                earnings!
              </p>
            </div>
          </div>
        </div>

        {/* Logout Button */}
        <div className="px-6 pb-24">
          <button
            onClick={handleLogout}
            className="w-full flex items-center justify-center gap-2 bg-red-50 text-red-600 py-3 rounded-xl font-medium hover:bg-red-100 transition-colors"
          >
            <LogOut className="w-5 h-5" />
            Logout
          </button>
        </div>
      </div>
      <TalentBottomNav />
      <AvailabilityModal
        isOpen={isAvailabilityModalOpen}
        onClose={() => setIsAvailabilityModalOpen(false)}
        onSave={handleSaveAvailability}
        currentUnavailableDates={unavailableDates}
      />
    </div>
  );
}