import { useState } from "react";
import { useNavigate } from "react-router";
import {
  Settings,
  Edit,
  Wallet,
  Star,
  Award,
  Clock,
  Eye,
  MessageCircle,
  LogOut,
  ChevronRight,
  Camera,
  Image as ImageIcon,
} from "lucide-react";
import { TalentBottomNav } from "../components/TalentBottomNav";
import { WithdrawModal } from "../components/WithdrawModal";
import { FlagBadge } from "../components/FlagBadge";
import { PhotoGalleryModal } from "../components/PhotoGalleryModal";

export function TalentProfile() {
  const navigate = useNavigate();
  const [isOnline, setIsOnline] = useState(true);
  const [isWithdrawModalOpen, setIsWithdrawModalOpen] = useState(false);
  const [isGalleryOpen, setIsGalleryOpen] = useState(false);
  const [selectedPhotoIndex, setSelectedPhotoIndex] = useState(0);
  const coinBalance = 4580;

  // Mock portfolio photos for the talent
  const portfolioPhotos = [
    "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400",
    "https://images.unsplash.com/photo-1762343040706-b74ea936c1c0?w=400",
    "https://images.unsplash.com/photo-1773955779694-42b1fba71f72?w=400",
    "https://images.unsplash.com/photo-1675275372275-0a5e5f0a9fa6?w=400",
    "https://images.unsplash.com/photo-1758467796950-1da4615c97b5?w=400",
  ];

  const handlePhotoClick = (index: number) => {
    setSelectedPhotoIndex(index);
    setIsGalleryOpen(true);
  };

  const handleLogout = () => {
    navigate("/");
  };

  const stats = [
    { label: "Total Earnings", value: "🪙 45,230", icon: Wallet },
    { label: "Total Hours", value: "582h", icon: Clock },
    { label: "Total Chats", value: "1,234", icon: MessageCircle },
    { label: "Profile Views", value: "12.5k", icon: Eye },
  ];

  return (
    <div className="min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-amber-100">
      <div className="max-w-md mx-auto bg-white min-h-screen shadow-2xl pb-20">
        {/* Header */}
        <div className="bg-gradient-to-br from-amber-700 to-amber-600 px-6 pt-8 pb-20 relative">
          <div className="flex items-center justify-between mb-4">
            <h1 className="text-2xl font-semibold text-white">My Profile</h1>
            <button
              onClick={() => navigate("/talent-settings")}
              className="text-white"
            >
              <Settings className="w-6 h-6" />
            </button>
          </div>
        </div>

        {/* Profile Card */}
        <div className="px-6 -mt-16 relative z-10">
          <div className="bg-white rounded-2xl shadow-lg p-6">
            <div className="flex items-start gap-4 mb-4">
              <div className="relative">
                <img
                  src="https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=200"
                  alt="Talent"
                  className="w-24 h-24 rounded-full object-cover"
                />
                <FlagBadge countryCode="MX" size="md" />
                <button className="absolute bottom-0 right-0 w-8 h-8 bg-amber-600 rounded-full flex items-center justify-center text-white shadow-lg">
                  <Camera className="w-4 h-4" />
                </button>
                <div
                  className={`absolute top-0 left-0 w-6 h-6 rounded-full border-3 border-white ${
                    isOnline ? "bg-green-500" : "bg-gray-400"
                  }`}
                ></div>
              </div>
              <div className="flex-1">
                <div className="flex items-center justify-between">
                  <h2 className="text-xl font-semibold">Jessica Martinez</h2>
                  <button className="text-amber-600">
                    <Edit className="w-5 h-5" />
                  </button>
                </div>
                <p className="text-gray-500 text-sm mb-2">jessica.martinez@email.com</p>
                <div className="flex items-center gap-2">
                  <div className="flex items-center gap-1">
                    <Star className="w-4 h-4 text-amber-500 fill-amber-500" />
                    <span className="text-sm font-semibold">4.8</span>
                  </div>
                  <span className="text-gray-400">•</span>
                  <span className="text-sm text-gray-600">234 reviews</span>
                </div>
              </div>
            </div>

            {/* Online Status Toggle */}
            <div className="bg-gradient-to-r from-amber-50 to-orange-50 rounded-xl p-4 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <span className="font-medium text-gray-800">
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
        </div>

        {/* Stats Grid */}
        <div className="px-6 mt-6">
          <h2 className="text-lg font-semibold mb-3">Your Stats</h2>
          <div className="grid grid-cols-2 gap-3">
            {stats.map((stat, index) => (
              <div key={index} className="bg-white rounded-xl shadow-sm p-4">
                <div className="flex items-center gap-2 mb-2">
                  <div className="w-8 h-8 bg-amber-100 rounded-full flex items-center justify-center">
                    <stat.icon className="w-4 h-4 text-amber-600" />
                  </div>
                </div>
                <p className="text-sm text-gray-600">{stat.label}</p>
                <p className="text-lg font-bold text-gray-800">{stat.value}</p>
              </div>
            ))}
          </div>
        </div>

        {/* Portfolio Section */}
        <div className="px-6 mt-6">
          <div className="bg-white rounded-2xl shadow-sm p-4">
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <ImageIcon className="w-5 h-5 text-amber-600" />
                <h3 className="font-semibold">My Portfolio</h3>
              </div>
              <button className="text-amber-600 text-sm font-medium">
                + Add Photos
              </button>
            </div>
            <div className="grid grid-cols-5 gap-2">
              {portfolioPhotos.map((photo, index) => (
                <button
                  key={index}
                  onClick={() => handlePhotoClick(index)}
                  className="aspect-square rounded-lg overflow-hidden hover:ring-2 hover:ring-amber-500 transition-all"
                >
                  <img
                    src={photo}
                    alt={`Portfolio ${index + 1}`}
                    className="w-full h-full object-cover"
                  />
                </button>
              ))}
            </div>
            <p className="text-xs text-gray-500 mt-3">
              {portfolioPhotos.length} photos • Users can view your portfolio on your profile
            </p>
          </div>
        </div>

        {/* Coin Balance */}
        <div className="px-6 mt-6">
          <div className="bg-gradient-to-r from-green-500 to-emerald-600 rounded-2xl p-5 text-white shadow-lg">
            <div className="flex items-center justify-between mb-3">
              <div>
                <p className="text-sm text-green-100 mb-1">Available Balance</p>
                <p className="text-3xl font-bold">🪙 {coinBalance} Coins</p>
              </div>
              <Wallet className="w-10 h-10 text-white/80" />
            </div>
            <button
              onClick={() => setIsWithdrawModalOpen(true)}
              className="w-full bg-white text-green-600 py-2.5 rounded-xl font-semibold mt-2 hover:bg-green-50 transition-colors"
            >
              Withdraw Earnings
            </button>
          </div>
        </div>

        {/* Menu Items */}
        <div className="px-6 mt-6">
          <div className="bg-white rounded-2xl shadow-sm divide-y divide-gray-100">
            <button className="w-full flex items-center gap-4 px-4 py-4 hover:bg-gray-50 transition-colors">
              <div className="w-10 h-10 bg-purple-100 rounded-full flex items-center justify-center">
                <Award className="w-5 h-5 text-purple-600" />
              </div>
              <div className="flex-1 text-left">
                <p className="font-medium">Achievements</p>
                <p className="text-sm text-gray-500">View your badges & rewards</p>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </button>

            <button className="w-full flex items-center gap-4 px-4 py-4 hover:bg-gray-50 transition-colors">
              <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center">
                <Clock className="w-5 h-5 text-blue-600" />
              </div>
              <div className="flex-1 text-left">
                <p className="font-medium">Schedule & Availability</p>
                <p className="text-sm text-gray-500">Manage your working hours</p>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </button>

            <button className="w-full flex items-center gap-4 px-4 py-4 hover:bg-gray-50 transition-colors">
              <div className="w-10 h-10 bg-amber-100 rounded-full flex items-center justify-center">
                <Wallet className="w-5 h-5 text-amber-600" />
              </div>
              <div className="flex-1 text-left">
                <p className="font-medium">Payment History</p>
                <p className="text-sm text-gray-500">View withdrawals & earnings</p>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </button>

            <button
              onClick={() => navigate("/talent-settings")}
              className="w-full flex items-center gap-4 px-4 py-4 hover:bg-gray-50 transition-colors"
            >
              <div className="w-10 h-10 bg-gray-100 rounded-full flex items-center justify-center">
                <Settings className="w-5 h-5 text-gray-600" />
              </div>
              <div className="flex-1 text-left">
                <p className="font-medium">Settings</p>
                <p className="text-sm text-gray-500">Privacy & preferences</p>
              </div>
              <ChevronRight className="w-5 h-5 text-gray-400" />
            </button>
          </div>
        </div>

        {/* Logout Button */}
        <div className="px-6 mt-6 mb-6">
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
      <WithdrawModal
        isOpen={isWithdrawModalOpen}
        onClose={() => setIsWithdrawModalOpen(false)}
        coinBalance={coinBalance}
      />
      <PhotoGalleryModal
        isOpen={isGalleryOpen}
        onClose={() => setIsGalleryOpen(false)}
        photos={portfolioPhotos}
        initialIndex={selectedPhotoIndex}
        hostName="My Portfolio"
      />
    </div>
  );
}