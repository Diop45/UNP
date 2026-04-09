import {
  Outlet,
  createRootRoute,
  createRoute,
  createRouter,
  Navigate,
  useRouterState,
} from "@tanstack/react-router";
import { BottomTabBar } from "@/components/BottomTabBar";
import { TourLauncher } from "@/components/Tour";
import { CirclesScreen } from "@/screens/CirclesScreen";
import { DemoScreenshotsPage } from "@/screens/DemoScreenshotsPage";
import { ExploreScreen } from "@/screens/ExploreScreen";
import { HomeScreen } from "@/screens/HomeScreen";
import { NudgeScreen } from "@/screens/NudgeScreen";
import { PourScreen } from "@/screens/PourScreen";
import { ProfileScreen } from "@/screens/ProfileScreen";
import "@/components/BottomTabBar.css";
import "@/design/tokens.css";

function RootLayout() {
  return (
    <>
      <Outlet />
      <BottomTabBar />
      <TourLauncher />
    </>
  );
}

const rootRoute = createRootRoute({
  component: RootLayout,
  notFoundComponent: () => <Navigate to="/" replace />,
});

// Build order: register Explore before other feature routes (index `/` is registered with Home).
const exploreRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "explore",
  component: ExploreScreen,
});

const indexRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "/",
  component: HomeScreen,
});

function PourPage() {
  const focus = useRouterState({
    select: (s) => {
      const q = s.location.search as Record<string, unknown>;
      return typeof q.focus === "string" ? q.focus : undefined;
    },
  });
  return <PourScreen focusId={focus} />;
}

const pourRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "pour",
  validateSearch: (search: Record<string, unknown>) => ({
    focus: typeof search.focus === "string" ? search.focus : undefined,
  }),
  component: PourPage,
});

const nudgeRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "nudge",
  component: NudgeScreen,
});

const circlesRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "circles",
  component: CirclesScreen,
});

const profileRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "profile",
  component: ProfileScreen,
});

const demoRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "demo-screenshots",
  component: DemoScreenshotsPage,
});

const routeTree = rootRoute.addChildren([
  exploreRoute,
  indexRoute,
  pourRoute,
  nudgeRoute,
  circlesRoute,
  profileRoute,
  demoRoute,
]);

export const router = createRouter({
  routeTree,
  defaultPreload: "intent",
});

declare module "@tanstack/react-router" {
  interface Register {
    router: typeof router;
  }
}
