import { useEffect, useState } from 'react';
import { useSearchParams } from 'react-router-dom';
import { Filter, ChevronDown, SlidersHorizontal, Plus } from 'lucide-react';
import { useRestaurantStore } from '../store/restaurantStore';
import { useAuthStore } from '../store/authStore';
import SearchBar from '../components/search/SearchBar';
import RestaurantCard from '../components/restaurant/RestaurantCard';
import AddRestaurantForm from '../components/restaurant/AddRestaurantForm';
import Button from '../components/ui/Button';
import LoadingSpinner from '../components/ui/LoadingSpinner';
import { supabase } from '../lib/supabase';
import { UserRole } from '../types/auth';

function SearchPage() {
  const [searchParams] = useSearchParams();
  const { 
    filteredRestaurants, 
    searchRestaurants, 
    isLoading, 
    getAvailableTimes,
    fetchRestaurants
  } = useRestaurantStore();
  const { user } = useAuthStore();
  
  const [showFilters, setShowFilters] = useState(false);
  const [showAddForm, setShowAddForm] = useState(false);
  const [selectedCuisine, setSelectedCuisine] = useState<string | null>(null);
  const [selectedPrice, setSelectedPrice] = useState<string | null>(null);
  
  // Get search parameters
  const date = searchParams.get('date') || '';
  const time = searchParams.get('time') || '';
  const people = parseInt(searchParams.get('people') || '2');
  const location = searchParams.get('location') || '';
  const cuisine = searchParams.get('cuisine') || '';
  
  // Get all unique cuisines from all restaurants
  const cuisines = [...new Set(
    filteredRestaurants.flatMap(r => r.cuisine)
  )].sort();
  
  // Determine if search is by name or location
  const isNameSearch = location && filteredRestaurants.some(r => 
    r.name.toLowerCase().includes(location.toLowerCase())
  );
  
  useEffect(() => {
    // Update selected cuisine when URL param changes
    setSelectedCuisine(cuisine || null);
  }, [cuisine]);
  
  useEffect(() => {
    // Call search API with params from URL
    searchRestaurants({
      date,
      time,
      people,
      location,
      cuisine: selectedCuisine || cuisine,
      price: selectedPrice
    });
  }, [
    searchRestaurants, 
    date, 
    time, 
    people, 
    location, 
    cuisine, 
    selectedCuisine, 
    selectedPrice
  ]);

  const handleDeleteRestaurant = async (restaurantId: string) => {
    try {
      // First, delete all pending and confirmed bookings for this restaurant
      const { error: bookingsError } = await supabase
        .from('bookings')
        .delete()
        .eq('restaurant_id', restaurantId)
        .in('status', ['pending', 'confirmed']);

      if (bookingsError) throw bookingsError;

      // Then delete the restaurant
      const { error: restaurantError } = await supabase
        .from('restaurants')
        .delete()
        .eq('id', restaurantId);

      if (restaurantError) throw restaurantError;

      // Refresh the restaurants list
      fetchRestaurants();
    } catch (error) {
      console.error('Error deleting restaurant:', error);
      alert('Failed to delete restaurant. Please try again.');
    }
  };
  
  // Get availability times for each restaurant
  const getRestaurantAvailability = (restaurantId: string) => {
    if (!date) return [];
    return getAvailableTimes(restaurantId, date, people);
  };
  
  return (
    <div className="container mx-auto px-4 py-8">
      <div className="mb-8">
        <SearchBar />
      </div>

      {/* Add Restaurant Button */}
      <div className="mb-6 flex justify-end">
        <Button
          onClick={() => setShowAddForm(!showAddForm)}
          className="flex items-center gap-2"
        >
          {showAddForm ? 'Close Form' : (
            <>
              <Plus className="h-5 w-5" />
              Add Your Restaurant
            </>
          )}
        </Button>
      </div>

      {/* Add Restaurant Form */}
      {showAddForm && (
        <div className="mb-8">
          <AddRestaurantForm />
        </div>
      )}
      
      <div className="flex flex-col md:flex-row gap-6">
        {/* Filters sidebar (desktop) */}
        <div className="hidden md:block w-64 flex-shrink-0">
          <div className="bg-white rounded-lg shadow-md p-4">
            <h2 className="text-lg font-bold text-gray-900 mb-4 flex items-center">
              <Filter className="h-5 w-5 mr-2" />
              Filters
            </h2>
            
            {/* Cuisine filter */}
            <div className="mb-6">
              <h3 className="font-medium text-gray-800 mb-2">Cuisine</h3>
              <div className="space-y-2">
                <div className="flex items-center">
                  <input
                    type="radio"
                    id="all-cuisines"
                    name="cuisine"
                    checked={!selectedCuisine}
                    onChange={() => setSelectedCuisine(null)}
                    className="h-4 w-4 text-primary-600 focus:ring-primary-500"
                  />
                  <label htmlFor="all-cuisines" className="ml-2 text-sm text-gray-700">
                    All Cuisines
                  </label>
                </div>
                
                {cuisines.map((cuisine) => (
                  <div key={cuisine} className="flex items-center">
                    <input
                      type="radio"
                      id={`cuisine-${cuisine}`}
                      name="cuisine"
                      checked={selectedCuisine === cuisine}
                      onChange={() => setSelectedCuisine(cuisine)}
                      className="h-4 w-4 text-primary-600 focus:ring-primary-500"
                    />
                    <label htmlFor={`cuisine-${cuisine}`} className="ml-2 text-sm text-gray-700">
                      {cuisine}
                    </label>
                  </div>
                ))}
              </div>
            </div>
            
            {/* Price filter */}
            <div className="mb-4">
              <h3 className="font-medium text-gray-800 mb-2">Price Range</h3>
              <div className="space-y-2">
                <div className="flex items-center">
                  <input
                    type="radio"
                    id="all-prices"
                    name="price"
                    checked={!selectedPrice}
                    onChange={() => setSelectedPrice(null)}
                    className="h-4 w-4 text-primary-600 focus:ring-primary-500"
                  />
                  <label htmlFor="all-prices" className="ml-2 text-sm text-gray-700">
                    All Prices
                  </label>
                </div>
                
                {['$', '$$', '$$$', '$$$$'].map((price, index) => (
                  <div key={price} className="flex items-center">
                    <input
                      type="radio"
                      id={`price-${index + 1}`}
                      name="price"
                      checked={selectedPrice === price}
                      onChange={() => setSelectedPrice(price)}
                      className="h-4 w-4 text-primary-600 focus:ring-primary-500"
                    />
                    <label htmlFor={`price-${index + 1}`} className="ml-2 text-sm text-gray-700">
                      {price}
                    </label>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
        
        {/* Mobile filters button */}
        <div className="md:hidden mb-4">
          <button
            onClick={() => setShowFilters(!showFilters)}
            className="flex items-center justify-between w-full bg-white rounded-lg shadow-sm p-3 border border-gray-200"
          >
            <div className="flex items-center">
              <SlidersHorizontal className="h-5 w-5 mr-2 text-gray-700" />
              <span className="font-medium">Filters</span>
            </div>
            <ChevronDown className={`h-5 w-5 transition-transform ${showFilters ? 'rotate-180' : ''}`} />
          </button>
          
          {/* Mobile filters dropdown */}
          {showFilters && (
            <div className="bg-white rounded-lg shadow-md mt-2 p-4 border border-gray-200">
              {/* Cuisine filter */}
              <div className="mb-6">
                <h3 className="font-medium text-gray-800 mb-2">Cuisine</h3>
                <div className="space-y-2">
                  <div className="flex items-center">
                    <input
                      type="radio"
                      id="mobile-all-cuisines"
                      name="mobile-cuisine"
                      checked={!selectedCuisine}
                      onChange={() => setSelectedCuisine(null)}
                      className="h-4 w-4 text-primary-600 focus:ring-primary-500"
                    />
                    <label htmlFor="mobile-all-cuisines" className="ml-2 text-sm text-gray-700">
                      All Cuisines
                    </label>
                  </div>
                  
                  {cuisines.map((cuisine) => (
                    <div key={`mobile-${cuisine}`} className="flex items-center">
                      <input
                        type="radio"
                        id={`mobile-cuisine-${cuisine}`}
                        name="mobile-cuisine"
                        checked={selectedCuisine === cuisine}
                        onChange={() => setSelectedCuisine(cuisine)}
                        className="h-4 w-4 text-primary-600 focus:ring-primary-500"
                      />
                      <label htmlFor={`mobile-cuisine-${cuisine}`} className="ml-2 text-sm text-gray-700">
                        {cuisine}
                      </label>
                    </div>
                  ))}
                </div>
              </div>
              
              {/* Price filter */}
              <div className="mb-4">
                <h3 className="font-medium text-gray-800 mb-2">Price Range</h3>
                <div className="space-y-2">
                  <div className="flex items-center">
                    <input
                      type="radio"
                      id="mobile-all-prices"
                      name="mobile-price"
                      checked={!selectedPrice}
                      onChange={() => setSelectedPrice(null)}
                      className="h-4 w-4 text-primary-600 focus:ring-primary-500"
                    />
                    <label htmlFor="mobile-all-prices" className="ml-2 text-sm text-gray-700">
                      All Prices
                    </label>
                  </div>
                  
                  {['$', '$$', '$$$', '$$$$'].map((price, index) => (
                    <div key={`mobile-${price}`} className="flex items-center">
                      <input
                        type="radio"
                        id={`mobile-price-${index + 1}`}
                        name="mobile-price"
                        checked={selectedPrice === price}
                        onChange={() => setSelectedPrice(price)}
                        className="h-4 w-4 text-primary-600 focus:ring-primary-500"
                      />
                      <label htmlFor={`mobile-price-${index + 1}`} className="ml-2 text-sm text-gray-700">
                        {price}
                      </label>
                    </div>
                  ))}
                </div>
              </div>
            </div>
          )}
        </div>
        
        {/* Restaurant results */}
        <div className="flex-1">
          {/* Results header */}
          <div className="mb-6">
            <h1 className="text-2xl font-bold text-gray-900 mb-2">
              {filteredRestaurants.length > 0 
                ? `${filteredRestaurants.length} restaurants available`
                : 'Restaurants'
              }
            </h1>
            {(location || selectedCuisine || selectedPrice) && (
              <p className="text-gray-600">
                {location && (isNameSearch 
                  ? `Search results for "${location}"`
                  : `Near ${location}`
                )}
                {selectedCuisine && (location ? ` • ${selectedCuisine}` : selectedCuisine)}
                {selectedPrice && 
                  ((location || selectedCuisine) ? ` • ${selectedPrice}` : selectedPrice)
                }
              </p>
            )}
          </div>
          
          {isLoading ? (
            <LoadingSpinner />
          ) : filteredRestaurants.length === 0 ? (
            <div className="bg-white rounded-lg shadow-md p-8 text-center">
              <h3 className="text-xl font-semibold text-gray-800 mb-2">No restaurants found</h3>
              <p className="text-gray-600 mb-4">
                Try adjusting your search filters or try a different location.
              </p>
            </div>
          ) : (
            <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
              {filteredRestaurants.map(restaurant => (
                <RestaurantCard 
                  key={restaurant.id} 
                  restaurant={restaurant}
                  availableTimes={getRestaurantAvailability(restaurant.id)}
                  date={date}
                  people={people}
                  onDelete={user?.role === UserRole.ADMIN ? handleDeleteRestaurant : undefined}
                />
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

export default SearchPage;