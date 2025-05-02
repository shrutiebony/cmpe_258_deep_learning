import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import { MapPin, Clock, Phone, Mail, Users, Calendar, UtensilsCrossed, ChevronLeft, ChevronRight } from 'lucide-react';
import StarRating from '../components/ui/StarRating';
import PriceRange from '../components/ui/PriceRange';
import AddReviewForm from '../components/restaurant/AddReviewForm';
import ReviewCard from '../components/restaurant/ReviewCard';
import Button from '../components/ui/Button';
import LoadingSpinner from '../components/ui/LoadingSpinner';
import { useAuthStore } from '../store/authStore';
import { useRestaurantStore } from '../store/restaurantStore';
import { useReviewStore } from '../store/reviewStore';
import { Restaurant } from '../types/restaurant';
import { Review } from '../types/review';
import { UserRole } from '../types/auth';
import { formatTime } from '../utils/dateUtils';

// UUID validation regex
const UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i;

function RestaurantPage() {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const [restaurant, setRestaurant] = useState<Restaurant | null>(null);
  const [reviews, setReviews] = useState<Review[]>([]);
  const [selectedDate, setSelectedDate] = useState(new Date().toISOString().split('T')[0]);
  const [selectedTime, setSelectedTime] = useState<string | null>(null);
  const [partySize, setPartySize] = useState(2);
  const [availableTimes, setAvailableTimes] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);
  const [currentImageIndex, setCurrentImageIndex] = useState(0);

  const { user } = useAuthStore();
  const { getRestaurantById, getAvailableTimes } = useRestaurantStore();
  const { getReviewsByRestaurantId } = useReviewStore();

  useEffect(() => {
    if (!id) return;

    const loadRestaurantData = async () => {
      setLoading(true);
      const restaurantData = await getRestaurantById(id);
      setRestaurant(restaurantData);

      if (restaurantData) {
        const times = getAvailableTimes(id, selectedDate, partySize);
        setAvailableTimes(times);

        // Only fetch reviews if the ID is a valid UUID
        if (UUID_REGEX.test(id)) {
          const restaurantReviews = await getReviewsByRestaurantId(id);
          setReviews(restaurantReviews);
        }
      }

      setLoading(false);
    };

    loadRestaurantData();
  }, [id, selectedDate, partySize, getRestaurantById, getReviewsByRestaurantId, getAvailableTimes]);

  const handleTimeSelect = (time: string) => {
    setSelectedTime(time);
    if (user?.role === UserRole.CUSTOMER) {
      navigate(`/booking/${id}?date=${selectedDate}&time=${time}&people=${partySize}`);
    } else {
      navigate('/login');
    }
  };

  const nextImage = () => {
    if (restaurant) {
      setCurrentImageIndex((prev) => 
        prev === restaurant.images.length - 1 ? 0 : prev + 1
      );
    }
  };

  const previousImage = () => {
    if (restaurant) {
      setCurrentImageIndex((prev) => 
        prev === 0 ? restaurant.images.length - 1 : prev - 1
      );
    }
  };

  if (loading) {
    return (
      <div className="container mx-auto px-4 py-8">
        <LoadingSpinner />
      </div>
    );
  }

  if (!restaurant) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="text-center">
          <UtensilsCrossed className="h-12 w-12 text-gray-400 mx-auto mb-4" />
          <h2 className="text-2xl font-bold text-gray-900 mb-2">Restaurant Not Found</h2>
          <p className="text-gray-600 mb-4">The restaurant you're looking for doesn't exist or has been removed.</p>
          <Button onClick={() => navigate('/search')}>Find Other Restaurants</Button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50">
      {/* Image Gallery */}
      <div className="relative h-[70vh] bg-black">
        <img
          src={restaurant.images[currentImageIndex]}
          alt={`${restaurant.name} - Image ${currentImageIndex + 1}`}
          className="w-full h-full object-cover opacity-90"
        />
        
        {/* Image Navigation */}
        <div className="absolute inset-0 flex items-center justify-between px-4">
          <button
            onClick={previousImage}
            className="p-2 rounded-full bg-black/50 text-white hover:bg-black/70 transition-colors"
          >
            <ChevronLeft className="h-8 w-8" />
          </button>
          <button
            onClick={nextImage}
            className="p-2 rounded-full bg-black/50 text-white hover:bg-black/70 transition-colors"
          >
            <ChevronRight className="h-8 w-8" />
          </button>
        </div>

        {/* Image Counter */}
        <div className="absolute bottom-4 left-1/2 -translate-x-1/2 bg-black/50 text-white px-3 py-1 rounded-full text-sm">
          {currentImageIndex + 1} / {restaurant.images.length}
        </div>

        {/* Restaurant Info Overlay */}
        <div className="absolute bottom-0 inset-x-0 bg-gradient-to-t from-black/80 to-transparent p-8">
          <div className="container mx-auto">
            <h1 className="text-4xl font-bold text-white mb-2">{restaurant.name}</h1>
            <div className="flex items-center gap-4 text-white mb-2">
              <StarRating rating={restaurant.rating} showValue />
              <span>({restaurant.reviewCount} reviews)</span>
              <PriceRange range={restaurant.priceRange} />
            </div>
            <div className="flex items-center gap-2">
              {restaurant.cuisine.map((type, index) => (
                <span
                  key={index}
                  className="bg-white/20 px-3 py-1 rounded-full text-sm text-white"
                >
                  {type}
                </span>
              ))}
            </div>
          </div>
        </div>
      </div>

      <div className="container mx-auto px-4 py-8">
        <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
          {/* Main Content */}
          <div className="lg:col-span-2 space-y-8">
            {/* Restaurant Info */}
            <div className="bg-white rounded-xl shadow-sm p-6">
              <h2 className="text-2xl font-semibold mb-4">About {restaurant.name}</h2>
              <p className="text-gray-600 mb-6">{restaurant.description}</p>
              
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                {restaurant.address && (
                  <div className="flex items-center gap-2">
                    <MapPin className="h-5 w-5 text-primary-600" />
                    <span>
                      {restaurant.address.street && `${restaurant.address.street}, `}
                      {restaurant.address.city}
                    </span>
                  </div>
                )}
                <div className="flex items-center gap-2">
                  <Phone className="h-5 w-5 text-primary-600" />
                  <span>{restaurant.phone}</span>
                </div>
                <div className="flex items-center gap-2">
                  <Mail className="h-5 w-5 text-primary-600" />
                  <span>{restaurant.email}</span>
                </div>
                <div className="flex items-center gap-2">
                  <Users className="h-5 w-5 text-primary-600" />
                  <span>{restaurant.bookingsToday} bookings today</span>
                </div>
              </div>

              {/* Features */}
              <div className="mt-6">
                <h3 className="text-lg font-medium mb-3">Features & Amenities</h3>
                <div className="flex flex-wrap gap-2">
                  {restaurant.features.map((feature, index) => (
                    <span
                      key={index}
                      className="bg-gray-100 text-gray-800 px-3 py-1 rounded-full text-sm"
                    >
                      {feature}
                    </span>
                  ))}
                </div>
              </div>
            </div>

            {/* Reviews Section */}
            <div className="bg-white rounded-xl shadow-sm p-6">
              <h2 className="text-2xl font-semibold mb-6">Reviews</h2>
              {reviews.length > 0 ? (
                <div className="space-y-6">
                  {reviews.map(review => (
                    <ReviewCard key={review.id} review={review} />
                  ))}
                </div>
              ) : (
                <p className="text-gray-600">No reviews yet. Be the first to review!</p>
              )}
              
              {user?.role === UserRole.CUSTOMER && (
                <div className="mt-8">
                  <AddReviewForm restaurantId={restaurant.id} onSuccess={() => {}} />
                </div>
              )}
            </div>
          </div>

          {/* Booking Sidebar */}
          <div className="lg:col-span-1">
            <div className="bg-white rounded-xl shadow-sm p-6 sticky top-24">
              <h3 className="text-xl font-semibold mb-4">Make a Reservation</h3>
              
              <div className="space-y-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Party Size
                  </label>
                  <div className="flex items-center border rounded-md">
                    <button
                      onClick={() => setPartySize(Math.max(1, partySize - 1))}
                      className="px-3 py-2 text-gray-600 hover:bg-gray-100"
                    >
                      -
                    </button>
                    <span className="flex-1 text-center">{partySize} people</span>
                    <button
                      onClick={() => setPartySize(Math.min(20, partySize + 1))}
                      className="px-3 py-2 text-gray-600 hover:bg-gray-100"
                    >
                      +
                    </button>
                  </div>
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Date
                  </label>
                  <input
                    type="date"
                    value={selectedDate}
                    onChange={(e) => setSelectedDate(e.target.value)}
                    min={new Date().toISOString().split('T')[0]}
                    className="w-full rounded-md border-gray-300 shadow-sm focus:border-primary-600 focus:ring-primary-600"
                  />
                </div>

                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">
                    Available Times
                  </label>
                  <div className="grid grid-cols-3 gap-2">
                    {availableTimes.map((time) => (
                      <button
                        key={time}
                        onClick={() => handleTimeSelect(time)}
                        className="px-4 py-2 text-sm font-medium rounded-md bg-primary-600 text-white hover:bg-primary-700 transition-colors"
                      >
                        {formatTime(time)}
                      </button>
                    ))}
                  </div>
                </div>

                {!user && (
                  <p className="text-sm text-gray-600 mt-4">
                    Please{' '}
                    <button
                      onClick={() => navigate('/login')}
                      className="text-primary-600 hover:text-primary-700 font-medium"
                    >
                      sign in
                    </button>
                    {' '}to make a reservation
                  </p>
                )}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default RestaurantPage;