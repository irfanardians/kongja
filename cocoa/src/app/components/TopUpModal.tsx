import { X, CreditCard, Smartphone, Wallet, Building2, Check } from "lucide-react";
import { useState } from "react";

interface TopUpModalProps {
  isOpen: boolean;
  onClose: () => void;
}

const coinPackages = [
  { coins: 100, price: "$4.99", bonus: "" },
  { coins: 500, price: "$19.99", bonus: "+50 bonus" },
  { coins: 1000, price: "$34.99", bonus: "+150 bonus", popular: true },
  { coins: 2500, price: "$79.99", bonus: "+500 bonus" },
  { coins: 5000, price: "$149.99", bonus: "+1200 bonus" },
];

const paymentMethods = [
  { id: "card", name: "Credit/Debit Card", icon: CreditCard, description: "Visa, Mastercard, Amex" },
  { id: "paypal", name: "PayPal", icon: Wallet, description: "Pay with PayPal" },
  { id: "googlepay", name: "Google Pay", icon: Smartphone, description: "Fast & secure" },
  { id: "bank", name: "Bank Transfer", icon: Building2, description: "Direct transfer" },
];

export function TopUpModal({ isOpen, onClose }: TopUpModalProps) {
  const [selectedPackage, setSelectedPackage] = useState(2); // Default to popular package
  const [selectedPayment, setSelectedPayment] = useState("card");
  const [step, setStep] = useState<"packages" | "payment" | "success">("packages");

  if (!isOpen) return null;

  const handleProceedToPayment = () => {
    setStep("payment");
  };

  const handleConfirmPayment = () => {
    setStep("success");
    setTimeout(() => {
      onClose();
      setStep("packages");
    }, 2000);
  };

  const handleClose = () => {
    onClose();
    setTimeout(() => setStep("packages"), 300);
  };

  return (
    <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
      <div className="bg-white rounded-2xl w-full max-w-md max-h-[90vh] overflow-hidden flex flex-col">
        {/* Header */}
        <div className="flex items-center justify-between p-6 border-b border-gray-200">
          <h2 className="text-xl font-semibold">
            {step === "packages" && "Top Up Coins"}
            {step === "payment" && "Payment Method"}
            {step === "success" && "Success!"}
          </h2>
          <button onClick={handleClose} className="text-gray-500 hover:text-gray-700">
            <X className="w-6 h-6" />
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-6">
          {step === "packages" && (
            <>
              <p className="text-gray-600 mb-6">Choose a coin package</p>
              <div className="space-y-3">
                {coinPackages.map((pkg, index) => (
                  <button
                    key={index}
                    onClick={() => setSelectedPackage(index)}
                    className={`w-full p-4 rounded-xl border-2 transition-all text-left relative ${
                      selectedPackage === index
                        ? "border-amber-600 bg-amber-50"
                        : "border-gray-200 hover:border-gray-300"
                    }`}
                  >
                    {pkg.popular && (
                      <div className="absolute -top-2 right-4 bg-gradient-to-r from-amber-600 to-orange-600 text-white text-xs px-3 py-1 rounded-full">
                        Most Popular
                      </div>
                    )}
                    <div className="flex items-center justify-between">
                      <div>
                        <div className="flex items-center gap-2 mb-1">
                          <span className="text-2xl font-semibold">🪙 {pkg.coins.toLocaleString()}</span>
                          {pkg.bonus && (
                            <span className="text-xs bg-green-100 text-green-700 px-2 py-0.5 rounded-full font-medium">
                              {pkg.bonus}
                            </span>
                          )}
                        </div>
                        <p className="text-sm text-gray-500">Coins</p>
                      </div>
                      <div className="text-right">
                        <p className="text-2xl font-semibold text-amber-700">{pkg.price}</p>
                      </div>
                    </div>
                  </button>
                ))}
              </div>
            </>
          )}

          {step === "payment" && (
            <>
              <div className="bg-gradient-to-r from-amber-50 to-orange-50 rounded-xl p-4 mb-6">
                <p className="text-sm text-gray-600 mb-1">You're purchasing:</p>
                <div className="flex items-center justify-between">
                  <p className="text-xl font-semibold">
                    🪙 {coinPackages[selectedPackage].coins.toLocaleString()}
                    {coinPackages[selectedPackage].bonus && (
                      <span className="text-sm text-green-600 ml-2">
                        {coinPackages[selectedPackage].bonus}
                      </span>
                    )}
                  </p>
                  <p className="text-xl font-semibold text-amber-700">
                    {coinPackages[selectedPackage].price}
                  </p>
                </div>
              </div>

              <p className="text-gray-600 mb-4">Select payment method</p>
              <div className="space-y-3">
                {paymentMethods.map((method) => (
                  <button
                    key={method.id}
                    onClick={() => setSelectedPayment(method.id)}
                    className={`w-full p-4 rounded-xl border-2 transition-all text-left ${
                      selectedPayment === method.id
                        ? "border-amber-600 bg-amber-50"
                        : "border-gray-200 hover:border-gray-300"
                    }`}
                  >
                    <div className="flex items-center gap-3">
                      <div className="w-12 h-12 bg-gradient-to-br from-amber-100 to-orange-100 rounded-xl flex items-center justify-center">
                        <method.icon className="w-6 h-6 text-amber-700" />
                      </div>
                      <div className="flex-1">
                        <p className="font-medium">{method.name}</p>
                        <p className="text-sm text-gray-500">{method.description}</p>
                      </div>
                      {selectedPayment === method.id && (
                        <div className="w-6 h-6 bg-amber-600 rounded-full flex items-center justify-center">
                          <Check className="w-4 h-4 text-white" />
                        </div>
                      )}
                    </div>
                  </button>
                ))}
              </div>
            </>
          )}

          {step === "success" && (
            <div className="text-center py-8">
              <div className="w-20 h-20 bg-green-100 rounded-full flex items-center justify-center mx-auto mb-4">
                <Check className="w-10 h-10 text-green-600" />
              </div>
              <h3 className="text-2xl font-semibold mb-2">Payment Successful!</h3>
              <p className="text-gray-600 mb-4">
                🪙 {coinPackages[selectedPackage].coins.toLocaleString()} coins have been added to your account
              </p>
              <div className="inline-block bg-gradient-to-r from-amber-50 to-orange-50 rounded-xl px-6 py-3">
                <p className="text-sm text-gray-600">New Balance</p>
                <p className="text-2xl font-semibold text-amber-700">
                  🪙 {(1250 + coinPackages[selectedPackage].coins).toLocaleString()}
                </p>
              </div>
            </div>
          )}
        </div>

        {/* Footer */}
        {step !== "success" && (
          <div className="p-6 border-t border-gray-200">
            {step === "packages" && (
              <button
                onClick={handleProceedToPayment}
                className="w-full bg-gradient-to-r from-amber-600 to-orange-600 text-white py-3.5 rounded-xl font-semibold hover:from-amber-700 hover:to-orange-700 transition-all"
              >
                Continue to Payment
              </button>
            )}
            {step === "payment" && (
              <div className="space-y-3">
                <button
                  onClick={handleConfirmPayment}
                  className="w-full bg-gradient-to-r from-amber-600 to-orange-600 text-white py-3.5 rounded-xl font-semibold hover:from-amber-700 hover:to-orange-700 transition-all"
                >
                  Pay {coinPackages[selectedPackage].price}
                </button>
                <button
                  onClick={() => setStep("packages")}
                  className="w-full bg-gray-100 text-gray-700 py-3 rounded-xl font-medium hover:bg-gray-200 transition-all"
                >
                  Back to Packages
                </button>
              </div>
            )}
          </div>
        )}
      </div>
    </div>
  );
}
