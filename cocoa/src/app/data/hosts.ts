export interface Host {
  id: number;
  name: string;
  age: number;
  description: string;
  rating: number;
  reviewCount: number;
  pricePerMin: number;
  image: string;
  badges: string[];
  isOnline: boolean;
  category: "top" | "new";
  country: string;
  location?: string;
  city?: string;
  portfolio: string[];
}

export const hosts: Host[] = [
  {
    id: 1,
    name: "Clara",
    age: 24,
    description: "Sweet & Caring",
    rating: 4.9,
    reviewCount: 121,
    pricePerMin: 30,
    image: "https://images.unsplash.com/photo-1761933808230-9a2e78956daa?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMGFzaWFuJTIwd29tYW4lMjBzbWlsaW5nJTIwcG9ydHJhaXR8ZW58MXx8fHwxNzc2MjMxNTg5fDA&ixlib=rb-4.1.0&q=80&w=1080",
    badges: ["#Funny", "Good Listener", "Loves Movies"],
    isOnline: true,
    category: "top",
    country: "PH",
    city: "Manila",
    location: "Manila, Philippines",
    portfolio: [
      "https://images.unsplash.com/photo-1761933808230-9a2e78956daa?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMGFzaWFuJTIwd29tYW4lMjBzbWlsaW5nJTIwcG9ydHJhaXR8ZW58MXx8fHwxNzc2MjMxNTg5fDA&ixlib=rb-4.1.0&q=80&w=1080",
      "https://images.unsplash.com/photo-1755143605418-f3f8955e4f5a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMGFzaWFuJTIwd29tYW4lMjBwb3J0cmFpdCUyMHNtaWxpbmclMjBsaWZlc3R5bGV8ZW58MXx8fHwxNzc2MzM3MjI2fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
      "https://images.unsplash.com/photo-1764642574254-bc89c96dfae2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMGFzaWFuJTIwd29tYW4lMjBmYXNoaW9uJTIwc3R5bGV8ZW58MXx8fHwxNzc2MzM3MjI3fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
      "https://images.unsplash.com/photo-1675275372275-0a5e5f0a9fa6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwcG9ydHJhaXQlMjBjb2ZmZWUlMjBzaG9wfGVufDF8fHx8MTc3NjMzNzIzMHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
      "https://images.unsplash.com/photo-1758467796950-1da4615c97b5?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwbmF0dXJlJTIwb3V0ZG9vciUyMHNtaWxlfGVufDF8fHx8MTc3NjMzNzIzMnww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
    ],
  },
  {
    id: 2,
    name: "Vina",
    age: 29,
    description: "Playful Cat",
    rating: 4.8,
    reviewCount: 98,
    pricePerMin: 30,
    image: "https://images.unsplash.com/photo-1710301660960-ffaa9f6ab108?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwYnJ1bmV0dGUlMjBwb3J0cmFpdHxlbnwxfHx8fDE3NzYzMjg5NjN8MA&ixlib=rb-4.1.0&q=80&w=1080",
    badges: ["#Caring", "Good Listener", "Loves Music"],
    isOnline: true,
    category: "top",
    country: "ID",
    city: "Jakarta",
    location: "Jakarta, Indonesia",
    portfolio: [
      "https://images.unsplash.com/photo-1710301660960-ffaa9f6ab108?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwYnJ1bmV0dGUlMjBwb3J0cmFpdHxlbnwxfHx8fDE3NzYzMjg5NjN8MA&ixlib=rb-4.1.0&q=80&w=1080",
      "https://images.unsplash.com/photo-1762343040706-b74ea936c1c0?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMGJydW5ldHRlJTIwd29tYW4lMjBwb3J0cmFpdCUyMGVsZWdhbnR8ZW58MXx8fHwxNzc2MzM3MjI3fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
      "https://images.unsplash.com/photo-1773955779694-42b1fba71f72?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMGJydW5ldHRlJTIwd29tYW4lMjBjYXN1YWwlMjBsaWZlc3R5bGV8ZW58MXx8fHwxNzc2MzM3MjI3fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
      "https://images.unsplash.com/photo-1760552068247-fe39fc60e1c1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwcmVhZGluZyUyMGJvb2slMjBjb3p5fGVufDF8fHx8MTc3NjMzNzIzMXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
    ],
  },
  {
    id: 3,
    name: "Mia",
    age: 25,
    description: "Elegant & Fun",
    rating: 4.7,
    reviewCount: 87,
    pricePerMin: 30,
    image: "https://images.unsplash.com/photo-1557353425-e322f6eb9559?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwYmxvbmRlJTIwcG9ydHJhaXR8ZW58MXx8fHwxNzc2MjY0MTk3fDA&ixlib=rb-4.1.0&q=80&w=1080",
    badges: ["#Adventurous", "Good Listener", "Loves Travel"],
    isOnline: false,
    category: "top",
    country: "US",
    city: "Los Angeles",
    location: "Los Angeles, USA",
    portfolio: [
      "https://images.unsplash.com/photo-1557353425-e322f6eb9559?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwYmxvbmRlJTIwcG9ydHJhaXR8ZW58MXx8fHwxNzc2MjY0MTk3fDA&ixlib=rb-4.1.0&q=80&w=1080",
      "https://images.unsplash.com/photo-1762522921456-cdfe882d36c3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMGJsb25kZSUyMHdvbWFuJTIwcG9ydHJhaXQlMjBwcm9mZXNzaW9uYWx8ZW58MXx8fHwxNzc2MzM3MjI3fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
      "https://images.unsplash.com/photo-1556982962-e61838e098c6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwYmVhY2glMjBzdW5zZXQlMjBwb3J0cmFpdHxlbnwxfHx8fDE3NzYzMzcyMzF8MA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
      "https://images.unsplash.com/photo-1759414515940-8960674b4496?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwY2l0eSUyMHN0cmVldCUyMGZhc2hpb258ZW58MXx8fHwxNzc2MzM3MjMxfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
    ],
  },
  {
    id: 4,
    name: "Dinda",
    age: 24,
    description: "Kind Hearted",
    rating: 4.9,
    reviewCount: 156,
    pricePerMin: 20,
    image: "https://images.unsplash.com/photo-1705830337569-47a1a24b0ad2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwY2FzdWFsJTIwcG9ydHJhaXR8ZW58MXx8fHwxNzY2MjU2MzUwfDA&ixlib=rb-4.1.0&q=80&w=1080",
    badges: ["#Funny", "Good Listener", "Loves Books"],
    isOnline: true,
    category: "new",
    country: "VN",
    city: "Ho Chi Minh City",
    location: "Ho Chi Minh City, Vietnam",
    portfolio: [
      "https://images.unsplash.com/photo-1705830337569-47a1a24b0ad2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwY2FzdWFsJTIwcG9ydHJhaXR8ZW58MXx8fHwxNzY2MjU2MzUwfDA&ixlib=rb-4.1.0&q=80&w=1080",
      "https://images.unsplash.com/photo-1760552068247-fe39fc60e1c1?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwcmVhZGluZyUyMGJvb2slMjBjb3p5fGVufDF8fHx8MTc3NjMzNzIzMXww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
      "https://images.unsplash.com/photo-1675275372275-0a5e5f0a9fa6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwcG9ydHJhaXQlMjBjb2ZmZWUlMjBzaG9wfGVufDF8fHx8MTc3NjMzNzIzMHww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
    ],
  },
  {
    id: 5,
    name: "Rika",
    age: 23,
    description: "Sweet Smile",
    rating: 4.8,
    reviewCount: 92,
    pricePerMin: 30,
    image: "https://images.unsplash.com/photo-1755143605418-f3f8955e4f5a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMGFzaWFuJTIwd29tYW4lMjBjYXN1YWx8ZW58MXx8fHwxNzc2MzI4OTY0fDA&ixlib=rb-4.1.0&q=80&w=1080",
    badges: ["#Caring", "Good Listener", "Loves Art"],
    isOnline: true,
    category: "new",
    country: "JP",
    city: "Tokyo",
    location: "Tokyo, Japan",
    portfolio: [
      "https://images.unsplash.com/photo-1755143605418-f3f8955e4f5a?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMGFzaWFuJTIwd29tYW4lMjBjYXN1YWx8ZW58MXx8fHwxNzc2MzI4OTY0fDA&ixlib=rb-4.1.0&q=80&w=1080",
      "https://images.unsplash.com/photo-1764642574254-bc89c96dfae2?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMGFzaWFuJTIwd29tYW4lMjBmYXNoaW9uJTIwc3R5bGV8ZW58MXx8fHwxNzc2MzM3MjI3fDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
      "https://images.unsplash.com/photo-1758467796950-1da4615c97b5?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwbmF0dXJlJTIwb3V0ZG9vciUyMHNtaWxlfGVufDF8fHx8MTc3NjMzNzIzMnww&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
    ],
  },
  {
    id: 6,
    name: "Elsa",
    age: 23,
    description: "Cheerful Soul",
    rating: 4.6,
    reviewCount: 73,
    pricePerMin: 30,
    image: "https://images.unsplash.com/photo-1762522921456-cdfe882d36c3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwaGVhZHNob3QlMjBwcm9mZXNzaW9uYWx8ZW58MXx8fHwxNzc2MzI4OTY4fDA&ixlib=rb-4.1.0&q=80&w=1080",
    badges: ["#Funny", "Good Listener", "Loves Sports"],
    isOnline: true,
    category: "new",
    country: "TH",
    city: "Bangkok",
    location: "Bangkok, Thailand",
    portfolio: [
      "https://images.unsplash.com/photo-1762522921456-cdfe882d36c3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwaGVhZHNob3QlMjBwcm9mZXNzaW9uYWx8ZW58MXx8fHwxNzc2MzI4OTY4fDA&ixlib=rb-4.1.0&q=80&w=1080",
      "https://images.unsplash.com/photo-1758599878766-a14043b42ec3?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwd29ya291dCUyMGZpdG5lc3MlMjBhY3RpdmV8ZW58MXx8fHwxNzc2MzM3MjMyfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
      "https://images.unsplash.com/photo-1759414515940-8960674b4496?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx5b3VuZyUyMHdvbWFuJTIwY2l0eSUyMHN0cmVldCUyMGZhc2hpb258ZW58MXx8fHwxNzc2MzM3MjMxfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral",
    ],
  },
];