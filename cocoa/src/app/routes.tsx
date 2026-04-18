import { createBrowserRouter } from "react-router";
import { Login } from "./pages/Login";
import { Register } from "./pages/Register";
import { RegisterTalent } from "./pages/RegisterTalent";
import { Home } from "./pages/Home";
import { TalentHome } from "./pages/TalentHome";
import { TalentMessages } from "./pages/TalentMessages";
import { TalentAnalytics } from "./pages/TalentAnalytics";
import { TalentProfile } from "./pages/TalentProfile";
import { TalentChat } from "./pages/TalentChat";
import { TalentReviews } from "./pages/TalentReviews";
import { TalentSchedule } from "./pages/TalentSchedule";
import { TalentSettings } from "./pages/TalentSettings";
import { Profile } from "./pages/Profile";
import { Chat } from "./pages/Chat";
import { Messages } from "./pages/Messages";
import { Favorites } from "./pages/Favorites";
import { UserProfile } from "./pages/UserProfile";
import { TopUp } from "./pages/TopUp";
import { Settings } from "./pages/Settings";
import { ReviewTalent } from "./pages/ReviewTalent";
import { TransactionHistory } from "./pages/TransactionHistory";
import { ErrorPage } from "./pages/ErrorPage";

export const router = createBrowserRouter([
  {
    path: "/",
    Component: Login,
    ErrorBoundary: ErrorPage,
  },
  {
    path: "/register",
    Component: Register,
    ErrorBoundary: ErrorPage,
  },
  {
    path: "/register-talent",
    Component: RegisterTalent,
    ErrorBoundary: ErrorPage,
  },
  {
    path: "/home",
    Component: Home,
    ErrorBoundary: ErrorPage,
  },
  {
    path: "/talent-home",
    Component: TalentHome,
    ErrorBoundary: ErrorPage,
  },
  {
    path: "/talent-messages",
    Component: TalentMessages,
    ErrorBoundary: ErrorPage,
  },
  {
    path: "/talent-analytics",
    Component: TalentAnalytics,
    ErrorBoundary: ErrorPage,
  },
  {
    path: "/talent-profile",
    Component: TalentProfile,
    ErrorBoundary: ErrorPage,
  },
  {
    path: "/talent-chat/:id",
    Component: TalentChat,
    ErrorBoundary: ErrorPage,
  },
  {
    path: "/talent-reviews",
    Component: TalentReviews,
    ErrorBoundary: ErrorPage,
  },
  {
    path: "/talent-schedule",
    Component: TalentSchedule,
    ErrorBoundary: ErrorPage,
  },
  {
    path: "/talent-settings",
    Component: TalentSettings,
    ErrorBoundary: ErrorPage,
  },
  {
    path: "/profile/:id",
    Component: Profile,
    ErrorBoundary: ErrorPage,
  },
  {
    path: "/chat/:id",
    Component: Chat,
    ErrorBoundary: ErrorPage,
  },
  {
    path: "/messages",
    Component: Messages,
    ErrorBoundary: ErrorPage,
  },
  {
    path: "/favorites",
    Component: Favorites,
    ErrorBoundary: ErrorPage,
  },
  {
    path: "/profile",
    Component: UserProfile,
    ErrorBoundary: ErrorPage,
  },
  {
    path: "/top-up",
    Component: TopUp,
    ErrorBoundary: ErrorPage,
  },
  {
    path: "/settings",
    Component: Settings,
    ErrorBoundary: ErrorPage,
  },
  {
    path: "/review-talent",
    Component: ReviewTalent,
    ErrorBoundary: ErrorPage,
  },
  {
    path: "/transaction-history",
    Component: TransactionHistory,
    ErrorBoundary: ErrorPage,
  },
]);