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
  CheckCircle
} from "lucide-react";

export function Register() {
  const navigate = useNavigate();
  const [showPassword, setShowPassword] = useState(false);
  const [showConfirmPassword, setShowConfirmPassword] = useState(false);
  const [formData, setFormData] = useState({
    username: "",
    password: "",
    confirmPassword: "",
    firstName: "",
    lastName: "",
    callName: "",
    email: "",
    phone: "",
    gender: "",
    dateOfBirth: "",
    address: "",
    country: "",
    city: "",
    postcode: ""
  });

  const handleInputChange = (e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  const handleRegister = () => {
    // Add validation here
    if (formData.password !== formData.confirmPassword) {
      alert("Passwords do not match!");
      return;
    }

    // Registration logic here
    console.log("Registration data:", formData);
    
    // Navigate to home after successful registration
    navigate("/home");
  };

  return (
    <div className="min-h-screen bg-[#f5f1e8] flex justify-center items-center p-4">
      <div className="w-full max-w-md bg-white min-h-screen flex flex-col">
        {/* Header */}
        <div className="bg-gradient-to-r from-amber-600 to-orange-600 px-6 py-4 flex items-center gap-4">
          <button
            onClick={() => navigate("/")}
            className="w-10 h-10 rounded-full bg-white/20 backdrop-blur-sm flex items-center justify-center text-white hover:bg-white/30 transition-colors"
          >
            <ChevronLeft className="w-6 h-6" />
          </button>
          <h1 className="text-xl font-bold text-white">Create Account</h1>
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
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-amber-600 transition-colors">
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
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-amber-600 transition-colors">
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
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-amber-600 transition-colors">
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

            {/* Password Requirements */}
            <div className="bg-amber-50 border border-amber-200 rounded-lg p-3">
              <p className="text-xs font-medium text-amber-900 mb-1">Password Requirements:</p>
              <ul className="text-xs text-amber-700 space-y-1">
                <li>• At least 8 characters long</li>
                <li>• Include uppercase and lowercase letters</li>
                <li>• Include at least one number</li>
                <li>• Include at least one special character</li>
              </ul>
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
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-amber-600 transition-colors">
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
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-amber-600 transition-colors">
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
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-amber-600 transition-colors">
                <User className="w-5 h-5 text-gray-400" />
                <input
                  type="text"
                  name="callName"
                  value={formData.callName}
                  onChange={handleInputChange}
                  className="flex-1 outline-none"
                  placeholder="How should others call you?"
                  required
                />
              </div>
              <p className="text-xs text-gray-500 mt-1">This is how others will see your name</p>
            </div>

            {/* Gender */}
            <div>
              <label className="text-sm text-gray-600 mb-1 block">
                Gender <span className="text-red-500">*</span>
              </label>
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-amber-600 transition-colors">
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
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-amber-600 transition-colors">
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
              <p className="text-xs text-gray-500 mt-1">Cannot be changed later</p>
            </div>

            {/* Email */}
            <div>
              <label className="text-sm text-gray-600 mb-1 block">
                Email Address <span className="text-red-500">*</span>
              </label>
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-amber-600 transition-colors">
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
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-amber-600 transition-colors">
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
              <div className="flex items-start gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-amber-600 transition-colors">
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
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-amber-600 transition-colors">
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
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-amber-600 transition-colors">
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
              <div className="flex items-center gap-3 p-3 border border-gray-200 rounded-lg focus-within:border-amber-600 transition-colors">
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

          {/* Terms & Privacy */}
          <div className="bg-blue-50 border border-blue-200 rounded-xl p-4">
            <div className="flex items-start gap-3">
              <input type="checkbox" className="mt-1" required />
              <p className="text-xs text-blue-900">
                I agree to the <span className="font-semibold underline cursor-pointer">Terms of Service</span> and{" "}
                <span className="font-semibold underline cursor-pointer">Privacy Policy</span>. I confirm that all information provided is accurate and truthful.
              </p>
            </div>
          </div>

          {/* Register Button */}
          <button 
            onClick={handleRegister}
            className="w-full bg-gradient-to-r from-amber-600 to-orange-600 text-white py-3.5 rounded-xl font-semibold hover:from-amber-700 hover:to-orange-700 transition-all shadow-lg"
          >
            Create Account
          </button>

          {/* Login Link */}
          <div className="text-center">
            <p className="text-sm text-gray-600">
              Already have an account?{" "}
              <button 
                onClick={() => navigate("/")}
                className="text-amber-600 font-semibold hover:text-amber-700 transition-colors"
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
