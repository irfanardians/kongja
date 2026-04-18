import { Home, MessageCircle, BarChart3, User } from "lucide-react";
import { useNavigate, useLocation } from "react-router";

export function TalentBottomNav() {
  const navigate = useNavigate();
  const location = useLocation();

  const navItems = [
    { icon: Home, label: "Home", path: "/talent-home" },
    { icon: MessageCircle, label: "Chats", path: "/talent-messages" },
    { icon: BarChart3, label: "Analytics", path: "/talent-analytics" },
    { icon: User, label: "Profile", path: "/talent-profile" },
  ];

  const isActive = (path: string) => {
    if (path === "/talent-home") {
      return location.pathname === "/talent-home";
    }
    return location.pathname.startsWith(path);
  };

  return (
    <nav className="fixed bottom-0 left-0 right-0 bg-white border-t border-gray-200 z-50">
      <div className="max-w-md mx-auto flex items-center justify-around px-6 py-3">
        {navItems.map((item) => {
          const active = isActive(item.path);
          return (
            <button
              key={item.path}
              onClick={() => navigate(item.path)}
              className={`flex flex-col items-center gap-1 transition-colors ${
                active ? "text-amber-700" : "text-gray-400"
              }`}
            >
              <item.icon className={`w-6 h-6 ${active ? "fill-amber-100" : ""}`} />
              <span className="text-xs font-medium">{item.label}</span>
            </button>
          );
        })}
      </div>
    </nav>
  );
}
