import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core
import '../network/network_info.dart';
import '../network/supabase_client.dart';
import '../localization/cubit/locale_cubit.dart';
import '../theme/cubit/theme_cubit.dart';

// ===== Features =====

// Auth
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';

// Clients
import '../../features/clients/presentation/cubit/client_cubit.dart';
import '../../features/clients/data/datasources/client_remote_datasource.dart';
import '../../features/clients/data/repositories/client_repository_impl.dart';
import '../../features/clients/domain/repositories/client_repository.dart';
import '../../features/clients/domain/usecases/create_client_usecase.dart';
import '../../features/clients/domain/usecases/delete_client_usecase.dart';
import '../../features/clients/domain/usecases/get_client_by_id_usecase.dart';
import '../../features/clients/domain/usecases/get_clients_usecase.dart';
import '../../features/clients/domain/usecases/update_client_usecase.dart';

// Users
import '../../features/users/presentation/cubit/user_cubit.dart';
import '../../features/users/data/datasources/user_remote_datasource.dart';
import '../../features/users/data/repositories/user_repository_impl.dart';
import '../../features/users/domain/repositories/user_repository.dart';
import '../../features/users/domain/usecases/get_users_usecase.dart';
import '../../features/users/domain/usecases/create_user_usecase.dart';
import '../../features/users/domain/usecases/update_users_usecase.dart';
import '../../features/users/domain/usecases/delete_user_usecase.dart';

// Branches
import '../../features/branches/presentation/cubit/branch_cubit.dart';
import '../../features/branches/data/datasources/branch_remote_datasource.dart';
import '../../features/branches/data/repositories/branch_repository_impl.dart';
import '../../features/branches/domain/repositories/branch_repository.dart';
import '../../features/branches/domain/usecases/get_branches_usecase.dart';
import '../../features/branches/domain/usecases/create_branch_usecase.dart';

// Attendance
import '../../features/attendance/presentation/cubit/attendance_cubit.dart';
import '../../features/attendance/data/datasources/attendance_remote_datasource.dart';
import '../../features/attendance/data/repositories/attendance_repository_impl.dart';
import '../../features/attendance/domain/repositories/attendance_repository.dart';
import '../../features/attendance/domain/usecases/check_in_usecase.dart';
import '../../features/attendance/domain/usecases/check_out_usecase.dart';
import '../../features/attendance/domain/usecases/get_attendance_history_usecase.dart';

// Payroll
import '../../features/payroll/presentation/cubit/payroll_cubit.dart';
import '../../features/payroll/data/datasources/payroll_remote_datasource.dart';
import '../../features/payroll/data/datasources/payroll_details_datasource.dart';
import '../../features/payroll/data/datasources/payroll_rules_remote_datasource.dart';
import '../../features/payroll/data/repositories/payroll_repository_impl.dart';
import '../../features/payroll/data/repositories/payroll_details_repository_impl.dart';
import '../../features/payroll/data/repositories/payroll_rule_repository_impl.dart';
import '../../features/payroll/domain/repositories/payroll_repository.dart';
import '../../features/payroll/domain/repositories/payroll_details_repository.dart';
import '../../features/payroll/domain/repositories/payroll_rules_repo.dart';
import '../../features/payroll/domain/usecases/create_payroll.dart';
import '../../features/payroll/domain/usecases/get_payrolls.dart';
import '../../features/payroll/domain/usecases/get_payroll_by_id.dart';
import '../../features/payroll/domain/usecases/update_payroll.dart';
import '../../features/payroll/domain/usecases/delete_payroll.dart';
import '../../features/payroll/domain/usecases/get_payroll_details.dart';
import '../../features/payroll/domain/usecases/add_payroll_detail.dart';
import '../../features/payroll/domain/usecases/delete_payroll_detail.dart';
import '../../features/payroll/domain/usecases/get_payroll_rules.dart';
import '../../features/payroll/domain/usecases/create_payroll_rule.dart';
import '../../features/payroll/domain/usecases/update_payroll_rule.dart';
import '../../features/payroll/domain/usecases/delete_payroll_rule.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! ================= CORE =================
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
  sl.registerLazySingleton<LocaleCubit>(() => LocaleCubit());
  sl.registerLazySingleton<NetworkInfo>(() => AlwaysConnectedNetworkInfo());
  sl.registerLazySingleton<SupabaseClient>(() => SupabaseConfig.client);

  //! ================= AUTH =================
  sl.registerFactory<LoginCubit>(() => LoginCubit());
  sl.registerFactory<AuthCubit>(() => AuthCubit());

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton(() => SignInUseCase(sl()));
  sl.registerLazySingleton(() => SignUpUseCase(sl()));
  sl.registerLazySingleton(() => SignOutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  //! ================= CLIENTS =================
  sl.registerFactory<ClientCubit>(() => ClientCubit(
        getClientsUseCase: sl(),
        getClientByIdUseCase: sl(),
        createClientUseCase: sl(),
        updateClientUseCase: sl(),
        deleteClientUseCase: sl(),
      ));

  sl.registerLazySingleton<ClientRemoteDataSource>(
    () => ClientRemoteDataSourceImpl(supabaseClient: sl()),
  );
  sl.registerLazySingleton<ClientRepository>(
    () => ClientRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton(() => GetClientsUseCase(sl()));
  sl.registerLazySingleton(() => GetClientByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateClientUseCase(sl()));
  sl.registerLazySingleton(() => UpdateClientUseCase(sl()));
  sl.registerLazySingleton(() => DeleteClientUseCase(sl()));

  //! ================= USERS =================
  sl.registerFactory<UserCubit>(() => UserCubit(
        getUsersUseCase: sl(),
        createUserUseCase: sl(),
        updateUsersUsecase: sl(),
        deleteUserUseCase: sl(),
      ));

  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(supabaseClient: sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton(() => GetUsersUseCase(sl()));
  sl.registerLazySingleton(() => CreateUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUsersUsecase(sl()));
  sl.registerLazySingleton(() => DeleteUserUseCase(sl()));

  //! ================= BRANCHES =================
  sl.registerFactory<BranchCubit>(() => BranchCubit(
        getBranchesUseCase: sl(),
        createBranchUseCase: sl(),
      ));

  sl.registerLazySingleton<BranchRemoteDataSource>(
    () => BranchRemoteDataSourceImpl(supabaseClient: sl()),
  );
  sl.registerLazySingleton<BranchRepository>(
    () => BranchRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton(() => GetBranchesUseCase(sl()));
  sl.registerLazySingleton(() => CreateBranchUseCase(sl()));

  //! ================= ATTENDANCE =================
  sl.registerFactory<AttendanceCubit>(() => AttendanceCubit());

  sl.registerLazySingleton<AttendanceRemoteDataSource>(
    () => AttendanceRemoteDataSourceImpl(supabaseClient: sl()),
  );
  sl.registerLazySingleton<AttendanceRepository>(
    () => AttendanceRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  sl.registerLazySingleton(() => CheckInUseCase(sl()));
  sl.registerLazySingleton(() => CheckOutUseCase(sl()));
  sl.registerLazySingleton(() => GetAttendanceHistoryUseCase(sl()));

  //! ================= PAYROLL =================
  sl.registerFactory<PayrollCubit>(() => PayrollCubit(
        createPayroll: sl(),
        getPayrolls: sl(),
        getPayrollById: sl(),
        updatePayroll: sl(),
        deletePayroll: sl(),
        getPayrollDetails: sl(),
        addPayrollDetail: sl(),
        deletePayrollDetail: sl(),
        getPayrollRules: sl(),
        createPayrollRule: sl(),
        updatePayrollRule: sl(),
        deletePayrollRule: sl(),
      ));

  // Payroll Repositories
  sl.registerLazySingleton<PayrollRepository>(
    () => PayrollRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<PayrollDetailRepository>(
    () => PayrollDetailRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PayrollRulesRepository>(
    () => PayrollRulesRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Payroll DataSources
  sl.registerLazySingleton<PayrollRemoteDataSource>(
    () => PayrollRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<PayrollDetailRemoteDataSource>(
    () => PayrollDetailRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<PayrollRulesRemoteDataSource>(
    () => PayrollRulesRemoteDataSourceImpl(client: sl()),
  );

  // Payroll UseCases
  sl.registerLazySingleton(() => CreatePayroll(sl()));
  sl.registerLazySingleton(() => GetPayrolls(sl()));
  sl.registerLazySingleton(() => GetPayrollById(sl()));
  sl.registerLazySingleton(() => UpdatePayroll(sl()));
  sl.registerLazySingleton(() => DeletePayroll(sl()));
  sl.registerLazySingleton(() => GetPayrollDetails(sl()));
  sl.registerLazySingleton(() => AddPayrollDetail(sl()));
  sl.registerLazySingleton(() => DeletePayrollDetail(sl()));
  sl.registerLazySingleton(() => GetPayrollRules(sl()));
  sl.registerLazySingleton(() => CreatePayrollRule(sl()));
  sl.registerLazySingleton(() => UpdatePayrollRule(sl()));
  sl.registerLazySingleton(() => DeletePayrollRule(sl()));
}

Future<void> initializeSupabase() async {
  await SupabaseConfig.initialize();
}

// Alias for backward compatibility
final getIt = sl;
