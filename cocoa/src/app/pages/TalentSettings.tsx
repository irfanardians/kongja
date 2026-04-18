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
  Home,
  Star,
  Building2,
  Briefcase,
  Languages as LanguagesIcon
} from "lucide-react";

type TabType = "basic" | "talent" | "security" | "verification";

export function TalentSettings() {
  const navigate = useNavigate();
  const [activeTab, setActiveTab] = useState<TabType>("basic");
  const [showCurrentPassword, setShowCurrentPassword] = useState(false);
  const [showNewPassword, setShowNewPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);

  const [verificationStatus, setVerificationStatus] = useState({
    idCard: true,
    selfie: true,
    email: true,
    phone: true,
  });

  const [selectedLanguages, setSelectedLanguages] = useState<string[]>(["English", "Spanish", "French"]);
  const [selectedSpecialties, setSelectedSpecialties] = useState<string[]>(["Casual Chat", "Gaming", "Music"]);

  const availableLanguages = ["English", "Spanish", "French", "German", "Italian", "Portuguese", "Chinese", "Japanese", "Korean", "Arabic"];
  const availableSpecialties = ["Casual Chat", "Gaming", "Music", "Art", "Fitness", "Cooking", "Travel", "Technology", "Fashion", "Business"];

  const toggleLanguage = (lang: string) => {
    if (selectedLanguages.includes(lang)) {
      setSelectedLanguages(selectedLanguages.filter(l => l !== lang));
    } else {
      setSelectedLanguages([...selectedLanguages, lang]);
    }
  };

  const toggleSpecialty = (specialty: string) => {
    if (selectedSpecialties.includes(specialty)) {
      setSelectedSpecialties(selectedSpecialties.filter(s => s !== specialty));
    } else {
      setSelectedSpecialties([...selectedSpecialties, specialty]);
    }
  };

  const renderBasicInfo = () => (
    <div className="space-y-6">
      {/* Personal Information */}
      <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-4">
        <h3 className="font-semibold mb-3">Personal Information</h3>
        
        {/* Call Name */}
        <div>
          <label className="text-sm text-gray-600 mb-1 block">Call Name (Nickname)</label>
          <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg">
            <User className="w-5 h-5 text-gray-400" />
            <input
              type="text"
              defaultValue="Jess"
              className="flex-1 outline-none"
              placeholder="Enter your preferred name"
            />
          </div>
          <p className="text-xs text-gray-500 mt-1">This is your personal nickname</p>
        </div>

        {/* Email */}
        <div>
          <label className="text-sm text-gray-600 mb-1 block">Email Address</label>
          <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg">
            <Mail className="w-5 h-5 text-gray-400" />
            <input
              type="email"
              defaultValue="jessica.martinez@email.com"
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
              defaultValue="+1 (555) 987-6543"
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
              defaultValue="456 Oak Avenue, Suite 12"
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
              defaultValue="Mexico"
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
              defaultValue="Mexico City"
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
              defaultValue="03100"
              className="flex-1 outline-none"
              placeholder="Enter your postcode"
            />
          </div>
        </div>
      </div>

      {/* Registration Information (Read-only) */}
      <div className="bg-gray-50 rounded-xl border border-gray-200 p-4 space-y-4">
        <h3 className="font-semibold mb-3 flex items-center gap-2">
          <Lock className="w-4 h-4 text-gray-500" />
          Registration Information (Cannot be changed)
        </h3>
        
        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="text-sm text-gray-500 mb-1 block">First Name</label>
            <div className="flex items-center gap-3 p-3 bg-gray-100 border border-gray-200 rounded-lg">
              <User className="w-5 h-5 text-gray-400" />
              <input
                type="text"
                defaultValue="Jessica"
                className="flex-1 outline-none bg-transparent text-gray-500"
                disabled
              />
            </div>
          </div>
          
          <div>
            <label className="text-sm text-gray-500 mb-1 block">Last Name</label>
            <div className="flex items-center gap-3 p-3 bg-gray-100 border border-gray-200 rounded-lg">
              <User className="w-5 h-5 text-gray-400" />
              <input
                type="text"
                defaultValue="Martinez"
                className="flex-1 outline-none bg-transparent text-gray-500"
                disabled
              />
            </div>
          </div>
        </div>

        <div className="grid grid-cols-2 gap-4">
          <div>
            <label className="text-sm text-gray-500 mb-1 block">Gender</label>
            <div className="flex items-center gap-3 p-3 bg-gray-100 border border-gray-200 rounded-lg">
              <Users className="w-5 h-5 text-gray-400" />
              <input
                type="text"
                defaultValue="Female"
                className="flex-1 outline-none bg-transparent text-gray-500"
                disabled
              />
            </div>
          </div>
          
          <div>
            <label className="text-sm text-gray-500 mb-1 block">Date of Birth</label>
            <div className="flex items-center gap-3 p-3 bg-gray-100 border border-gray-200 rounded-lg">
              <Calendar className="w-5 h-5 text-gray-400" />
              <input
                type="text"
                defaultValue="Mar 22, 1996"
                className="flex-1 outline-none bg-transparent text-gray-500"
                disabled
              />
            </div>
          </div>
        </div>

        <p className="text-xs text-gray-500 italic">
          These details were set during registration and cannot be modified for security reasons.
        </p>
      </div>

      {/* Save Button */}
      <button className="w-full bg-gradient-to-r from-purple-600 to-pink-600 text-white py-3 rounded-xl font-semibold hover:from-purple-700 hover:to-pink-700 transition-all">
        Save Changes
      </button>
    </div>
  );

  const renderTalentProfile = () => (
    <div className="space-y-6">
      {/* Talent Profile Information */}
      <div className="bg-gradient-to-br from-purple-50 to-pink-50 rounded-xl border border-purple-200 p-4 space-y-4">
        <div className="flex items-center gap-2 mb-3">
          <Star className="w-5 h-5 text-purple-600" />
          <h3 className="font-semibold text-purple-900">Talent Profile</h3>
        </div>
        
        {/* Stage Name */}
        <div>
          <label className="text-sm text-gray-600 mb-1 block">
            Stage Name <span className="text-red-500">*</span>
          </label>
          <div className="flex items-center gap-3 p-3 bg-white border border-purple-200 rounded-lg">
            <Star className="w-5 h-5 text-gray-400" />
            <input
              type="text"
              defaultValue="Jessica Martinez"
              className="flex-1 outline-none"
              placeholder="Your professional name"
            />
          </div>
          <p className="text-xs text-purple-700 mt-1">This is how users will see you on the platform</p>
        </div>

        {/* Bio */}
        <div>
          <label className="text-sm text-gray-600 mb-1 block">
            Bio / Description <span className="text-red-500">*</span>
          </label>
          <div className="flex items-start gap-3 p-3 bg-white border border-purple-200 rounded-lg">
            <User className="w-5 h-5 text-gray-400 mt-1 flex-shrink-0" />
            <textarea
              defaultValue="Hey! I'm Jessica, a friendly companion who loves deep conversations, gaming, and helping people feel heard. Let's chat about life, hobbies, or just have fun together! Available for casual chats, gaming sessions, and more. 🎮💬"
              className="flex-1 outline-none resize-none"
              rows={4}
              placeholder="Tell users about yourself..."
            />
          </div>
          <p className="text-xs text-gray-500 mt-1">250/500 characters</p>
        </div>

        {/* Referral Agency */}
        <div>
          <label className="text-sm text-gray-600 mb-1 block">
            Referral Agency <span className="text-gray-400">(Optional)</span>
          </label>
          <div className="flex items-center gap-3 p-3 bg-white border border-purple-200 rounded-lg">
            <Building2 className="w-5 h-5 text-gray-400" />
            <input
              type="text"
              defaultValue="TalentHub Agency"
              className="flex-1 outline-none"
              placeholder="Enter agency name or code"
            />
          </div>
          <p className="text-xs text-gray-500 mt-1">If you were referred by an agency</p>
        </div>

        {/* Experience Years */}
        <div>
          <label className="text-sm text-gray-600 mb-1 block">
            Years of Experience <span className="text-red-500">*</span>
          </label>
          <div className="flex items-center gap-3 p-3 bg-white border border-purple-200 rounded-lg">
            <Briefcase className="w-5 h-5 text-gray-400" />
            <select
              defaultValue="2-5"
              className="flex-1 outline-none"
            >
              <option value="0-1">Less than 1 year</option>
              <option value="1-2">1-2 years</option>
              <option value="2-5">2-5 years</option>
              <option value="5+">5+ years</option>
            </select>
          </div>
        </div>

        {/* Languages */}
        <div>
          <label className="text-sm text-gray-600 mb-2 block">
            Languages You Speak <span className="text-red-500">*</span>
          </label>
          <div className="flex flex-wrap gap-2">
            {availableLanguages.map(lang => (
              <button
                key={lang}
                type="button"
                onClick={() => toggleLanguage(lang)}
                className={`px-3 py-1.5 rounded-full text-sm transition-all ${
                  selectedLanguages.includes(lang)
                    ? "bg-purple-600 text-white"
                    : "bg-white border border-purple-200 text-gray-700 hover:border-purple-400"
                }`}
              >
                {lang}
              </button>
            ))}
          </div>
          <p className="text-xs text-gray-500 mt-2">Select all languages you can speak fluently</p>
        </div>

        {/* Specialties */}
        <div>
          <label className="text-sm text-gray-600 mb-2 block">
            Specialties / Interests <span className="text-gray-400">(Optional)</span>
          </label>
          <div className="flex flex-wrap gap-2">
            {availableSpecialties.map(specialty => (
              <button
                key={specialty}
                type="button"
                onClick={() => toggleSpecialty(specialty)}
                className={`px-3 py-1.5 rounded-full text-sm transition-all ${
                  selectedSpecialties.includes(specialty)
                    ? "bg-pink-600 text-white"
                    : "bg-white border border-pink-200 text-gray-700 hover:border-pink-400"
                }`}
              >
                {specialty}
              </button>
            ))}
          </div>
          <p className="text-xs text-gray-500 mt-2">Select topics you're passionate about</p>
        </div>
      </div>

      {/* Social Media */}
      <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-4">
        <h3 className="font-semibold mb-3">Social Media <span className="text-gray-400 text-sm font-normal">(Optional)</span></h3>
        <p className="text-xs text-gray-600 mb-3">Link your social media to build credibility</p>

        {/* Instagram */}
        <div>
          <label className="text-sm text-gray-600 mb-1 block">Instagram</label>
          <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg">
            <span className="text-gray-500">@</span>
            <input
              type="text"
              defaultValue="jessicamartinez"
              className="flex-1 outline-none"
              placeholder="username"
            />
          </div>
        </div>

        {/* Twitter */}
        <div>
          <label className="text-sm text-gray-600 mb-1 block">Twitter / X</label>
          <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg">
            <span className="text-gray-500">@</span>
            <input
              type="text"
              defaultValue="jess_m"
              className="flex-1 outline-none"
              placeholder="username"
            />
          </div>
        </div>

        {/* TikTok */}
        <div>
          <label className="text-sm text-gray-600 mb-1 block">TikTok</label>
          <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg">
            <span className="text-gray-500">@</span>
            <input
              type="text"
              defaultValue=""
              className="flex-1 outline-none"
              placeholder="username"
            />
          </div>
        </div>
      </div>

      {/* Save Button */}
      <button className="w-full bg-gradient-to-r from-purple-600 to-pink-600 text-white py-3 rounded-xl font-semibold hover:from-purple-700 hover:to-pink-700 transition-all">
        Save Talent Profile
      </button>
    </div>
  );

  const renderSecurity = () => (
    <div className="space-y-6">
      {/* Change Password */}
      <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-4">
        <h3 className="font-semibold mb-3">Change Password</h3>
        
        {/* Current Password */}
        <div>
          <label className="text-sm text-gray-600 mb-1 block">Current Password</label>
          <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg">
            <Lock className="w-5 h-5 text-gray-400" />
            <input
              type={showCurrentPassword ? "text" : "password"}
              className="flex-1 outline-none"
              placeholder="Enter current password"
            />
            <button onClick={() => setShowCurrentPassword(!showCurrentPassword)}>
              {showCurrentPassword ? (
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
              type={showNewPassword ? "text" : "password"}
              className="flex-1 outline-none"
              placeholder="Enter new password"
            />
            <button onClick={() => setShowNewPassword(!showNewPassword)}>
              {showNewPassword ? (
                <EyeOff className="w-5 h-5 text-gray-400" />
              ) : (
                <Eye className="w-5 h-5 text-gray-400" />
              )}
            </button>
          </div>
        </div>

        {/* Confirm New Password */}
        <div>
          <label className="text-sm text-gray-600 mb-1 block">Confirm New Password</label>
          <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg">
            <Lock className="w-5 h-5 text-gray-400" />
            <input
              type={showConfirmPassword ? "text" : "password"}
              className="flex-1 outline-none"
              placeholder="Re-enter new password"
            />
            <button onClick={() => setShowConfirmPassword(!showConfirmPassword)}>
              {showConfirmPassword ? (
                <EyeOff className="w-5 h-5 text-gray-400" />
              ) : (
                <Eye className="w-5 h-5 text-gray-400" />
              )}
            </button>
          </div>
        </div>

        <button className="w-full bg-amber-600 text-white py-2.5 rounded-lg font-medium hover:bg-amber-700 transition-colors">
          Update Password
        </button>
      </div>
    </div>
  );

  const renderVerification = () => (
    <div className="space-y-6">
      {/* ID Card Verification */}
      <div className="bg-white rounded-xl border border-gray-200 p-4">
        <div className="flex items-start justify-between mb-3">
          <div className="flex-1">
            <div className="flex items-center gap-2 mb-1">
              <CreditCard className="w-5 h-5 text-purple-600" />
              <h3 className="font-semibold">ID Card Verification</h3>
            </div>
            <p className="text-sm text-gray-600">Upload a government-issued ID</p>
          </div>
          {verificationStatus.idCard ? (
            <div className="flex items-center gap-1 text-green-600 text-sm font-medium">
              <CheckCircle className="w-5 h-5" />
              Verified
            </div>
          ) : (
            <div className="flex items-center gap-1 text-amber-600 text-sm font-medium">
              <AlertCircle className="w-5 h-5" />
              Pending
            </div>
          )}
        </div>

        {!verificationStatus.idCard && (
          <button className="w-full flex items-center justify-center gap-2 bg-purple-50 text-purple-600 py-2.5 rounded-lg font-medium hover:bg-purple-100 transition-colors">
            <Upload className="w-4 h-4" />
            Upload ID Card
          </button>
        )}
      </div>

      {/* Selfie Verification */}
      <div className="bg-white rounded-xl border border-gray-200 p-4">
        <div className="flex items-start justify-between mb-3">
          <div className="flex-1">
            <div className="flex items-center gap-2 mb-1">
              <Camera className="w-5 h-5 text-purple-600" />
              <h3 className="font-semibold">Selfie with ID Verification</h3>
            </div>
            <p className="text-sm text-gray-600">Take a selfie holding your ID</p>
          </div>
          {verificationStatus.selfie ? (
            <div className="flex items-center gap-1 text-green-600 text-sm font-medium">
              <CheckCircle className="w-5 h-5" />
              Verified
            </div>
          ) : (
            <div className="flex items-center gap-1 text-amber-600 text-sm font-medium">
              <AlertCircle className="w-5 h-5" />
              Pending
            </div>
          )}
        </div>

        {!verificationStatus.selfie && (
          <button className="w-full flex items-center justify-center gap-2 bg-purple-50 text-purple-600 py-2.5 rounded-lg font-medium hover:bg-purple-100 transition-colors">
            <Camera className="w-4 h-4" />
            Take Selfie
          </button>
        )}
      </div>

      {/* Email Verification */}
      <div className="bg-white rounded-xl border border-gray-200 p-4">
        <div className="flex items-start justify-between mb-3">
          <div className="flex-1">
            <div className="flex items-center gap-2 mb-1">
              <Mail className="w-5 h-5 text-purple-600" />
              <h3 className="font-semibold">Email Verification</h3>
            </div>
            <p className="text-sm text-gray-600">jessica.martinez@email.com</p>
          </div>
          {verificationStatus.email ? (
            <div className="flex items-center gap-1 text-green-600 text-sm font-medium">
              <CheckCircle className="w-5 h-5" />
              Verified
            </div>
          ) : (
            <div className="flex items-center gap-1 text-amber-600 text-sm font-medium">
              <AlertCircle className="w-5 h-5" />
              Pending
            </div>
          )}
        </div>

        {!verificationStatus.email && (
          <button className="w-full bg-purple-50 text-purple-600 py-2.5 rounded-lg font-medium hover:bg-purple-100 transition-colors">
            Resend Verification Email
          </button>
        )}
      </div>

      {/* Phone Verification */}
      <div className="bg-white rounded-xl border border-gray-200 p-4">
        <div className="flex items-start justify-between mb-3">
          <div className="flex-1">
            <div className="flex items-center gap-2 mb-1">
              <Phone className="w-5 h-5 text-purple-600" />
              <h3 className="font-semibold">Phone Verification</h3>
            </div>
            <p className="text-sm text-gray-600">+1 (555) 987-6543</p>
          </div>
          {verificationStatus.phone ? (
            <div className="flex items-center gap-1 text-green-600 text-sm font-medium">
              <CheckCircle className="w-5 h-5" />
              Verified
            </div>
          ) : (
            <div className="flex items-center gap-1 text-amber-600 text-sm font-medium">
              <AlertCircle className="w-5 h-5" />
              Pending
            </div>
          )}
        </div>

        {!verificationStatus.phone && (
          <button className="w-full bg-purple-50 text-purple-600 py-2.5 rounded-lg font-medium hover:bg-purple-100 transition-colors">
            Verify Phone Number
          </button>
        )}
      </div>

      {/* Info Box */}
      <div className="bg-blue-50 border border-blue-200 rounded-xl p-4">
        <div className="flex items-start gap-3">
          <ShieldCheck className="w-5 h-5 text-blue-600 flex-shrink-0 mt-0.5" />
          <div>
            <p className="text-sm font-medium text-blue-900 mb-1">Why verify?</p>
            <p className="text-xs text-blue-800">
              Verification helps build trust with users and increases your profile visibility. Verified talents receive more bookings and higher ratings.
            </p>
          </div>
        </div>
      </div>
    </div>
  );

  return (
    <div className="min-h-screen bg-[#f5f1e8]">
      <div className="max-w-md mx-auto bg-white min-h-screen shadow-2xl">
        {/* Header */}
        <div className="bg-gradient-to-r from-purple-600 to-pink-600 px-6 py-4 flex items-center gap-4 sticky top-0 z-50">
          <button
            onClick={() => navigate("/talent-profile")}
            className="w-10 h-10 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center text-white hover:bg-white/30 transition-colors"
          >
            <ChevronLeft className="w-6 h-6" />
          </button>
          <h1 className="text-xl font-bold text-white">Talent Settings</h1>
        </div>

        {/* Tabs */}
        <div className="bg-white border-b border-gray-200 sticky top-[72px] z-40">
          <div className="flex overflow-x-auto">
            <button
              onClick={() => setActiveTab("basic")}
              className={`flex-1 px-4 py-3 text-sm font-medium whitespace-nowrap transition-colors ${
                activeTab === "basic"
                  ? "text-purple-600 border-b-2 border-purple-600"
                  : "text-gray-600 hover:text-gray-800"
              }`}
            >
              Basic Info
            </button>
            <button
              onClick={() => setActiveTab("talent")}
              className={`flex-1 px-4 py-3 text-sm font-medium whitespace-nowrap transition-colors ${
                activeTab === "talent"
                  ? "text-purple-600 border-b-2 border-purple-600"
                  : "text-gray-600 hover:text-gray-800"
              }`}
            >
              Talent Profile
            </button>
            <button
              onClick={() => setActiveTab("security")}
              className={`flex-1 px-4 py-3 text-sm font-medium whitespace-nowrap transition-colors ${
                activeTab === "security"
                  ? "text-purple-600 border-b-2 border-purple-600"
                  : "text-gray-600 hover:text-gray-800"
              }`}
            >
              Security
            </button>
            <button
              onClick={() => setActiveTab("verification")}
              className={`flex-1 px-4 py-3 text-sm font-medium whitespace-nowrap transition-colors ${
                activeTab === "verification"
                  ? "text-purple-600 border-b-2 border-purple-600"
                  : "text-gray-600 hover:text-gray-800"
              }`}
            >
              Verification
            </button>
          </div>
        </div>

        {/* Content */}
        <div className="p-6 pb-24">
          {activeTab === "basic" && renderBasicInfo()}
          {activeTab === "talent" && renderTalentProfile()}
          {activeTab === "security" && renderSecurity()}
          {activeTab === "verification" && renderVerification()}
        </div>
      </div>
    </div>
  );
}
