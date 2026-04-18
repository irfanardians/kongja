import { useRouteError, useNavigate } from "react-router";
import { AlertCircle, Home } from "lucide-react";

export function ErrorPage() {
  const error = useRouteError() as any;
  const navigate = useNavigate();

  return (
    <div className="min-h-screen bg-[#f5f1e8] flex justify-center items-center p-4">
      <div className="w-full max-w-md bg-white min-h-screen flex flex-col items-center justify-center p-8">
        <div className="w-20 h-20 bg-red-100 rounded-full flex items-center justify-center mb-6">
          <AlertCircle className="w-12 h-12 text-red-600" />
        </div>
        <h1 className="text-2xl font-bold text-gray-800 mb-2">Oops! Something went wrong</h1>
        <p className="text-gray-600 text-center mb-6">
          {error?.statusText || error?.message || "An unexpected error occurred"}
        </p>
        <button
          onClick={() => navigate("/")}
          className="bg-gradient-to-r from-purple-600 to-purple-500 text-white px-8 py-3 rounded-full font-semibold flex items-center gap-2 hover:shadow-lg transition-all"
        >
          <Home className="w-5 h-5" />
          Go Home
        </button>
      </div>
    </div>
  );
}
