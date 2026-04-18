import { useState } from "react";
import { useNavigate } from "react-router";
import { ChevronLeft, Star, Gift, Send, CheckCircle } from "lucide-react";
import { FlagBadge } from "../components/FlagBadge";

// Mock data for talents the user has interacted with
const interactedTalents = [
  {
    id: 1,
    name: "Clara",
    image: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400",
    country: "ID",
    location: "Jakarta, Indonesia",
    lastChat: "2 days ago",
    hasReviewed: false,
  },
  {
    id: 2,
    name: "Sophie",
    image: "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400",
    country: "FR",
    location: "Paris, France",
    lastChat: "1 week ago",
    hasReviewed: false,
  },
  {
    id: 3,
    name: "Emma",
    image: "https://images.unsplash.com/photo-1524504388940-b1c1722653e1?w=400",
    country: "GB",
    location: "London, UK",
    lastChat: "3 days ago",
    hasReviewed: true,
  },
  {
    id: 4,
    name: "Yuki",
    image: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400",
    country: "JP",
    location: "Tokyo, Japan",
    lastChat: "5 days ago",
    hasReviewed: false,
  },
];

// Virtual gifts catalog
const virtualGifts = [
  { id: 1, name: "Rose", icon: "🌹", coins: 50 },
  { id: 2, name: "Heart", icon: "❤️", coins: 100 },
  { id: 3, name: "Diamond", icon: "💎", coins: 500 },
  { id: 4, name: "Crown", icon: "👑", coins: 1000 },
  { id: 5, name: "Trophy", icon: "🏆", coins: 2000 },
];

export function ReviewTalent() {
  const navigate = useNavigate();
  const [selectedTalent, setSelectedTalent] = useState<number | null>(null);
  const [rating, setRating] = useState(0);
  const [hoverRating, setHoverRating] = useState(0);
  const [reviewText, setReviewText] = useState("");
  const [selectedGift, setSelectedGift] = useState<number | null>(null);
  const [showSuccess, setShowSuccess] = useState(false);

  const handleSubmitReview = () => {
    if (!selectedTalent || rating === 0) {
      alert("Please select a talent and provide a rating");
      return;
    }

    // In a real app, this would send the review to the backend
    console.log({
      talentId: selectedTalent,
      rating,
      reviewText,
      gift: selectedGift ? virtualGifts.find(g => g.id === selectedGift) : null,
    });

    setShowSuccess(true);
    
    // Reset form and go back after showing success
    setTimeout(() => {
      setShowSuccess(false);
      navigate("/profile");
    }, 2000);
  };

  const getTalent = (id: number) => {
    return interactedTalents.find(t => t.id === id);
  };

  const selectedTalentData = selectedTalent ? getTalent(selectedTalent) : null;
  const selectedGiftData = selectedGift ? virtualGifts.find(g => g.id === selectedGift) : null;
  const totalCost = selectedGiftData ? selectedGiftData.coins : 0;

  return (
    <div className="min-h-screen bg-[#f5f1e8] flex justify-center items-center p-4">
      <div className="w-full max-w-md bg-white min-h-screen flex flex-col">
        {/* Header */}
        <div className="bg-gradient-to-r from-purple-600 to-purple-500 px-6 py-4 flex items-center gap-4">
          <button
            onClick={() => navigate(-1)}
            className="w-10 h-10 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center text-white hover:bg-white/30 transition-colors"
          >
            <ChevronLeft className="w-6 h-6" />
          </button>
          <h1 className="text-xl font-bold text-white">Review Talent</h1>
        </div>

        {!selectedTalent ? (
          // Talent Selection View
          <div className="flex-1 overflow-y-auto p-6">
            <div className="mb-4">
              <h2 className="text-lg font-semibold text-gray-800 mb-2">Select a Talent to Review</h2>
              <p className="text-sm text-gray-600">Choose from talents you've chatted with</p>
            </div>

            <div className="space-y-3">
              {interactedTalents.map((talent) => (
                <button
                  key={talent.id}
                  onClick={() => !talent.hasReviewed && setSelectedTalent(talent.id)}
                  disabled={talent.hasReviewed}
                  className={`w-full bg-white rounded-xl border-2 p-4 flex items-center gap-4 transition-all ${
                    talent.hasReviewed
                      ? "border-gray-200 opacity-50 cursor-not-allowed"
                      : "border-gray-200 hover:border-purple-500 hover:shadow-md"
                  }`}
                >
                  <div className="relative flex-shrink-0">
                    <img
                      src={talent.image}
                      alt={talent.name}
                      className="w-16 h-16 rounded-full object-cover"
                    />
                    <FlagBadge countryCode={talent.country} size="md" />
                  </div>
                  <div className="flex-1 text-left">
                    <h3 className="font-semibold text-gray-800">{talent.name}</h3>
                    <p className="text-sm text-gray-600">{talent.location}</p>
                    <p className="text-xs text-gray-500 mt-1">Last chat: {talent.lastChat}</p>
                  </div>
                  {talent.hasReviewed && (
                    <div className="flex items-center gap-1 text-green-600">
                      <CheckCircle className="w-5 h-5" />
                      <span className="text-xs font-medium">Reviewed</span>
                    </div>
                  )}
                </button>
              ))}
            </div>

            {interactedTalents.filter(t => !t.hasReviewed).length === 0 && (
              <div className="text-center py-12">
                <div className="w-20 h-20 bg-purple-100 rounded-full flex items-center justify-center mx-auto mb-4">
                  <CheckCircle className="w-10 h-10 text-purple-600" />
                </div>
                <h3 className="font-semibold text-gray-800 mb-2">All Caught Up!</h3>
                <p className="text-sm text-gray-600">You've reviewed all your recent chats</p>
              </div>
            )}
          </div>
        ) : (
          // Review Form View
          <div className="flex-1 overflow-y-auto p-6">
            {/* Selected Talent Info */}
            <div className="bg-gradient-to-br from-purple-50 to-pink-50 rounded-2xl border border-purple-200 p-4 mb-6">
              <p className="text-xs font-medium text-purple-600 mb-3">REVIEWING</p>
              <div className="flex items-center gap-4">
                <div className="relative">
                  <img
                    src={selectedTalentData?.image}
                    alt={selectedTalentData?.name}
                    className="w-16 h-16 rounded-full object-cover"
                  />
                  <FlagBadge countryCode={selectedTalentData?.country || "US"} size="md" />
                </div>
                <div>
                  <h3 className="font-semibold text-gray-800">{selectedTalentData?.name}</h3>
                  <p className="text-sm text-gray-600">{selectedTalentData?.location}</p>
                </div>
              </div>
            </div>

            {/* Rating Selection */}
            <div className="mb-6">
              <h3 className="font-semibold text-gray-800 mb-3">How was your experience?</h3>
              <div className="flex justify-center gap-2 mb-2">
                {[1, 2, 3, 4, 5].map((star) => (
                  <button
                    key={star}
                    onClick={() => setRating(star)}
                    onMouseEnter={() => setHoverRating(star)}
                    onMouseLeave={() => setHoverRating(0)}
                    className="transition-transform hover:scale-110"
                  >
                    <Star
                      className={`w-12 h-12 transition-colors ${
                        star <= (hoverRating || rating)
                          ? "fill-yellow-400 text-yellow-400"
                          : "text-gray-300"
                      }`}
                    />
                  </button>
                ))}
              </div>
              {rating > 0 && (
                <p className="text-center text-sm text-gray-600">
                  {rating === 5 && "Excellent! ⭐"}
                  {rating === 4 && "Great! 👍"}
                  {rating === 3 && "Good 🙂"}
                  {rating === 2 && "Could be better 😕"}
                  {rating === 1 && "Not satisfied 😞"}
                </p>
              )}
            </div>

            {/* Review Text */}
            <div className="mb-6">
              <h3 className="font-semibold text-gray-800 mb-3">Share your thoughts (Optional)</h3>
              <textarea
                value={reviewText}
                onChange={(e) => setReviewText(e.target.value)}
                placeholder={`Tell us about your experience with ${selectedTalentData?.name}...`}
                className="w-full border-2 border-gray-200 rounded-xl p-4 outline-none focus:border-purple-500 transition-colors resize-none"
                rows={4}
                maxLength={500}
              />
              <p className="text-xs text-gray-500 text-right mt-1">
                {reviewText.length}/500 characters
              </p>
            </div>

            {/* Gift Selection */}
            <div className="mb-6">
              <h3 className="font-semibold text-gray-800 mb-3">
                Send a Gift (Optional) <Gift className="w-5 h-5 inline text-pink-500" />
              </h3>
              <p className="text-sm text-gray-600 mb-3">Show extra appreciation with a virtual gift</p>
              <div className="grid grid-cols-5 gap-2">
                {virtualGifts.map((gift) => (
                  <button
                    key={gift.id}
                    onClick={() => setSelectedGift(selectedGift === gift.id ? null : gift.id)}
                    className={`aspect-square rounded-xl border-2 flex flex-col items-center justify-center gap-1 transition-all ${
                      selectedGift === gift.id
                        ? "border-purple-500 bg-purple-50 shadow-md scale-105"
                        : "border-gray-200 hover:border-purple-300 hover:bg-purple-50"
                    }`}
                  >
                    <span className="text-2xl">{gift.icon}</span>
                    <span className="text-xs font-medium text-gray-700">🪙 {gift.coins}</span>
                  </button>
                ))}
              </div>
              {selectedGift && (
                <div className="mt-3 bg-purple-50 border border-purple-200 rounded-xl p-3">
                  <p className="text-sm text-purple-800 font-medium">
                    Selected: {selectedGiftData?.icon} {selectedGiftData?.name} - 🪙 {selectedGiftData?.coins}
                  </p>
                </div>
              )}
            </div>

            {/* Action Buttons */}
            <div className="flex gap-3 mt-8">
              <button
                onClick={() => {
                  setSelectedTalent(null);
                  setRating(0);
                  setReviewText("");
                  setSelectedGift(null);
                }}
                className="flex-1 px-6 py-3.5 bg-gray-100 text-gray-700 rounded-xl font-semibold hover:bg-gray-200 transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={handleSubmitReview}
                disabled={rating === 0}
                className={`flex-1 px-6 py-3.5 rounded-xl font-semibold transition-all flex items-center justify-center gap-2 ${
                  rating === 0
                    ? "bg-gray-300 text-gray-500 cursor-not-allowed"
                    : "bg-gradient-to-r from-purple-600 to-purple-500 text-white hover:shadow-lg"
                }`}
              >
                <Send className="w-5 h-5" />
                Submit Review
                {totalCost > 0 && ` (🪙 ${totalCost})`}
              </button>
            </div>
          </div>
        )}

        {/* Success Modal */}
        {showSuccess && (
          <div className="fixed inset-0 bg-black/60 backdrop-blur-sm flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-2xl shadow-2xl max-w-sm w-full p-8 text-center">
              <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <CheckCircle className="w-12 h-12 text-green-600" />
              </div>
              <h3 className="text-xl font-bold text-gray-800 mb-2">Review Submitted!</h3>
              <p className="text-sm text-gray-600 mb-4">
                Thank you for your feedback. It helps talents improve their service.
              </p>
              {selectedGift && (
                <div className="bg-purple-50 border border-purple-200 rounded-xl p-3">
                  <p className="text-sm text-purple-800">
                    Your gift {selectedGiftData?.icon} has been sent to {selectedTalentData?.name}!
                  </p>
                </div>
              )}
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
