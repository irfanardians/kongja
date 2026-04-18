import { useNavigate } from "react-router";
import { Settings, Edit, Wallet, LogOut, Star, History, ShieldCheck, MessageSquare } from "lucide-react";
import { BottomNav } from "../components/BottomNav";
import { FlagBadge } from "../components/FlagBadge";

export function UserProfile() {
  const navigate = useNavigate();

  const handleLogout = () => {
    // Clear any stored auth data here if needed
    navigate("/");
  };

  return (
    <div className="min-h-screen bg-[#f5f1e8] flex justify-center items-center p-4">
      <div className="w-full max-w-md bg-white min-h-screen rounded-3xl overflow-hidden shadow-2xl relative pb-20">
        {/* Header */}
        <div className="bg-gradient-to-br from-amber-700 to-amber-600 px-6 pt-8 pb-20 relative">
          <div className="flex items-center justify-between mb-8">
            <h1 className="text-2xl font-semibold text-white">Profile</h1>
            <button className="text-white" onClick={() => navigate("/settings")}>
              <Settings className="w-6 h-6" />
            </button>
          </div>
        </div>

        {/* Profile Card */}
        <div className="px-6 -mt-12 relative z-10">
          <div className="bg-white rounded-2xl shadow-lg p-6">
            <div className="flex items-center gap-4 mb-4">
              <div className="relative">
                <img
                  src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200"
                  alt="User"
                  className="w-20 h-20 rounded-full object-cover"
                />
                <FlagBadge countryCode="US" size="md" />
                <button className="absolute bottom-0 right-0 w-7 h-7 bg-amber-600 rounded-full flex items-center justify-center text-white">
                  <Edit className="w-4 h-4" />
                </button>
              </div>
              <div className="flex-1">
                <h2 className="text-xl font-semibold">Alex Johnson</h2>
                <p className="text-gray-500 text-sm">alex.johnson@email.com</p>
                <div className="flex items-center gap-1 mt-1">
                  <Star className="w-4 h-4 fill-amber-500 text-amber-500" />
                  <span className="text-sm font-semibold">4.8</span>
                  <span className="text-gray-400 text-xs">(24 reviews)</span>
                </div>
              </div>
            </div>

            {/* Coin Balance */}
            <div className="bg-gradient-to-r from-amber-50 to-orange-50 rounded-xl p-4 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <div className="w-10 h-10 bg-amber-600 rounded-full flex items-center justify-center">
                  <Wallet className="w-5 h-5 text-white" />
                </div>
                <div>
                  <p className="text-sm text-gray-600">Coin Balance</p>
                  <p className="text-lg font-semibold">🪙 1,250</p>
                </div>
              </div>
              <button className="bg-amber-600 text-white px-4 py-2 rounded-full text-sm font-medium" onClick={() => navigate("/top-up")}>
                Top Up
              </button>
            </div>
          </div>
        </div>

        {/* Menu Items */}
        <div className="px-6 mt-6">
          <div className="bg-white rounded-2xl shadow-sm divide-y divide-gray-100">
            <button 
              onClick={() => navigate("/review-talent")}
              className="w-full flex items-center gap-4 px-4 py-4 hover:bg-gray-50 transition-colors"
            >
              <div className="w-10 h-10 bg-purple-100 rounded-full flex items-center justify-center relative">
                <MessageSquare className="w-5 h-5 text-purple-600" />
                <Star className="w-3 h-3 text-purple-600 fill-purple-600 absolute -top-0.5 -right-0.5" />
              </div>
              <div className="flex-1 text-left">
                <p className="font-medium">Review Talent</p>
                <p className="text-sm text-gray-500">Rate your experiences</p>
              </div>
            </button>

            <button 
              onClick={() => navigate("/transaction-history")}
              className="w-full flex items-center gap-4 px-4 py-4 hover:bg-gray-50 transition-colors"
            >
              <div className="w-10 h-10 bg-amber-100 rounded-full flex items-center justify-center">
                <Wallet className="w-5 h-5 text-amber-600" />
              </div>
              <div className="flex-1 text-left">
                <p className="font-medium">Transaction History</p>
                <p className="text-sm text-gray-500">View purchases & top ups</p>
              </div>
            </button>

            <button className="w-full flex items-center gap-4 px-4 py-4 hover:bg-gray-50 transition-colors">
              <div className="w-10 h-10 bg-yellow-100 rounded-full flex items-center justify-center">
                <Star className="w-5 h-5 text-yellow-600" />
              </div>
              <div className="flex-1 text-left">
                <p className="font-medium">Membership</p>
                <p className="text-sm text-gray-500">Upgrade to VIP</p>
              </div>
            </button>

            <button className="w-full flex items-center gap-4 px-4 py-4 hover:bg-gray-50 transition-colors" onClick={handleLogout}>
              <div className="w-10 h-10 bg-red-100 rounded-full flex items-center justify-center">
                <LogOut className="w-5 h-5 text-red-600" />
              </div>
              <div className="flex-1 text-left">
                <p className="font-medium">Logout</p>
                <p className="text-sm text-gray-500">Sign out of your account</p>
              </div>
            </button>
          </div>
        </div>

        {/* Bottom Navigation */}
        <BottomNav />
      </div>
    </div>
  );
}