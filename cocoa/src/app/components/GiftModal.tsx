import { X } from "lucide-react";

interface Gift {
  id: number;
  name: string;
  price: number;
  emoji: string;
}

interface GiftModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSend: (gift: Gift) => void;
}

const gifts: Gift[] = [
  { id: 1, name: "Rose", price: 100, emoji: "🌹" },
  { id: 2, name: "Cake", price: 300, emoji: "🧁" },
  { id: 3, name: "Diamond", price: 700, emoji: "💎" },
  { id: 4, name: "Teddy Bear", price: 1200, emoji: "🧸" },
];

export function GiftModal({ isOpen, onClose, onSend }: GiftModalProps) {
  if (!isOpen) return null;

  return (
    <div className="fixed inset-0 bg-black/50 flex items-end justify-center z-50">
      <div className="w-full max-w-md bg-white rounded-t-3xl p-6 animate-slide-up">
        {/* Header */}
        <div className="flex items-center justify-between mb-4">
          <h3 className="text-lg font-semibold">Send a Gift</h3>
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-full bg-gray-100 flex items-center justify-center"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Coin Balance */}
        <div className="bg-amber-50 rounded-lg p-3 mb-4">
          <p className="text-sm text-amber-900">
            Your Coins: <span className="font-semibold">🪙 1,250</span>
          </p>
        </div>

        {/* Gift Grid */}
        <div className="grid grid-cols-2 gap-3 mb-4">
          {gifts.map((gift) => (
            <button
              key={gift.id}
              onClick={() => onSend(gift)}
              className="bg-gradient-to-br from-orange-50 to-orange-100 rounded-2xl p-4 flex flex-col items-center justify-center hover:shadow-lg transition-shadow"
            >
              <div className="text-5xl mb-2">{gift.emoji}</div>
              <p className="font-medium text-gray-800">{gift.name}</p>
              <p className="text-sm text-orange-600">🪙 {gift.price}</p>
            </button>
          ))}
        </div>

        {/* Send Button */}
        <button
          onClick={onClose}
          className="w-full bg-gradient-to-r from-orange-600 to-orange-500 text-white py-3 rounded-full font-semibold"
        >
          Send
        </button>
      </div>
    </div>
  );
}