import { useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { UtensilsCrossed, Utensils, Clock, MapPin } from 'lucide-react';
import { useRestaurantStore } from '../store/restaurantStore';
import SearchBar from '../components/search/SearchBar';
import RestaurantCard from '../components/restaurant/RestaurantCard';
import Button from '../components/ui/Button';

function HomePage() {
  const { restaurants, fetchRestaurants, isLoading } = useRestaurantStore();
  const navigate = useNavigate();
  
  useEffect(() => {
    fetchRestaurants();
  }, [fetchRestaurants]);
  
  // Get 3 featured restaurants (highest rated)
  const featuredRestaurants = [...restaurants]
    .sort((a, b) => b.rating - a.rating)
    .slice(0, 3);
  
  const topCuisines = [
    { name: 'Italian', image: 'https://images.pexels.com/photos/1527603/pexels-photo-1527603.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940' },
    { name: 'Japanese', image: 'https://images.pexels.com/photos/2098085/pexels-photo-2098085.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940' },
    { name: 'Mexican', image: 'https://images.pexels.com/photos/2092507/pexels-photo-2092507.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940' },
    { name: 'Vegan', image: 'https://images.pexels.com/photos/1095550/pexels-photo-1095550.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940' }
  ];
  
  return (
    <div>
      {/* Hero Section */}
      <section className="relative h-96 overflow-hidden mb-12">
        <div className="absolute inset-0">
          <img 
            src="https://images.pexels.com/photos/67468/pexels-photo-67468.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=650&w=940" 
            alt="Restaurant dining" 
            className="w-full h-full object-cover"
          />
          <div className="absolute inset-0 bg-gradient-to-r from-black/70 to-black/30"></div>
        </div>
        
        <div className="relative container mx-auto px-4 h-full flex flex-col justify-center">
          <h1 className="text-3xl md:text-5xl font-bold text-white mb-4 max-w-2xl animate-fade-in">
            Discover and book the perfect table.
          </h1>
          <p className="text-xl text-gray-200 mb-8 max-w-lg animate-fade-in">
            Find and reserve tables at top restaurants in your area.
          </p>
          
          <div className="max-w-4xl animate-slide-up">
            <SearchBar />
          </div>
        </div>
      </section>
      
      {/* Featured Restaurants */}
      <section className="container mx-auto px-4 mb-16">
        <div className="flex justify-between items-center mb-8">
          <h2 className="text-2xl font-bold text-gray-900">Featured Restaurants</h2>
          <Link to="/search" className="text-blue-600 hover:text-blue-800 font-medium">
            View all
          </Link>
        </div>
        
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {featuredRestaurants.map(restaurant => (
            <RestaurantCard 
              key={restaurant.id} 
              restaurant={restaurant} 
            />
          ))}
        </div>
      </section>
      
      {/* Browse by Cuisine */}
      <section className="bg-gray-50 py-12 mb-16">
        <div className="container mx-auto px-4">
          <h2 className="text-2xl font-bold text-gray-900 mb-8 text-center">
            Browse by Cuisine
          </h2>
          
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {topCuisines.map((cuisine, index) => (
              <div 
                key={index}
                onClick={() => navigate(`/search?cuisine=${cuisine.name}`)}
                className="relative h-36 md:h-64 rounded-lg overflow-hidden cursor-pointer group"
              >
                <img 
                  src={cuisine.image} 
                  alt={cuisine.name} 
                  className="w-full h-full object-cover transition-transform duration-500 group-hover:scale-110"
                />
                <div className="absolute inset-0 bg-black/40 group-hover:bg-black/50 transition-colors duration-300"></div>
                <div className="absolute inset-0 flex items-center justify-center">
                  <span className="text-lg md:text-xl font-bold text-white">
                    {cuisine.name}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>
      
      {/* How it works */}
      <section className="container mx-auto px-4 mb-16">
        <h2 className="text-2xl font-bold text-gray-900 mb-12 text-center">
          How BookTable Works
        </h2>
        
        <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
          <div className="text-center p-6">
            <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <Utensils className="h-8 w-8 text-blue-600" />
            </div>
            <h3 className="text-xl font-semibold mb-3">Search Restaurants</h3>
            <p className="text-gray-600">
              Find restaurants by location, cuisine, or availability.
            </p>
          </div>
          
          <div className="text-center p-6">
            <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <Clock className="h-8 w-8 text-blue-600" />
            </div>
            <h3 className="text-xl font-semibold mb-3">Select a Time</h3>
            <p className="text-gray-600">
              Browse available time slots and choose what works for you.
            </p>
          </div>
          
          <div className="text-center p-6">
            <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center mx-auto mb-4">
              <MapPin className="h-8 w-8 text-blue-600" />
            </div>
            <h3 className="text-xl font-semibold mb-3">Dine Out</h3>
            <p className="text-gray-600">
              Receive confirmation and enjoy your dining experience.
            </p>
          </div>
        </div>
      </section>
      
      {/* Join as Restaurant CTA */}
      <section className="bg-blue-600 py-16 text-white">
        <div className="container mx-auto px-4 text-center">
          <div className="flex items-center justify-center mb-6">
            <UtensilsCrossed className="h-12 w-12" />
          </div>
          <h2 className="text-3xl font-bold mb-6">
            Are you a restaurant owner?
          </h2>
          <p className="text-xl mb-8 max-w-2xl mx-auto">
            Join BookTable and connect with thousands of potential customers.
          </p>
          <div>
            <Link to="/register">
              <Button 
                variant="outline" 
                size="lg" 
                className="border-white text-white hover:bg-white/10"
              >
                Join as a Restaurant
              </Button>
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
}

export default HomePage;