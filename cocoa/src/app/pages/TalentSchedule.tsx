import { useState } from "react";
import { useNavigate } from "react-router";
import {
  ArrowLeft,
  Calendar,
  Clock,
  MapPin,
  User,
  Check,
  X,
  AlertCircle,
  CheckCircle,
  XCircle,
  ChevronDown,
} from "lucide-react";
import { TalentBottomNav } from "../components/TalentBottomNav";
import { FlagBadge } from "../components/FlagBadge";

interface Booking {
  id: number;
  userName: string;
  userAvatar: string;
  countryCode: string;
  date: string;
  time: string;
  duration: string;
  location: string;
  coins: number;
  status: "pending" | "accepted" | "cancelled" | "completed";
  requestedAt: string;
  userNote?: string;
}

export function TalentSchedule() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<"pending" | "upcoming" | "history">("pending");
  const [showCancelModal, setShowCancelModal] = useState(false);
  const [selectedBooking, setSelectedBooking] = useState<Booking | null>(null);
  const [cancelReason, setCancelReason] = useState("");
  const [selectedReasonOption, setSelectedReasonOption] = useState("");
  const [showReasonDropdown, setShowReasonDropdown] = useState(false);

  // Sample bookings data
  const [bookings, setBookings] = useState<Booking[]>([
    {
      id: 1,
      userName: "Sarah Johnson",
      userAvatar: "https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100",
      countryCode: "US",
      date: "2026-04-20",
      time: "10:00 AM",
      duration: "4 hours",
      location: "Starbucks Downtown, Main St",
      coins: 400,
      status: "pending",
      requestedAt: "2 hours ago",
      userNote: "Looking forward to meeting you! I'd love to discuss travel experiences.",
    },
    {
      id: 2,
      userName: "Mike Chen",
      userAvatar: "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100",
      countryCode: "CN",
      date: "2026-04-21",
      time: "2:00 PM",
      duration: "3 hours",
      location: "Central Park Cafe",
      coins: 300,
      status: "pending",
      requestedAt: "5 hours ago",
    },
    {
      id: 3,
      userName: "Emma Wilson",
      userAvatar: "https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100",
      countryCode: "GB",
      date: "2026-04-22",
      time: "11:00 AM",
      duration: "5 hours",
      location: "Riverside Restaurant",
      coins: 500,
      status: "accepted",
      requestedAt: "1 day ago",
    },
    {
      id: 4,
      userName: "David Lee",
      userAvatar: "https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100",
      countryCode: "KR",
      date: "2026-04-15",
      time: "3:00 PM",
      duration: "4 hours",
      location: "Marina Bay View",
      coins: 400,
      status: "completed",
      requestedAt: "3 days ago",
    },
    {
      id: 5,
      userName: "Lisa Anderson",
      userAvatar: "https://images.unsplash.com/photo-1517841905240-472988babdf9?w=100",
      countryCode: "AU",
      date: "2026-04-18",
      time: "1:00 PM",
      duration: "3 hours",
      location: "Beachside Cafe",
      coins: 300,
      status: "cancelled",
      requestedAt: "2 days ago",
    },
  ]);

  const cancelReasons = [
    "Personal emergency",
    "Schedule conflict",
    "Feeling unwell",
    "Location is too far",
    "Safety concerns",
    "Double booking",
    "Other (please specify)",
  ];

  const handleAccept = (booking: Booking) => {
    setBookings((prev) =>
      prev.map((b) => (b.id === booking.id ? { ...b, status: "accepted" } : b))
    );
    // Show success message
    alert(`✅ Booking accepted! You will meet ${booking.userName} on ${formatDate(booking.date)} at ${booking.time}`);
  };

  const handleCancelClick = (booking: Booking) => {
    setSelectedBooking(booking);
    setShowCancelModal(true);
    setCancelReason("");
    setSelectedReasonOption("");
  };

  const handleCancelConfirm = () => {
    if (!selectedBooking) return;

    const finalReason = selectedReasonOption === "Other (please specify)" 
      ? cancelReason 
      : selectedReasonOption;

    if (!finalReason.trim()) {
      alert("Please provide a cancellation reason");
      return;
    }

    setBookings((prev) =>
      prev.map((b) => (b.id === selectedBooking.id ? { ...b, status: "cancelled" } : b))
    );

    setShowCancelModal(false);
    
    // Show refund confirmation
    alert(
      `❌ Booking cancelled\n\n` +
      `Reason: ${finalReason}\n\n` +
      `🪙 ${selectedBooking.coins} coins will be refunded to ${selectedBooking.userName}`
    );

    setSelectedBooking(null);
    setCancelReason("");
    setSelectedReasonOption("");
  };

  const formatDate = (dateStr: string) => {
    const date = new Date(dateStr);
    return date.toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" });
  };

  const getFilteredBookings = () => {
    switch (activeTab) {
      case "pending":
        return bookings.filter((b) => b.status === "pending");
      case "upcoming":
        return bookings.filter((b) => b.status === "accepted");
      case "history":
        return bookings.filter((b) => b.status === "completed" || b.status === "cancelled");
      default:
        return [];
    }
  };

  const filteredBookings = getFilteredBookings();

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "pending":
        return (
          <span className="px-2 py-1 bg-yellow-100 text-yellow-700 text-xs font-semibold rounded-full">
            ⏳ Pending
          </span>
        );
      case "accepted":
        return (
          <span className="px-2 py-1 bg-green-100 text-green-700 text-xs font-semibold rounded-full">
            ✓ Accepted
          </span>
        );
      case "cancelled":
        return (
          <span className="px-2 py-1 bg-red-100 text-red-700 text-xs font-semibold rounded-full">
            ✕ Cancelled
          </span>
        );
      case "completed":
        return (
          <span className="px-2 py-1 bg-blue-100 text-blue-700 text-xs font-semibold rounded-full">
            ✓ Completed
          </span>
        );
      default:
        return null;
    }
  };

  return (
    <div className="min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-amber-100">
      <div className="max-w-md mx-auto bg-white min-h-screen shadow-2xl pb-24">
        {/* Header */}
        <div className="bg-gradient-to-br from-amber-700 to-amber-600 px-6 pt-8 pb-6 sticky top-0 z-20 shadow-lg">
          <div className="flex items-center gap-4 mb-4">
            <button
              onClick={() => navigate("/talent-home")}
              className="text-white hover:bg-white/20 p-2 rounded-full transition-colors"
            >
              <ArrowLeft className="w-6 h-6" />
            </button>
            <h1 className="text-2xl font-bold text-white">Booking Schedule</h1>
          </div>

          {/* Tabs */}
          <div className="flex gap-2 bg-white/20 backdrop-blur-sm rounded-xl p-1">
            <button
              onClick={() => setActiveTab("pending")}
              className={`flex-1 py-2 px-3 rounded-lg font-medium text-sm transition-all ${
                activeTab === "pending"
                  ? "bg-white text-amber-700 shadow-md"
                  : "text-white/90 hover:text-white"
              }`}
            >
              Pending
              {bookings.filter((b) => b.status === "pending").length > 0 && (
                <span className="ml-1 bg-red-500 text-white text-xs px-1.5 py-0.5 rounded-full">
                  {bookings.filter((b) => b.status === "pending").length}
                </span>
              )}
            </button>
            <button
              onClick={() => setActiveTab("upcoming")}
              className={`flex-1 py-2 px-3 rounded-lg font-medium text-sm transition-all ${
                activeTab === "upcoming"
                  ? "bg-white text-amber-700 shadow-md"
                  : "text-white/90 hover:text-white"
              }`}
            >
              Upcoming
            </button>
            <button
              onClick={() => setActiveTab("history")}
              className={`flex-1 py-2 px-3 rounded-lg font-medium text-sm transition-all ${
                activeTab === "history"
                  ? "bg-white text-amber-700 shadow-md"
                  : "text-white/90 hover:text-white"
              }`}
            >
              History
            </button>
          </div>
        </div>

        {/* Bookings List */}
        <div className="px-6 py-6">
          {filteredBookings.length === 0 ? (
            <div className="text-center py-12">
              <Calendar className="w-16 h-16 text-gray-300 mx-auto mb-4" />
              <p className="text-gray-500 font-medium">No bookings in this category</p>
              <p className="text-gray-400 text-sm mt-1">
                {activeTab === "pending" && "New booking requests will appear here"}
                {activeTab === "upcoming" && "Accepted bookings will appear here"}
                {activeTab === "history" && "Completed and cancelled bookings will appear here"}
              </p>
            </div>
          ) : (
            <div className="space-y-4">
              {filteredBookings.map((booking) => (
                <div key={booking.id} className="bg-white rounded-2xl shadow-lg overflow-hidden border border-gray-100">
                  {/* User Info */}
                  <div className="p-4 border-b border-gray-100">
                    <div className="flex items-center justify-between mb-3">
                      <div className="flex items-center gap-3">
                        <div className="relative">
                          <img
                            src={booking.userAvatar}
                            alt={booking.userName}
                            className="w-12 h-12 rounded-full object-cover"
                          />
                          <FlagBadge countryCode={booking.countryCode} size="sm" />
                        </div>
                        <div>
                          <p className="font-semibold text-gray-800">{booking.userName}</p>
                          <p className="text-xs text-gray-500">Requested {booking.requestedAt}</p>
                        </div>
                      </div>
                      {getStatusBadge(booking.status)}
                    </div>

                    {/* User Note */}
                    {booking.userNote && (
                      <div className="bg-blue-50 border border-blue-100 rounded-xl p-3 mt-3">
                        <p className="text-xs font-semibold text-blue-700 mb-1">💬 Message from user:</p>
                        <p className="text-sm text-gray-700">{booking.userNote}</p>
                      </div>
                    )}
                  </div>

                  {/* Booking Details */}
                  <div className="p-4 bg-gray-50 space-y-3">
                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                        <Calendar className="w-4 h-4 text-blue-600" />
                      </div>
                      <div>
                        <p className="text-xs text-gray-500">Date</p>
                        <p className="font-semibold text-gray-800">{formatDate(booking.date)}</p>
                      </div>
                    </div>

                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 bg-purple-100 rounded-full flex items-center justify-center">
                        <Clock className="w-4 h-4 text-purple-600" />
                      </div>
                      <div>
                        <p className="text-xs text-gray-500">Time & Duration</p>
                        <p className="font-semibold text-gray-800">
                          {booking.time} • {booking.duration}
                        </p>
                      </div>
                    </div>

                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 bg-green-100 rounded-full flex items-center justify-center">
                        <MapPin className="w-4 h-4 text-green-600" />
                      </div>
                      <div className="flex-1">
                        <p className="text-xs text-gray-500">Meeting Location</p>
                        <p className="font-semibold text-gray-800">{booking.location}</p>
                      </div>
                    </div>

                    <div className="flex items-center gap-3">
                      <div className="w-8 h-8 bg-amber-100 rounded-full flex items-center justify-center text-amber-600 font-bold">
                        🪙
                      </div>
                      <div>
                        <p className="text-xs text-gray-500">Payment</p>
                        <p className="font-semibold text-gray-800">🪙 {booking.coins} coins</p>
                      </div>
                    </div>
                  </div>

                  {/* Action Buttons */}
                  {booking.status === "pending" && (
                    <div className="p-4 grid grid-cols-2 gap-3">
                      <button
                        onClick={() => handleAccept(booking)}
                        className="flex items-center justify-center gap-2 bg-green-500 text-white py-3 rounded-xl font-semibold hover:bg-green-600 transition-colors"
                      >
                        <Check className="w-5 h-5" />
                        Accept
                      </button>
                      <button
                        onClick={() => handleCancelClick(booking)}
                        className="flex items-center justify-center gap-2 bg-red-500 text-white py-3 rounded-xl font-semibold hover:bg-red-600 transition-colors"
                      >
                        <X className="w-5 h-5" />
                        Decline
                      </button>
                    </div>
                  )}

                  {booking.status === "accepted" && (
                    <div className="p-4">
                      <button
                        onClick={() => handleCancelClick(booking)}
                        className="w-full flex items-center justify-center gap-2 bg-red-50 text-red-600 py-3 rounded-xl font-semibold hover:bg-red-100 transition-colors border border-red-200"
                      >
                        <X className="w-5 h-5" />
                        Cancel Booking
                      </button>
                    </div>
                  )}
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Cancel Modal */}
        {showCancelModal && selectedBooking && (
          <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
            <div className="bg-white rounded-2xl max-w-md w-full max-h-[90vh] overflow-y-auto">
              {/* Modal Header */}
              <div className="bg-red-500 px-6 py-4 flex items-center gap-3">
                <AlertCircle className="w-6 h-6 text-white" />
                <h2 className="text-xl font-bold text-white">Cancel Booking</h2>
              </div>

              {/* Modal Content */}
              <div className="p-6">
                <div className="bg-red-50 border border-red-200 rounded-xl p-4 mb-4">
                  <p className="text-sm text-red-700 font-semibold mb-2">⚠️ Important:</p>
                  <p className="text-sm text-gray-700">
                    If you cancel this booking, <span className="font-bold">🪙 {selectedBooking.coins} coins will be refunded</span> to {selectedBooking.userName}.
                  </p>
                </div>

                {/* Booking Summary */}
                <div className="bg-gray-50 rounded-xl p-4 mb-4">
                  <p className="font-semibold text-gray-800 mb-2">Booking Details:</p>
                  <div className="space-y-1 text-sm text-gray-600">
                    <p>👤 {selectedBooking.userName}</p>
                    <p>📅 {formatDate(selectedBooking.date)} at {selectedBooking.time}</p>
                    <p>⏱️ Duration: {selectedBooking.duration}</p>
                    <p>📍 {selectedBooking.location}</p>
                  </div>
                </div>

                {/* Reason Selection */}
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Cancellation Reason <span className="text-red-500">*</span>
                </label>

                {/* Dropdown for preset reasons */}
                <div className="relative mb-4">
                  <button
                    onClick={() => setShowReasonDropdown(!showReasonDropdown)}
                    className="w-full flex items-center justify-between px-4 py-3 border border-gray-300 rounded-xl text-left hover:border-amber-500 transition-colors"
                  >
                    <span className={selectedReasonOption ? "text-gray-800" : "text-gray-400"}>
                      {selectedReasonOption || "Select a reason..."}
                    </span>
                    <ChevronDown className={`w-5 h-5 text-gray-400 transition-transform ${showReasonDropdown ? "rotate-180" : ""}`} />
                  </button>

                  {showReasonDropdown && (
                    <div className="absolute top-full left-0 right-0 mt-1 bg-white border border-gray-200 rounded-xl shadow-lg z-10 max-h-60 overflow-y-auto">
                      {cancelReasons.map((reason, index) => (
                        <button
                          key={index}
                          onClick={() => {
                            setSelectedReasonOption(reason);
                            setShowReasonDropdown(false);
                            if (reason !== "Other (please specify)") {
                              setCancelReason(reason);
                            } else {
                              setCancelReason("");
                            }
                          }}
                          className={`w-full text-left px-4 py-3 hover:bg-gray-50 transition-colors ${
                            index !== cancelReasons.length - 1 ? "border-b border-gray-100" : ""
                          } ${selectedReasonOption === reason ? "bg-amber-50 text-amber-700 font-semibold" : "text-gray-700"}`}
                        >
                          {reason}
                        </button>
                      ))}
                    </div>
                  )}
                </div>

                {/* Custom Reason Input (shown when "Other" is selected) */}
                {selectedReasonOption === "Other (please specify)" && (
                  <div className="mb-4">
                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                      Please specify your reason:
                    </label>
                    <textarea
                      value={cancelReason}
                      onChange={(e) => setCancelReason(e.target.value)}
                      placeholder="Enter your cancellation reason..."
                      className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:outline-none focus:ring-2 focus:ring-amber-500 resize-none"
                      rows={3}
                    />
                  </div>
                )}

                {/* Action Buttons */}
                <div className="flex gap-3">
                  <button
                    onClick={() => {
                      setShowCancelModal(false);
                      setSelectedBooking(null);
                      setCancelReason("");
                      setSelectedReasonOption("");
                    }}
                    className="flex-1 px-4 py-3 bg-gray-100 text-gray-700 rounded-xl font-semibold hover:bg-gray-200 transition-colors"
                  >
                    Keep Booking
                  </button>
                  <button
                    onClick={handleCancelConfirm}
                    className="flex-1 px-4 py-3 bg-red-500 text-white rounded-xl font-semibold hover:bg-red-600 transition-colors"
                  >
                    Confirm Cancel
                  </button>
                </div>
              </div>
            </div>
          </div>
        )}
      </div>
      <TalentBottomNav />
    </div>
  );
}
