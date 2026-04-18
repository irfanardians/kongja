import { useState } from "react";
import { X, Wallet, DollarSign, ChevronDown, Check, CreditCard, Building2 } from "lucide-react";

interface WithdrawModalProps {
  isOpen: boolean;
  onClose: () => void;
  coinBalance: number;
}

interface Currency {
  code: string;
  symbol: string;
  name: string;
  flag: string;
  rate: number; // How much 1 coin is worth in this currency
}

const currencies: Currency[] = [
  { code: "USD", symbol: "$", name: "US Dollar", flag: "🇺🇸", rate: 0.10 },
  { code: "EUR", symbol: "€", name: "Euro", flag: "🇪🇺", rate: 0.092 },
  { code: "GBP", symbol: "£", name: "British Pound", flag: "🇬🇧", rate: 0.079 },
  { code: "JPY", symbol: "¥", name: "Japanese Yen", flag: "🇯🇵", rate: 14.50 },
  { code: "CAD", symbol: "C$", name: "Canadian Dollar", flag: "🇨🇦", rate: 0.14 },
  { code: "AUD", symbol: "A$", name: "Australian Dollar", flag: "🇦🇺", rate: 0.15 },
  { code: "MXN", symbol: "MX$", name: "Mexican Peso", flag: "🇲🇽", rate: 1.75 },
  { code: "BRL", symbol: "R$", name: "Brazilian Real", flag: "🇧🇷", rate: 0.52 },
  { code: "INR", symbol: "₹", name: "Indian Rupee", flag: "🇮🇳", rate: 8.30 },
  { code: "SGD", symbol: "S$", name: "Singapore Dollar", flag: "🇸🇬", rate: 0.13 },
  { code: "PHP", symbol: "₱", name: "Philippine Peso", flag: "🇵🇭", rate: 5.60 },
];

export function WithdrawModal({ isOpen, onClose, coinBalance }: WithdrawModalProps) {
  const [selectedCurrency, setSelectedCurrency] = useState<Currency>(currencies[0]);
  const [showCurrencyDropdown, setShowCurrencyDropdown] = useState(false);
  const [withdrawAmount, setWithdrawAmount] = useState("");
  const [paymentMethod, setPaymentMethod] = useState<"bank" | "paypal">("bank");

  if (!isOpen) return null;

  const coinsToWithdraw = Number(withdrawAmount) || 0;
  const convertedAmount = coinsToWithdraw * selectedCurrency.rate;
  const minimumWithdrawal = 1000; // minimum coins to withdraw
  const fee = coinsToWithdraw * 0.05; // 5% platform fee
  const finalAmount = convertedAmount * 0.95; // After fee

  const handleWithdraw = () => {
    if (coinsToWithdraw < minimumWithdrawal) {
      alert(`Minimum withdrawal is ${minimumWithdrawal} coins`);
      return;
    }
    if (coinsToWithdraw > coinBalance) {
      alert("Insufficient balance");
      return;
    }
    alert(
      `Withdrawal request submitted!\n${coinsToWithdraw} coins → ${selectedCurrency.symbol}${finalAmount.toFixed(2)} ${selectedCurrency.code}\nPayment method: ${paymentMethod === "bank" ? "Bank Transfer" : "PayPal"}`
    );
    onClose();
  };

  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/50">
      <div className="w-full max-w-md bg-white rounded-t-3xl shadow-2xl animate-slide-up">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-gray-200">
          <h2 className="text-xl font-semibold">Withdraw Earnings</h2>
          <button onClick={onClose} className="text-gray-500 hover:text-gray-700">
            <X className="w-6 h-6" />
          </button>
        </div>

        <div className="p-6 max-h-[80vh] overflow-y-auto">
          {/* Available Balance */}
          <div className="bg-gradient-to-r from-green-500 to-emerald-600 rounded-2xl p-5 text-white mb-6">
            <div className="flex items-center gap-2 mb-2">
              <Wallet className="w-5 h-5" />
              <p className="text-sm text-green-100">Available Balance</p>
            </div>
            <p className="text-3xl font-bold">🪙 {coinBalance.toLocaleString()} Coins</p>
            <p className="text-green-100 text-sm mt-2">
              ≈ {selectedCurrency.flag} {selectedCurrency.symbol}
              {(coinBalance * selectedCurrency.rate).toFixed(2)} {selectedCurrency.code}
            </p>
          </div>

          {/* Currency Selection */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Select Currency
            </label>
            <div className="relative">
              <button
                onClick={() => setShowCurrencyDropdown(!showCurrencyDropdown)}
                className="w-full flex items-center justify-between bg-gray-100 rounded-xl px-4 py-3 focus:outline-none focus:ring-2 focus:ring-green-500"
              >
                <div className="flex items-center gap-3">
                  <span className="text-2xl">{selectedCurrency.flag}</span>
                  <div className="text-left">
                    <p className="font-medium">{selectedCurrency.name}</p>
                    <p className="text-sm text-gray-500">
                      1 coin = {selectedCurrency.symbol}
                      {selectedCurrency.rate.toFixed(2)} {selectedCurrency.code}
                    </p>
                  </div>
                </div>
                <ChevronDown className="w-5 h-5 text-gray-400" />
              </button>

              {showCurrencyDropdown && (
                <div className="absolute top-full left-0 right-0 mt-2 bg-white rounded-xl shadow-xl border border-gray-200 max-h-64 overflow-y-auto z-10">
                  {currencies.map((currency) => (
                    <button
                      key={currency.code}
                      onClick={() => {
                        setSelectedCurrency(currency);
                        setShowCurrencyDropdown(false);
                      }}
                      className="w-full flex items-center gap-3 px-4 py-3 hover:bg-gray-50 transition-colors"
                    >
                      <span className="text-2xl">{currency.flag}</span>
                      <div className="flex-1 text-left">
                        <p className="font-medium">{currency.name}</p>
                        <p className="text-sm text-gray-500">
                          1 coin = {currency.symbol}
                          {currency.rate.toFixed(2)}
                        </p>
                      </div>
                      {selectedCurrency.code === currency.code && (
                        <Check className="w-5 h-5 text-green-500" />
                      )}
                    </button>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Withdrawal Amount */}
          <div className="mb-4">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Amount to Withdraw
            </label>
            <div className="relative">
              <input
                type="number"
                value={withdrawAmount}
                onChange={(e) => setWithdrawAmount(e.target.value)}
                placeholder="Enter amount in coins"
                className="w-full bg-gray-100 rounded-xl px-4 py-3 pr-20 focus:outline-none focus:ring-2 focus:ring-green-500"
              />
              <span className="absolute right-4 top-1/2 -translate-y-1/2 text-gray-500 font-medium">
                Coins
              </span>
            </div>
            <div className="flex gap-2 mt-2">
              {[1000, 2500, 5000].map((amount) => (
                <button
                  key={amount}
                  onClick={() => setWithdrawAmount(amount.toString())}
                  className="flex-1 bg-gray-100 hover:bg-gray-200 rounded-lg px-3 py-2 text-sm font-medium transition-colors"
                >
                  {amount}
                </button>
              ))}
              <button
                onClick={() => setWithdrawAmount(coinBalance.toString())}
                className="flex-1 bg-green-100 hover:bg-green-200 text-green-700 rounded-lg px-3 py-2 text-sm font-medium transition-colors"
              >
                Max
              </button>
            </div>
            <p className="text-xs text-gray-500 mt-2">
              Minimum withdrawal: {minimumWithdrawal} coins
            </p>
          </div>

          {/* Payment Method */}
          <div className="mb-6">
            <label className="block text-sm font-medium text-gray-700 mb-2">
              Payment Method
            </label>
            <div className="grid grid-cols-2 gap-3">
              <button
                onClick={() => setPaymentMethod("bank")}
                className={`flex items-center gap-2 p-4 rounded-xl border-2 transition-all ${
                  paymentMethod === "bank"
                    ? "border-green-500 bg-green-50"
                    : "border-gray-200 hover:border-gray-300"
                }`}
              >
                <Building2 className="w-5 h-5" />
                <span className="font-medium">Bank</span>
              </button>
              <button
                onClick={() => setPaymentMethod("paypal")}
                className={`flex items-center gap-2 p-4 rounded-xl border-2 transition-all ${
                  paymentMethod === "paypal"
                    ? "border-green-500 bg-green-50"
                    : "border-gray-200 hover:border-gray-300"
                }`}
              >
                <CreditCard className="w-5 h-5" />
                <span className="font-medium">PayPal</span>
              </button>
            </div>
          </div>

          {/* Conversion Summary */}
          {coinsToWithdraw > 0 && (
            <div className="bg-blue-50 rounded-2xl p-4 mb-6">
              <h3 className="font-semibold mb-3 flex items-center gap-2">
                <DollarSign className="w-5 h-5 text-blue-600" />
                Conversion Summary
              </h3>
              <div className="space-y-2 text-sm">
                <div className="flex justify-between">
                  <span className="text-gray-600">Amount in coins:</span>
                  <span className="font-medium">🪙 {coinsToWithdraw.toLocaleString()}</span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Conversion rate:</span>
                  <span className="font-medium">
                    1 coin = {selectedCurrency.symbol}
                    {selectedCurrency.rate.toFixed(2)}
                  </span>
                </div>
                <div className="flex justify-between">
                  <span className="text-gray-600">Before fees:</span>
                  <span className="font-medium">
                    {selectedCurrency.symbol}
                    {convertedAmount.toFixed(2)}
                  </span>
                </div>
                <div className="flex justify-between text-orange-600">
                  <span>Platform fee (5%):</span>
                  <span className="font-medium">
                    -{selectedCurrency.symbol}
                    {(convertedAmount * 0.05).toFixed(2)}
                  </span>
                </div>
                <div className="border-t border-blue-200 pt-2 mt-2"></div>
                <div className="flex justify-between text-lg font-bold text-green-600">
                  <span>You'll receive:</span>
                  <span>
                    {selectedCurrency.flag} {selectedCurrency.symbol}
                    {finalAmount.toFixed(2)} {selectedCurrency.code}
                  </span>
                </div>
              </div>
            </div>
          )}

          {/* Action Buttons */}
          <div className="flex gap-3">
            <button
              onClick={onClose}
              className="flex-1 bg-gray-100 text-gray-700 py-3 rounded-xl font-semibold hover:bg-gray-200 transition-colors"
            >
              Cancel
            </button>
            <button
              onClick={handleWithdraw}
              disabled={coinsToWithdraw < minimumWithdrawal || coinsToWithdraw > coinBalance}
              className="flex-1 bg-green-600 text-white py-3 rounded-xl font-semibold hover:bg-green-700 transition-colors disabled:bg-gray-300 disabled:cursor-not-allowed"
            >
              Confirm Withdrawal
            </button>
          </div>

          <p className="text-xs text-gray-500 text-center mt-4">
            Processing time: 3-5 business days
          </p>
        </div>
      </div>
    </div>
  );
}
