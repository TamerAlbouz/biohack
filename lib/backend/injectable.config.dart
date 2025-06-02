// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:cloud_functions/cloud_functions.dart' as _i809;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:firebase_storage/firebase_storage.dart' as _i457;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:logger/logger.dart' as _i974;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../agora/bloc/agora_bloc.dart' as _i595;
import '../app/bloc/auth/route_bloc.dart' as _i522;
import '../bloc_observer.dart' as _i55;
import '../doctor/appointments/bloc/doctor_appointments_bloc.dart' as _i1063;
import '../doctor/dashboard/bloc/doctor_dashboard_bloc.dart' as _i990;
import '../doctor/design/bloc/design_bloc.dart' as _i480;
import '../doctor/navigation/cubit/navigation_doctor_cubit.dart' as _i194;
import '../doctor/patients/bloc/chat_bloc.dart' as _i158;
import '../doctor/patients/bloc/patient_details_bloc.dart' as _i634;
import '../doctor/patients/bloc/patients_list_bloc.dart' as _i65;
import '../doctor/signup/bloc/signup_doctor_bloc.dart' as _i125;
import '../doctor/stats/bloc/statistics_bloc.dart' as _i611;
import '../login/bloc/forgot_password_bloc.dart' as _i93;
import '../login/bloc/login_bloc.dart' as _i1034;
import '../patient/chat/bloc/chat_list/chat_list_bloc.dart' as _i684;
import '../patient/chat/bloc/chat_room/chat_bloc.dart' as _i342;
import '../patient/dashboard/bloc/appointment/appointment_bloc.dart' as _i600;
import '../patient/dashboard/bloc/doctor/doctor_bloc.dart' as _i246;
import '../patient/dashboard/bloc/document/document_bloc.dart' as _i621;
import '../patient/dashboard/bloc/patient/patient_bloc.dart' as _i161;
import '../patient/navigation/cubit/navigation_patient_cubit.dart' as _i256;
import '../patient/profile/bloc/patient_profile_bloc.dart' as _i108;
import '../patient/search_doctors/bloc/doctor_profile_bloc.dart' as _i688;
import '../patient/search_doctors/bloc/search_doctors_bloc.dart' as _i461;
import '../patient/search_doctors/bloc/setup_appointment_bloc.dart' as _i873;
import '../patient/signup/bloc/signup_patient_bloc.dart' as _i425;
import 'appointment/interfaces/appointment_interface.dart' as _i715;
import 'appointment/repositories/appointment_repository.dart' as _i490;
import 'authentication/interfaces/auth_interface.dart' as _i953;
import 'authentication/repositories/auth_repository.dart' as _i924;
import 'backend_injectable_module.dart' as _i17;
import 'cache/shared_preferences.dart' as _i957;
import 'chat/interfaces/chat_interface.dart' as _i43;
import 'chat/repositories/chat_repository.dart' as _i512;
import 'doctor/interfaces/doctor_interface.dart' as _i999;
import 'doctor/repositories/doctor_repository.dart' as _i383;
import 'encryption/interfaces/crypto_interface.dart' as _i710;
import 'encryption/interfaces/encryption_interface.dart' as _i417;
import 'encryption/interfaces/secure_encryption_repository_interface.dart'
    as _i672;
import 'encryption/repositories/crypto_repository.dart' as _i378;
import 'encryption/repositories/encryption_repository.dart' as _i721;
import 'encryption/repositories/secure_encryption_storage_repository.dart'
    as _i788;
import 'hashing/interfaces/hash_interface.dart' as _i481;
import 'hashing/repositories/hash_repository.dart' as _i954;
import 'mail/interfaces/mail_interface.dart' as _i436;
import 'mail/repositories/mail_respoitory.dart' as _i810;
import 'medical_doc/interfaces/medical_doc_interface.dart' as _i535;
import 'medical_doc/repositories/medical_doc_repository.dart' as _i126;
import 'patient/interfaces/patient_interface.dart' as _i1064;
import 'patient/repositories/patient_repository.dart' as _i784;
import 'rate_limiter/interfaces/rate_limiter_interface.dart' as _i802;
import 'rate_limiter/repositories/rate_limiter_repository.dart' as _i938;
import 'secure_storage/interfaces/secure_storage_interface.dart' as _i386;
import 'secure_storage/repositories/secure_storage_repository.dart' as _i338;
import 'services/interfaces/services_interface.dart' as _i35;
import 'services/repositories/services_repository.dart' as _i796;
import 'storage/interfaces/storage_interface.dart' as _i317;
import 'storage/repositories/storage_repository.dart' as _i636;
import 'user/interfaces/user_interface.dart' as _i153;
import 'user/repositories/user_repository.dart' as _i456;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final backendInjectableModule = _$BackendInjectableModule();
    gh.factory<_i158.ChatBloc>(() => _i158.ChatBloc());
    gh.factory<_i256.NavigationPatientCubit>(
        () => _i256.NavigationPatientCubit());
    gh.factory<_i688.DoctorProfileBloc>(() => _i688.DoctorProfileBloc());
    gh.singleton<_i974.Logger>(() => backendInjectableModule.logger);
    gh.lazySingleton<_i457.FirebaseStorage>(
        () => backendInjectableModule.firebaseStorage);
    await gh.lazySingletonAsync<_i460.SharedPreferences>(
      () => backendInjectableModule.sharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i59.FirebaseAuth>(
        () => backendInjectableModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(
        () => backendInjectableModule.firestore);
    gh.lazySingleton<_i809.FirebaseFunctions>(
        () => backendInjectableModule.functions);
    gh.lazySingleton<_i481.IHashRepository>(() => _i954.HashRepository());
    gh.lazySingleton<_i417.IEncryptionRepository>(
        () => _i721.EncryptionRepository(
              gh<_i974.FirebaseFirestore>(),
              gh<_i974.Logger>(),
            ));
    gh.lazySingleton<_i317.IStorageRepository>(() => _i636.StorageRepository(
          storage: gh<_i457.FirebaseStorage>(),
          logger: gh<_i974.Logger>(),
        ));
    gh.lazySingleton<_i35.IServiceRepository>(() => _i796.ServicesRepository(
          gh<_i974.FirebaseFirestore>(),
          gh<_i974.Logger>(),
        ));
    gh.factory<_i595.AgoraBloc>(() => _i595.AgoraBloc(gh<_i974.Logger>()));
    gh.factory<_i55.CustomBlocObserver>(
        () => _i55.CustomBlocObserver(gh<_i974.Logger>()));
    gh.lazySingleton<_i953.IAuthenticationRepository>(
        () => _i924.AuthenticationRepository(
              gh<_i59.FirebaseAuth>(),
              gh<_i809.FirebaseFunctions>(),
              gh<_i974.Logger>(),
            ));
    gh.lazySingleton<_i802.IRateLimiter>(() => _i938.RateLimiter(
          gh<_i974.FirebaseFirestore>(),
          gh<_i974.Logger>(),
        ));
    gh.lazySingleton<_i535.IMedicalDocumentRepository>(
        () => _i126.MedicalDocumentRepository(
              gh<_i974.FirebaseFirestore>(),
              gh<_i974.Logger>(),
            ));
    gh.lazySingleton<_i1064.IPatientRepository>(() => _i784.PatientRepository(
          gh<_i974.FirebaseFirestore>(),
          gh<_i974.Logger>(),
        ));
    gh.factory<_i108.PatientProfileBloc>(() => _i108.PatientProfileBloc(
          gh<_i1064.IPatientRepository>(),
          gh<_i974.Logger>(),
        ));
    gh.lazySingleton<_i715.IAppointmentRepository>(
        () => _i490.AppointmentRepository(
              gh<_i974.FirebaseFirestore>(),
              gh<_i974.Logger>(),
            ));
    gh.lazySingleton<_i43.IChatRepository>(() => _i512.ChatRepository(
          gh<_i974.FirebaseFirestore>(),
          gh<_i974.Logger>(),
        ));
    gh.lazySingleton<_i957.UserPreferences>(() => _i957.UserPreferences(
          gh<_i460.SharedPreferences>(),
          gh<_i974.Logger>(),
        ));
    gh.lazySingleton<_i153.IUserRepository>(() => _i456.UserRepository());
    gh.factory<_i684.ChatsListBloc>(() => _i684.ChatsListBloc(
          gh<_i43.IChatRepository>(),
          gh<_i974.Logger>(),
        ));
    gh.factory<_i342.ChatBloc>(() => _i342.ChatBloc(
          gh<_i43.IChatRepository>(),
          gh<_i974.Logger>(),
        ));
    gh.lazySingleton<_i436.IMailRepository>(() => _i810.MailRepository(
          gh<_i974.FirebaseFirestore>(),
          gh<_i974.Logger>(),
        ));
    gh.lazySingleton<_i999.IDoctorRepository>(() => _i383.DoctorRepository(
          gh<_i974.FirebaseFirestore>(),
          gh<_i974.Logger>(),
        ));
    gh.factory<_i990.DoctorDashboardBloc>(() => _i990.DoctorDashboardBloc(
          gh<_i953.IAuthenticationRepository>(),
          gh<_i715.IAppointmentRepository>(),
          gh<_i1064.IPatientRepository>(),
          gh<_i974.Logger>(),
        ));
    gh.factory<_i611.DoctorStatsBloc>(() => _i611.DoctorStatsBloc(
          gh<_i953.IAuthenticationRepository>(),
          gh<_i715.IAppointmentRepository>(),
          gh<_i1064.IPatientRepository>(),
          gh<_i974.Logger>(),
        ));
    gh.lazySingleton<_i386.ISecureStorageRepository>(
        () => _i338.SecureStorageRepository());
    gh.factory<_i873.SetupAppointmentBloc>(() => _i873.SetupAppointmentBloc(
          gh<_i436.IMailRepository>(),
          gh<_i715.IAppointmentRepository>(),
          gh<_i953.IAuthenticationRepository>(),
          gh<_i999.IDoctorRepository>(),
          gh<_i1064.IPatientRepository>(),
          gh<_i974.Logger>(),
        ));
    gh.factory<_i522.RouteBloc>(() => _i522.RouteBloc(
          gh<_i953.IAuthenticationRepository>(),
          gh<_i957.UserPreferences>(),
          gh<_i386.ISecureStorageRepository>(),
          gh<_i974.Logger>(),
        ));
    gh.factory<_i194.NavigationDoctorCubit>(() => _i194.NavigationDoctorCubit(
          gh<_i953.IAuthenticationRepository>(),
          gh<_i999.IDoctorRepository>(),
          gh<_i974.Logger>(),
        ));
    gh.lazySingleton<_i710.ICryptoRepository>(
        () => _i378.CryptoRepository(gh<_i974.Logger>()));
    gh.factory<_i161.PatientBloc>(() => _i161.PatientBloc(
          gh<_i1064.IPatientRepository>(),
          gh<_i953.IAuthenticationRepository>(),
          gh<_i974.Logger>(),
        ));
    gh.factory<_i125.SignUpDoctorBloc>(() => _i125.SignUpDoctorBloc(
          gh<_i710.ICryptoRepository>(),
          gh<_i953.IAuthenticationRepository>(),
          gh<_i417.IEncryptionRepository>(),
          gh<_i999.IDoctorRepository>(),
          gh<_i1064.IPatientRepository>(),
          gh<_i386.ISecureStorageRepository>(),
          gh<_i317.IStorageRepository>(),
          gh<_i974.Logger>(),
        ));
    gh.factory<_i246.PatientDoctorBloc>(
        () => _i246.PatientDoctorBloc(gh<_i999.IDoctorRepository>()));
    gh.factory<_i461.SearchDoctorsBloc>(() => _i461.SearchDoctorsBloc(
          gh<_i999.IDoctorRepository>(),
          gh<_i974.Logger>(),
        ));
    gh.factory<_i600.PatientAppointmentBloc>(
        () => _i600.PatientAppointmentBloc(gh<_i715.IAppointmentRepository>()));
    gh.factory<_i65.PatientsBloc>(() => _i65.PatientsBloc(
          gh<_i953.IAuthenticationRepository>(),
          gh<_i1064.IPatientRepository>(),
          gh<_i715.IAppointmentRepository>(),
          gh<_i974.Logger>(),
        ));
    gh.factory<_i1034.LoginBloc>(() => _i1034.LoginBloc(
          gh<_i953.IAuthenticationRepository>(),
          gh<_i417.IEncryptionRepository>(),
          gh<_i386.ISecureStorageRepository>(),
          gh<_i710.ICryptoRepository>(),
          gh<_i974.Logger>(),
        ));
    gh.factory<_i480.DesignBloc>(() => _i480.DesignBloc(
          gh<_i953.IAuthenticationRepository>(),
          gh<_i999.IDoctorRepository>(),
          gh<_i974.Logger>(),
        ));
    gh.factory<_i621.PatientDocumentBloc>(() =>
        _i621.PatientDocumentBloc(gh<_i535.IMedicalDocumentRepository>()));
    gh.factory<_i1063.DoctorAppointmentsBloc>(
        () => _i1063.DoctorAppointmentsBloc(
              gh<_i715.IAppointmentRepository>(),
              gh<_i953.IAuthenticationRepository>(),
              gh<_i1064.IPatientRepository>(),
              gh<_i974.Logger>(),
            ));
    gh.factory<_i634.PatientDetailsBloc>(() => _i634.PatientDetailsBloc(
          gh<_i1064.IPatientRepository>(),
          gh<_i715.IAppointmentRepository>(),
          gh<_i974.Logger>(),
        ));
    gh.factory<_i425.SignUpPatientBloc>(() => _i425.SignUpPatientBloc(
          gh<_i710.ICryptoRepository>(),
          gh<_i953.IAuthenticationRepository>(),
          gh<_i417.IEncryptionRepository>(),
          gh<_i1064.IPatientRepository>(),
          gh<_i386.ISecureStorageRepository>(),
          gh<_i974.Logger>(),
        ));
    gh.factory<_i93.ForgotPasswordBloc>(() => _i93.ForgotPasswordBloc(
          gh<_i953.IAuthenticationRepository>(),
          gh<_i417.IEncryptionRepository>(),
          gh<_i710.ICryptoRepository>(),
          gh<_i802.IRateLimiter>(),
          gh<_i974.Logger>(),
        ));
    gh.lazySingleton<_i672.ISecureEncryptionStorage>(
        () => _i788.SecureEncryptionStorageRepository(
              gh<_i710.ICryptoRepository>(),
              gh<_i386.ISecureStorageRepository>(),
              gh<_i974.Logger>(),
            ));
    return this;
  }
}

class _$BackendInjectableModule extends _i17.BackendInjectableModule {}
