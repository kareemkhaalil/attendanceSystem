import 'package:get_it/get_it.dart';
import 'package:manzoma/core/localization/cubit/locale_cubit.dart';
import 'package:manzoma/core/theme/cubit/theme_cubit.dart';
import 'package:manzoma/features/attendance/data/datasources/attendance_rules_remote_datasource.dart';
import 'package:manzoma/features/attendance/data/repositories/attendance_rules_repository_impl.dart';
import 'package:manzoma/features/attendance/domain/repositories/attendance_rules_repository.dart';
import 'package:manzoma/features/attendance/domain/usecases/assign_rule_to_user_usecase.dart';
import 'package:manzoma/features/attendance/domain/usecases/check_in_with_qr_usecase.dart';
import 'package:manzoma/features/attendance/domain/usecases/get_attendance_history_tennent_usecase.dart';
import 'package:manzoma/features/attendance/domain/usecases/get_metrics_usecase.dart';
import 'package:manzoma/features/attendance/presentation/cubit/attendance_cubit.dart';
import 'package:manzoma/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:manzoma/features/auth/presentation/cubit/login_cubit.dart';
import 'package:manzoma/features/clients/presentation/cubit/client_cubit.dart';
import 'package:manzoma/features/payroll/domain/usecases/generate_payroll_entries_usecase.dart';
import 'package:manzoma/features/payroll/presentation/cubit/payroll_cubit.dart';
import 'package:manzoma/features/users/presentation/cubit/user_cubit.dart';
import 'package:manzoma/features/branches/presentation/cubit/branch_cubit.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Core
import '../network/network_info.dart';
import '../network/supabase_client.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/sign_in_usecase.dart';
import '../../features/auth/domain/usecases/sign_up_usecase.dart';
import '../../features/auth/domain/usecases/sign_out_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_usecase.dart';

// Users
import '../../features/users/data/datasources/user_remote_datasource.dart';
import '../../features/users/data/repositories/user_repository_impl.dart';
import '../../features/users/domain/repositories/user_repository.dart';
import '../../features/users/domain/usecases/get_users_usecase.dart';
import '../../features/users/domain/usecases/create_user_usecase.dart';
import '../../features/users/domain/usecases/update_users_usecase.dart';

// Clients
import '../../features/clients/data/datasources/client_remote_datasource.dart';
import '../../features/clients/data/repositories/client_repository_impl.dart';
import '../../features/clients/domain/repositories/client_repository.dart';
import '../../features/clients/domain/usecases/create_client_usecase.dart';
import '../../features/clients/domain/usecases/delete_client_usecase.dart';
import '../../features/clients/domain/usecases/get_client_by_id_usecase.dart';
import '../../features/clients/domain/usecases/get_clients_usecase.dart';
import '../../features/clients/domain/usecases/update_client_usecase.dart';

// Branches
import '../../features/branches/data/datasources/branch_remote_datasource.dart';
import '../../features/branches/data/repositories/branch_repository_impl.dart';
import '../../features/branches/domain/repositories/branch_repository.dart';
import '../../features/branches/domain/usecases/get_branches_usecase.dart';
import '../../features/branches/domain/usecases/create_branch_usecase.dart';

// Attendance
import '../../features/attendance/data/datasources/attendance_remote_datasource.dart';
import '../../features/attendance/data/repositories/attendance_repository_impl.dart';
import '../../features/attendance/domain/repositories/attendance_repository.dart';
import '../../features/attendance/domain/usecases/check_in_usecase.dart';
import '../../features/attendance/domain/usecases/check_out_usecase.dart';
import '../../features/attendance/domain/usecases/get_attendance_history_usecase.dart';

// Payroll
import '../../features/payroll/data/datasources/payroll_remote_datasource.dart';
import '../../features/payroll/data/datasources/payroll_details_datasource.dart';
import '../../features/payroll/data/datasources/payroll_rules_remote_datasource.dart';
import '../../features/payroll/data/repositories/payroll_repository_impl.dart';
import '../../features/payroll/data/repositories/payroll_details_repository_impl.dart';
import '../../features/payroll/data/repositories/payroll_rule_repository_impl.dart';
import '../../features/payroll/domain/repositories/payroll_repository.dart';
import '../../features/payroll/domain/repositories/payroll_details_repository.dart';
import '../../features/payroll/domain/repositories/payroll_rules_repo.dart';
import '../../features/payroll/domain/usecases/add_payroll_detail.dart';
import '../../features/payroll/domain/usecases/create_payroll.dart';
import '../../features/payroll/domain/usecases/create_payroll_rule.dart';
import '../../features/payroll/domain/usecases/delete_payroll.dart';
import '../../features/payroll/domain/usecases/delete_payroll_detail.dart';
import '../../features/payroll/domain/usecases/delete_payroll_rule.dart';
import '../../features/payroll/domain/usecases/get_payroll_by_id.dart';
import '../../features/payroll/domain/usecases/get_payroll_details.dart';
import '../../features/payroll/domain/usecases/get_payroll_rules.dart';
import '../../features/payroll/domain/usecases/get_payrolls.dart';
import '../../features/payroll/domain/usecases/update_payroll.dart';
import '../../features/payroll/domain/usecases/update_payroll_rule.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! -------------------- Cubits --------------------
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
  sl.registerLazySingleton<LocaleCubit>(() => LocaleCubit());

  sl.registerFactory<LoginCubit>(() => LoginCubit());
  sl.registerFactory<AuthCubit>(() => AuthCubit());

  sl.registerFactory<ClientCubit>(() => ClientCubit(
        getClientsUseCase: sl(),
        getClientByIdUseCase: sl(),
        createClientUseCase: sl(),
        updateClientUseCase: sl(),
        deleteClientUseCase: sl(),
      ));

  sl.registerFactory<UserCubit>(() => UserCubit(
        getUsersUseCase: sl(),
        createUserUseCase: sl(),
        updateUsersUsecase: sl(),
      ));

  sl.registerFactory<BranchCubit>(() => BranchCubit(
        getBranchesUseCase: sl(),
        createBranchUseCase: sl(),
      ));

  sl.registerFactory<AttendanceCubit>(() => AttendanceCubit());

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
        generatePayrollEntries: sl(),
        getClientsUseCase: sl(),
        getUsersUseCase: sl(),
      ));

  //! -------------------- UseCases --------------------
  // Auth
  sl.registerLazySingleton<SignInUseCase>(() => SignInUseCase(sl()));
  sl.registerLazySingleton<SignUpUseCase>(() => SignUpUseCase(sl()));
  sl.registerLazySingleton<SignOutUseCase>(() => SignOutUseCase(sl()));
  sl.registerLazySingleton<GetCurrentUserUseCase>(
      () => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton<ResetPasswordUseCase>(
      () => ResetPasswordUseCase(sl()));

  // Users
  sl.registerLazySingleton<GetUsersUseCase>(() => GetUsersUseCase(sl()));
  sl.registerLazySingleton<CreateUserUseCase>(() => CreateUserUseCase(sl()));
  sl.registerLazySingleton<UpdateUsersUsecase>(() => UpdateUsersUsecase(sl()));

  // Clients
  sl.registerLazySingleton<CreateClientUseCase>(
      () => CreateClientUseCase(sl()));
  sl.registerLazySingleton<GetClientsUseCase>(() => GetClientsUseCase(sl()));
  sl.registerLazySingleton<UpdateClientUseCase>(
      () => UpdateClientUseCase(sl()));
  sl.registerLazySingleton<DeleteClientUseCase>(
      () => DeleteClientUseCase(sl()));
  sl.registerLazySingleton<GetClientByIdUseCase>(
      () => GetClientByIdUseCase(sl()));

  // Branches
  sl.registerLazySingleton<GetBranchesUseCase>(() => GetBranchesUseCase(sl()));
  sl.registerLazySingleton<CreateBranchUseCase>(
      () => CreateBranchUseCase(sl()));

  // Attendance
  sl.registerLazySingleton<CheckInUseCase>(() => CheckInUseCase(sl()));
  sl.registerLazySingleton<CheckInWithQrUseCase>(
      () => CheckInWithQrUseCase(sl()));
  sl.registerLazySingleton<CheckOutUseCase>(() => CheckOutUseCase(sl()));
  sl.registerLazySingleton<GetAttendanceHistoryUseCase>(
      () => GetAttendanceHistoryUseCase(sl()));
  sl.registerLazySingleton<GetAttendanceHistoryByTennentidUseCase>(
      () => GetAttendanceHistoryByTennentidUseCase(sl()));
  sl.registerLazySingleton<AssignRuleToUserUsecase>(
      () => AssignRuleToUserUsecase(sl()));
  sl.registerLazySingleton<GetMetricsUseCase>(() => GetMetricsUseCase(sl()));

  // Payroll
  sl.registerLazySingleton<CreatePayroll>(() => CreatePayroll(sl()));
  sl.registerLazySingleton<GetPayrolls>(() => GetPayrolls(sl()));
  sl.registerLazySingleton<GetPayrollById>(() => GetPayrollById(sl()));
  sl.registerLazySingleton<UpdatePayroll>(() => UpdatePayroll(sl()));
  sl.registerLazySingleton<DeletePayroll>(() => DeletePayroll(sl()));

  sl.registerLazySingleton<GetPayrollDetails>(() => GetPayrollDetails(sl()));
  sl.registerLazySingleton<AddPayrollDetail>(() => AddPayrollDetail(sl()));
  sl.registerLazySingleton<DeletePayrollDetail>(
      () => DeletePayrollDetail(sl()));

  sl.registerLazySingleton<GetPayrollRules>(() => GetPayrollRules(sl()));
  sl.registerLazySingleton<CreatePayrollRule>(() => CreatePayrollRule(sl()));
  sl.registerLazySingleton<UpdatePayrollRule>(() => UpdatePayrollRule(sl()));
  sl.registerLazySingleton<DeletePayrollRule>(() => DeletePayrollRule(sl()));
  sl.registerLazySingleton<GeneratePayrollEntries>(
      () => GeneratePayrollEntries(sl()));

  //! -------------------- Repositories --------------------
  // Auth
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(
        remoteDataSource: sl(),
        networkInfo: sl(),
      ));

  // Users
  sl.registerLazySingleton<UserRepository>(() => UserRepositoryImpl(
        remoteDataSource: sl(),
        networkInfo: sl(),
      ));

  // Clients
  sl.registerLazySingleton<ClientRepository>(() => ClientRepositoryImpl(
        remoteDataSource: sl(),
        networkInfo: sl(),
      ));

  // Branches
  sl.registerLazySingleton<BranchRepository>(() => BranchRepositoryImpl(
        remoteDataSource: sl(),
        networkInfo: sl(),
      ));

  // Attendance
  sl.registerLazySingleton<AttendanceRepository>(() => AttendanceRepositoryImpl(
        remoteDataSource: sl(),
        networkInfo: sl(),
      ));
  sl.registerLazySingleton<AttendanceRulesRepository>(
      () => AttendanceRulesRepositoryImpl(remote: sl()));

  // Payroll
  sl.registerLazySingleton<PayrollRepository>(() => PayrollRepositoryImpl(
        remoteDataSource: sl(),
        networkInfo: sl(),
      ));

  sl.registerLazySingleton<PayrollDetailRepository>(
      () => PayrollDetailRepositoryImpl(remoteDataSource: sl()));

  sl.registerLazySingleton<PayrollRulesRepository>(() =>
      PayrollRulesRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()));

  //! -------------------- DataSources --------------------
  // Auth
  sl.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(supabaseClient: sl()));

  // Users
  sl.registerLazySingleton<UserRemoteDataSource>(
      () => UserRemoteDataSourceImpl(supabaseClient: sl()));

  // Clients
  sl.registerLazySingleton<ClientRemoteDataSource>(
      () => ClientRemoteDataSourceImpl(supabaseClient: sl()));

  // Branches
  sl.registerLazySingleton<BranchRemoteDataSource>(
      () => BranchRemoteDataSourceImpl(supabaseClient: sl()));

  // Attendance
  sl.registerLazySingleton<AttendanceRemoteDataSource>(
      () => AttendanceRemoteDataSourceImpl(supabaseClient: sl()));
  sl.registerLazySingleton<AttendanceRulesRemoteDataSource>(
    () => AttendanceRulesRemoteDataSourceImpl(
      supabase: sl(),
    ),
  );

  // Payroll
  sl.registerLazySingleton<PayrollRemoteDataSource>(
      () => PayrollRemoteDataSourceImpl(client: sl()));

  sl.registerLazySingleton<PayrollDetailRemoteDataSource>(
      () => PayrollDetailRemoteDataSourceImpl(client: sl()));

  sl.registerLazySingleton<PayrollRulesDataSource>(
      () => PayrollRulesDataSource(supabase: sl()));

  //! -------------------- Core --------------------
  sl.registerLazySingleton<NetworkInfo>(() => AlwaysConnectedNetworkInfo());

  //! -------------------- External --------------------
  sl.registerLazySingleton<SupabaseClient>(() => SupabaseConfig.client);
}

Future<void> initializeSupabase() async {
  await SupabaseConfig.initialize();
}

// Alias
final getIt = sl;
