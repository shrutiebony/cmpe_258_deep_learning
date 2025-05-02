import { useEffect, useState } from 'react';
import { useParams, useNavigate, useSearchParams } from 'react-router-dom';
import { CalendarIcon, Clock, Users } from 'lucide-react';
import Button from '../components/ui/Button';
import LoadingSpinner from '../components/ui/LoadingSpinner';
import { useRestaurantStore } from '../store/restaurantStore';
import { useBookingStore } from '../store/bookingStore';
import { Restaurant } from '../types/restaurant';

const BookingPage = () => {
  const { restaurantId } = useParams<{ restaurantId: string }>();
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  
  const [restaurant, setRestaurant] = useState<Restaurant | null>(null);
  const [date, setDate] = useState(searchParams.get('date') || '');
  const [time, setTime] = useState(searchParams.get('time') || '');
  const [guests, setGuests] = useState(parseInt(searchParams.get('people') || '2'));
  const [notes, setNotes] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  
  const { getRestaurantById } = useRestaurantStore();
  const { createBooking } = useBookingStore();

  useEffect(() => {
    if (!restaurantId) return;
    
    try {
      const foundRestaurant = getRestaurantById(restaurantId);
      if (foundRestaurant) {
        setRestaurant(foundRestaurant);
      } else {
        setError('Restaurant not found');
      }
    } catch (err) {
      setError('Failed to load restaurant');
    }
  }, [restaurantId, getRestaurantById]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    
    if (!restaurantId || !date || !time || !guests) {
      setError('Please fill in all required fields');
      return;
    }
    
    setIsLoading(true);
    setError(null);
    
    try {
      const booking = await createBooking({
        restaurantId,
        date,
        time,
        guests,
        notes
      });
      
      if (booking) {
        navigate('/profile');
      } else {
        throw new Error('Failed to create booking');
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to create booking');
      setIsLoading(false);
    }
  };

  if (error) {
    return (
      <div className="container mx-auto px-4 py-8">
        <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded">
          {error}
        </div>
        <div className="mt-4">
          <Button onClick={() => navigate(-1)}>Go Back</Button>
        </div>
      </div>
    );
  }

  if (!restaurant) {
    return <LoadingSpinner />;
  }

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="max-w-2xl mx-auto">
        <h1 className="text-3xl font-bold mb-6">Book a table at {restaurant.name}</h1>
        
        <div className="bg-white rounded-lg shadow-lg p-6 mb-8">
          <h2 className="text-xl font-semibold mb-4">Reservation Details</h2>
          
          <form onSubmit={handleSubmit} className="space-y-6">
            <div>
              <label className="block text-gray-700 mb-2 font-medium" htmlFor="date">
                Date
              </label>
              <div className="relative">
                <CalendarIcon className="absolute left-3 top-3 text-gray-400 h-5 w-5" />
                <input
                  id="date"
                  type="date"
                  className="pl-10 w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  value={date}
                  onChange={(e) => setDate(e.target.value)}
                  min={new Date().toISOString().split('T')[0]}
                  required
                />
              </div>
            </div>
            
            <div>
              <label className="block text-gray-700 mb-2 font-medium" htmlFor="time">
                Time
              </label>
              <div className="relative">
                <Clock className="absolute left-3 top-3 text-gray-400 h-5 w-5" />
                <select
                  id="time"
                  className="pl-10 w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  value={time}
                  onChange={(e) => setTime(e.target.value)}
                  required
                >
                  <option value="">Select a time</option>
                  <option value="12:00">12:00 PM</option>
                  <option value="12:30">12:30 PM</option>
                  <option value="13:00">1:00 PM</option>
                  <option value="13:30">1:30 PM</option>
                  <option value="14:00">2:00 PM</option>
                  <option value="18:00">6:00 PM</option>
                  <option value="18:30">6:30 PM</option>
                  <option value="19:00">7:00 PM</option>
                  <option value="19:30">7:30 PM</option>
                  <option value="20:00">8:00 PM</option>
                  <option value="20:30">8:30 PM</option>
                </select>
              </div>
            </div>
            
            <div>
              <label className="block text-gray-700 mb-2 font-medium" htmlFor="guests">
                Number of Guests
              </label>
              <div className="relative">
                <Users className="absolute left-3 top-3 text-gray-400 h-5 w-5" />
                <input
                  id="guests"
                  type="number"
                  min="1"
                  max="20"
                  className="pl-10 w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                  value={guests}
                  onChange={(e) => setGuests(parseInt(e.target.value))}
                  required
                />
              </div>
            </div>
            
            <div>
              <label className="block text-gray-700 mb-2 font-medium" htmlFor="notes">
                Special Requests (Optional)
              </label>
              <textarea
                id="notes"
                rows={3}
                className="w-full p-2 border border-gray-300 rounded-md focus:ring-2 focus:ring-blue-500 focus:border-blue-500"
                value={notes}
                onChange={(e) => setNotes(e.target.value)}
                placeholder="E.g., dietary requirements, special occasions, seating preferences"
              />
            </div>
            
            <div className="flex items-center justify-between pt-4">
              <Button type="button" variant="outline" onClick={() => navigate(-1)}>
                Cancel
              </Button>
              <Button type="submit" disabled={isLoading}>
                {isLoading ? 'Creating Reservation...' : 'Confirm Reservation'}
              </Button>
            </div>
          </form>
        </div>
        
        <div className="bg-blue-50 border border-blue-200 text-blue-700 px-4 py-3 rounded">
          <p className="font-medium">Reservation Policy</p>
          <p className="text-sm mt-1">
            Please arrive within 15 minutes of your reservation time. We hold tables for 15 minutes
            after the reservation time, after which the table may be given to other guests.
          </p>
        </div>
      </div>
    </div>
  );
}

export default BookingPage;