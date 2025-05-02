import { useEffect, useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { User, Settings, Star, Calendar, Ban, AlertTriangle, DollarSign, Clock } from 'lucide-react';
import { useAuthStore } from '../store/authStore';
import { useBookingStore } from '../store/bookingStore';
import BookingCard from '../components/booking/BookingCard';
import Button from '../components/ui/Button';
import LoadingSpinner from '../components/ui/LoadingSpinner';
import { Booking } from '../types/booking';
import { Restaurant } from '../types/restaurant';
import { useRestaurantStore } from '../store/restaurantStore';
import StarRating from '../components/ui/StarRating';

function ProfilePage() {
  const navigate = useNavigate();
  const { user } = useAuthStore();
  const { fetchUserBookings, userBookings, cancelBooking } = useBookingStore();
  const { getRestaurantById } = useRestaurantStore();
  const [isLoading, setIsLoading] = useState(true);
  const [restaurants, setRestaurants] = useState<Map<string, Restaurant>>(new Map());

  useEffect(() => {
    if (!user) return;

    const loadBookings = async () => {
      await fetchUserBookings(user.id);
      setIsLoading(false);
    };

    loadBookings();
  }, [user, fetchUserBookings]);

  useEffect(() => {
    // Load restaurant details for each booking
    const loadRestaurants = () => {
      const restaurantMap = new Map<string, Restaurant>();
      
      userBookings.forEach(booking => {
        const restaurant = getRestaurantById(booking.restaurantId);
        if (restaurant) {
          restaurantMap.set(booking.restaurantId, restaurant);
        }
      });
      
      setRestaurants(restaurantMap);
    };

    loadRestaurants();
  }, [userBookings, getRestaurantById]);

  const handleCancelBooking = async (bookingId: string) => {
    if (window.confirm('Are you sure you want to cancel this reservation?')) {
      await cancelBooking(bookingId);
    }
  };

  if (!user) {
    navigate('/login');
    return null;
  }

  if (isLoading) {
    return <LoadingSpinner />;
  }

  // Calculate stats
  const completedBookings = userBookings.filter(b => b.status === 'completed').length;
  const upcomingBookings = userBookings.filter(b => b.status === 'confirmed').length;

  return (
    <div className="container mx-auto px-4 py-8">
      {/* Profile Header */}
      <div className="bg-white rounded-lg shadow-md p-6 mb-8">
        <div className="flex flex-col md:flex-row md:items-center md:justify-between">
          <div className="flex items-center space-x-4 mb-4 md:mb-0">
            <div className="w-20 h-20 bg-blue-100 rounded-full flex items-center justify-center">
              {user.avatar ? (
                <img
                  src={user.avatar}
                  alt={user.name}
                  className="w-full h-full rounded-full object-cover"
                />
              ) : (
                <User className="w-10 h-10 text-blue-600" />
              )}
            </div>
            <div>
              <h1 className="text-2xl font-bold text-gray-900">{user.name}</h1>
              <p className="text-gray-600">{user.email}</p>
              {user.customerRating && (
                <div className="flex items-center mt-1">
                  <StarRating rating={user.customerRating} size="sm" />
                  <span className="ml-2 text-sm text-gray-600">Customer Rating</span>
                </div>
              )}
            </div>
          </div>
          <Button
            variant="outline"
            onClick={() => navigate('/settings')}
          >
            <Settings className="w-4 h-4 mr-2" />
            Account Settings
          </Button>
        </div>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <div className="bg-white rounded-lg shadow-md p-6">
          <div className="flex items-center justify-between mb-2">
            <h3 className="text-lg font-semibold text-gray-900">Visit Count</h3>
            <Calendar className="w-6 h-6 text-blue-600" />
          </div>
          <p className="text-3xl font-bold text-gray-900">{user.visitCount}</p>
          {user.lastVisit && (
            <p className="text-sm text-gray-600 mt-1">
              Last visit: {new Date(user.lastVisit).toLocaleDateString()}
            </p>
          )}
        </div>

        <div className="bg-white rounded-lg shadow-md p-6">
          <div className="flex items-center justify-between mb-2">
            <h3 className="text-lg font-semibold text-gray-900">Total Spent</h3>
            <DollarSign className="w-6 h-6 text-green-600" />
          </div>
          <p className="text-3xl font-bold text-gray-900">
            ${user.totalSpent.toFixed(2)}
          </p>
          {user.isRegular && (
            <p className="text-sm text-green-600 mt-1">Regular Customer</p>
          )}
        </div>

        <div className="bg-white rounded-lg shadow-md p-6">
          <div className="flex items-center justify-between mb-2">
            <h3 className="text-lg font-semibold text-gray-900">Cancelled</h3>
            <Ban className="w-6 h-6 text-red-600" />
          </div>
          <p className="text-3xl font-bold text-gray-900">{user.cancelledBookings}</p>
          <p className="text-sm text-gray-600 mt-1">Total cancellations</p>
        </div>

        <div className="bg-white rounded-lg shadow-md p-6">
          <div className="flex items-center justify-between mb-2">
            <h3 className="text-lg font-semibold text-gray-900">No Shows</h3>
            <AlertTriangle className="w-6 h-6 text-orange-600" />
          </div>
          <p className="text-3xl font-bold text-gray-900">{user.noShowCount}</p>
          <p className="text-sm text-gray-600 mt-1">Missed reservations</p>
        </div>
      </div>

      {/* Bookings Section */}
      <div className="bg-white rounded-lg shadow-md p-6">
        <div className="flex items-center justify-between mb-6">
          <h2 className="text-xl font-bold text-gray-900">Your Reservations</h2>
          <div className="flex items-center space-x-4">
            <div className="text-sm text-gray-600">
              <span className="font-medium">{upcomingBookings}</span> upcoming
            </div>
            <div className="text-sm text-gray-600">
              <span className="font-medium">{completedBookings}</span> completed
            </div>
          </div>
        </div>

        {userBookings.length === 0 ? (
          <div className="text-center py-8">
            <Clock className="w-12 h-12 text-gray-400 mx-auto mb-4" />
            <p className="text-gray-600 mb-4">You don't have any reservations yet.</p>
            <Button onClick={() => navigate('/search')}>
              Find a Restaurant
            </Button>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {userBookings.map((booking: Booking) => (
              <BookingCard
                key={booking.id}
                booking={booking}
                restaurant={restaurants.get(booking.restaurantId)}
                onCancel={handleCancelBooking}
              />
            ))}
          </div>
        )}
      </div>

      {/* Special Notes */}
      {user.specialNotes && (
        <div className="mt-8 bg-blue-50 border border-blue-200 rounded-lg p-6">
          <h3 className="text-lg font-semibold text-blue-900 mb-2">Special Notes</h3>
          <p className="text-blue-800">{user.specialNotes}</p>
        </div>
      )}
    </div>
  );
}

export default ProfilePage;