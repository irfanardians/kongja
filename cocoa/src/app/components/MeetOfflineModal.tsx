import { useState } from "react";
import { X, Calendar, Clock, MapPin, CheckCircle2, ChevronLeft, ChevronRight, AlertCircle, Sparkles } from "lucide-react";

interface MeetOfflineModalProps {
  isOpen: boolean;
  onClose: () => void;
  hostName: string;
  hostLocation?: string;
}

interface TimeSlot {
  time: string;
  hour: number;
  minute: number;
  isBooked: boolean;
  isPast: boolean;
}

interface CalendarDay {
  date: Date;
  dateString: string;
  day: number;
  isCurrentMonth: boolean;
  isToday: boolean;
  isPast: boolean;
  isSelectable: boolean;
  hasBookings: boolean;
  isFullyBooked: boolean;
  isTalentHoliday?: boolean;
}

// DATA SAMPLE: Existing Bookings (one booking per day policy)
// When a user books a day, the ENTIRE day becomes unavailable to others
interface Booking {
  id: string;
  userId: string;
  userName: string;
  date: string; // ISO date format: "2026-04-15"
  time: string; // Selected time slot: "02:00 PM"
  eventType: string; // "Casual Event" or "Formal Event"
  meetingAddress: string;
  bookedAt: string; // Timestamp when booking was made
  status: "confirmed" | "cancelled";
}

// DATA SAMPLE: Talent's Holiday/Unavailable Dates
// These are dates set by the talent as unavailable
interface TalentHoliday {
  date: string; // ISO date format: "2026-04-01"
  reason?: string; // Optional reason: "Personal Day", "Vacation", etc.
}

// SAMPLE DATA: Existing bookings from other users
const SAMPLE_BOOKINGS: Booking[] = [
  {
    id: "booking-001",
    userId: "user-123",
    userName: "John Smith",
    date: "2026-04-03",
    time: "02:00 PM",
    eventType: "Casual Event",
    meetingAddress: "Starbucks, 123 Main St, Bangkok",
    bookedAt: "2026-04-01T10:30:00Z",
    status: "confirmed"
  },
  {
    id: "booking-002",
    userId: "user-456",
    userName: "Sarah Johnson",
    date: "2026-04-07",
    time: "07:00 PM",
    eventType: "Formal Event",
    meetingAddress: "The Ritz Restaurant, 456 Sukhumvit Rd, Bangkok",
    bookedAt: "2026-04-02T14:20:00Z",
    status: "confirmed"
  },
  {
    id: "booking-003",
    userId: "user-789",
    userName: "Mike Chen",
    date: "2026-04-11",
    time: "11:00 AM",
    eventType: "Casual Event",
    meetingAddress: "Central Park, Near Fountain, Bangkok",
    bookedAt: "2026-04-05T09:15:00Z",
    status: "confirmed"
  },
  {
    id: "booking-004",
    userId: "user-321",
    userName: "Emily Davis",
    date: "2026-04-15",
    time: "05:00 PM",
    eventType: "Formal Event",
    meetingAddress: "Grand Hotel Ballroom, 789 Wireless Rd, Bangkok",
    bookedAt: "2026-04-08T16:45:00Z",
    status: "confirmed"
  },
  {
    id: "booking-005",
    userId: "user-654",
    userName: "David Kim",
    date: "2026-04-19",
    time: "01:00 PM",
    eventType: "Casual Event",
    meetingAddress: "Cafe Latte, Siam Square, Bangkok",
    bookedAt: "2026-04-12T11:30:00Z",
    status: "confirmed"
  },
  {
    id: "booking-006",
    userId: "user-987",
    userName: "Lisa Wong",
    date: "2026-04-23",
    time: "09:00 PM",
    eventType: "Formal Event",
    meetingAddress: "Sky Bar, 999 Silom Rd, Bangkok",
    bookedAt: "2026-04-15T13:20:00Z",
    status: "confirmed"
  },
  {
    id: "booking-007",
    userId: "user-147",
    userName: "Tom Brown",
    date: "2026-04-27",
    time: "03:00 PM",
    eventType: "Casual Event",
    meetingAddress: "Beach Club, Pattaya",
    bookedAt: "2026-04-18T15:10:00Z",
    status: "confirmed"
  }
];

// SAMPLE DATA: Talent's holiday/unavailable dates
const SAMPLE_TALENT_HOLIDAYS: TalentHoliday[] = [
  {
    date: "2026-04-01",
    reason: "Personal Day"
  },
  {
    date: "2026-04-05",
    reason: "Family Event"
  },
  {
    date: "2026-04-09",
    reason: "Vacation"
  },
  {
    date: "2026-04-13",
    reason: "Health Appointment"
  },
  {
    date: "2026-04-17",
    reason: "Personal Day"
  },
  {
    date: "2026-04-21",
    reason: "Out of Town"
  },
  {
    date: "2026-04-25",
    reason: "Vacation"
  },
  {
    date: "2026-04-29",
    reason: "Personal Day"
  }
];

// Helper: Check if a date is booked by another user
const isDateBooked = (dateString: string): boolean => {
  return SAMPLE_BOOKINGS.some(
    booking => booking.date === dateString && booking.status === "confirmed"
  );
};

// Helper: Check if a date is a talent holiday
const isDateTalentHoliday = (dateString: string): boolean => {
  return SAMPLE_TALENT_HOLIDAYS.some(holiday => holiday.date === dateString);
};

// Helper: Get booking details for a date
const getBookingForDate = (dateString: string): Booking | undefined => {
  return SAMPLE_BOOKINGS.find(
    booking => booking.date === dateString && booking.status === "confirmed"
  );
};

// Generate time slots for a given date
const generateTimeSlots = (date: Date, currentDate: Date): TimeSlot[] => {
  const slots: TimeSlot[] = [];
  
  // Generate slots from 9 AM to 5 PM (every hour) - 5 PM is the maximum END time
  const hours = [9, 10, 11, 12, 13, 14, 15, 16, 17];
  
  hours.forEach((hour) => {
    const slotDate = new Date(date);
    slotDate.setHours(hour, 0, 0, 0);
    
    // Check if slot is at least 1 hour from now
    const oneHourFromNow = new Date(currentDate.getTime() + 60 * 60 * 1000);
    const isPast = slotDate < oneHourFromNow;
    
    // Determine if slot is booked
    // Since only ONE booking per day is allowed, if the day is booked, ALL slots are marked as booked
    let isBooked = false;
    if (!isPast) {
      if (isDateBooked(date.toISOString().split("T")[0])) {
        isBooked = true; // Entire day is unavailable
      }
    }
    
    // Format time
    const period = hour >= 12 ? "PM" : "AM";
    const displayHour = hour > 12 ? hour - 12 : hour === 0 ? 12 : hour;
    const time = `${displayHour.toString().padStart(2, "0")}:00 ${period}`;
    
    slots.push({
      time,
      hour,
      minute: 0,
      isBooked,
      isPast,
    });
  });
  
  return slots;
};

// Generate calendar days for a given month
const generateCalendarDays = (year: number, month: number): CalendarDay[] => {
  const currentDate = new Date();
  currentDate.setHours(0, 0, 0, 0);
  
  const firstDay = new Date(year, month, 1);
  const lastDay = new Date(year, month + 1, 0);
  const daysInMonth = lastDay.getDate();
  const startingDayOfWeek = firstDay.getDay();
  
  const days: CalendarDay[] = [];
  
  // Add previous month's days
  const prevMonthLastDay = new Date(year, month, 0).getDate();
  for (let i = startingDayOfWeek - 1; i >= 0; i--) {
    const date = new Date(year, month - 1, prevMonthLastDay - i);
    days.push({
      date,
      dateString: date.toISOString().split("T")[0],
      day: prevMonthLastDay - i,
      isCurrentMonth: false,
      isToday: false,
      isPast: true,
      isSelectable: false,
      hasBookings: false,
      isFullyBooked: false,
    });
  }
  
  // Add current month's days
  for (let day = 1; day <= daysInMonth; day++) {
    const date = new Date(year, month, day);
    date.setHours(0, 0, 0, 0);
    
    const dateString = date.toISOString().split("T")[0];
    const isToday = date.getTime() === currentDate.getTime();
    const isPast = date < currentDate;
    
    // Check if this is a talent holiday
    const dayOfMonth = day;
    const isTalentHoliday = isDateTalentHoliday(dateString);
    
    // Only allow booking for dates that are today or in the future AND not talent holiday
    const isSelectable = !isPast && !isTalentHoliday;
    
    // Check bookings for this date
    const slotsForDate = generateTimeSlots(date, currentDate);
    const bookedSlots = slotsForDate.filter(slot => slot.isBooked && !slot.isPast);
    const availableSlots = slotsForDate.filter(slot => !slot.isBooked && !slot.isPast);
    
    const hasBookings = bookedSlots.length > 0;
    const isFullyBooked = availableSlots.length === 0 && !isPast && !isTalentHoliday;
    
    days.push({
      date,
      dateString,
      day,
      isCurrentMonth: true,
      isToday,
      isPast,
      isSelectable,
      hasBookings,
      isFullyBooked,
      isTalentHoliday,
    });
  }
  
  // Add next month's days to fill the grid
  const remainingDays = 42 - days.length; // 6 weeks * 7 days
  for (let day = 1; day <= remainingDays; day++) {
    const date = new Date(year, month + 1, day);
    days.push({
      date,
      dateString: date.toISOString().split("T")[0],
      day,
      isCurrentMonth: false,
      isToday: false,
      isPast: false,
      isSelectable: false,
      hasBookings: false,
      isFullyBooked: false,
    });
  }
  
  return days;
};

export function MeetOfflineModal({
  isOpen,
  onClose,
  hostName,
  hostLocation,
}: MeetOfflineModalProps) {
  const currentDate = new Date();
  const [currentMonth, setCurrentMonth] = useState(currentDate.getMonth());
  const [currentYear, setCurrentYear] = useState(currentDate.getFullYear());
  const [selectedDate, setSelectedDate] = useState<string | null>(null);
  const [selectedTime, setSelectedTime] = useState<string>("");
  const [selectedDuration, setSelectedDuration] = useState<number>(0);
  const [eventType, setEventType] = useState<string>("Casual Event");
  const [meetingAddress, setMeetingAddress] = useState<string>("");
  const [showConfirmation, setShowConfirmation] = useState(false);
  const [showFullyBookedModal, setShowFullyBookedModal] = useState(false);

  const calendarDays = generateCalendarDays(currentYear, currentMonth);
  const monthName = new Date(currentYear, currentMonth, 1).toLocaleDateString("en-US", { 
    month: "long", 
    year: "numeric" 
  });

  const handlePreviousMonth = () => {
    if (currentMonth === 0) {
      setCurrentMonth(11);
      setCurrentYear(currentYear - 1);
    } else {
      setCurrentMonth(currentMonth - 1);
    }
  };

  const handleNextMonth = () => {
    if (currentMonth === 11) {
      setCurrentMonth(0);
      setCurrentYear(currentYear + 1);
    } else {
      setCurrentMonth(currentMonth + 1);
    }
  };

  const handleDateSelect = (day: CalendarDay) => {
    // Don't allow selection of talent holidays
    if (day.isTalentHoliday) return;
    
    // Don't allow selection of past dates
    if (!day.isCurrentMonth || day.isPast) return;
    
    // Check if fully booked - show modal instead of selecting
    if (day.isFullyBooked) {
      setShowFullyBookedModal(true);
      return;
    }
    
    // Date is available - select it
    setSelectedDate(day.dateString);
    setSelectedTime(""); // Reset time selection when date changes
  };

  // Get time slots for selected date
  const getTimeSlotsForDate = (dateString: string): TimeSlot[] => {
    const date = new Date(dateString);
    date.setHours(0, 0, 0, 0);
    return generateTimeSlots(date, new Date());
  };

  const selectedTimeSlots = selectedDate ? getTimeSlotsForDate(selectedDate) : [];
  const availableTimeSlots = selectedTimeSlots.filter(slot => !slot.isBooked && !slot.isPast);
  
  // Get selected day data
  const selectedDayData = selectedDate 
    ? calendarDays.find(day => day.dateString === selectedDate)
    : null;

  // Calculate available duration options based on selected start time
  // DURATION RULES:
  // 1. Minimum duration is always 3 hours
  // 2. If start time <= 1:00 PM (13:00), can choose 3 to 8 hours
  // 3. If start time > 1:00 PM (13:00), can choose 3 to 4 hours ONLY
  // 4. Start time max is 5:00 PM, but end time is NOT limited
  const getAvailableDurations = (startTimeString: string): number[] => {
    if (!startTimeString) return [];
    
    // Find the slot with matching time
    const selectedSlot = availableTimeSlots.find(slot => slot.time === startTimeString);
    if (!selectedSlot) return [];
    
    const startHour = selectedSlot.hour;
    const minDuration = 3; // Minimum 3 hours required
    
    // Calculate time-based max duration
    // <= 1:00 PM (13:00) = can book 3-8 hours
    // > 1:00 PM (13:00) = can book 3-4 hours ONLY
    const maxDuration = startHour <= 13 ? 8 : 4;
    
    // Generate duration options from 3 to maxDuration
    const durations: number[] = [];
    for (let i = minDuration; i <= maxDuration; i++) {
      durations.push(i);
    }
    
    return durations;
  };
  
  const availableDurations = getAvailableDurations(selectedTime);
  
  // Calculate end time based on start time and duration
  const calculateEndTime = (startTimeString: string, durationHours: number): string => {
    if (!startTimeString || !durationHours) return "";
    
    const selectedSlot = availableTimeSlots.find(slot => slot.time === startTimeString);
    if (!selectedSlot) return "";
    
    const endHour = selectedSlot.hour + durationHours;
    const period = endHour >= 12 ? "PM" : "AM";
    const displayHour = endHour > 12 ? endHour - 12 : endHour === 0 ? 12 : endHour;
    
    return `${displayHour.toString().padStart(2, "0")}:00 ${period}`;
  };

  const bookingFee = 500; // 500 coins booking fee

  const handleConfirmBooking = () => {
    if (!selectedTime || !selectedDuration || !meetingAddress.trim()) return;
    setShowConfirmation(true);
  };

  const handleFinalizeBooking = () => {
    // Here would be the actual booking logic
    alert(`Booking confirmed with ${hostName} on ${selectedDate} at ${selectedTime}\nEvent: ${eventType}\nLocation: ${meetingAddress}`);
    onClose();
    setSelectedDate(null);
    setSelectedTime("");
    setEventType("Casual Event");
    setMeetingAddress("");
    setShowConfirmation(false);
  };

  const handleCancel = () => {
    setShowConfirmation(false);
  };

  const closeFullyBookedModal = () => {
    setShowFullyBookedModal(false);
  };

  if (!isOpen) return null;

  return (
    <>
      <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
        <div className="bg-white rounded-2xl w-full max-w-md shadow-2xl max-h-[90vh] overflow-y-auto">
          {!showConfirmation ? (
            <>
              {/* Header */}
              <div className="sticky top-0 bg-white border-b border-gray-200 px-4 sm:px-6 py-4 flex items-center justify-between rounded-t-2xl">
                <div>
                  <h2 className="text-lg sm:text-xl font-semibold">Meet Offline</h2>
                  <p className="text-xs sm:text-sm text-gray-600">Book a date with {hostName}</p>
                </div>
                <button
                  onClick={onClose}
                  className="w-8 h-8 rounded-full hover:bg-gray-100 flex items-center justify-center transition-colors"
                >
                  <X className="w-5 h-5 text-gray-600" />
                </button>
              </div>

              {/* Event Type Selection */}
              <div className="px-4 sm:px-6 pt-4">
                <h3 className="font-semibold mb-3 flex items-center gap-2 text-sm sm:text-base">
                  <Sparkles className="w-5 h-5 text-gray-600" />
                  Event Type
                </h3>
                <div className="relative">
                  <select
                    value={eventType}
                    onChange={(e) => setEventType(e.target.value)}
                    className="w-full px-4 py-3.5 rounded-xl border-2 border-gray-300 focus:border-orange-500 focus:ring-2 focus:ring-orange-200 transition-all appearance-none bg-white text-gray-900 font-medium cursor-pointer hover:border-orange-400"
                  >
                    <option value="Casual Event">Casual Event</option>
                    <option value="Formal Event">Formal Event</option>
                  </select>
                  <div className="absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none">
                    <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                    </svg>
                  </div>
                </div>
              </div>

              {/* Meeting Address Input */}
              <div className="px-4 sm:px-6 pt-4">
                <h3 className="font-semibold mb-3 flex items-center gap-2 text-sm sm:text-base">
                  <MapPin className="w-5 h-5 text-gray-600" />
                  Meeting Location
                </h3>
                <input
                  type="text"
                  value={meetingAddress}
                  onChange={(e) => setMeetingAddress(e.target.value)}
                  placeholder="Enter meeting address..."
                  className="w-full px-4 py-3.5 rounded-xl border-2 border-gray-300 focus:border-orange-500 focus:ring-2 focus:ring-orange-200 transition-all bg-white text-gray-900 placeholder:text-gray-400"
                />
                <p className="text-xs text-gray-500 mt-2">Please provide the complete address for the meeting</p>
              </div>

              {/* Date Selection */}
              <div className="px-4 sm:px-6 py-4">
                <h3 className="font-semibold mb-3 flex items-center gap-2 text-sm sm:text-base">
                  <Calendar className="w-5 h-5 text-gray-600" />
                  Select Date
                </h3>
                <div className="flex items-center justify-between mb-3">
                  <button
                    onClick={handlePreviousMonth}
                    className="w-8 h-8 rounded-full hover:bg-gray-100 flex items-center justify-center transition-colors"
                  >
                    <ChevronLeft className="w-5 h-5 text-gray-600" />
                  </button>
                  <p className="text-sm text-gray-600 font-medium">{monthName}</p>
                  <button
                    onClick={handleNextMonth}
                    className="w-8 h-8 rounded-full hover:bg-gray-100 flex items-center justify-center transition-colors"
                  >
                    <ChevronRight className="w-5 h-5 text-gray-600" />
                  </button>
                </div>
                
                {/* Calendar Legend */}
                <div className="flex items-center justify-center gap-3 sm:gap-4 mb-3 text-xs">
                  <div className="flex items-center gap-1">
                    <div className="w-3 h-3 rounded-full bg-green-500"></div>
                    <span className="text-gray-600">Available</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <div className="w-3 h-3 rounded-full bg-red-500"></div>
                    <span className="text-gray-600">Booked</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <div className="w-3 h-3 rounded-full bg-gray-400"></div>
                    <span className="text-gray-600">Holiday</span>
                  </div>
                </div>

                <div className="grid grid-cols-7 gap-1">
                  {["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"].map((day) => (
                    <div key={day} className="text-xs text-gray-500 font-semibold text-center py-2">
                      {day}
                    </div>
                  ))}
                  {calendarDays.map((day, index) => {
                    return (
                      <button
                        key={`${day.dateString}-${index}`}
                        onClick={() => handleDateSelect(day)}
                        disabled={!day.isSelectable && !day.isFullyBooked}
                        className={`aspect-square p-1.5 sm:p-2 rounded-lg border-2 transition-all text-xs sm:text-sm font-medium relative ${
                          !day.isCurrentMonth
                            ? "text-gray-300 border-transparent cursor-default"
                            : selectedDate === day.dateString
                            ? "border-orange-500 bg-orange-100 text-orange-700 ring-2 ring-orange-300"
                            : day.isTalentHoliday && day.isCurrentMonth
                            ? "text-gray-400 border-gray-300 bg-gray-100 cursor-not-allowed"
                            : day.isFullyBooked
                            ? "border-red-400 bg-red-100 text-red-700 cursor-not-allowed"
                            : !day.isSelectable
                            ? "text-gray-300 border-gray-200 bg-gray-50 cursor-not-allowed"
                            : day.isToday
                            ? "border-green-400 bg-green-50 text-green-700 hover:border-green-500 cursor-pointer"
                            : "border-green-300 bg-green-50 text-green-700 hover:border-green-400 cursor-pointer"
                        }`}
                      >
                        {day.day}
                        {day.isCurrentMonth && (
                          <>
                            {day.isTalentHoliday && (
                              <div className="absolute bottom-0.5 left-1/2 -translate-x-1/2 w-1 h-1 rounded-full bg-gray-400"></div>
                            )}
                            {!day.isTalentHoliday && day.isFullyBooked && (
                              <div className="absolute bottom-0.5 left-1/2 -translate-x-1/2 w-1 h-1 rounded-full bg-red-500"></div>
                            )}
                            {!day.isTalentHoliday && !day.isFullyBooked && day.isSelectable && (
                              <div className="absolute bottom-0.5 left-1/2 -translate-x-1/2 w-1 h-1 rounded-full bg-green-500"></div>
                            )}
                          </>
                        )}
                      </button>
                    );
                  })}
                </div>
              </div>

              {/* Time Slot Selection Dropdown */}
              {selectedDate && (
                <div className="px-4 sm:px-6 pb-4">
                  <h3 className="font-semibold mb-3 flex items-center gap-2 text-sm sm:text-base">
                    <Clock className="w-5 h-5 text-gray-600" />
                    Select Time
                  </h3>
                  
                  {availableTimeSlots.length > 0 ? (
                    <>
                      {/* Booking Policy Info */}
                      <div className="bg-amber-50 border-2 border-amber-300 rounded-xl p-3 mb-3">
                        <div className="flex items-start gap-2">
                          <AlertCircle className="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" />
                          <div>
                            <p className="text-xs sm:text-sm text-amber-900 font-semibold mb-1">
                              One Booking Per Day Policy
                            </p>
                            <p className="text-xs text-amber-700">
                              Only one user can book this talent per day. Choose your preferred meeting time below. Once you confirm, this entire day will be unavailable to others.
                            </p>
                          </div>
                        </div>
                      </div>
                      
                      <div className="relative">
                        <select
                          value={selectedTime}
                          onChange={(e) => setSelectedTime(e.target.value)}
                          className="w-full px-4 py-3.5 rounded-xl border-2 border-gray-300 focus:border-orange-500 focus:ring-2 focus:ring-orange-200 transition-all appearance-none bg-white text-gray-900 font-medium cursor-pointer hover:border-orange-400"
                        >
                          <option value="">Choose your preferred meeting time</option>
                          {availableTimeSlots.map((slot) => (
                            <option key={slot.time} value={slot.time}>
                              {slot.time}
                            </option>
                          ))}
                        </select>
                        <div className="absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none">
                          <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                          </svg>
                        </div>
                      </div>
                      
                      <p className="text-xs text-gray-500 mt-2">
                        ℹ️ This time is for scheduling purposes. The entire day will be reserved for you.
                      </p>
                    </>
                  ) : (
                    <div className="bg-red-100 border-2 border-red-300 rounded-xl p-4 text-center">
                      <p className="text-sm font-semibold text-red-700 mb-1">This date is already booked</p>
                      <p className="text-xs text-red-600">Another user has reserved this day. Please choose a different date.</p>
                    </div>
                  )}
                </div>
              )}

              {/* Duration Selection Dropdown */}
              {selectedTime && (
                <div className="px-4 sm:px-6 pb-4">
                  <h3 className="font-semibold mb-3 flex items-center gap-2 text-sm sm:text-base">
                    <Clock className="w-5 h-5 text-gray-600" />
                    Select Duration
                  </h3>
                  
                  {availableDurations.length > 0 ? (
                    <>
                      <div className="relative">
                        <select
                          value={selectedDuration}
                          onChange={(e) => setSelectedDuration(Number(e.target.value))}
                          className="w-full px-4 py-3.5 rounded-xl border-2 border-gray-300 focus:border-orange-500 focus:ring-2 focus:ring-orange-200 transition-all appearance-none bg-white text-gray-900 font-medium cursor-pointer hover:border-orange-400"
                        >
                          <option value="">Choose duration</option>
                          {availableDurations.map((duration) => (
                            <option key={duration} value={duration}>
                              {duration} hour(s)
                            </option>
                          ))}
                        </select>
                        <div className="absolute right-4 top-1/2 -translate-y-1/2 pointer-events-none">
                          <svg className="w-5 h-5 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
                          </svg>
                        </div>
                      </div>
                      
                      <p className="text-xs text-gray-500 mt-2">
                        End Time: {calculateEndTime(selectedTime, selectedDuration)}
                      </p>
                    </>
                  ) : (
                    <div className="bg-red-100 border-2 border-red-300 rounded-xl p-4 text-center">
                      <p className="text-sm font-semibold text-red-700 mb-1">No available durations</p>
                      <p className="text-xs text-red-600">Please select a different time.</p>
                    </div>
                  )}
                </div>
              )}

              {/* Confirm Button */}
              <div className="sticky bottom-0 bg-white border-t border-gray-200 px-4 sm:px-6 py-4 rounded-b-2xl">
                <button
                  onClick={handleConfirmBooking}
                  disabled={!selectedDate || !selectedTime || !selectedDuration || selectedDayData?.isFullyBooked || !meetingAddress.trim()}
                  className={`w-full py-3.5 rounded-xl font-semibold transition-all text-sm sm:text-base ${
                    selectedDate && selectedTime && selectedDuration && !selectedDayData?.isFullyBooked && meetingAddress.trim()
                      ? "bg-gradient-to-r from-orange-600 to-orange-500 text-white hover:from-orange-700 hover:to-orange-600 shadow-lg"
                      : "bg-gray-200 text-gray-400 cursor-not-allowed"
                  }`}
                >
                  Continue to Booking
                </button>
              </div>
            </>
          ) : (
            <>
              {/* Confirmation Screen */}
              <div className="px-4 sm:px-6 py-4 border-b border-gray-200 flex items-center justify-between">
                <h2 className="text-lg sm:text-xl font-semibold">Confirm Booking</h2>
                <button
                  onClick={handleCancel}
                  className="w-8 h-8 rounded-full hover:bg-gray-100 flex items-center justify-center transition-colors"
                >
                  <X className="w-5 h-5 text-gray-600" />
                </button>
              </div>

              <div className="px-4 sm:px-6 py-6">
                {/* Success Icon */}
                <div className="flex justify-center mb-6">
                  <div className="w-16 h-16 bg-green-100 rounded-full flex items-center justify-center">
                    <CheckCircle2 className="w-8 h-8 text-green-600" />
                  </div>
                </div>

                {/* Booking Details */}
                <div className="bg-gradient-to-r from-gray-50 to-gray-100 rounded-xl p-4 mb-6 space-y-3">
                  <div className="flex items-center justify-between">
                    <span className="text-xs sm:text-sm text-gray-600">Host</span>
                    <span className="font-semibold text-sm sm:text-base">{hostName}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-xs sm:text-sm text-gray-600">Event Type</span>
                    <span className="font-semibold text-sm sm:text-base">{eventType}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-xs sm:text-sm text-gray-600">Date</span>
                    <span className="font-semibold text-sm sm:text-base">{selectedDate}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-xs sm:text-sm text-gray-600">Time</span>
                    <span className="font-semibold text-sm sm:text-base">{selectedTime}</span>
                  </div>
                  <div className="flex items-center justify-between">
                    <span className="text-xs sm:text-sm text-gray-600">Duration</span>
                    <span className="font-semibold text-sm sm:text-base">{selectedDuration} hour(s)</span>
                  </div>
                  <div className="flex items-start justify-between gap-3">
                    <span className="text-xs sm:text-sm text-gray-600 flex-shrink-0">Location</span>
                    <span className="font-semibold text-right text-sm sm:text-base break-words">{meetingAddress}</span>
                  </div>
                </div>

                {/* Fee Display */}
                <div className="bg-gradient-to-r from-amber-50 to-orange-50 rounded-xl p-4 mb-6 border-2 border-orange-200">
                  <div className="flex items-center justify-between mb-2">
                    <span className="text-gray-700 font-medium text-sm sm:text-base">Booking Fee</span>
                    <span className="text-xl sm:text-2xl font-bold text-amber-700">🪙 {bookingFee}</span>
                  </div>
                  <p className="text-xs text-gray-600">
                    This fee will be deducted from your coin balance to confirm the booking.
                  </p>
                </div>

                {/* Action Buttons */}
                <div className="space-y-3">
                  <button
                    onClick={handleFinalizeBooking}
                    className="w-full bg-gradient-to-r from-orange-600 to-orange-500 text-white py-3.5 rounded-xl font-semibold hover:from-orange-700 hover:to-orange-600 transition-all shadow-lg text-sm sm:text-base"
                  >
                    Confirm & Pay 🪙 {bookingFee}
                  </button>
                  <button
                    onClick={handleCancel}
                    className="w-full bg-gray-100 text-gray-700 py-3 rounded-xl font-medium hover:bg-gray-200 transition-all text-sm sm:text-base"
                  >
                    Cancel
                  </button>
                </div>
              </div>
            </>
          )}
        </div>
      </div>

      {/* Fully Booked Modal */}
      {showFullyBookedModal && (
        <div className="fixed inset-0 bg-black/60 flex items-center justify-center z-[60] p-4">
          <div className="bg-white rounded-2xl w-full max-w-sm shadow-2xl animate-scale-in">
            <div className="p-6">
              {/* Alert Icon */}
              <div className="flex justify-center mb-4">
                <div className="w-16 h-16 bg-red-100 rounded-full flex items-center justify-center">
                  <AlertCircle className="w-8 h-8 text-red-600" />
                </div>
              </div>

              {/* Message */}
              <h3 className="text-lg sm:text-xl font-semibold text-center mb-2 text-gray-900">
                Talent Holiday / Cannot Book
              </h3>
              <p className="text-sm sm:text-base text-gray-600 text-center mb-6">
                This talent is not available on this date. Please choose another date.
              </p>

              {/* Close Button */}
              <button
                onClick={closeFullyBookedModal}
                className="w-full bg-gradient-to-r from-red-600 to-red-500 text-white py-3 rounded-xl font-semibold hover:from-red-700 hover:to-red-600 transition-all shadow-lg"
              >
                Choose Another Date
              </button>
            </div>
          </div>
        </div>
      )}
    </>
  );
}