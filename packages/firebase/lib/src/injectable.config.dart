// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:injectable/injectable.dart' as _i526;

import '../firebase.dart' as _i554;
import 'firebase_injectable_module.dart' as _i574;
import 'interfaces/appointment_interface.dart' as _i1019;
import 'interfaces/auth_interface.dart' as _i450;
import 'interfaces/medical_doc_interface.dart' as _i60;
import 'repositories/appointment_repository.dart' as _i885;
import 'repositories/auth_repository.dart' as _i665;
import 'repositories/medical_doc_repository.dart' as _i535;
import 'repositories/patient_repository.dart' as _i689;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final firebaseInjectableModule = _$FirebaseInjectableModule();
    gh.lazySingleton<_i116.GoogleSignIn>(
        () => firebaseInjectableModule.googleSignIn);
    gh.lazySingleton<_i59.FirebaseAuth>(
        () => firebaseInjectableModule.firebaseAuth);
    gh.lazySingleton<_i974.FirebaseFirestore>(
        () => firebaseInjectableModule.firestore);
    gh.lazySingleton<_i1019.IAppointmentRepository>(
        () => _i885.AppointmentRepository(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i554.IUserInterface>(
        () => _i689.PatientRepository(gh<_i974.FirebaseFirestore>()));
    gh.lazySingleton<_i450.IAuthenticationRepository>(
        () => _i665.AuthenticationRepository(
              gh<_i59.FirebaseAuth>(),
              gh<_i116.GoogleSignIn>(),
            ));
    gh.lazySingleton<_i60.IMedicalDocumentRepository>(
        () => _i535.MedicalDocumentRepository(gh<_i974.FirebaseFirestore>()));
    return this;
  }
}

class _$FirebaseInjectableModule extends _i574.FirebaseInjectableModule {}
