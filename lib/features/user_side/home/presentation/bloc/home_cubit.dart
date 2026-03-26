import 'package:bloc/bloc.dart';
import '../../domain/entities/home_user_entity.dart';
import 'package:injectable/injectable.dart';
import 'home_state.dart';

@injectable
class HomeCubit extends Cubit<HomeState> {
  List<HomeUserEntity> _allUsers = [];

  HomeCubit() : super(const HomeState()) {
    _loadInitialData();
  }

  void _loadInitialData() {
    // Mock Data based on the screenshot
    _allUsers = [
      const HomeUserEntity(
        name: 'Santha',
        imageUrl: '', // Will use placeholder if empty
        status: UserStatus.online,
        isFavorite: true,
      ),
      const HomeUserEntity(
        name: 'Vimala',
        imageUrl: '',
        status: UserStatus.online,
      ),
      const HomeUserEntity(
        name: 'Hariyaa',
        imageUrl: '',
        status: UserStatus.onCall,
        isFavorite: true,
      ),
      const HomeUserEntity(
        name: 'Santha',
        imageUrl: '',
        status: UserStatus.online,
      ),
      const HomeUserEntity(
        name: 'Hariyaa',
        imageUrl: '',
        status: UserStatus.onCall,
      ),
      const HomeUserEntity(
        name: 'Santha',
        imageUrl: '',
        status: UserStatus.online,
      ),
      const HomeUserEntity(
        name: 'Meera',
        imageUrl: '',
        status: UserStatus.online,
        isFavorite: true,
      ),
      const HomeUserEntity(
        name: 'Kavin',
        imageUrl: '',
        status: UserStatus.onCall,
      ),
      const HomeUserEntity(
        name: 'Anjana',
        imageUrl: '',
        status: UserStatus.online,
      ),
      const HomeUserEntity(
        name: 'Rithik',
        imageUrl: '',
        status: UserStatus.online,
      ),
      const HomeUserEntity(
        name: 'Nila',
        imageUrl: '',
        status: UserStatus.onCall,
        isFavorite: true,
      ),
      const HomeUserEntity(
        name: 'Arun',
        imageUrl: '',
        status: UserStatus.online,
      ),
      const HomeUserEntity(
        name: 'Devi',
        imageUrl: '',
        status: UserStatus.online,
      ),
      const HomeUserEntity(
        name: 'Offline User',
        imageUrl: '',
        status: UserStatus.online,
        isFavorite: true,
      ),
      const HomeUserEntity(
        name: 'John Doe',
        imageUrl: '',
        status: UserStatus.online,
      ),
    ];

    // Apply initial filter (Active tab)
    _applyFilter(state.selectedTab);
  }

  void changeTab(HomeTab tab) {
    _applyFilter(tab);
  }

  void _applyFilter(HomeTab tab) {
    List<HomeUserEntity> filteredUsers;

    switch (tab) {
      case HomeTab.active:
        filteredUsers = _allUsers
            .where(
              (user) =>
                  user.status == UserStatus.online ||
                  user.status == UserStatus.onCall,
            )
            .toList();
        break;
      case HomeTab.favorites:
        filteredUsers = _allUsers.where((user) => user.isFavorite).toList();
        break;
      case HomeTab.offline:
        filteredUsers = _allUsers
            .where((user) => user.status == UserStatus.offline)
            .toList();
        break;
    }

    emit(state.copyWith(selectedTab: tab, users: filteredUsers));
  }

  void notifyUser(HomeUserEntity user) {
    String message;
    NotificationType type;
    if (user.status == UserStatus.onCall) {
      message = "We will notify you when ${user.name} is free";
      type = NotificationType.info;
    } else {
      message = "We will notify you when ${user.name} is online";
      type = NotificationType.success;
    }

    emit(
      state.copyWith(
        notificationMessage: message,
        notificationType: type,
        notificationId: (state.notificationId ?? 0) + 1,
      ),
    );
  }
}
