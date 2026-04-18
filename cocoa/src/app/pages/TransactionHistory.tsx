import { useState } from "react";
import { useNavigate } from "react-router";
import { ChevronLeft, ArrowUpCircle, ArrowDownCircle, MessageCircle, Phone, Video, MapPin, Calendar, Clock, Wallet } from "lucide-react";

// Transaction types
type TransactionType = "topup" | "chat" | "voice" | "video" | "meet";

interface Transaction {
  id: number;
  type: TransactionType;
  amount: number;
  date: string;
  time: string;
  talentName?: string;
  talentImage?: string;
  duration?: number; // in minutes
  paymentMethod?: string;
  description: string;
}

// Mock transaction data
const transactions: Transaction[] = [
  {
    id: 1,
    type: "topup",
    amount: 5000,
    date: "2024-04-15",
    time: "14:30",
    paymentMethod: "Credit Card",
    description: "Top Up - 5000 Coins Package"
  },
  {
    id: 2,
    type: "chat",
    amount: -480,
    date: "2024-04-15",
    time: "15:45",
    talentName: "Clara Lee",
    talentImage: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200",
    duration: 120,
    description: "Chat with Clara Lee"
  },
  {
    id: 3,
    type: "video",
    amount: -960,
    date: "2024-04-14",
    time: "20:15",
    talentName: "Sophie Chen",
    talentImage: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200",
    duration: 60,
    description: "Video Call with Sophie Chen"
  },
  {
    id: 4,
    type: "topup",
    amount: 2000,
    date: "2024-04-13",
    time: "10:20",
    paymentMethod: "PayPal",
    description: "Top Up - 2000 Coins Package"
  },
  {
    id: 5,
    type: "meet",
    amount: -1500,
    date: "2024-04-12",
    time: "18:00",
    talentName: "Clara Lee",
    talentImage: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200",
    duration: 180,
    description: "Offline Meeting with Clara Lee"
  },
  {
    id: 6,
    type: "voice",
    amount: -360,
    date: "2024-04-11",
    time: "16:30",
    talentName: "Emma Wilson",
    talentImage: "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200",
    duration: 60,
    description: "Voice Call with Emma Wilson"
  },
  {
    id: 7,
    type: "chat",
    amount: -240,
    date: "2024-04-10",
    time: "12:00",
    talentName: "Sophie Chen",
    talentImage: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200",
    duration: 60,
    description: "Chat with Sophie Chen"
  },
  {
    id: 8,
    type: "topup",
    amount: 1000,
    date: "2024-04-09",
    time: "09:15",
    paymentMethod: "Credit Card",
    description: "Top Up - 1000 Coins Package"
  },
  {
    id: 9,
    type: "video",
    amount: -1920,
    date: "2024-04-08",
    time: "21:00",
    talentName: "Clara Lee",
    talentImage: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200",
    duration: 120,
    description: "Video Call with Clara Lee"
  },
  {
    id: 10,
    type: "chat",
    amount: -360,
    date: "2024-04-07",
    time: "19:30",
    talentName: "Emma Wilson",
    talentImage: "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=200",
    duration: 90,
    description: "Chat with Emma Wilson"
  },
];

export function TransactionHistory() {
  const navigate = useNavigate();
  const [filter, setFilter] = useState<"all" | "topup" | "spending">("all");
  const [currentBalance] = useState(1250); // User's current coin balance

  const getFilteredTransactions = () => {
    if (filter === "all") return transactions;
    if (filter === "topup") return transactions.filter(t => t.type === "topup");
    return transactions.filter(t => t.type !== "topup");
  };

  const getTransactionIcon = (type: TransactionType) => {
    switch (type) {
      case "topup":
        return <ArrowUpCircle className="w-5 h-5 text-green-600" />;
      case "chat":
        return <MessageCircle className="w-5 h-5 text-blue-600" />;
      case "voice":
        return <Phone className="w-5 h-5 text-emerald-600" />;
      case "video":
        return <Video className="w-5 h-5 text-purple-600" />;
      case "meet":
        return <MapPin className="w-5 h-5 text-orange-600" />;
    }
  };

  const getTransactionBgColor = (type: TransactionType) => {
    switch (type) {
      case "topup":
        return "bg-green-100";
      case "chat":
        return "bg-blue-100";
      case "voice":
        return "bg-emerald-100";
      case "video":
        return "bg-purple-100";
      case "meet":
        return "bg-orange-100";
    }
  };

  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr);
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(yesterday.getDate() - 1);

    if (date.toDateString() === today.toDateString()) {
      return "Today";
    } else if (date.toDateString() === yesterday.toDateString()) {
      return "Yesterday";
    } else {
      return date.toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" });
    }
  };

  const getTotalSpent = () => {
    return Math.abs(
      transactions
        .filter(t => t.type !== "topup")
        .reduce((sum, t) => sum + t.amount, 0)
    );
  };

  const getTotalTopUp = () => {
    return transactions
      .filter(t => t.type === "topup")
      .reduce((sum, t) => sum + t.amount, 0);
  };

  const filteredTransactions = getFilteredTransactions();

  return (
    <div className="min-h-screen bg-[#f5f1e8] flex justify-center items-center p-4">
      <div className="w-full max-w-md bg-white min-h-screen rounded-3xl overflow-hidden shadow-2xl relative">
        {/* Header */}
        <div className="bg-gradient-to-br from-amber-700 to-amber-600 px-6 pt-8 pb-6 relative">
          <div className="flex items-center gap-4 mb-6">
            <button
              onClick={() => navigate("/profile")}
              className="w-10 h-10 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center text-white hover:bg-white/30 transition-colors"
            >
              <ChevronLeft className="w-6 h-6" />
            </button>
            <h1 className="text-2xl font-semibold text-white">Transaction History</h1>
          </div>

          {/* Current Balance */}
          <div className="bg-white/20 backdrop-blur-sm rounded-xl p-4 mb-4">
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-12 h-12 bg-white/20 rounded-full flex items-center justify-center">
                  <Wallet className="w-6 h-6 text-white" />
                </div>
                <div>
                  <p className="text-xs text-white/80 mb-1">Current Balance</p>
                  <p className="text-2xl font-bold text-white">🪙 {currentBalance.toLocaleString()}</p>
                </div>
              </div>
              <button
                onClick={() => navigate("/top-up")}
                className="bg-white text-amber-600 px-4 py-2 rounded-full text-sm font-semibold hover:bg-white/90 transition-colors"
              >
                Top Up
              </button>
            </div>
          </div>

          {/* Summary Cards */}
          <div className="grid grid-cols-2 gap-3">
            <div className="bg-white/20 backdrop-blur-sm rounded-xl p-3">
              <div className="flex items-center gap-2 mb-1">
                <ArrowUpCircle className="w-4 h-4 text-white" />
                <p className="text-xs text-white/80">Total Top Up</p>
              </div>
              <p className="text-lg font-semibold text-white">🪙 {getTotalTopUp().toLocaleString()}</p>
            </div>
            <div className="bg-white/20 backdrop-blur-sm rounded-xl p-3">
              <div className="flex items-center gap-2 mb-1">
                <ArrowDownCircle className="w-4 h-4 text-white" />
                <p className="text-xs text-white/80">Total Spent</p>
              </div>
              <p className="text-lg font-semibold text-white">🪙 {getTotalSpent().toLocaleString()}</p>
            </div>
          </div>
        </div>

        {/* Filter Tabs */}
        <div className="px-6 pt-6 pb-4 bg-white sticky top-0 z-10 border-b border-gray-100">
          <div className="flex gap-2">
            <button
              onClick={() => setFilter("all")}
              className={`flex-1 py-2 px-4 rounded-full text-sm font-medium transition-all ${
                filter === "all"
                  ? "bg-amber-600 text-white shadow-md"
                  : "bg-gray-100 text-gray-600 hover:bg-gray-200"
              }`}
            >
              All
            </button>
            <button
              onClick={() => setFilter("topup")}
              className={`flex-1 py-2 px-4 rounded-full text-sm font-medium transition-all ${
                filter === "topup"
                  ? "bg-amber-600 text-white shadow-md"
                  : "bg-gray-100 text-gray-600 hover:bg-gray-200"
              }`}
            >
              Top Up
            </button>
            <button
              onClick={() => setFilter("spending")}
              className={`flex-1 py-2 px-4 rounded-full text-sm font-medium transition-all ${
                filter === "spending"
                  ? "bg-amber-600 text-white shadow-md"
                  : "bg-gray-100 text-gray-600 hover:bg-gray-200"
              }`}
            >
              Spending
            </button>
          </div>
        </div>

        {/* Transaction List */}
        <div className="px-6 pb-6">
          {filteredTransactions.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-12">
              <div className="w-20 h-20 bg-gray-100 rounded-full flex items-center justify-center mb-4">
                <ArrowUpCircle className="w-10 h-10 text-gray-400" />
              </div>
              <p className="text-gray-500 text-center">No transactions found</p>
            </div>
          ) : (
            <div className="space-y-3 mt-4">
              {filteredTransactions.map((transaction) => (
                <div
                  key={transaction.id}
                  className="bg-white border border-gray-100 rounded-xl p-4 hover:shadow-md transition-shadow"
                >
                  <div className="flex items-start gap-3">
                    {/* Icon */}
                    <div className={`w-10 h-10 ${getTransactionBgColor(transaction.type)} rounded-full flex items-center justify-center flex-shrink-0`}>
                      {getTransactionIcon(transaction.type)}
                    </div>

                    {/* Content */}
                    <div className="flex-1 min-w-0">
                      <div className="flex items-start justify-between gap-2 mb-1">
                        <div className="flex-1 min-w-0">
                          <p className="font-semibold text-gray-800 truncate">
                            {transaction.description}
                          </p>
                          {transaction.talentName && (
                            <div className="flex items-center gap-2 mt-1">
                              {transaction.talentImage && (
                                <img
                                  src={transaction.talentImage}
                                  alt={transaction.talentName}
                                  className="w-5 h-5 rounded-full object-cover"
                                />
                              )}
                              <p className="text-sm text-gray-600">{transaction.talentName}</p>
                            </div>
                          )}
                        </div>
                        <p className={`text-sm font-bold flex-shrink-0 ${
                          transaction.amount > 0 ? "text-green-600" : "text-red-600"
                        }`}>
                          {transaction.amount > 0 ? "+" : ""}🪙 {Math.abs(transaction.amount).toLocaleString()}
                        </p>
                      </div>

                      {/* Details */}
                      <div className="flex items-center gap-4 mt-2 text-xs text-gray-500">
                        <div className="flex items-center gap-1">
                          <Calendar className="w-3 h-3" />
                          <span>{formatDate(transaction.date)}</span>
                        </div>
                        <div className="flex items-center gap-1">
                          <Clock className="w-3 h-3" />
                          <span>{transaction.time}</span>
                        </div>
                        {transaction.duration && (
                          <div className="flex items-center gap-1">
                            <span>⏱</span>
                            <span>{transaction.duration} min</span>
                          </div>
                        )}
                      </div>

                      {/* Payment Method for Top Ups */}
                      {transaction.paymentMethod && (
                        <div className="mt-2 inline-flex items-center gap-1 px-2 py-1 bg-green-50 rounded-full">
                          <span className="text-xs text-green-700 font-medium">💳 {transaction.paymentMethod}</span>
                        </div>
                      )}
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}