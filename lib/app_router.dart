import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/otp_screen.dart';
import 'screens/home/main_shell.dart';
import 'screens/listings/listing_detail_screen.dart';
import 'screens/listings/new_listing_screen.dart';
import 'screens/contact/contact_farmer_screen.dart';
import 'screens/advertise/advertise_screen.dart';

GoRouter createRouter(BuildContext context) => GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final auth = context.read<AuthProvider>();
        final isAuth = auth.isAuthenticated;
        final isAuthRoute = state.matchedLocation.startsWith('/login') ||
            state.matchedLocation.startsWith('/signup') ||
            state.matchedLocation.startsWith('/otp');

        if (auth.isLoading) return null;
        if (!isAuth && !isAuthRoute) return '/login';
        if (isAuth && isAuthRoute) return '/home';
        return null;
      },
      refreshListenable: context.read<AuthProvider>(),
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
        GoRoute(
          path: '/otp',
          builder: (_, state) =>
              OtpScreen(phone: state.extra as String? ?? ''),
        ),
        ShellRoute(
          builder: (context, state, child) => MainShell(child: child),
          routes: [
            GoRoute(path: '/home', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/listings', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/markets', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/prices', builder: (_, __) => const SizedBox()),
            GoRoute(path: '/trends', builder: (_, __) => const SizedBox()),
          ],
        ),
        GoRoute(
          path: '/listing/:id',
          builder: (_, state) =>
              ListingDetailScreen(listingId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/new-listing',
          builder: (_, __) => const NewListingScreen(),
        ),
        GoRoute(
          path: '/contact/:listingId',
          builder: (_, state) =>
              ContactFarmerScreen(listingId: state.pathParameters['listingId']!),
        ),
        GoRoute(
          path: '/advertise',
          builder: (_, __) => const AdvertiseScreen(),
        ),
      ],
    );
