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
import '../../features/auth/domain/usecases/reset_password_usecase.dart';

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
import '../../features/payroll/domain/usecases/get_payroll_regulation_usecase.dart';
import '../../features/payroll/domain/usecases/update_payroll_regulation_usecase.dart';
import '../../features/payroll/domain/usecases/get_employee_salary_profile_usecase.dart';
import '../../features/payroll/domain/usecases/upsert_employee_salary_profile_usecase.dart';
import '../../features/payroll/domain/usecases/get_employee_salary_component_ids_usecase.dart';
import '../../features/payroll/domain/usecases/update_employee_salary_components_usecase.dart';

// Landing
import '../../features/landing/data/datasources/landing_remote_datasource.dart';
import '../../features/landing/data/repositories/landing_repository_impl.dart';
import '../../features/landing/domain/repositories/landing_repository.dart';
import '../../features/landing/domain/usecases/get_landing_content_usecase.dart';
import '../../features/landing/domain/usecases/update_landing_content_usecase.dart';
import '../../features/landing/presentation/cubit/landing_cubit.dart';

// Payment
import '../../features/payment/data/datasources/payment_remote_datasource.dart';
import '../../features/payment/data/repositories/payment_repository_impl.dart';
import '../../features/payment/domain/repositories/payment_repository.dart';
import '../../features/payment/domain/usecases/get_plans_usecase.dart';
import '../../features/payment/domain/usecases/get_payment_methods_usecase.dart';
import '../../features/payment/domain/usecases/create_transaction_usecase.dart';
import '../../features/payment/domain/usecases/get_subscription_usecase.dart';
import '../../features/payment/domain/usecases/get_all_transactions_usecase.dart';
import '../../features/payment/domain/usecases/approve_transaction_usecase.dart';
import '../../features/payment/presentation/cubit/payment_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! -------------------- Cubits --------------------
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit());
  sl.registerLazySingleton<LocaleCubit>(() => LocaleCubit());

  sl.registerFactory<LoginCubit>(() => LoginCubit());
  sl.registerFactory<AuthCubit>(() => AuthCubit());
  sl.registerFactory<LandingCubit>(() => LandingCubit());
  sl.registerFactory<PaymentCubit>(() => PaymentCubit(
        getPlans: sl(),
        getMethods: sl(),
        createTransaction: sl(),
        getSubscription: sl(),
        getAllTransactions: sl(),
        approveTransaction: sl(),
      ));

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
        getPayrollRegulationUseCase: sl(),
        updatePayrollRegulationUseCase: sl(),
        getEmployeeSalaryProfileUseCase: sl(),
        upsertEmployeeSalaryProfileUseCase: sl(),
        getEmployeeSalaryComponentIdsUseCase: sl(),
        updateEmployeeSalaryComponentsUseCase: sl(),
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

  // Landing
  sl.registerLazySingleton<LandingRemoteDataSource>(
      () => LandingRemoteDataSourceImpl(supabaseClient: sl()));
  sl.registerLazySingleton<LandingRepository>(
      () => LandingRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<GetLandingContentUseCase>(
      () => GetLandingContentUseCase(sl()));
  sl.registerLazySingleton<UpdateLandingContentUseCase>(
      () => UpdateLandingContentUseCase(sl()));

  // Payment
  sl.registerLazySingleton<PaymentRemoteDataSource>(
      () => PaymentRemoteDataSourceImpl(supabaseClient: sl()));
  sl.registerLazySingleton<PaymentRepository>(
      () => PaymentRepositoryImpl(remoteDataSource: sl()));
  sl.registerLazySingleton<GetPlansUseCase>(() => GetPlansUseCase(sl()));
  sl.registerLazySingleton<GetPaymentMethodsUseCase>(
      () => GetPaymentMethodsUseCase(sl()));
  sl.registerLazySingleton<CreateTransactionUseCase>(
      () => CreateTransactionUseCase(sl()));
  sl.registerLazySingleton<GetSubscriptionUseCase>(
      () => GetSubscriptionUseCase(sl()));
  sl.registerLazySingleton<GetAllTransactionsUseCase>(
      () => GetAllTransactionsUseCase(sl()));
  sl.registerLazySingleton<ApproveTransactionUseCase>(
      () => ApproveTransactionUseCase(sl()));

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
  sl.registerLazySingleton<GetPayrollRegulationUseCase>(
      () => GetPayrollRegulationUseCase(sl()));
  sl.registerLazySingleton<UpdatePayrollRegulationUseCase>(
      () => UpdatePayrollRegulationUseCase(sl()));
  sl.registerLazySingleton<GetEmployeeSalaryProfileUseCase>(
      () => GetEmployeeSalaryProfileUseCase(sl()));
  sl.registerLazySingleton<UpsertEmployeeSalaryProfileUseCase>(
      () => UpsertEmployeeSalaryProfileUseCase(sl()));
  sl.registerLazySingleton<GetEmployeeSalaryComponentIdsUseCase>(
      () => GetEmployeeSalaryComponentIdsUseCase(sl()));
  sl.registerLazySingleton<UpdateEmployeeSalaryComponentsUseCase>(
      () => UpdateEmployeeSalaryComponentsUseCase(sl()));

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
