import { TrendingUp, TrendingDown, DollarSign, Clock, MessageCircle, Users } from "lucide-react";
import { TalentBottomNav } from "../components/TalentBottomNav";

export function TalentAnalytics() {
  const weeklyData = [
    { day: "Mon", earnings: 280, hours: 4.5 },
    { day: "Tue", earnings: 420, hours: 6.2 },
    { day: "Wed", earnings: 350, hours: 5.0 },
    { day: "Thu", earnings: 480, hours: 7.1 },
    { day: "Fri", earnings: 390, hours: 5.8 },
    { day: "Sat", earnings: 520, hours: 8.0 },
    { day: "Sun", earnings: 310, hours: 4.6 },
  ];

  const maxEarnings = Math.max(...weeklyData.map((d) => d.earnings));

  return (
    <div className="min-h-screen bg-gradient-to-br from-amber-50 via-orange-50 to-amber-100">
      <div className="max-w-md mx-auto bg-white min-h-screen shadow-2xl pb-20">
        {/* Header */}
        <div className="bg-gradient-to-br from-amber-700 to-amber-600 px-6 pt-8 pb-6 rounded-b-3xl shadow-lg">
          <h1 className="text-2xl font-semibold text-white mb-2">Analytics</h1>
          <p className="text-amber-100 text-sm">Track your performance</p>
        </div>

        {/* Summary Cards */}
        <div className="px-6 -mt-8 relative z-10">
          <div className="grid grid-cols-2 gap-3 mb-6">
            <div className="bg-white rounded-2xl shadow-lg p-4">
              <div className="flex items-center gap-2 mb-2">
                <div className="w-8 h-8 rounded-full bg-green-500 flex items-center justify-center">
                  <DollarSign className="w-4 h-4 text-white" />
                </div>
              </div>
              <p className="text-sm text-gray-600">This Month</p>
              <p className="text-xl font-bold text-gray-800">🪙 8,450</p>
              <div className="flex items-center gap-1 mt-1">
                <TrendingUp className="w-3 h-3 text-green-500" />
                <span className="text-xs text-green-600">+15%</span>
              </div>
            </div>

            <div className="bg-white rounded-2xl shadow-lg p-4">
              <div className="flex items-center gap-2 mb-2">
                <div className="w-8 h-8 rounded-full bg-blue-500 flex items-center justify-center">
                  <Clock className="w-4 h-4 text-white" />
                </div>
              </div>
              <p className="text-sm text-gray-600">Total Hours</p>
              <p className="text-xl font-bold text-gray-800">142.5h</p>
              <div className="flex items-center gap-1 mt-1">
                <TrendingUp className="w-3 h-3 text-green-500" />
                <span className="text-xs text-green-600">+8%</span>
              </div>
            </div>

            <div className="bg-white rounded-2xl shadow-lg p-4">
              <div className="flex items-center gap-2 mb-2">
                <div className="w-8 h-8 rounded-full bg-purple-500 flex items-center justify-center">
                  <MessageCircle className="w-4 h-4 text-white" />
                </div>
              </div>
              <p className="text-sm text-gray-600">Total Chats</p>
              <p className="text-xl font-bold text-gray-800">156</p>
              <div className="flex items-center gap-1 mt-1">
                <TrendingDown className="w-3 h-3 text-red-500" />
                <span className="text-xs text-red-600">-3%</span>
              </div>
            </div>

            <div className="bg-white rounded-2xl shadow-lg p-4">
              <div className="flex items-center gap-2 mb-2">
                <div className="w-8 h-8 rounded-full bg-amber-500 flex items-center justify-center">
                  <Users className="w-4 h-4 text-white" />
                </div>
              </div>
              <p className="text-sm text-gray-600">Avg / Hour</p>
              <p className="text-xl font-bold text-gray-800">🪙 59</p>
              <div className="flex items-center gap-1 mt-1">
                <TrendingUp className="w-3 h-3 text-green-500" />
                <span className="text-xs text-green-600">+12%</span>
              </div>
            </div>
          </div>
        </div>

        {/* Weekly Earnings Chart */}
        <div className="px-6 mb-6">
          <div className="bg-white rounded-2xl shadow-sm p-5">
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-lg font-semibold">Weekly Earnings</h2>
              <span className="text-sm text-gray-500">Last 7 days</span>
            </div>

            {/* Bar Chart */}
            <div className="flex items-end justify-between gap-2 h-40 mb-3">
              {weeklyData.map((data, index) => {
                const height = (data.earnings / maxEarnings) * 100;
                return (
                  <div key={index} className="flex-1 flex flex-col items-center gap-2">
                    <div className="relative w-full flex flex-col items-center">
                      <span className="text-xs font-medium text-gray-700 mb-1">
                        {data.earnings}
                      </span>
                      <div
                        className="w-full bg-gradient-to-t from-amber-600 to-amber-400 rounded-t-lg transition-all hover:opacity-80"
                        style={{ height: `${height}%` }}
                      ></div>
                    </div>
                    <span className="text-xs text-gray-500 font-medium">{data.day}</span>
                  </div>
                );
              })}
            </div>

            <div className="pt-3 border-t border-gray-100">
              <div className="flex items-center justify-between text-sm">
                <span className="text-gray-600">Total:</span>
                <span className="font-bold text-gray-800">🪙 2,750 coins</span>
              </div>
            </div>
          </div>
        </div>

        {/* Performance Insights */}
        <div className="px-6 mb-6">
          <h2 className="text-lg font-semibold mb-3">Performance Insights</h2>
          <div className="space-y-3">
            <div className="bg-green-50 rounded-xl p-4 border border-green-200">
              <div className="flex items-start gap-3">
                <div className="w-10 h-10 bg-green-500 rounded-full flex items-center justify-center flex-shrink-0">
                  <TrendingUp className="w-5 h-5 text-white" />
                </div>
                <div>
                  <p className="font-semibold text-green-900 mb-1">Great Performance!</p>
                  <p className="text-sm text-green-700">
                    Your earnings are 15% higher than last month. Keep up the excellent work!
                  </p>
                </div>
              </div>
            </div>

            <div className="bg-blue-50 rounded-xl p-4 border border-blue-200">
              <div className="flex items-start gap-3">
                <div className="w-10 h-10 bg-blue-500 rounded-full flex items-center justify-center flex-shrink-0">
                  <Clock className="w-5 h-5 text-white" />
                </div>
                <div>
                  <p className="font-semibold text-blue-900 mb-1">Peak Time: 7PM - 10PM</p>
                  <p className="text-sm text-blue-700">
                    Most users connect during evening hours. Consider being online during this time.
                  </p>
                </div>
              </div>
            </div>

            <div className="bg-amber-50 rounded-xl p-4 border border-amber-200">
              <div className="flex items-start gap-3">
                <div className="w-10 h-10 bg-amber-500 rounded-full flex items-center justify-center flex-shrink-0">
                  <Users className="w-5 h-5 text-white" />
                </div>
                <div>
                  <p className="font-semibold text-amber-900 mb-1">Response Rate: 92%</p>
                  <p className="text-sm text-amber-700">
                    Excellent! You're responding quickly to user requests.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Goals */}
        <div className="px-6 mb-6">
          <h2 className="text-lg font-semibold mb-3">Monthly Goals</h2>
          <div className="bg-white rounded-2xl shadow-sm p-5">
            <div className="mb-4">
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-medium text-gray-700">Earnings Goal</span>
                <span className="text-sm font-bold text-gray-800">🪙 8,450 / 10,000</span>
              </div>
              <div className="w-full h-3 bg-gray-200 rounded-full overflow-hidden">
                <div
                  className="h-full bg-gradient-to-r from-green-500 to-emerald-600 rounded-full"
                  style={{ width: "84.5%" }}
                ></div>
              </div>
              <p className="text-xs text-gray-500 mt-1">84.5% completed</p>
            </div>

            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-medium text-gray-700">Hours Goal</span>
                <span className="text-sm font-bold text-gray-800">142.5 / 160h</span>
              </div>
              <div className="w-full h-3 bg-gray-200 rounded-full overflow-hidden">
                <div
                  className="h-full bg-gradient-to-r from-blue-500 to-blue-600 rounded-full"
                  style={{ width: "89%" }}
                ></div>
              </div>
              <p className="text-xs text-gray-500 mt-1">89% completed</p>
            </div>
          </div>
        </div>
      </div>
      <TalentBottomNav />
    </div>
  );
}
