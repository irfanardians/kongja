import { useState } from "react";
import { useParams, useNavigate } from "react-router";
import { ChevronLeft, Phone, Video, Star, Image as ImageIcon, Heart, MapPin, MessageCircle, X, Coins, AlertCircle, ShieldCheck } from "lucide-react";
import { hosts } from "../data/hosts";
import { FlagBadge } from "../components/FlagBadge";
import { PhotoGalleryModal } from "../components/PhotoGalleryModal";
import { MeetOfflineModal } from "../components/MeetOfflineModal";

export function Profile() {
  const { id } = useParams();
  const navigate = useNavigate();
  const host = hosts.find((h) => h.id === Number(id));
  const [isGalleryOpen, setIsGalleryOpen] = useState(false);
  const [selectedPhotoIndex, setSelectedPhotoIndex] = useState(0);
  const [isFavorite, setIsFavorite] = useState(false);
  const [isMeetOfflineOpen, setIsMeetOfflineOpen] = useState(false);
  const [showPaymentModal, setShowPaymentModal] = useState(false);
  const [showErrorModal, setShowErrorModal] = useState(false);
  const [showVerificationModal, setShowVerificationModal] = useState(false);
  const [paymentType, setPaymentType] = useState<"chat" | "voice" | "video">("chat");
  const [userBalance] = useState(1250); // User's current coin balance
  const [isTopUpOpen, setIsTopUpOpen] = useState(false);

  // Simulate verification status - in real app, this would come from user profile data
  const [isVerified] = useState({
    idCard: false, // Set to false to require verification
    selfie: false, // Set to false to require verification
  });

  if (!host) {
    return <div>Host not found</div>;
  }

  const handlePhotoClick = (index: number) => {
    setSelectedPhotoIndex(index);
    setIsGalleryOpen(true);
  };

  const handleChatClick = () => {
    setPaymentType("chat");
    setShowPaymentModal(true);
  };

  const handleVoiceClick = () => {
    setPaymentType("voice");
    setShowPaymentModal(true);
  };

  const handleVideoClick = () => {
    setPaymentType("video");
    setShowPaymentModal(true);
  };

  const handlePaymentConfirm = () => {
    const cost = getCost();
    
    if (userBalance < cost) {
      setShowErrorModal(true);
      setShowPaymentModal(false);
      return;
    }

    setShowPaymentModal(false);
    
    // Navigate based on type
    if (paymentType === "chat") {
      navigate(`/chat/${host.id}`);
    } else if (paymentType === "voice") {
      // Navigate to voice call (you can create a voice call page later)
      const hourlyRate = Math.round(host.pricePerMin * 60 * 1.5);
      alert(`Voice call started with ${host.name}! 🎤\n\nRate: 🪙 ${hourlyRate.toLocaleString()}/hour`);
    } else if (paymentType === "video") {
      // Navigate to video call (you can create a video call page later)
      const hourlyRate = host.pricePerMin * 60 * 2;
      alert(`Video call started with ${host.name}! 📹\n\nRate: 🪙 ${hourlyRate.toLocaleString()}/hour`);
    }
  };

  const getCost = () => {
    // Convert per minute rate to per hour rate
    const hourlyRate = host.pricePerMin * 60;
    if (paymentType === "chat") return hourlyRate;
    if (paymentType === "voice") return Math.round(hourlyRate * 1.5);
    if (paymentType === "video") return hourlyRate * 2;
    return 0;
  };

  const getPaymentIcon = () => {
    if (paymentType === "chat") return <MessageCircle className="w-12 h-12 text-blue-500" />;
    if (paymentType === "voice") return <Phone className="w-12 h-12 text-green-500" />;
    if (paymentType === "video") return <Video className="w-12 h-12 text-purple-500" />;
    return null;
  };

  const getPaymentTitle = () => {
    if (paymentType === "chat") return "Start Chat";
    if (paymentType === "voice") return "Start Voice Call";
    if (paymentType === "video") return "Start Video Call";
    return "";
  };

  const getPaymentDescription = () => {
    if (paymentType === "chat") return "You will be charged per hour for chatting";
    if (paymentType === "voice") return "You will be charged per hour for voice calling";
    if (paymentType === "video") return "You will be charged per hour for video calling";
    return "";
  };

  return (
    <div className="min-h-screen bg-[#f5f1e8] flex justify-center items-center p-4">
      <div className="w-full max-w-md bg-gradient-to-b from-gray-800 to-gray-900 min-h-screen rounded-3xl overflow-hidden shadow-2xl relative">
        {/* Background Image */}
        <div className="absolute inset-0">
          <img
            src={host.image}
            alt={host.name}
            className="w-full h-full object-cover opacity-40"
          />
          <div className="absolute inset-0 bg-gradient-to-b from-transparent via-gray-900/50 to-gray-900"></div>
        </div>

        {/* Content */}
        <div className="relative z-10 h-full flex flex-col">
          {/* Header */}
          <div className="p-4 flex items-center justify-between">
            <button
              onClick={() => navigate("/home")}
              className="w-10 h-10 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center text-white"
            >
              <ChevronLeft className="w-6 h-6" />
            </button>
            <div className="flex items-center gap-2">
              <button
                onClick={() => setIsFavorite(!isFavorite)}
                className="w-10 h-10 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center text-white hover:bg-white/30 transition-all"
              >
                <Heart
                  className={`w-5 h-5 transition-all ${
                    isFavorite
                      ? "fill-red-500 text-red-500"
                      : "text-white"
                  }`}
                />
              </button>
              <div className="relative w-10 h-10">
                <img
                  src={host.image}
                  alt={host.name}
                  className="w-10 h-10 rounded-full object-cover border-2 border-white"
                />
                <FlagBadge countryCode={host.country} size="sm" className="bottom-0 right-0" />
              </div>
              <button className="w-10 h-10 rounded-full bg-green-500 flex items-center justify-center">
                <div className="w-3 h-3 bg-white rounded-full"></div>
              </button>
            </div>
          </div>

          {/* Profile Info */}
          <div className="flex-1 flex flex-col justify-end p-6">
            <h1 className="text-white text-4xl font-semibold mb-2">
              {host.name}, {host.age}
            </h1>
            <p className="text-white/90 text-lg mb-4">{host.description}</p>

            {/* Badges */}
            <div className="flex flex-wrap gap-2 mb-6">
              {host.badges.map((badge, index) => (
                <span
                  key={index}
                  className="px-3 py-1 bg-white/20 backdrop-blur-sm rounded-full text-white text-sm"
                >
                  {badge}
                </span>
              ))}
            </div>

            {/* Chat Button */}
            <button
              onClick={handleChatClick}
              className="w-full bg-gradient-to-r from-orange-600 to-orange-500 text-white py-3.5 rounded-full font-semibold mb-4 shadow-lg"
            >
              Chat Now 🪙 {host.pricePerMin} / Min →
            </button>

            {/* Portfolio/Photos Section */}
            {host.portfolio && host.portfolio.length > 0 && (
              <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-4 mb-4">
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center gap-2">
                    <ImageIcon className="w-5 h-5 text-white" />
                    <h3 className="text-white font-semibold">Photos</h3>
                  </div>
                  <span className="text-white/70 text-sm">{host.portfolio.length} photos</span>
                </div>
                <div className="grid grid-cols-4 gap-2">
                  {host.portfolio.slice(0, 8).map((photo, index) => (
                    <button
                      key={index}
                      onClick={() => handlePhotoClick(index)}
                      className="aspect-square rounded-lg overflow-hidden hover:ring-2 hover:ring-white transition-all"
                    >
                      <img
                        src={photo}
                        alt={`${host.name} - Photo ${index + 1}`}
                        className="w-full h-full object-cover"
                      />
                    </button>
                  ))}
                </div>
                {host.portfolio.length > 8 && (
                  <button
                    onClick={() => handlePhotoClick(0)}
                    className="text-orange-400 text-sm mt-3 hover:text-orange-300 transition-colors"
                  >
                    View all {host.portfolio.length} photos →
                  </button>
                )}
              </div>
            )}

            {/* Action Buttons */}
            <div className="grid grid-cols-3 gap-3 mb-6">
              <button
                onClick={handleVoiceClick}
                className="flex flex-col items-center justify-center gap-1 bg-white/10 backdrop-blur-sm text-white py-3 rounded-xl"
              >
                <Phone className="w-5 h-5" />
                <span className="text-xs">Voice</span>
              </button>
              <button
                onClick={handleVideoClick}
                className="flex flex-col items-center justify-center gap-1 bg-white/10 backdrop-blur-sm text-white py-3 rounded-xl"
              >
                <Video className="w-5 h-5" />
                <span className="text-xs">Video</span>
              </button>
              <button
                onClick={() => {
                  // Check if user is verified before allowing offline meeting
                  if (!isVerified.idCard || !isVerified.selfie) {
                    setShowVerificationModal(true);
                  } else {
                    setIsMeetOfflineOpen(true);
                  }
                }}
                className="flex flex-col items-center justify-center gap-1 bg-white/10 backdrop-blur-sm text-white py-3 rounded-xl hover:bg-white/20 transition-all relative"
              >
                <MapPin className="w-5 h-5" />
                <span className="text-xs">Meet</span>
                {(!isVerified.idCard || !isVerified.selfie) && (
                  <div className="absolute -top-1 -right-1 w-4 h-4 bg-red-500 rounded-full flex items-center justify-center">
                    <span className="text-white text-xs">!</span>
                  </div>
                )}
              </button>
            </div>

            {/* Reviews */}
            <div className="bg-white/10 backdrop-blur-sm rounded-2xl p-4">
              <div className="flex items-center gap-2 mb-3">
                <h3 className="text-white font-semibold">Reviews</h3>
                <div className="flex items-center gap-1">
                  {[...Array(5)].map((_, i) => (
                    <Star
                      key={i}
                      className={`w-4 h-4 ${
                        i < Math.floor(host.rating)
                          ? "fill-yellow-400 text-yellow-400"
                          : "text-gray-400"
                      }`}
                    />
                  ))}
                  <span className="text-white text-sm ml-1">
                    {host.rating} ({host.reviewCount} Reviews)
                  </span>
                </div>
              </div>
              <div className="flex items-start gap-3">
                <img
                  src="https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=100"
                  alt="Reviewer"
                  className="w-10 h-10 rounded-full object-cover"
                />
                <div className="flex-1">
                  <p className="text-white font-medium text-sm">Aditya</p>
                  <p className="text-white/80 text-sm mt-1">
                    Clara is really sweet and easy to talk to. Always makes me smile!
                  </p>
                </div>
              </div>
              <button className="text-orange-400 text-sm mt-3 flex items-center gap-1">
                ♥ 125 Reviews
              </button>
            </div>
          </div>
        </div>
      </div>
      <PhotoGalleryModal
        isOpen={isGalleryOpen}
        onClose={() => setIsGalleryOpen(false)}
        photos={host.portfolio}
        initialIndex={selectedPhotoIndex}
        hostName={`${host.name}'s Portfolio`}
      />
      <MeetOfflineModal
        isOpen={isMeetOfflineOpen}
        onClose={() => setIsMeetOfflineOpen(false)}
        hostName={host.name}
        hostLocation={host.location}
      />
      {/* Payment Modal */}
      {showPaymentModal && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full overflow-hidden">
            {/* Modal Header */}
            <div className="bg-gradient-to-r from-orange-600 to-orange-500 px-6 py-4 flex items-center justify-between">
              <h2 className="text-xl font-bold text-white">{getPaymentTitle()}</h2>
              <button
                onClick={() => setShowPaymentModal(false)}
                className="w-8 h-8 rounded-full bg-white/20 hover:bg-white/30 flex items-center justify-center transition-colors"
              >
                <X className="w-5 h-5 text-white" />
              </button>
            </div>

            {/* Modal Content */}
            <div className="p-6">
              {/* Icon Display */}
              <div className="flex items-center justify-center mb-4">
                <div className={`w-20 h-20 rounded-full flex items-center justify-center ${
                  paymentType === "chat" ? "bg-blue-100" :
                  paymentType === "voice" ? "bg-green-100" :
                  "bg-purple-100"
                }`}>
                  {getPaymentIcon()}
                </div>
              </div>

              {/* Host Info */}
              <div className="flex items-center gap-3 mb-4 bg-gray-50 rounded-xl p-4">
                <div className="relative">
                  <img
                    src={host.image}
                    alt={host.name}
                    className="w-12 h-12 rounded-full object-cover"
                  />
                  <FlagBadge countryCode={host.country} size="sm" />
                </div>
                <div className="flex-1">
                  <p className="font-semibold text-gray-800">{host.name}</p>
                  <p className="text-sm text-gray-600">{host.location}</p>
                </div>
              </div>

              {/* Description */}
              <div className="bg-blue-50 border border-blue-200 rounded-xl p-4 mb-4">
                <p className="text-sm text-blue-800 font-medium mb-1">ℹ️ Payment Information</p>
                <p className="text-sm text-gray-700">{getPaymentDescription()}</p>
              </div>

              {/* Cost Breakdown */}
              <div className="space-y-3 mb-6">
                <div className="flex items-center justify-between py-2 border-b border-gray-200">
                  <span className="text-gray-600">Rate per hour</span>
                  <span className="font-semibold text-gray-800">🪙 {getCost().toLocaleString()}</span>
                </div>
                <div className="flex items-center justify-between py-2 border-b border-gray-200">
                  <span className="text-gray-600">Your balance</span>
                  <span className={`font-semibold ${userBalance >= getCost() ? "text-green-600" : "text-red-600"}`}>
                    🪙 {userBalance.toLocaleString()}
                  </span>
                </div>
                {userBalance < getCost() && (
                  <div className="bg-red-50 border border-red-200 rounded-xl p-3">
                    <p className="text-sm text-red-700 font-semibold">⚠️ Insufficient Balance</p>
                    <p className="text-xs text-red-600 mt-1">
                      Please top up your account to continue
                    </p>
                  </div>
                )}
              </div>

              {/* Action Buttons */}
              <div className="flex gap-3">
                <button
                  onClick={() => setShowPaymentModal(false)}
                  className="flex-1 px-6 py-3 bg-gray-100 text-gray-700 rounded-xl font-semibold hover:bg-gray-200 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={handlePaymentConfirm}
                  className="flex-1 px-6 py-3 bg-gradient-to-r from-orange-600 to-orange-500 text-white rounded-xl font-semibold hover:shadow-lg transition-all"
                >
                  Confirm & Start
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
      {/* Error Modal */}
      {showErrorModal && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full overflow-hidden">
            {/* Modal Header */}
            <div className="bg-gradient-to-r from-red-600 to-red-500 px-6 py-4 flex items-center justify-between">
              <h2 className="text-xl font-bold text-white">Insufficient Balance</h2>
              <button
                onClick={() => setShowErrorModal(false)}
                className="w-8 h-8 rounded-full bg-white/20 hover:bg-white/30 flex items-center justify-center transition-colors"
              >
                <X className="w-5 h-5 text-white" />
              </button>
            </div>

            {/* Modal Content */}
            <div className="p-6">
              <div className="flex items-center justify-center mb-4">
                <AlertCircle className="w-20 h-20 text-red-500" />
              </div>
              <p className="text-sm text-gray-700 text-center mb-4">
                You do not have enough coins to proceed with this payment.
              </p>
              <div className="flex gap-3">
                <button
                  onClick={() => setShowErrorModal(false)}
                  className="flex-1 px-6 py-3 bg-gray-100 text-gray-700 rounded-xl font-semibold hover:bg-gray-200 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={() => navigate("/top-up")}
                  className="flex-1 px-6 py-3 bg-gradient-to-r from-orange-600 to-orange-500 text-white rounded-xl font-semibold hover:shadow-lg transition-all"
                >
                  Top Up
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
      {/* Verification Required Modal */}
      {showVerificationModal && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full overflow-hidden">
            {/* Modal Header */}
            <div className="bg-gradient-to-r from-amber-600 to-orange-600 px-6 py-4 flex items-center justify-between">
              <h2 className="text-xl font-bold text-white">Verification Required</h2>
              <button
                onClick={() => setShowVerificationModal(false)}
                className="w-8 h-8 rounded-full bg-white/20 hover:bg-white/30 flex items-center justify-center transition-colors"
              >
                <X className="w-5 h-5 text-white" />
              </button>
            </div>

            {/* Modal Content */}
            <div className="p-6">
              <div className="flex items-center justify-center mb-4">
                <div className="w-20 h-20 bg-amber-100 rounded-full flex items-center justify-center">
                  <ShieldCheck className="w-12 h-12 text-amber-600" />
                </div>
              </div>
              
              <h3 className="text-lg font-semibold text-gray-800 text-center mb-2">
                Verify Your Identity
              </h3>
              <p className="text-sm text-gray-600 text-center mb-6">
                For safety and security, you must complete identity verification before booking offline meetings with talent.
              </p>

              {/* Requirements List */}
              <div className="bg-gray-50 rounded-xl p-4 mb-6 space-y-3">
                <h4 className="text-sm font-semibold text-gray-700 mb-2">Required Verification:</h4>
                <div className="flex items-start gap-3">
                  <div className={`w-5 h-5 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 ${
                    isVerified.idCard ? "bg-green-100" : "bg-red-100"
                  }`}>
                    {isVerified.idCard ? (
                      <span className="text-green-600 text-xs">✓</span>
                    ) : (
                      <span className="text-red-600 text-xs">✗</span>
                    )}
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-800">ID Card Verification</p>
                    <p className="text-xs text-gray-600">Upload government-issued ID</p>
                  </div>
                </div>
                <div className="flex items-start gap-3">
                  <div className={`w-5 h-5 rounded-full flex items-center justify-center flex-shrink-0 mt-0.5 ${
                    isVerified.selfie ? "bg-green-100" : "bg-red-100"
                  }`}>
                    {isVerified.selfie ? (
                      <span className="text-green-600 text-xs">✓</span>
                    ) : (
                      <span className="text-red-600 text-xs">✗</span>
                    )}
                  </div>
                  <div>
                    <p className="text-sm font-medium text-gray-800">Selfie Verification</p>
                    <p className="text-xs text-gray-600">Upload selfie holding your ID</p>
                  </div>
                </div>
              </div>

              {/* Info Box */}
              <div className="bg-blue-50 border border-blue-200 rounded-xl p-4 mb-6">
                <div className="flex gap-3">
                  <ShieldCheck className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
                  <div>
                    <p className="text-sm font-medium text-blue-900 mb-1">Why Verification?</p>
                    <p className="text-xs text-blue-700">
                      Verification protects both users and talent, ensuring safe and trustworthy offline meetings. Your documents are encrypted and secure.
                    </p>
                  </div>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex gap-3">
                <button
                  onClick={() => setShowVerificationModal(false)}
                  className="flex-1 px-6 py-3 bg-gray-100 text-gray-700 rounded-xl font-semibold hover:bg-gray-200 transition-colors"
                >
                  Cancel
                </button>
                <button
                  onClick={() => {
                    setShowVerificationModal(false);
                    navigate("/settings");
                  }}
                  className="flex-1 px-6 py-3 bg-gradient-to-r from-amber-600 to-orange-600 text-white rounded-xl font-semibold hover:shadow-lg transition-all"
                >
                  Verify Now
                </button>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}