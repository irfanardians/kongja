import { useState } from "react";
import { useNavigate } from "react-router";
import { 
  ChevronLeft, 
  User, 
  Mail, 
  Phone, 
  MapPin, 
  Calendar,
  CreditCard,
  ShieldCheck,
  Camera,
  Lock,
  Eye,
  EyeOff,
  Upload,
  CheckCircle,
  AlertCircle,
  ChevronRight,
  Users,
  Globe,
  Home
} from "lucide-react";

export function Settings() {
  const navigate = useNavigate();
  const [showPassword, setShowPassword] = useState(false);
  const [activeTab, setActiveTab] = useState<"basic" | "security" | "verification">("basic");

  // Verification status
  const [verificationStatus, setVerificationStatus] = useState({
    idCard: false,
    selfie: false,
    phone: true,
    email: true,
  });

  const handleFileUpload = (type: "idCard" | "selfie") => {
    // Simulated file upload
    setVerificationStatus(prev => ({ ...prev, [type]: true }));
  };

  return (
    <div className="min-h-screen bg-[#f5f1e8] flex justify-center items-center p-4">
      <div className="w-full max-w-md bg-white min-h-screen flex flex-col">
        {/* Header */}
        <div className="bg-gradient-to-r from-amber-600 to-orange-600 px-6 py-4 flex items-center gap-4">
          <button
            onClick={() => navigate(-1)}
            className="w-10 h-10 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center text-white hover:bg-white/30 transition-colors"
          >
            <ChevronLeft className="w-6 h-6" />
          </button>
          <h1 className="text-xl font-bold text-white">Settings</h1>
        </div>

        {/* Tabs */}
        <div className="flex border-b border-gray-200 bg-white">
          <button
            onClick={() => setActiveTab("basic")}
            className={`flex-1 py-3 text-sm font-medium transition-colors ${
              activeTab === "basic"
                ? "text-amber-600 border-b-2 border-amber-600"
                : "text-gray-500 hover:text-gray-700"
            }`}
          >
            Basic Info
          </button>
          <button
            onClick={() => setActiveTab("security")}
            className={`flex-1 py-3 text-sm font-medium transition-colors ${
              activeTab === "security"
                ? "text-amber-600 border-b-2 border-amber-600"
                : "text-gray-500 hover:text-gray-700"
            }`}
          >
            Security
          </button>
          <button
            onClick={() => setActiveTab("verification")}
            className={`flex-1 py-3 text-sm font-medium transition-colors ${
              activeTab === "verification"
                ? "text-amber-600 border-b-2 border-amber-600"
                : "text-gray-500 hover:text-gray-700"
            }`}
          >
            Verification
          </button>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-6 space-y-6">
          {activeTab === "basic" && (
            <>
              <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-4">
                <h3 className="font-semibold mb-3">Personal Information</h3>
                
                {/* Call Name */}
                <div>
                  <label className="text-sm text-gray-600 mb-1 block">Call Name (Nickname)</label>
                  <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg">
                    <User className="w-5 h-5 text-gray-400" />
                    <input
                      type="text"
                      defaultValue="Alex"
                      className="flex-1 outline-none"
                      placeholder="Enter your preferred name"
                    />
                  </div>
                  <p className="text-xs text-gray-500 mt-1">This is how others will see your name</p>
                </div>

                {/* Email */}
                <div>
                  <label className="text-sm text-gray-600 mb-1 block">Email Address</label>
                  <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg">
                    <Mail className="w-5 h-5 text-gray-400" />
                    <input
                      type="email"
                      defaultValue="alex.johnson@email.com"
                      className="flex-1 outline-none"
                      placeholder="Enter your email"
                    />
                    {verificationStatus.email && (
                      <CheckCircle className="w-5 h-5 text-green-500" />
                    )}
                  </div>
                  <p className="text-xs text-amber-600 mt-1 flex items-center gap-1">
                    <AlertCircle className="w-3 h-3" />
                    Changing email requires re-verification
                  </p>
                </div>

                {/* Phone */}
                <div>
                  <label className="text-sm text-gray-600 mb-1 block">Phone Number</label>
                  <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg">
                    <Phone className="w-5 h-5 text-gray-400" />
                    <input
                      type="tel"
                      defaultValue="+1 (555) 123-4567"
                      className="flex-1 outline-none"
                      placeholder="Enter your phone number"
                    />
                    {verificationStatus.phone && (
                      <CheckCircle className="w-5 h-5 text-green-500" />
                    )}
                  </div>
                  <p className="text-xs text-amber-600 mt-1 flex items-center gap-1">
                    <AlertCircle className="w-3 h-3" />
                    Changing phone requires re-verification
                  </p>
                </div>
              </div>

              {/* Address Information */}
              <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-4">
                <h3 className="font-semibold mb-3">Address Information</h3>

                {/* Full Address */}
                <div>
                  <label className="text-sm text-gray-600 mb-1 block">Address</label>
                  <div className="flex items-start gap-3 p-3 border border-gray-200 rounded-lg">
                    <Home className="w-5 h-5 text-gray-400 mt-1 flex-shrink-0" />
                    <textarea
                      defaultValue="123 Main Street, Apartment 4B"
                      className="flex-1 outline-none resize-none"
                      rows={3}
                      placeholder="Enter your full address"
                    />
                  </div>
                </div>

                {/* Country */}
                <div>
                  <label className="text-sm text-gray-600 mb-1 block">Country</label>
                  <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg">
                    <Globe className="w-5 h-5 text-gray-400" />
                    <input
                      type="text"
                      defaultValue="United States"
                      className="flex-1 outline-none"
                      placeholder="Enter your country"
                    />
                  </div>
                </div>

                {/* City */}
                <div>
                  <label className="text-sm text-gray-600 mb-1 block">City</label>
                  <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg">
                    <MapPin className="w-5 h-5 text-gray-400" />
                    <input
                      type="text"
                      defaultValue="New York"
                      className="flex-1 outline-none"
                      placeholder="Enter your city"
                    />
                  </div>
                </div>

                {/* Postcode */}
                <div>
                  <label className="text-sm text-gray-600 mb-1 block">Postcode / ZIP Code</label>
                  <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg">
                    <MapPin className="w-5 h-5 text-gray-400" />
                    <input
                      type="text"
                      defaultValue="10001"
                      className="flex-1 outline-none"
                      placeholder="Enter your postcode"
                    />
                  </div>
                </div>
              </div>

              {/* Read-only Registration Info */}
              <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-4">
                <div className="flex items-center justify-between mb-3">
                  <h3 className="font-semibold">Registration Information</h3>
                  <span className="text-xs text-gray-500 bg-gray-100 px-2 py-1 rounded-full">Read Only</span>
                </div>

                {/* First Name */}
                <div>
                  <label className="text-sm text-gray-600 mb-1 block">First Name</label>
                  <div className="flex items-center gap-3 p-3 bg-gray-50 border border-gray-200 rounded-lg">
                    <User className="w-5 h-5 text-gray-400" />
                    <span className="flex-1 text-gray-700">Alexander</span>
                    <Lock className="w-4 h-4 text-gray-400" />
                  </div>
                </div>

                {/* Last Name */}
                <div>
                  <label className="text-sm text-gray-600 mb-1 block">Last Name</label>
                  <div className="flex items-center gap-3 p-3 bg-gray-50 border border-gray-200 rounded-lg">
                    <User className="w-5 h-5 text-gray-400" />
                    <span className="flex-1 text-gray-700">Johnson</span>
                    <Lock className="w-4 h-4 text-gray-400" />
                  </div>
                </div>

                {/* Gender */}
                <div>
                  <label className="text-sm text-gray-600 mb-1 block">Gender</label>
                  <div className="flex items-center gap-3 p-3 bg-gray-50 border border-gray-200 rounded-lg">
                    <Users className="w-5 h-5 text-gray-400" />
                    <span className="flex-1 text-gray-700">Male</span>
                    <Lock className="w-4 h-4 text-gray-400" />
                  </div>
                </div>

                {/* Date of Birth */}
                <div>
                  <label className="text-sm text-gray-600 mb-1 block">Date of Birth</label>
                  <div className="flex items-center gap-3 p-3 bg-gray-50 border border-gray-200 rounded-lg">
                    <Calendar className="w-5 h-5 text-gray-400" />
                    <span className="flex-1 text-gray-700">June 15, 1995 (28 years old)</span>
                    <Lock className="w-4 h-4 text-gray-400" />
                  </div>
                </div>

                <p className="text-xs text-gray-500 mt-2 bg-blue-50 border border-blue-200 rounded-lg p-3">
                  <span className="font-medium text-blue-900">ℹ️ Legal Information:</span>
                  <span className="text-blue-700 ml-1">These fields are set during registration and cannot be changed for security and verification purposes.</span>
                </p>
              </div>

              <button className="w-full bg-gradient-to-r from-amber-600 to-orange-600 text-white py-3.5 rounded-xl font-semibold hover:from-amber-700 hover:to-orange-700 transition-all">
                Save Changes
              </button>
            </>
          )}

          {activeTab === "security" && (
            <>
              <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-4">
                <h3 className="font-semibold mb-3">Password & Security</h3>

                {/* Current Password */}
                <div>
                  <label className="text-sm text-gray-600 mb-1 block">Current Password</label>
                  <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg">
                    <Lock className="w-5 h-5 text-gray-400" />
                    <input
                      type={showPassword ? "text" : "password"}
                      className="flex-1 outline-none"
                      placeholder="Enter current password"
                    />
                    <button onClick={() => setShowPassword(!showPassword)}>
                      {showPassword ? (
                        <EyeOff className="w-5 h-5 text-gray-400" />
                      ) : (
                        <Eye className="w-5 h-5 text-gray-400" />
                      )}
                    </button>
                  </div>
                </div>

                {/* New Password */}
                <div>
                  <label className="text-sm text-gray-600 mb-1 block">New Password</label>
                  <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg">
                    <Lock className="w-5 h-5 text-gray-400" />
                    <input
                      type={showPassword ? "text" : "password"}
                      className="flex-1 outline-none"
                      placeholder="Enter new password"
                    />
                  </div>
                </div>

                {/* Confirm Password */}
                <div>
                  <label className="text-sm text-gray-600 mb-1 block">Confirm New Password</label>
                  <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg">
                    <Lock className="w-5 h-5 text-gray-400" />
                    <input
                      type={showPassword ? "text" : "password"}
                      className="flex-1 outline-none"
                      placeholder="Confirm new password"
                    />
                  </div>
                </div>
              </div>

              <div className="bg-amber-50 border border-amber-200 rounded-xl p-4">
                <div className="flex gap-3">
                  <AlertCircle className="w-5 h-5 text-amber-600 flex-shrink-0 mt-0.5" />
                  <div>
                    <p className="text-sm font-medium text-amber-900 mb-1">Password Requirements</p>
                    <ul className="text-xs text-amber-700 space-y-1">
                      <li>• At least 8 characters long</li>
                      <li>• Include uppercase and lowercase letters</li>
                      <li>• Include at least one number</li>
                      <li>• Include at least one special character</li>
                    </ul>
                  </div>
                </div>
              </div>

              <button className="w-full bg-gradient-to-r from-amber-600 to-orange-600 text-white py-3.5 rounded-xl font-semibold hover:from-amber-700 hover:to-orange-700 transition-all">
                Update Password
              </button>
            </>
          )}

          {activeTab === "verification" && (
            <>
              {/* Verification Status Overview */}
              <div className="bg-gradient-to-br from-amber-50 to-orange-50 rounded-xl p-4 border border-amber-200">
                <div className="flex items-center gap-3 mb-3">
                  <div className="w-12 h-12 bg-amber-600 rounded-full flex items-center justify-center">
                    <ShieldCheck className="w-6 h-6 text-white" />
                  </div>
                  <div>
                    <h3 className="font-semibold">Account Verification</h3>
                    <p className="text-sm text-gray-600">
                      {verificationStatus.idCard && verificationStatus.selfie ? (
                        <span className="text-green-600 font-medium">✓ Fully Verified</span>
                      ) : (
                        <span className="text-amber-600 font-medium">Verification Required</span>
                      )}
                    </p>
                  </div>
                </div>
                <p className="text-xs text-gray-600">
                  Verified users are trusted and get priority support. Complete all steps below for full verification.
                </p>
              </div>

              {/* ID Card Verification */}
              <div className="bg-white rounded-xl border border-gray-200 p-4">
                <div className="flex items-start gap-3 mb-3">
                  <div className="w-10 h-10 bg-blue-100 rounded-full flex items-center justify-center flex-shrink-0">
                    <CreditCard className="w-5 h-5 text-blue-600" />
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <h4 className="font-semibold">ID Card Verification</h4>
                      {verificationStatus.idCard && (
                        <CheckCircle className="w-5 h-5 text-green-500" />
                      )}
                    </div>
                    <p className="text-sm text-gray-600 mb-3">
                      Upload a photo of your government-issued ID (passport, driver's license, or national ID card)
                    </p>
                    
                    {!verificationStatus.idCard ? (
                      <button
                        onClick={() => handleFileUpload("idCard")}
                        className="flex items-center gap-2 px-4 py-2 border-2 border-dashed border-gray-300 rounded-lg hover:border-amber-600 hover:bg-amber-50 transition-all w-full justify-center"
                      >
                        <Upload className="w-5 h-5 text-gray-400" />
                        <span className="text-sm font-medium text-gray-700">Upload ID Card</span>
                      </button>
                    ) : (
                      <div className="flex items-center gap-2 px-4 py-2 bg-green-50 border border-green-200 rounded-lg">
                        <CheckCircle className="w-5 h-5 text-green-600" />
                        <span className="text-sm font-medium text-green-700">ID Card Verified</span>
                      </div>
                    )}
                  </div>
                </div>
              </div>

              {/* Selfie Verification */}
              <div className="bg-white rounded-xl border border-gray-200 p-4">
                <div className="flex items-start gap-3 mb-3">
                  <div className="w-10 h-10 bg-purple-100 rounded-full flex items-center justify-center flex-shrink-0">
                    <Camera className="w-5 h-5 text-purple-600" />
                  </div>
                  <div className="flex-1">
                    <div className="flex items-center gap-2 mb-1">
                      <h4 className="font-semibold">Selfie Verification</h4>
                      {verificationStatus.selfie && (
                        <CheckCircle className="w-5 h-5 text-green-500" />
                      )}
                    </div>
                    <p className="text-sm text-gray-600 mb-3">
                      Take a selfie holding your ID card next to your face for identity confirmation
                    </p>
                    
                    {!verificationStatus.selfie ? (
                      <button
                        onClick={() => handleFileUpload("selfie")}
                        className="flex items-center gap-2 px-4 py-2 border-2 border-dashed border-gray-300 rounded-lg hover:border-amber-600 hover:bg-amber-50 transition-all w-full justify-center"
                      >
                        <Camera className="w-5 h-5 text-gray-400" />
                        <span className="text-sm font-medium text-gray-700">Upload Selfie</span>
                      </button>
                    ) : (
                      <div className="flex items-center gap-2 px-4 py-2 bg-green-50 border border-green-200 rounded-lg">
                        <CheckCircle className="w-5 h-5 text-green-600" />
                        <span className="text-sm font-medium text-green-700">Selfie Verified</span>
                      </div>
                    )}
                  </div>
                </div>
              </div>

              {/* Email & Phone Verification */}
              <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-3">
                <h4 className="font-semibold mb-2">Contact Verification</h4>
                
                <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                  <div className="flex items-center gap-3">
                    <Mail className="w-5 h-5 text-gray-400" />
                    <div>
                      <p className="text-sm font-medium">Email Verification</p>
                      <p className="text-xs text-gray-500">alex.johnson@email.com</p>
                    </div>
                  </div>
                  {verificationStatus.email ? (
                    <CheckCircle className="w-5 h-5 text-green-500" />
                  ) : (
                    <button className="text-xs text-amber-600 font-medium">Verify</button>
                  )}
                </div>

                <div className="flex items-center justify-between p-3 bg-gray-50 rounded-lg">
                  <div className="flex items-center gap-3">
                    <Phone className="w-5 h-5 text-gray-400" />
                    <div>
                      <p className="text-sm font-medium">Phone Verification</p>
                      <p className="text-xs text-gray-500">+1 (555) 123-4567</p>
                    </div>
                  </div>
                  {verificationStatus.phone ? (
                    <CheckCircle className="w-5 h-5 text-green-500" />
                  ) : (
                    <button className="text-xs text-amber-600 font-medium">Verify</button>
                  )}
                </div>
              </div>

              {/* Privacy & Trust */}
              <div className="bg-blue-50 border border-blue-200 rounded-xl p-4">
                <div className="flex gap-3">
                  <ShieldCheck className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
                  <div>
                    <p className="text-sm font-medium text-blue-900 mb-1">Your Privacy is Protected</p>
                    <p className="text-xs text-blue-700">
                      All verification documents are encrypted and securely stored. They will only be used for identity verification purposes.
                    </p>
                  </div>
                </div>
              </div>
            </>
          )}
        </div>
      </div>
    </div>
  );
}