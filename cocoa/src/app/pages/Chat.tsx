import { useState } from "react";
import { useParams, useNavigate } from "react-router";
import { ChevronLeft, Gift, Mic } from "lucide-react";
import { hosts } from "../data/hosts";
import { GiftModal } from "../components/GiftModal";
import { FlagBadge } from "../components/FlagBadge";

interface Message {
  id: number;
  text: string;
  sender: "user" | "host";
  timestamp: string;
}

export function Chat() {
  const { id } = useParams();
  const navigate = useNavigate();
  const host = hosts.find((h) => h.id === Number(id));
  const [messages, setMessages] = useState<Message[]>([
    {
      id: 1,
      text: "Hi! How's your day? 😊",
      sender: "host",
      timestamp: "04:52",
    },
    {
      id: 2,
      text: "Hey Clara! My day was pretty busy.",
      sender: "user",
      timestamp: "04:53",
    },
    {
      id: 3,
      text: "I'd love to hear more about it! 😊",
      sender: "host",
      timestamp: "04:54",
    },
    {
      id: 4,
      text: "Taking a break now.",
      sender: "user",
      timestamp: "04:55",
    },
  ]);
  const [inputValue, setInputValue] = useState("");
  const [isGiftModalOpen, setIsGiftModalOpen] = useState(false);

  if (!host) {
    return <div>Host not found</div>;
  }

  const handleSendMessage = () => {
    if (inputValue.trim()) {
      setMessages([
        ...messages,
        {
          id: messages.length + 1,
          text: inputValue,
          sender: "user",
          timestamp: new Date().toLocaleTimeString("en-US", {
            hour: "2-digit",
            minute: "2-digit",
            hour12: false,
          }),
        },
      ]);
      setInputValue("");
    }
  };

  return (
    <div className="min-h-screen bg-[#f5f1e8] flex justify-center items-center p-4">
      <div className="w-full max-w-md bg-white min-h-screen rounded-3xl overflow-hidden shadow-2xl flex flex-col">
        {/* Header */}
        <div className="bg-gradient-to-r from-amber-700 to-amber-600 px-4 py-3 flex items-center gap-3">
          <button
            onClick={() => navigate(-1)}
            className="text-white"
          >
            <ChevronLeft className="w-6 h-6" />
          </button>
          <div className="relative">
            <img
              src={host.image}
              alt={host.name}
              className="w-10 h-10 rounded-full object-cover"
            />
            <FlagBadge countryCode={host.country} size="sm" />
          </div>
          <div className="flex-1">
            <p className="text-white font-semibold">{host.name}</p>
            <p className="text-white/90 text-sm">{host.description}</p>
          </div>
          <div className="bg-amber-800/50 px-3 py-1 rounded-full">
            <p className="text-white text-sm">04:52</p>
          </div>
        </div>

        {/* Messages */}
        <div className="flex-1 overflow-y-auto p-4 bg-gray-50">
          {messages.map((message) => (
            <div
              key={message.id}
              className={`mb-4 flex ${
                message.sender === "user" ? "justify-end" : "justify-start"
              }`}
            >
              <div
                className={`max-w-[70%] rounded-2xl px-4 py-2 ${
                  message.sender === "user"
                    ? "bg-gray-800 text-white rounded-br-sm"
                    : "bg-white text-gray-800 rounded-bl-sm shadow-sm"
                }`}
              >
                <p>{message.text}</p>
              </div>
            </div>
          ))}
        </div>

        {/* Input Area */}
        <div className="bg-white border-t border-gray-200 p-4">
          <div className="flex items-center gap-2 mb-3">
            <input
              type="text"
              placeholder="Type a message..."
              value={inputValue}
              onChange={(e) => setInputValue(e.target.value)}
              onKeyPress={(e) => e.key === "Enter" && handleSendMessage()}
              className="flex-1 bg-gray-100 rounded-full px-4 py-2 focus:outline-none focus:ring-2 focus:ring-gray-300"
            />
            <button
              onClick={handleSendMessage}
              className="bg-gray-800 text-white px-6 py-2 rounded-full font-medium"
            >
              Send
            </button>
          </div>
          <div className="flex items-center gap-4">
            <button
              onClick={() => setIsGiftModalOpen(true)}
              className="flex items-center gap-2 text-gray-700"
            >
              <Gift className="w-5 h-5" />
              <span className="text-sm">Send Gift</span>
            </button>
            <button className="flex items-center gap-2 text-gray-700">
              <Mic className="w-5 h-5" />
              <span className="text-sm">Voice Note</span>
            </button>
          </div>
        </div>

        {/* Gift Modal */}
        <GiftModal
          isOpen={isGiftModalOpen}
          onClose={() => setIsGiftModalOpen(false)}
          onSend={(gift) => {
            setMessages([
              ...messages,
              {
                id: messages.length + 1,
                text: `Sent a ${gift.name} ${gift.emoji}`,
                sender: "user",
                timestamp: new Date().toLocaleTimeString("en-US", {
                  hour: "2-digit",
                  minute: "2-digit",
                  hour12: false,
                }),
              },
            ]);
            setIsGiftModalOpen(false);
          }}
        />
      </div>
    </div>
  );
}