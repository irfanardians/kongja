import { useState } from "react";
import { useNavigate } from "react-router";
import { 
  User, 
  Mail, 
  Phone, 
  MapPin, 
  Calendar,
  Lock,
  Eye,
  EyeOff,
  Users,
  Globe,
  Home,
  ChevronLeft,
  AlertCircle,
  CheckCircle,
  Star,
  Building2,
  Briefcase,
  Languages,
  DollarSign,
  Camera,
  Upload
} from "lucide-react";

export function RegisterTalent() {
  const navigate = useNavigate();
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [formData, setFormData] = useState({
    // Account credentials
    username: "",
    password: "",
    confirmPassword: "",
    
    // Personal Information
    firstName: "",
    lastName: "",
    callName: "",
    email: "",
    phone: "",
    gender: "",
    dateOfBirth: "",
    
    // Address Information
    address: "",
    country: "",
    city: "",
    postcode: "",
    
    // Talent-Specific Information
    stageName: "",
    bio: "",
    referralAgency: "",
    languages: [] as string[],
    specialties: [] as string[],
    experienceYears: "",
    socialMedia: {
      instagram: "",
      twitter: "",
      tiktok: ""
    }
  });

  const [selectedLanguages, setSelectedLanguages] = useState<string[]>([]);
  const [selectedSpecialties, setSelectedSpecialties] = useState<string[]>([]);

  const availableLanguages = ["English", "Spanish", "French", "German", "Italian", "Portuguese", "Chinese", "Japanese", "Korean", "Arabic"];
  const availableSpecialties = ["Casual Chat", "Gaming", "Music", "Art", "Fitness", "Cooking", "Travel", "Technology", "Fashion", "Business"];

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    const { name, value } = e.target;
    
    // Handle nested social media fields
    if (name.startsWith("social_")) {
      const platform = name.replace("social_", "");
      setFormData({
        ...formData,
        socialMedia: {
          ...formData.socialMedia,
          [platform]: value
        }
      });
    } else {
      setFormData({
        ...formData,
        [name]: value
      });
    }
  };

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

  const handleRegister = () => {
    // Add validation here
    if (formData.password !== formData.confirmPassword) {
      alert("Passwords do not match!");
      return;
    }

    if (!formData.stageName) {
      alert("Stage name is required!");
      return;
    }

    if (selectedLanguages.length === 0) {
      alert("Please select at least one language!");
      return;
    }

    // Registration logic here
    const finalData = {
      ...formData,
      languages: selectedLanguages,
      specialties: selectedSpecialties
    };
    console.log("Talent Registration data:", finalData);
    
    // Navigate to talent home after successful registration
    navigate("/talent-home");
  };

  return (
    <div className="min-h-screen bg-[#f5f1e8] flex justify-center items-center p-4">
      <div className="w-full max-w-md bg-white min-h-screen flex flex-col">
        {/* Header */}
        <div className="bg-gradient-to-r from-purple-600 to-pink-600 px-6 py-4 flex items-center gap-4">
          <button
            onClick={() => navigate("/")}
            className="w-10 h-10 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center text-white hover:bg-white/30 transition-colors"
          >
            <ChevronLeft className="w-6 h-6" />
          </button>
          <h1 className="text-xl font-bold text-white">Become a Talent</h1>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto p-6 space-y-6">
          {/* Account Credentials */}
          <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-4">
            <h3 className="font-semibold mb-3">Account Credentials</h3>
            
            {/* Username */}
            <div>
              <label className="text-sm text-gray-600 mb-1 block">
                Username <span className="text-red-500">*</span>
              </label>
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-purple-600 transition-colors">
                <User className="w-5 h-5 text-gray-400" />
                <input
                  type="text"
                  name="username"
                  value={formData.username}
                  onChange={handleInputChange}
                  className="flex-1 outline-none"
                  placeholder="Choose a username"
                  required
                />
              </div>
            </div>

            {/* Password */}
            <div>
              <label className="text-sm text-gray-600 mb-1 block">
                Password <span className="text-red-500">*</span>
              </label>
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-purple-600 transition-colors">
                <Lock className="w-5 h-5 text-gray-400" />
                <input
                  type={showPassword ? "text" : "password"}
                  name="password"
                  value={formData.password}
                  onChange={handleInputChange}
                  className="flex-1 outline-none"
                  placeholder="Enter password"
                  required
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

            {/* Confirm Password */}
            <div>
              <label className="text-sm text-gray-600 mb-1 block">
                Confirm Password <span className="text-red-500">*</span>
              </label>
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-purple-600 transition-colors">
                <Lock className="w-5 h-5 text-gray-400" />
                <input
                  type={showConfirmPassword ? "text" : "password"}
                  name="confirmPassword"
                  value={formData.confirmPassword}
                  onChange={handleInputChange}
                  className="flex-1 outline-none"
                  placeholder="Re-enter password"
                  required
                />
                <button onClick={() => setShowConfirmPassword(!showConfirmPassword)}>
                  {showConfirmPassword ? (
                    <EyeOff className="w-5 h-5 text-gray-400" />
                  ) : (
                    <Eye className="w-5 h-5 text-gray-400" />
                  )}
                </button>
              </div>
              {formData.password && formData.confirmPassword && formData.password !== formData.confirmPassword && (
                <p className="text-xs text-red-600 mt-1 flex items-center gap-1">
                  <AlertCircle className="w-3 h-3" />
                  Passwords do not match
                </p>
              )}
              {formData.password && formData.confirmPassword && formData.password === formData.confirmPassword && (
                <p className="text-xs text-green-600 mt-1 flex items-center gap-1">
                  <CheckCircle className="w-3 h-3" />
                  Passwords match
                </p>
              )}
            </div>
          </div>

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
              <div className="flex items-center gap-3 p-3 bg-white border border-purple-200 rounded-lg focus-within:border-purple-600 transition-colors">
                <Star className="w-5 h-5 text-gray-400" />
                <input
                  type="text"
                  name="stageName"
                  value={formData.stageName}
                  onChange={handleInputChange}
                  className="flex-1 outline-none"
                  placeholder="Your professional name"
                  required
                />
              </div>
              <p className="text-xs text-purple-700 mt-1">This is how users will see you on the platform</p>
            </div>

            {/* Bio */}
            <div>
              <label className="text-sm text-gray-600 mb-1 block">
                Bio / Description <span className="text-red-500">*</span>
              </label>
              <div className="flex items-start gap-3 p-3 bg-white border border-purple-200 rounded-lg focus-within:border-purple-600 transition-colors">
                <User className="w-5 h-5 text-gray-400 mt-1 flex-shrink-0" />
                <textarea
                  name="bio"
                  value={formData.bio}
                  onChange={handleInputChange}
                  className="flex-1 outline-none resize-none"
                  rows={4}
                  placeholder="Tell users about yourself, your interests, and what you can offer..."
                  required
                />
              </div>
              <p className="text-xs text-gray-500 mt-1">{formData.bio.length}/500 characters</p>
            </div>

            {/* Referral Agency */}
            <div>
              <label className="text-sm text-gray-600 mb-1 block">
                Referral Agency <span className="text-gray-400">(Optional)</span>
              </label>
              <div className="flex items-center gap-3 p-3 bg-white border border-purple-200 rounded-lg focus-within:border-purple-600 transition-colors">
                <Building2 className="w-5 h-5 text-gray-400" />
                <input
                  type="text"
                  name="referralAgency"
                  value={formData.referralAgency}
                  onChange={handleInputChange}
                  className="flex-1 outline-none"
                  placeholder="Enter agency name or code"
                />
              </div>
              <p className="text-xs text-gray-500 mt-1">If you were referred by an agency, enter their name or code</p>
            </div>

            {/* Experience Years */}
            <div>
              <label className="text-sm text-gray-600 mb-1 block">
                Years of Experience <span className="text-red-500">*</span>
              </label>
              <div className="flex items-center gap-3 p-3 bg-white border border-purple-200 rounded-lg focus-within:border-purple-600 transition-colors">
                <Briefcase className="w-5 h-5 text-gray-400" />
                <select
                  name="experienceYears"
                  value={formData.experienceYears}
                  onChange={handleInputChange}
                  className="flex-1 outline-none"
                  required
                >
                  <option value="">Select experience level</option>
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

          {/* Personal Information */}
          <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-4">
            <h3 className="font-semibold mb-3">Personal Information</h3>
            
            {/* First Name */}
            <div>
              <label className="text-sm text-gray-600 mb-1 block">
                First Name <span className="text-red-500">*</span>
              </label>
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-purple-600 transition-colors">
                <User className="w-5 h-5 text-gray-400" />
                <input
                  type="text"
                  name="firstName"
                  value={formData.firstName}
                  onChange={handleInputChange}
                  className="flex-1 outline-none"
                  placeholder="Enter your first name"
                  required
                />
              </div>
              <p className="text-xs text-gray-500 mt-1">Legal name as per ID (cannot be changed later)</p>
            </div>

            {/* Last Name */}
            <div>
              <label className="text-sm text-gray-600 mb-1 block">
                Last Name <span className="text-red-500">*</span>
              </label>
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-purple-600 transition-colors">
                <User className="w-5 h-5 text-gray-400" />
                <input
                  type="text"
                  name="lastName"
                  value={formData.lastName}
                  onChange={handleInputChange}
                  className="flex-1 outline-none"
                  placeholder="Enter your last name"
                  required
                />
              </div>
              <p className="text-xs text-gray-500 mt-1">Legal name as per ID (cannot be changed later)</p>
            </div>

            {/* Call Name */}
            <div>
              <label className="text-sm text-gray-600 mb-1 block">
                Call Name (Nickname) <span className="text-red-500">*</span>
              </label>
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-purple-600 transition-colors">
                <User className="w-5 h-5 text-gray-400" />
                <input
                  type="text"
                  name="callName"
                  value={formData.callName}
                  onChange={handleInputChange}
                  className="flex-1 outline-none"
                  placeholder="Your personal nickname"
                  required
                />
              </div>
              <p className="text-xs text-gray-500 mt-1">For internal use (different from stage name)</p>
            </div>

            {/* Gender */}
            <div>
              <label className="text-sm text-gray-600 mb-1 block">
                Gender <span className="text-red-500">*</span>
              </label>
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-purple-600 transition-colors">
                <Users className="w-5 h-5 text-gray-400" />
                <select
                  name="gender"
                  value={formData.gender}
                  onChange={handleInputChange}
                  className="flex-1 outline-none"
                  required
                >
                  <option value="">Select your gender</option>
                  <option value="Male">Male</option>
                  <option value="Female">Female</option>
                  <option value="Other">Other</option>
                </select>
              </div>
              <p className="text-xs text-gray-500 mt-1">Cannot be changed later</p>
            </div>

            {/* Date of Birth */}
            <div>
              <label className="text-sm text-gray-600 mb-1 block">
                Date of Birth <span className="text-red-500">*</span>
              </label>
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-purple-600 transition-colors">
                <Calendar className="w-5 h-5 text-gray-400" />
                <input
                  type="date"
                  name="dateOfBirth"
                  value={formData.dateOfBirth}
                  onChange={handleInputChange}
                  className="flex-1 outline-none"
                  required
                />
              </div>
              <p className="text-xs text-gray-500 mt-1">Must be 18+ years old. Cannot be changed later</p>
            </div>

            {/* Email */}
            <div>
              <label className="text-sm text-gray-600 mb-1 block">
                Email Address <span className="text-red-500">*</span>
              </label>
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-purple-600 transition-colors">
                <Mail className="w-5 h-5 text-gray-400" />
                <input
                  type="email"
                  name="email"
                  value={formData.email}
                  onChange={handleInputChange}
                  className="flex-1 outline-none"
                  placeholder="Enter your email"
                  required
                />
              </div>
            </div>

            {/* Phone */}
            <div>
              <label className="text-sm text-gray-600 mb-1 block">
                Phone Number <span className="text-red-500">*</span>
              </label>
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-purple-600 transition-colors">
                <Phone className="w-5 h-5 text-gray-400" />
                <input
                  type="tel"
                  name="phone"
                  value={formData.phone}
                  onChange={handleInputChange}
                  className="flex-1 outline-none"
                  placeholder="Enter your phone number"
                  required
                />
              </div>
            </div>
          </div>

          {/* Address Information */}
          <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-4">
            <h3 className="font-semibold mb-3">Address Information</h3>

            {/* Full Address */}
            <div>
              <label className="text-sm text-gray-600 mb-1 block">
                Address <span className="text-red-500">*</span>
              </label>
              <div className="flex items-start gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-purple-600 transition-colors">
                <Home className="w-5 h-5 text-gray-400 mt-1 flex-shrink-0" />
                <textarea
                  name="address"
                  value={formData.address}
                  onChange={handleInputChange}
                  className="flex-1 outline-none resize-none"
                  rows={3}
                  placeholder="Enter your full address"
                  required
                />
              </div>
            </div>

            {/* Country */}
            <div>
              <label className="text-sm text-gray-600 mb-1 block">
                Country <span className="text-red-500">*</span>
              </label>
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-purple-600 transition-colors">
                <Globe className="w-5 h-5 text-gray-400" />
                <input
                  type="text"
                  name="country"
                  value={formData.country}
                  onChange={handleInputChange}
                  className="flex-1 outline-none"
                  placeholder="Enter your country"
                  required
                />
              </div>
            </div>

            {/* City */}
            <div>
              <label className="text-sm text-gray-600 mb-1 block">
                City <span className="text-red-500">*</span>
              </label>
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-purple-600 transition-colors">
                <MapPin className="w-5 h-5 text-gray-400" />
                <input
                  type="text"
                  name="city"
                  value={formData.city}
                  onChange={handleInputChange}
                  className="flex-1 outline-none"
                  placeholder="Enter your city"
                  required
                />
              </div>
            </div>

            {/* Postcode */}
            <div>
              <label className="text-sm text-gray-600 mb-1 block">
                Postcode / ZIP Code <span className="text-red-500">*</span>
              </label>
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-purple-600 transition-colors">
                <MapPin className="w-5 h-5 text-gray-400" />
                <input
                  type="text"
                  name="postcode"
                  value={formData.postcode}
                  onChange={handleInputChange}
                  className="flex-1 outline-none"
                  placeholder="Enter your postcode"
                  required
                />
              </div>
            </div>
          </div>

          {/* Social Media (Optional) */}
          <div className="bg-white rounded-xl border border-gray-200 p-4 space-y-4">
            <h3 className="font-semibold mb-3">Social Media <span className="text-gray-400 text-sm font-normal">(Optional)</span></h3>
            <p className="text-xs text-gray-600 mb-3">Link your social media to build credibility</p>

            {/* Instagram */}
            <div>
              <label className="text-sm text-gray-600 mb-1 block">Instagram</label>
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-purple-600 transition-colors">
                <span className="text-gray-500">@</span>
                <input
                  type="text"
                  name="social_instagram"
                  value={formData.socialMedia.instagram}
                  onChange={handleInputChange}
                  className="flex-1 outline-none"
                  placeholder="username"
                />
              </div>
            </div>

            {/* Twitter */}
            <div>
              <label className="text-sm text-gray-600 mb-1 block">Twitter / X</label>
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-purple-600 transition-colors">
                <span className="text-gray-500">@</span>
                <input
                  type="text"
                  name="social_twitter"
                  value={formData.socialMedia.twitter}
                  onChange={handleInputChange}
                  className="flex-1 outline-none"
                  placeholder="username"
                />
              </div>
            </div>

            {/* TikTok */}
            <div>
              <label className="text-sm text-gray-600 mb-1 block">TikTok</label>
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-purple-600 transition-colors">
                <span className="text-gray-500">@</span>
                <input
                  type="text"
                  name="social_tiktok"
                  value={formData.socialMedia.tiktok}
                  onChange={handleInputChange}
                  className="flex-1 outline-none"
                  placeholder="username"
                />
              </div>
            </div>
          </div>

          {/* Terms & Privacy */}
          <div className="bg-purple-50 border border-purple-200 rounded-xl p-4">
            <div className="flex items-start gap-3">
              <input type="checkbox" className="mt-1" required />
              <p className="text-xs text-purple-900">
                I agree to the <span className="font-semibold underline cursor-pointer">Talent Terms of Service</span> and{" "}
                <span className="font-semibold underline cursor-pointer">Privacy Policy</span>. I confirm that I am 18 years or older and all information provided is accurate and truthful.
              </p>
            </div>
          </div>

          {/* Register Button */}
          <button 
            onClick={handleRegister}
            className="w-full bg-gradient-to-r from-purple-600 to-pink-600 text-white py-3.5 rounded-xl font-semibold hover:from-purple-700 hover:to-pink-700 transition-all shadow-lg"
          >
            Create Talent Account
          </button>

          {/* Login Link */}
          <div className="text-center">
            <p className="text-sm text-gray-600">
              Already have an account?{" "}
              <button 
                onClick={() => navigate("/")}
                className="text-purple-600 font-semibold hover:text-purple-700 transition-colors"
              >
                Login here
              </button>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}