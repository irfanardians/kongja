import { useNavigate } from "react-router";
import { Search, MessageCircle, MessageCircleOff, Clock, AlertCircle, X } from "lucide-react";
import { hosts } from "../data/hosts";
import { BottomNav } from "../components/BottomNav";
import { FlagBadge } from "../components/FlagBadge";
import { useState } from "react";

interface Conversation {
  hostId: number;
  lastMessage: string;
  timestamp: string;
  unread: boolean;
  isActive: boolean; // true if duration is still active, false if expired
  remainingMinutes?: number; // optional: remaining minutes if active
}

export function Messages() {
  const navigate = useNavigate();
  const [showExpiredModal, setShowExpiredModal] = useState(false);
  const [selectedHost, setSelectedHost] = useState<typeof hosts[0] | null>(null);
  
  const conversations: Conversation[] = [
    {
      hostId: 1,
      lastMessage: "I'd love to hear more about it! 😊",
      timestamp: "2m ago",
      unread: true,
      isActive: true,
      remainingMinutes: 5,
    },
    {
      hostId: 2,
      lastMessage: "Thanks for chatting today!",
      timestamp: "1h ago",
      unread: false,
      isActive: false,
    },
    {
      hostId: 4,
      lastMessage: "See you soon! 💕",
      timestamp: "3h ago",
      unread: true,
      isActive: true,
      remainingMinutes: 10,
    },
  ];

  const handleConversationClick = (conv: Conversation, host: typeof hosts[0]) => {
    if (!conv.isActive) {
      // Show expired chat modal
      setSelectedHost(host);
      setShowExpiredModal(true);
    } else {
      // Navigate to chat
      navigate(`/chat/${host.id}`);
    }
  };

  const handleContinueChat = () => {
    if (selectedHost) {
      setShowExpiredModal(false);
      navigate(`/chat/${selectedHost.id}`);
    }
  };

  const handleCloseModal = () => {
    setShowExpiredModal(false);
    setSelectedHost(null);
  };
  
  const [showAlert, setShowAlert] = useState(false);

  return (
    <div className="min-h-screen bg-[#f5f1e8] flex justify-center items-center p-4">
      <div className="w-full max-w-md bg-white min-h-screen rounded-3xl overflow-hidden shadow-2xl relative pb-20">
        {/* Header */}
        <div className="px-6 pt-8 pb-4">
          <h1 className="text-2xl font-semibold mb-4">Messages</h1>
          
          {/* Search */}
          <div className="relative mb-4">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input
              type="text"
              placeholder="Search conversations..."
              className="w-full pl-10 pr-4 py-2 bg-gray-50 rounded-lg border border-gray-200 focus:outline-none focus:ring-2 focus:ring-gray-300"
            />
          </div>
        </div>

        {/* Conversations */}
        <div className="px-6">
          {conversations.map((conv) => {
            const host = hosts.find((h) => h.id === conv.hostId);
            if (!host) return null;

            return (
              <div
                key={conv.hostId}
                onClick={() => handleConversationClick(conv, host)}
                className="flex items-center gap-3 py-4 border-b border-gray-100 cursor-pointer hover:bg-gray-50 -mx-6 px-6 transition-colors"
              >
                <div className="relative">
                  <img
                    src={host.image}
                    alt={host.name}
                    className="w-14 h-14 rounded-full object-cover"
                  />
                  <FlagBadge countryCode={host.country} size="sm" />
                  {host.isOnline && (
                    <div className="absolute bottom-0 right-0 w-4 h-4 bg-green-500 rounded-full border-2 border-white"></div>
                  )}
                </div>
                <div className="flex-1 min-w-0">
                  <div className="flex items-center justify-between mb-1">
                    <h3 className="font-semibold">{host.name}</h3>
                    <span className="text-xs text-gray-500">{conv.timestamp}</span>
                  </div>
                  <p className={`text-sm truncate ${conv.unread ? 'text-gray-900 font-medium' : 'text-gray-500'}`}>
                    {conv.lastMessage}
                  </p>
                  {/* Chat Status */}
                  {conv.isActive ? (
                    <div className="flex items-center gap-1 mt-1">
                      <MessageCircle className="w-3.5 h-3.5 text-green-600" />
                      <span className="text-xs text-green-600 font-medium">Active - {conv.remainingMinutes}m left</span>
                    </div>
                  ) : (
                    <div className="flex items-center gap-1 mt-1">
                      <Clock className="w-3.5 h-3.5 text-gray-400" />
                      <span className="text-xs text-gray-400">Chat expired</span>
                    </div>
                  )}
                </div>
                {conv.unread && (
                  <div className="w-2 h-2 bg-amber-600 rounded-full"></div>
                )}
              </div>
            );
          })}
        </div>

        {/* Alert */}
        {showAlert && (
          <div className="absolute bottom-20 left-0 right-0 px-6 py-4 bg-red-500 text-white rounded-lg shadow-lg flex items-center justify-between">
            <div className="flex items-center gap-2">
              <AlertCircle className="w-5 h-5" />
              <span className="text-sm">You have unread messages!</span>
            </div>
            <X className="w-5 h-5 cursor-pointer" onClick={() => setShowAlert(false)} />
          </div>
        )}

        {/* Bottom Navigation */}
        <BottomNav />
      </div>

      {/* Expired Chat Modal */}
      {showExpiredModal && selectedHost && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl w-full max-w-sm p-6 shadow-2xl">
            {/* Header */}
            <div className="flex flex-col items-center mb-6">
              <div className="w-16 h-16 bg-orange-100 rounded-full flex items-center justify-center mb-3">
                <Clock className="w-8 h-8 text-orange-600" />
              </div>
              <h2 className="text-xl font-semibold mb-2">Chat Session Expired</h2>
              <p className="text-gray-600 text-center text-sm">
                Your chat session with <span className="font-semibold">{selectedHost.name}</span> has ended.
              </p>
            </div>

            {/* Host Info */}
            <div className="bg-gradient-to-r from-amber-50 to-orange-50 rounded-xl p-4 mb-6">
              <div className="flex items-center gap-3 mb-3">
                <div className="relative">
                  <img
                    src={selectedHost.image}
                    alt={selectedHost.name}
                    className="w-12 h-12 rounded-full object-cover"
                  />
                  <FlagBadge countryCode={selectedHost.country} size="sm" />
                </div>
                <div className="flex-1">
                  <p className="font-semibold">{selectedHost.name}</p>
                  <p className="text-sm text-gray-600">Continue chatting</p>
                </div>
              </div>
              <div className="flex items-center justify-between pt-3 border-t border-orange-200">
                <span className="text-sm text-gray-600">Chat Rate</span>
                <span className="font-semibold text-amber-700">🪙 {selectedHost.pricePerMin} / min</span>
              </div>
            </div>

            {/* Message */}
            <p className="text-center text-gray-600 text-sm mb-6">
              Would you like to start a new chat session?
            </p>

            {/* Actions */}
            <div className="space-y-3">
              <button
                onClick={handleContinueChat}
                className="w-full bg-gradient-to-r from-amber-600 to-orange-600 text-white py-3.5 rounded-xl font-semibold hover:from-amber-700 hover:to-orange-700 transition-all shadow-lg"
              >
                Yes, Start New Chat
              </button>
              <button
                onClick={handleCloseModal}
                className="w-full bg-gray-100 text-gray-700 py-3 rounded-xl font-medium hover:bg-gray-200 transition-all"
              >
                No, Maybe Later
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}