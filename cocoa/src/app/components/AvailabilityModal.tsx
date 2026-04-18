import { useState } from "react";
import { X, Calendar, Check, AlertCircle } from "lucide-react";

interface AvailabilityModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (unavailableDates: Date[]) => void;
  currentUnavailableDates: Date[];
}

export function AvailabilityModal({ isOpen, onClose, onSave, currentUnavailableDates }: AvailabilityModalProps) {
  const [selectedMonth, setSelectedMonth] = useState(new Date());
  const [unavailableDates, setUnavailableDates] = useState<Date[]>(currentUnavailableDates);

  if (!isOpen) return null;

  const monthNames = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  const getDaysInMonth = (date: Date) => {
    const year = date.getFullYear();
    const month = date.getMonth();
    const firstDay = new Date(year, month, 1);
    const lastDay = new Date(year, month + 1, 0);
    const daysInMonth = lastDay.getDate();
    const startingDayOfWeek = firstDay.getDay();

    return { daysInMonth, startingDayOfWeek };
  };

  const { daysInMonth, startingDayOfWeek } = getDaysInMonth(selectedMonth);

  const isDateUnavailable = (day: number) => {
    const checkDate = new Date(selectedMonth.getFullYear(), selectedMonth.getMonth(), day);
    return unavailableDates.some(unavailableDate => 
      unavailableDate.getFullYear() === checkDate.getFullYear() &&
      unavailableDate.getMonth() === checkDate.getMonth() &&
      unavailableDate.getDate() === checkDate.getDate()
    );
  };

  const isPastDate = (day: number) => {
    const checkDate = new Date(selectedMonth.getFullYear(), selectedMonth.getMonth(), day);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    checkDate.setHours(0, 0, 0, 0);
    return checkDate < today;
  };

  const toggleDate = (day: number) => {
    if (isPastDate(day)) return; // Can't modify past dates

    const clickedDate = new Date(selectedMonth.getFullYear(), selectedMonth.getMonth(), day);
    
    const isCurrentlyUnavailable = isDateUnavailable(day);
    
    if (isCurrentlyUnavailable) {
      // Remove from unavailable dates (mark as available)
      setUnavailableDates(unavailableDates.filter(date => 
        !(date.getFullYear() === clickedDate.getFullYear() &&
          date.getMonth() === clickedDate.getMonth() &&
          date.getDate() === clickedDate.getDate())
      ));
    } else {
      // Add to unavailable dates (mark as holiday/offline)
      setUnavailableDates([...unavailableDates, clickedDate]);
    }
  };

  const previousMonth = () => {
    setSelectedMonth(new Date(selectedMonth.getFullYear(), selectedMonth.getMonth() - 1));
  };

  const nextMonth = () => {
    setSelectedMonth(new Date(selectedMonth.getFullYear(), selectedMonth.getMonth() + 1));
  };

  const handleSave = () => {
    onSave(unavailableDates);
    onClose();
  };

  const renderCalendar = () => {
    const days = [];
    
    // Empty cells for days before the first day of the month
    for (let i = 0; i < startingDayOfWeek; i++) {
      days.push(
        <div key={`empty-${i}`} className="aspect-square"></div>
      );
    }
    
    // Actual days of the month
    for (let day = 1; day <= daysInMonth; day++) {
      const isUnavailable = isDateUnavailable(day);
      const isPast = isPastDate(day);
      
      days.push(
        <button
          key={day}
          onClick={() => toggleDate(day)}
          disabled={isPast}
          className={`aspect-square rounded-lg flex items-center justify-center text-sm font-medium transition-all relative ${
            isPast
              ? "text-gray-300 cursor-not-allowed"
              : isUnavailable
              ? "bg-red-100 text-red-700 border-2 border-red-400 hover:bg-red-200"
              : "bg-green-100 text-green-700 border-2 border-green-400 hover:bg-green-200"
          }`}
        >
          {day}
          {!isPast && (
            <div className="absolute top-0.5 right-0.5">
              {isUnavailable ? (
                <X className="w-3 h-3 text-red-600" />
              ) : (
                <Check className="w-3 h-3 text-green-600" />
              )}
            </div>
          )}
        </button>
      );
    }
    
    return days;
  };

  return (
    <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center p-4">
      <div className="bg-white rounded-2xl shadow-2xl max-w-lg w-full max-h-[90vh] overflow-y-auto">
        {/* Header */}
        <div className="bg-gradient-to-r from-amber-600 to-orange-600 px-6 py-4 flex items-center justify-between sticky top-0 z-10 rounded-t-2xl">
          <div className="flex items-center gap-2">
            <Calendar className="w-6 h-6 text-white" />
            <h2 className="text-xl font-bold text-white">Set Availability</h2>
          </div>
          <button
            onClick={onClose}
            className="w-8 h-8 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center text-white hover:bg-white/30 transition-colors"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Content */}
        <div className="p-6 space-y-6">
          {/* Info Box */}
          <div className="bg-blue-50 border border-blue-200 rounded-xl p-4">
            <div className="flex items-start gap-3">
              <AlertCircle className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
              <div>
                <p className="text-sm font-medium text-blue-900 mb-1">How it works</p>
                <ul className="text-xs text-blue-800 space-y-1">
                  <li>• <strong className="text-green-700">Green dates</strong> = Available for bookings</li>
                  <li>• <strong className="text-red-700">Red dates</strong> = Holiday/Offline (users cannot book)</li>
                  <li>• Click any date to toggle availability</li>
                </ul>
              </div>
            </div>
          </div>

          {/* Month Navigation */}
          <div className="flex items-center justify-between">
            <button
              onClick={previousMonth}
              className="px-4 py-2 bg-gray-100 hover:bg-gray-200 rounded-lg font-medium transition-colors"
            >
              Previous
            </button>
            <h3 className="text-lg font-bold text-gray-800">
              {monthNames[selectedMonth.getMonth()]} {selectedMonth.getFullYear()}
            </h3>
            <button
              onClick={nextMonth}
              className="px-4 py-2 bg-gray-100 hover:bg-gray-200 rounded-lg font-medium transition-colors"
            >
              Next
            </button>
          </div>

          {/* Calendar */}
          <div>
            {/* Day headers */}
            <div className="grid grid-cols-7 gap-2 mb-2">
              {["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"].map(day => (
                <div key={day} className="text-center text-sm font-semibold text-gray-600">
                  {day}
                </div>
              ))}
            </div>

            {/* Calendar grid */}
            <div className="grid grid-cols-7 gap-2">
              {renderCalendar()}
            </div>
          </div>

          {/* Legend */}
          <div className="flex items-center gap-4 justify-center pt-4 border-t border-gray-200">
            <div className="flex items-center gap-2">
              <div className="w-6 h-6 bg-green-100 border-2 border-green-400 rounded flex items-center justify-center">
                <Check className="w-3 h-3 text-green-600" />
              </div>
              <span className="text-sm text-gray-700">Available</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-6 h-6 bg-red-100 border-2 border-red-400 rounded flex items-center justify-center">
                <X className="w-3 h-3 text-red-600" />
              </div>
              <span className="text-sm text-gray-700">Unavailable</span>
            </div>
          </div>

          {/* Action Buttons */}
          <div className="flex gap-3 pt-4">
            <button
              onClick={onClose}
              className="flex-1 px-4 py-3 bg-gray-100 text-gray-700 rounded-xl font-semibold hover:bg-gray-200 transition-colors"
            >
              Cancel
            </button>
            <button
              onClick={handleSave}
              className="flex-1 px-4 py-3 bg-gradient-to-r from-amber-600 to-orange-600 text-white rounded-xl font-semibold hover:from-amber-700 hover:to-orange-700 transition-all shadow-lg"
            >
              Save Availability
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
