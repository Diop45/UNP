import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AppProvider } from './context/AppContext';
import { Layout } from './components/Layout';
import { TourOverlay } from './components/TourOverlay';
import { HomePage } from './pages/HomePage';
import { PourPage } from './pages/PourPage';
import { BeverageDetailPage } from './pages/BeverageDetailPage';
import { AmbassadorUploadPage } from './pages/AmbassadorUploadPage';
import { NudgePage } from './pages/NudgePage';
import { NudgeDetailPage } from './pages/NudgeDetailPage';
import { ExplorePage } from './pages/ExplorePage';
import { EventDetailPage } from './pages/EventDetailPage';
import { CirclesPage } from './pages/CirclesPage';
import { ProfilePage } from './pages/ProfilePage';
import { OnboardingPage } from './pages/OnboardingPage';
import { DemoPage } from './pages/DemoPage';

export default function App() {
  return (
    <AppProvider>
      <BrowserRouter>
        <TourOverlay />
        <Routes>
          {/* Onboarding — no layout */}
          <Route path="/onboarding" element={<OnboardingPage />} />

          {/* Main app with layout */}
          <Route
            path="/*"
            element={
              <Layout>
                <Routes>
                  <Route path="/" element={<HomePage />} />
                  <Route path="/pour" element={<PourPage />} />
                  <Route path="/pour/upload" element={<AmbassadorUploadPage />} />
                  <Route path="/pour/:id" element={<BeverageDetailPage />} />
                  <Route path="/nudge" element={<NudgePage />} />
                  <Route path="/nudge/:id" element={<NudgeDetailPage />} />
                  <Route path="/explore" element={<ExplorePage />} />
                  <Route path="/explore/:id" element={<EventDetailPage />} />
                  <Route path="/circles" element={<CirclesPage />} />
                  <Route path="/profile" element={<ProfilePage />} />
                  <Route path="/demo" element={<DemoPage />} />
                  <Route path="*" element={<Navigate to="/" replace />} />
                </Routes>
              </Layout>
            }
          />
        </Routes>
      </BrowserRouter>
    </AppProvider>
  );
}
