import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medtalk/common/widgets/custom_input_field.dart';
import 'package:medtalk/intro/cubit/intro_patient_cubit.dart';
import 'package:medtalk/styles/colors.dart';
import 'package:medtalk/styles/sizes.dart';
import 'package:medtalk/styles/styles/button.dart';

import '../../../styles/font.dart';

class IntroScreenPatient extends StatelessWidget {
  const IntroScreenPatient({super.key});

  static Route<void> route() {
    return MaterialPageRoute<void>(builder: (_) => const IntroScreenPatient());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IntroPatientCubit(getIt<IPatientRepository>()),
      child: BlocListener<IntroPatientCubit, IntroPatientState>(
        listener: (context, state) {
          // TODO: implement listener
        },
        child: const Scaffold(
          body: Padding(
            padding: kPaddL20R20T68B20,
            child: SingleChildScrollView(
              child: Column(
                textDirection: TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Hello!',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: Font.largest, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Before we continue, we’d like more info about you to assist our doctors',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: Font.mediumLarge),
                  ),
                  kGap10,
                  Divider(color: MyColors.lineDivider),
                  kGap10,
                  Text(
                    'Personal Information',
                    style: TextStyle(
                        fontSize: Font.mediumLarge,
                        fontWeight: FontWeight.bold),
                  ),
                  kGap14,
                  _FullNameInput(),
                  _BiographyInput(),
                  kGap10,
                  Divider(color: MyColors.lineDivider),
                  kGap10,
                  Text(
                    'Health Information',
                    style: TextStyle(
                        fontSize: Font.mediumLarge,
                        fontWeight: FontWeight.bold),
                  ),
                  kGap14,
                  _BloodGroupInput(),
                  _HeightInput(),
                  _WeightInput(),
                  kGap10,
                  Divider(color: MyColors.lineDivider),
                  kGap10,
                  Text(
                    'Additional Information',
                    style: TextStyle(
                        fontSize: Font.mediumLarge,
                        fontWeight: FontWeight.bold),
                  ),
                  kGap14,
                  _DateOfBirthInput(),
                  _SexInput(),
                  kGap10,
                  _GetStartedButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FullNameInput extends StatelessWidget {
  const _FullNameInput({super.key});

  @override
  Widget build(BuildContext context) {
    var displayError = context
        .select((IntroPatientCubit cubit) => cubit.state.fullName.displayError);

    return InputField(
        hintText: "Full Name",
        onChanged: (name) =>
            context.read<IntroPatientCubit>().fullNameChanged(name),
        keyboardType: TextInputType.name,
        errorText: displayError != null ? "Invalid Full Name" : null);
  }
}

// biography
class _BiographyInput extends StatelessWidget {
  const _BiographyInput({super.key});

  @override
  Widget build(BuildContext context) {
    var displayError = context.select(
        (IntroPatientCubit cubit) => cubit.state.biography.displayError);

    return InputField(
        hintText: "Biography (Optional)",
        height: 150,
        onChanged: (bio) =>
            context.read<IntroPatientCubit>().biographyChanged(bio),
        keyboardType: TextInputType.text,
        errorText: displayError != null ? "Invalid Biography" : null);
  }
}

// blood group
class _BloodGroupInput extends StatelessWidget {
  const _BloodGroupInput({super.key});

  @override
  Widget build(BuildContext context) {
    var displayError = context.select(
        (IntroPatientCubit cubit) => cubit.state.bloodGroup.displayError);

    return InputField(
        hintText: "Blood Group",
        onChanged: (blood) =>
            context.read<IntroPatientCubit>().bloodGroupChanged(blood),
        keyboardType: TextInputType.text,
        errorText: displayError != null ? "Invalid Blood Group" : null);
  }
}

//height
class _HeightInput extends StatelessWidget {
  const _HeightInput({super.key});

  @override
  Widget build(BuildContext context) {
    var displayError = context
        .select((IntroPatientCubit cubit) => cubit.state.height.displayError);

    return InputField(
        hintText: "Height",
        onChanged: (height) => context
            .read<IntroPatientCubit>()
            .heightChanged(double.tryParse(height) ?? 0),
        keyboardType: TextInputType.number,
        errorText: displayError != null ? "Invalid Height" : null);
  }
}

//weight
class _WeightInput extends StatelessWidget {
  const _WeightInput({super.key});

  @override
  Widget build(BuildContext context) {
    var displayError = context
        .select((IntroPatientCubit cubit) => cubit.state.weight.displayError);

    return InputField(
        hintText: "Weight",
        onChanged: (weight) => context
            .read<IntroPatientCubit>()
            .weightChanged(double.tryParse(weight) ?? 0),
        keyboardType: TextInputType.number,
        errorText: displayError != null ? "Invalid Weight" : null);
  }
}

//age
class _DateOfBirthInput extends StatelessWidget {
  const _DateOfBirthInput({super.key});

  @override
  Widget build(BuildContext context) {
    var displayError = context.select(
        (IntroPatientCubit cubit) => cubit.state.dateOfBirth.displayError);
    return InputField(
        hintText: "Date of Birth",
        onChanged: (dob) =>
            context.read<IntroPatientCubit>().dateOfBirthChanged(dob),
        keyboardType: TextInputType.datetime,
        errorText: displayError != null ? "Invalid Date" : null);
  }
}

class _SexInput extends StatelessWidget {
  const _SexInput({super.key});

  @override
  Widget build(BuildContext context) {
    var displayError = context
        .select((IntroPatientCubit cubit) => cubit.state.sex.displayError);
    return InputField(
        hintText: "Sex",
        onChanged: (sex) => context.read<IntroPatientCubit>().sexChanged(sex),
        keyboardType: TextInputType.text,
        errorText: displayError != null ? "Invalid Sex" : null);
  }
}

class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        var email = context.read<IAuthenticationRepository>().currentUser.email;
        var uid = context.read<IAuthenticationRepository>().currentUser.uid;
        context.read<IntroPatientCubit>().createPatient(email, uid);
      },
      style: kMainButtonStyle,
      child: const Text('Get Started'),
    );
  }
}
