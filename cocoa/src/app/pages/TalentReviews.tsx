import { useState } from "react";
import { useNavigate } from "react-router";
import { ChevronLeft, Star, ThumbsUp, MessageSquare } from "lucide-react";
import { TalentBottomNav } from "../components/TalentBottomNav";
import { FlagBadge } from "../components/FlagBadge";

interface Review {
  id: number;
  userName: string;
  userAvatar: string;
  rating: number;
  comment: string;
  date: string;
  chatDuration: string;
  coinsEarned: number;
}

export function TalentReviews() {
  const navigate = useNavigate();
  const [filter, setFilter] = useState<"all" | "5" | "4" | "3">("all");

  const reviews: Review[] = [
    {
      id: 1,
      userName: "Sarah Johnson",
      userAvatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100",
      rating: 5,
      comment: "Amazing conversation! Jessica is very kind and understanding. Really enjoyed chatting with her!",
      date: "2 days ago",
      chatDuration: "45 min",
      coinsEarned: 120,
    },
    {
      id: 2,
      userName: "Mike Chen",
      userAvatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100",
      rating: 5,
      comment: "Great listener! Made my day better.",
      date: "3 days ago",
      chatDuration: "30 min",
      coinsEarned: 80,
    },
    {
      id: 3,
      userName: "Emma Wilson",
      userAvatar: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100",
      rating: 4,
      comment: "Very pleasant conversation. Would chat again!",
      date: "5 days ago",
      chatDuration: "25 min",
      coinsEarned: 65,
    },
    {
      id: 4,
      userName: "David Lee",
      userAvatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100",
      rating: 5,
      comment: "Jessica is wonderful! So easy to talk to and very genuine.",
      date: "1 week ago",
      chatDuration: "60 min",
      coinsEarned: 150,
    },
    {
      id: 5,
      userName: "Lisa Anderson",
      userAvatar: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100",
      rating: 5,
      comment: "Best chat I've had on this app! Highly recommend.",
      date: "1 week ago",
      chatDuration: "40 min",
      coinsEarned: 100,
    },
    {
      id: 6,
      userName: "James Wilson",
      userAvatar: "https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?w=100",
      rating: 4,
      comment: "Good conversation, very friendly!",
      date: "2 weeks ago",
      chatDuration: "35 min",
      coinsEarned: 90,
    },
  ];

  const filteredReviews = reviews.filter((review) => {
    if (filter === "all") return true;
    return review.rating === Number(filter);
  });

  const averageRating = (
    reviews.reduce((sum, review) => sum + review.rating, 0) / reviews.length
  ).toFixed(1);

  const ratingDistribution = {
    5: reviews.filter((r) => r.rating === 5).length,
    4: reviews.filter((r) => r.rating === 4).length,
    3: reviews.filter((r) => r.rating === 3).length,
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-amber-100">
      <div className="max-w-md mx-auto bg-white min-h-screen shadow-2xl pb-20">
        {/* Header */}
        <div className="bg-gradient-to-br from-amber-700 to-amber-600 px-6 pt-8 pb-6">
          <button
            onClick={() => navigate("/talent-home")}
            className="text-white mb-4"
          >
            <ChevronLeft className="w-6 h-6" />
          </button>
          <h1 className="text-2xl font-semibold text-white mb-2">User Reviews</h1>
          <p className="text-amber-100 text-sm">See what users are saying about you</p>
        </div>

        {/* Rating Overview */}
        <div className="px-6 -mt-4 relative z-10">
          <div className="bg-white rounded-2xl shadow-lg p-6">
            <div className="flex items-center gap-6 mb-6">
              <div className="text-center">
                <p className="text-5xl font-bold text-gray-800 mb-1">{averageRating}</p>
                <div className="flex items-center gap-1 mb-1">
                  {[1, 2, 3, 4, 5].map((star) => (
                    <Star
                      key={star}
                      className={`w-4 h-4 ${
                        star <= Math.round(Number(averageRating))
                          ? "fill-amber-500 text-amber-500"
                          : "text-gray-300"
                      }`}
                    />
                  ))}
                </div>
                <p className="text-sm text-gray-500">{reviews.length} reviews</p>
              </div>

              <div className="flex-1">
                {[5, 4, 3].map((rating) => (
                  <div key={rating} className="flex items-center gap-2 mb-2">
                    <span className="text-sm text-gray-600 w-3">{rating}</span>
                    <Star className="w-3 h-3 fill-amber-500 text-amber-500" />
                    <div className="flex-1 h-2 bg-gray-200 rounded-full overflow-hidden">
                      <div
                        className="h-full bg-amber-500 rounded-full"
                        style={{
                          width: `${(ratingDistribution[rating as keyof typeof ratingDistribution] / reviews.length) * 100}%`,
                        }}
                      ></div>
                    </div>
                    <span className="text-sm text-gray-500 w-8 text-right">
                      {ratingDistribution[rating as keyof typeof ratingDistribution]}
                    </span>
                  </div>
                ))}
              </div>
            </div>

            {/* Filter Buttons */}
            <div className="flex gap-2">
              <button
                onClick={() => setFilter("all")}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                  filter === "all"
                    ? "bg-amber-600 text-white"
                    : "bg-gray-100 text-gray-600 hover:bg-gray-200"
                }`}
              >
                All
              </button>
              <button
                onClick={() => setFilter("5")}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                  filter === "5"
                    ? "bg-amber-600 text-white"
                    : "bg-gray-100 text-gray-600 hover:bg-gray-200"
                }`}
              >
                5 ⭐
              </button>
              <button
                onClick={() => setFilter("4")}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                  filter === "4"
                    ? "bg-amber-600 text-white"
                    : "bg-gray-100 text-gray-600 hover:bg-gray-200"
                }`}
              >
                4 ⭐
              </button>
              <button
                onClick={() => setFilter("3")}
                className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                  filter === "3"
                    ? "bg-amber-600 text-white"
                    : "bg-gray-100 text-gray-600 hover:bg-gray-200"
                }`}
              >
                3 ⭐
              </button>
            </div>
          </div>
        </div>

        {/* Reviews List */}
        <div className="px-6 mt-6">
          <h2 className="text-lg font-semibold mb-3">Recent Reviews</h2>
          <div className="space-y-4">
            {filteredReviews.map((review) => (
              <div
                key={review.id}
                className="bg-white rounded-2xl shadow-sm p-4"
              >
                <div className="flex items-start gap-3 mb-3">
                  <div className="relative">
                    <img
                      src={review.userAvatar}
                      alt={review.userName}
                      className="w-12 h-12 rounded-full object-cover"
                    />
                    <FlagBadge countryCode="US" size="sm" />
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center justify-between mb-1">
                      <p className="font-semibold text-gray-800">{review.userName}</p>
                      <span className="text-xs text-gray-400">{review.date}</span>
                    </div>
                    <div className="flex items-center gap-1 mb-2">
                      {[1, 2, 3, 4, 5].map((star) => (
                        <Star
                          key={star}
                          className={`w-4 h-4 ${
                            star <= review.rating
                              ? "fill-amber-500 text-amber-500"
                              : "text-gray-300"
                          }`}
                        />
                      ))}
                    </div>
                  </div>
                </div>

                <p className="text-gray-700 mb-3">{review.comment}</p>

                <div className="flex items-center gap-4 pt-3 border-t border-gray-100">
                  <div className="flex items-center gap-1 text-sm text-gray-500">
                    <MessageSquare className="w-4 h-4" />
                    <span>{review.chatDuration}</span>
                  </div>
                  <div className="flex items-center gap-1 text-sm text-green-600 font-medium">
                    <span>🪙 {review.coinsEarned} coins</span>
                  </div>
                </div>
              </div>
            ))}
          </div>

          {filteredReviews.length === 0 && (
            <div className="text-center py-12">
              <p className="text-gray-500">No reviews found for this rating</p>
            </div>
          )}
        </div>
      </div>
      <TalentBottomNav />
    </div>
  );
}