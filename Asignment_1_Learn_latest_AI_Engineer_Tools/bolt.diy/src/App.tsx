import { Routes, Route } from 'react-router-dom';
import { Suspense, lazy } from 'react';
import Layout from './components/layout/Layout';
import HomePage from './pages/HomePage';
import LoadingSpinner from './components/ui/LoadingSpinner';
import ProtectedRoute from './components/auth/ProtectedRoute';
import { UserRole } from './types/auth';
import CallbackPage from './pages/auth/CallbackPage';

// Lazy loaded pages
const SearchPage = lazy(() => import('./pages/SearchPage'));
const RestaurantPage = lazy(() => import('./pages/RestaurantPage'));
const BookingPage = lazy(() => import('./pages/BookingPage'));
const ProfilePage = lazy(() => import('./pages/ProfilePage'));
const LoginPage = lazy(() => import('./pages/LoginPage'));
const RegisterPage = lazy(() => import('./pages/RegisterPage'));
const RestaurantDashboardPage = lazy(() => import('./pages/restaurant/DashboardPage'));
const RestaurantSettingsPage = lazy(() => import('./pages/restaurant/SettingsPage'));
const AdminDashboardPage = lazy(() => import('./pages/admin/DashboardPage'));
const AdminRestaurantsPage = lazy(() => import('./pages/admin/RestaurantsPage'));
const NotFoundPage = lazy(() => import('./pages/NotFoundPage'));

function App() {
  return (
    <Layout>
      <Suspense fallback={<LoadingSpinner />}>
        <Routes>
          {/* Public routes */}
          <Route path="/" element={<HomePage />} />
          <Route path="/search" element={<SearchPage />} />
          <Route path="/restaurant/:id" element={<RestaurantPage />} />
          <Route path="/login" element={<LoginPage />} />
          <Route path="/register" element={<RegisterPage />} />
          <Route path="/auth/callback" element={<CallbackPage />} />
          
          {/* Customer routes */}
          <Route 
            path="/booking/:restaurantId" 
            element={
              <ProtectedRoute allowedRoles={[UserRole.CUSTOMER]}>
                <BookingPage />
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/profile" 
            element={
              <ProtectedRoute allowedRoles={[UserRole.CUSTOMER]}>
                <ProfilePage />
              </ProtectedRoute>
            } 
          />
          
          {/* Restaurant manager routes */}
          <Route 
            path="/restaurant-dashboard" 
            element={
              <ProtectedRoute allowedRoles={[UserRole.RESTAURANT_MANAGER]}>
                <RestaurantDashboardPage />
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/restaurant-settings" 
            element={
              <ProtectedRoute allowedRoles={[UserRole.RESTAURANT_MANAGER]}>
                <RestaurantSettingsPage />
              </ProtectedRoute>
            } 
          />
          
          {/* Admin routes */}
          <Route 
            path="/admin" 
            element={
              <ProtectedRoute allowedRoles={[UserRole.ADMIN]}>
                <AdminDashboardPage />
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/admin/restaurants" 
            element={
              <ProtectedRoute allowedRoles={[UserRole.ADMIN]}>
                <AdminRestaurantsPage />
              </ProtectedRoute>
            } 
          />
          
          {/* 404 route */}
          <Route path="*" element={<NotFoundPage />} />
        </Routes>
      </Suspense>
    </Layout>
  );
}

export default App;