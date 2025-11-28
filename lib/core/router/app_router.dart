import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:rimba_app/core/services/auth_service.dart';
import 'package:rimba_app/ui/viewmodels/categories_viewmodel.dart';
import 'package:rimba_app/ui/views/admin_dashboard_view.dart';
import 'package:rimba_app/ui/views/categories_management_view.dart';
import 'package:rimba_app/ui/views/users_management_view.dart';
import 'package:rimba_app/ui/views/home_view.dart';
import 'package:rimba_app/ui/views/login_view.dart';
import 'package:rimba_app/ui/views/register_view.dart';
import 'package:rimba_app/ui/views/welcome_view.dart';
import 'package:rimba_app/ui/views/flora_management_view.dart';
import 'package:rimba_app/ui/viewmodels/flora_viewmodel.dart';
import 'package:rimba_app/ui/viewmodels/users_viewmodel.dart';
import 'package:rimba_app/data/app_database.dart';
import 'package:rimba_app/ui/views/categories_overview_view.dart';
import 'package:rimba_app/ui/views/category_flora_list_view.dart';
import 'package:rimba_app/ui/views/flora_detail_view.dart';
import 'package:rimba_app/ui/views/moments_list_view.dart';
import 'package:rimba_app/ui/views/moment_add_view.dart';
import 'package:rimba_app/ui/views/moment_detail_view.dart';
import 'package:rimba_app/ui/views/found_detail_view.dart';
import 'package:rimba_app/ui/views/found_list_view.dart';




class AppRouter {
  final AuthService authService;
  final AppDatabase db;

  AppRouter(this.authService, this.db);

  late final GoRouter router = GoRouter(
    refreshListenable: authService,
    initialLocation: '/',
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        builder: (context, state) => const WelcomeView(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeView(),
      ),
    // ==== MOMENTS (LIBRARY) ====
    GoRoute(
      path: '/moments',
      builder: (context, state) => const MomentsListView(),
    ),
    GoRoute(
      path: '/moments/add',
      builder: (context, state) => const MomentAddView(),
    ),
    GoRoute(
      path: '/moments/:id',
      builder: (context, state) {
        final id = int.parse(state.pathParameters['id']!);
        final moment =
            state.extra is Moment ? state.extra as Moment : null;
        return MomentDetailView(
          momentId: id,
          initialMoment: moment,
        );
      },
    ),
GoRoute(
  path: '/found',
  builder: (context, state) => const FoundListView(),
),
GoRoute(
  path: '/found/:id',
  builder: (context, state) {
    final flora = state.extra as FloraTableData;
    return FoundDetailView(flora: flora);
  },
),


            GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesOverviewView(),
      ),
      GoRoute(
        path: '/categories/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final category = state.extra is Category ? state.extra as Category : null;
          return CategoryFloraListView(
            categoryId: id,
            category: category,
          );
        },
      ),
      GoRoute(
        path: '/flora/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          final flora =
              state.extra is FloraTableData ? state.extra as FloraTableData : null;
          return FloraDetailView(
            floraId: id,
            initialFlora: flora,
          );
        },
      ),

      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminDashboardView(),
      ),
      GoRoute(
        path: '/admin/flora',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => FloraViewModel(Provider.of<AppDatabase>(context, listen: false)),
          child: const FloraManagementView(),
        ),
      ),
      GoRoute(
        path: '/admin/kategori',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => CategoriesViewModel(Provider.of<AppDatabase>(context, listen: false)),
          child: const CategoriesManagementView(),
        ),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => ChangeNotifierProvider(
          create: (_) => UsersViewModel(Provider.of<AppDatabase>(context, listen: false))..loadUsers(),
          child: const UsersManagementView(),
        ),
      ),
    ],
    redirect: (context, state) {
      final loggedIn = authService.isLoggedIn;
      final userRole = authService.currentUser?.role;
      final location = state.uri.toString();

      final publicPages = ['/', '/login', '/register'];
      final isPublicPage = publicPages.contains(location);

      if (!loggedIn && !isPublicPage) return '/login';
      if (loggedIn && isPublicPage) {
        if (userRole == 'admin') return '/admin';
        return '/home';
      }

      if (loggedIn && location == '/admin' && userRole != 'admin') return '/home';
      if (loggedIn && location == '/home' && userRole == 'admin') return '/admin';

      return null;
    },
  );
}
