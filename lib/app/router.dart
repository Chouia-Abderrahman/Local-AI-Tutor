import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/chat/chat_list_screen.dart';
import '../features/chat/chat_screen.dart';
import '../features/home/home_shell.dart';
import '../features/library/document_screen.dart';
import '../features/library/library_screen.dart';
import '../features/library/section_screen.dart';
import '../features/model/model_lab_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/study/session_screen.dart';
import '../features/study/study_screen.dart';
import '../features/web/web_settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: '/library',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => HomeShell(shell: shell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/library',
                builder: (context, state) => const LibraryScreen(),
                routes: [
                  GoRoute(
                    path: 'doc/:id',
                    builder: (context, state) => DocumentScreen(
                      documentId: int.parse(state.pathParameters['id']!),
                    ),
                    routes: [
                      GoRoute(
                        path: 'section/:sectionId',
                        builder: (context, state) => SectionScreen(
                          sectionId: int.parse(
                            state.pathParameters['sectionId']!,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/study',
                builder: (context, state) => const StudyScreen(),
                routes: [
                  GoRoute(
                    path: 'session',
                    builder: (context, state) => SessionScreen(
                      documentId: int.tryParse(
                        state.uri.queryParameters['doc'] ?? '',
                      ),
                      sectionId: int.tryParse(
                        state.uri.queryParameters['section'] ?? '',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/chat',
                builder: (context, state) => const ChatListScreen(),
                routes: [
                  GoRoute(
                    path: 'conversation',
                    builder: (context, state) => const ChatScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/settings',
                builder: (context, state) => const SettingsScreen(),
                routes: [
                  GoRoute(
                    path: 'model',
                    builder: (context, state) => const ModelLabScreen(),
                  ),
                  GoRoute(
                    path: 'web',
                    builder: (context, state) => const WebSettingsScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
