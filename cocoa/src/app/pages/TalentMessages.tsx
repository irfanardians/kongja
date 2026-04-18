import { useState } from "react";
import { useNavigate } from "react-router";
import { Search, Filter } from "lucide-react";
import { TalentBottomNav } from "../components/TalentBottomNav";
import { FlagBadge } from "../components/FlagBadge";

export function TalentMessages() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<"all" | "active" | "archived">("all");

  const conversations = [
    {
      id: 1,
      name: "Sarah Johnson",
      message: "Thank you for the chat!",
      time: "2 min ago",
      avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100",
      unread: 2,
      status: "active",
      lastEarning: "50 coins",
    },
    {
      id: 2,
      name: "Mike Chen",
      message: "Are you available now?",
      time: "15 min ago",
      avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100",
      unread: 1,
      status: "active",
      lastEarning: "35 coins",
    },
    {
      id: 3,
      name: "Emma Wilson",
      message: "Great conversation!",
      time: "1 hr ago",
      avatar: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100",
      unread: 0,
      status: "active",
      lastEarning: "120 coins",
    },
    {
      id: 4,
      name: "David Lee",
      message: "See you next time!",
      time: "2 hrs ago",
      avatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100",
      unread: 0,
      status: "archived",
      lastEarning: "80 coins",
    },
    {
      id: 5,
      name: "Lisa Anderson",
      message: "Thanks for your time",
      time: "3 hrs ago",
      avatar: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100",
      unread: 0,
      status: "archived",
      lastEarning: "95 coins",
    },
  ];

  const filteredConversations = conversations.filter((conv) => {
    if (activeTab === "all") return true;
    return conv.status === activeTab;
  });

  return (
    <div className="min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-amber-100">
      <div className="max-w-md mx-auto bg-white min-h-screen shadow-2xl pb-20">
        {/* Header */}
        <div className="bg-gradient-to-br from-amber-700 to-amber-600 px-6 pt-8 pb-6 rounded-b-3xl shadow-lg">
          <h1 className="text-2xl font-semibold text-white mb-4">Messages</h1>

          {/* Search Bar */}
          <div className="relative">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
            <input
              type="text"
              placeholder="Search conversations..."
              className="w-full pl-11 pr-4 py-3 bg-white rounded-xl focus:outline-none focus:ring-2 focus:ring-amber-500"
            />
          </div>
        </div>

        {/* Tabs */}
        <div className="px-6 -mt-4 relative z-10">
          <div className="bg-white rounded-xl shadow-lg p-1 flex gap-1">
            <button
              onClick={() => setActiveTab("all")}
              className={`flex-1 py-2 rounded-lg font-medium transition-all ${
                activeTab === "all"
                  ? "bg-amber-600 text-white"
                  : "text-gray-600 hover:bg-gray-50"
              }`}
            >
              All
            </button>
            <button
              onClick={() => setActiveTab("active")}
              className={`flex-1 py-2 rounded-lg font-medium transition-all ${
                activeTab === "active"
                  ? "bg-amber-600 text-white"
                  : "text-gray-600 hover:bg-gray-50"
              }`}
            >
              Active
            </button>
            <button
              onClick={() => setActiveTab("archived")}
              className={`flex-1 py-2 rounded-lg font-medium transition-all ${
                activeTab === "archived"
                  ? "bg-amber-600 text-white"
                  : "text-gray-600 hover:bg-gray-50"
              }`}
            >
              Archived
            </button>
          </div>
        </div>

        {/* Conversations List */}
        <div className="px-6 mt-6">
          <div className="bg-white rounded-2xl shadow-sm divide-y divide-gray-100">
            {filteredConversations.map((conv) => (
              <button
                key={conv.id}
                onClick={() => navigate(`/talent-chat/${conv.id}`)}
                className="w-full flex items-center gap-3 p-4 hover:bg-gray-50 transition-colors"
              >
                <div className="relative">
                  <img
                    src={conv.avatar}
                    alt={conv.name}
                    className="w-14 h-14 rounded-full object-cover"
                  />
                  <FlagBadge countryCode="US" size="sm" />
                  {conv.unread > 0 && (
                    <div className="absolute -top-1 -right-1 w-5 h-5 bg-red-500 rounded-full flex items-center justify-center text-xs text-white">
                      {conv.unread}
                    </div>
                  )}
                </div>
                <div className="flex-1 text-left">
                  <div className="flex items-center justify-between mb-1">
                    <p className="font-semibold text-gray-800">{conv.name}</p>
                    <span className="text-xs text-gray-400">{conv.time}</span>
                  </div>
                  <p
                    className={`text-sm truncate ${
                      conv.unread > 0 ? "text-gray-800 font-medium" : "text-gray-500"
                    }`}
                  >
                    {conv.message}
                  </p>
                  <div className="flex items-center gap-2 mt-1">
                    <span className="text-xs text-green-600 font-medium">
                      🪙 {conv.lastEarning}
                    </span>
                  </div>
                </div>
                <button
                  onClick={(e) => {
                    e.stopPropagation();
                    // Handle more options
                  }}
                  className="text-gray-400 hover:text-gray-600"
                >
                  <Filter className="w-5 h-5" />
                </button>
              </button>
            ))}
          </div>

          {filteredConversations.length === 0 && (
            <div className="text-center py-12">
              <p className="text-gray-500">No conversations found</p>
            </div>
          )}
        </div>
      </div>
      <TalentBottomNav />
    </div>
  );
}