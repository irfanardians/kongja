import { useState } from "react";
import { useParams, useNavigate } from "react-router";
import { ChevronLeft, Gift, Mic, Phone, Video } from "lucide-react";
import { FlagBadge } from "../components/FlagBadge";

interface Message {
  id: number;
  text: string;
  sender: "talent" | "user";
  timestamp: string;
}

export function TalentChat() {
  const { id } = useParams();
  const navigate = useNavigate();

  // Mock user data based on the conversations from TalentMessages
  const users = [
    {
      id: 1,
      name: "Sarah Johnson",
      avatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100",
    },
    {
      id: 2,
      name: "Mike Chen",
      avatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100",
    },
    {
      id: 3,
      name: "Emma Wilson",
      avatar: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100",
    },
    {
      id: 4,
      name: "David Lee",
      avatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100",
    },
    {
      id: 5,
      name: "Lisa Anderson",
      avatar: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100",
    },
  ];

  const user = users.find((u) => u.id === Number(id)) || users[0];

  const [messages, setMessages] = useState<Message[]>([
    {
      id: 1,
      text: "Hi! Are you available to chat?",
      sender: "user",
      timestamp: "04:52",
    },
    {
      id: 2,
      text: "Yes, I'm here! How can I help you today? 😊",
      sender: "talent",
      timestamp: "04:53",
    },
    {
      id: 3,
      text: "I just wanted to talk about my day",
      sender: "user",
      timestamp: "04:54",
    },
    {
      id: 4,
      text: "I'd love to hear all about it! Tell me everything 💕",
      sender: "talent",
      timestamp: "04:55",
    },
  ]);
  const [inputValue, setInputValue] = useState("");
  const [coinsEarned, setCoinsEarned] = useState(45);

  const handleSendMessage = () => {
    if (inputValue.trim()) {
      setMessages([
        ...messages,
        {
          id: messages.length + 1,
          text: inputValue,
          sender: "talent",
          timestamp: new Date().toLocaleTimeString("en-US", {
            hour: "2-digit",
            minute: "2-digit",
            hour12: false,
          }),
        },
      ]);
      setInputValue("");
      // Simulate earning coins for responding
      setCoinsEarned(coinsEarned + 5);
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-amber-100">
      <div className="max-w-md mx-auto bg-white min-h-screen shadow-2xl flex flex-col">
        {/* Header */}
        <div className="bg-gradient-to-r from-amber-700 to-amber-600 px-4 py-3 flex items-center gap-3">
          <button
            onClick={() => navigate("/talent-messages")}
            className="text-white"
          >
            <ChevronLeft className="w-6 h-6" />
          </button>
          <div className="relative">
            <img
              src={user.avatar}
              alt={user.name}
              className="w-10 h-10 rounded-full object-cover border-2 border-white"
            />
            <FlagBadge countryCode="US" size="sm" />
          </div>
          <div className="flex-1">
            <p className="text-white font-semibold">{user.name}</p>
            <p className="text-white/90 text-xs">Active now</p>
          </div>
          <div className="flex items-center gap-2">
            <button className="text-white/90 hover:text-white">
              <Phone className="w-5 h-5" />
            </button>
            <button className="text-white/90 hover:text-white">
              <Video className="w-5 h-5" />
            </button>
          </div>
        </div>

        {/* Earnings Banner */}
        <div className="bg-green-50 border-b border-green-200 px-4 py-2">
          <div className="flex items-center justify-between">
            <span className="text-sm text-green-700">This conversation</span>
            <div className="flex items-center gap-1">
              <span className="text-sm font-bold text-green-700">🪙 {coinsEarned} coins</span>
            </div>
          </div>
        </div>

        {/* Messages */}
        <div className="flex-1 overflow-y-auto p-4 bg-gray-50">
          {messages.map((message) => (
            <div
              key={message.id}
              className={`mb-4 flex ${
                message.sender === "talent" ? "justify-end" : "justify-start"
              }`}
            >
              <div
                className={`max-w-[70%] rounded-2xl px-4 py-2 ${
                  message.sender === "talent"
                    ? "bg-amber-600 text-white rounded-br-sm"
                    : "bg-white text-gray-800 rounded-bl-sm shadow-sm"
                }`}
              >
                <p>{message.text}</p>
                <p
                  className={`text-xs mt-1 ${
                    message.sender === "talent" ? "text-amber-100" : "text-gray-400"
                  }`}
                >
                  {message.timestamp}
                </p>
              </div>
            </div>
          ))}
        </div>

        {/* Input Area */}
        <div className="bg-white border-t border-gray-200 p-4">
          <div className="flex items-center gap-2 mb-3">
            <input
              type="text"
              placeholder="Type your reply..."
              value={inputValue}
              onChange={(e) => setInputValue(e.target.value)}
              onKeyPress={(e) => e.key === "Enter" && handleSendMessage()}
              className="flex-1 bg-gray-100 rounded-full px-4 py-2.5 focus:outline-none focus:ring-2 focus:ring-amber-500"
            />
            <button
              onClick={handleSendMessage}
              className="bg-amber-600 text-white px-6 py-2.5 rounded-full font-medium hover:bg-amber-700 transition-colors"
            >
              Send
            </button>
          </div>
          <div className="flex items-center gap-4">
            <button className="flex items-center gap-2 text-gray-600 hover:text-amber-600 transition-colors">
              <Gift className="w-5 h-5" />
              <span className="text-sm">Gifts Received</span>
            </button>
            <button className="flex items-center gap-2 text-gray-600 hover:text-amber-600 transition-colors">
              <Mic className="w-5 h-5" />
              <span className="text-sm">Voice Note</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}