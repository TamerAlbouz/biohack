import 'package:firebase/firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formz/formz.dart';
import 'package:intl/intl.dart';
import 'package:medtalk/common/widgets/button/loading_button.dart';
import 'package:medtalk/common/widgets/button/success_button.dart';
import 'package:medtalk/common/widgets/custom_input_field.dart';
import 'package:medtalk/common/widgets/date_picker.dart';
import 'package:medtalk/common/widgets/dividers/section_divider.dart';
import 'package:medtalk/common/widgets/dropdown/custom_simple_dropdown.dart';
import 'package:medtalk/common/widgets/rounded_radio_button.dart';
import 'package:medtalk/patient/intro/cubit/intro_patient_cubit.dart';
import 'package:medtalk/patient/navigation/screens/navigation_patient_screen.dart';
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
            padding: kPaddL15R15T68B20,
            child: SingleChildScrollView(
              child: Column(
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
                    'Before we continue, we’d like more information about you to assist our doctors',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontSize: Font.medium),
                  ),
                  kGap10,
                  SectionDivider(),
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
                  SectionDivider(),
                  kGap10,
                  Text(
                    'Blood Group',
                    style: TextStyle(
                        fontSize: Font.mediumLarge,
                        fontWeight: FontWeight.bold),
                  ),
                  kGap14,
                  _BloodGroupInput(),
                  kGap10,
                  SectionDivider(),
                  kGap10,
                  Text(
                    'Body Measurements',
                    style: TextStyle(
                        fontSize: Font.mediumLarge,
                        fontWeight: FontWeight.bold),
                  ),
                  kGap14,
                  _HeightInput(),
                  _WeightInput(),
                  kGap10,
                  SectionDivider(),
                  kGap10,
                  Text(
                    'Additional Information',
                    style: TextStyle(
                        fontSize: Font.mediumLarge,
                        fontWeight: FontWeight.bold),
                  ),
                  kGap14,
                  _DateOfBirthInput(),
                  kGap10,
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
  const _FullNameInput();

  @override
  Widget build(BuildContext context) {
    var displayError = context
        .select((IntroPatientCubit cubit) => cubit.state.fullName.displayError);

    return InputField(
      hintText: "Full Name",
      onChanged: (name) =>
          context.read<IntroPatientCubit>().fullNameChanged(name),
      keyboardType: TextInputType.name,
      errorText: displayError != null ? "Invalid Full Name" : null,
    );
  }
}

// biography
class _BiographyInput extends StatelessWidget {
  const _BiographyInput();

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
class _BloodGroupInput extends StatefulWidget {
  const _BloodGroupInput();

  @override
  State<_BloodGroupInput> createState() => _BloodGroupInputState();
}

class _BloodGroupInputState extends State<_BloodGroupInput> {
  @override
  Widget build(BuildContext context) {
    return RadioButtonGroup(
      options: const ['O+', 'O-', 'A+', 'A-', 'B+', 'B-', 'AB+', 'AB-'],
      onChanged: (value) =>
          context.read<IntroPatientCubit>().bloodGroupChanged(value),
    );
  }
}

//height
class _HeightInput extends StatelessWidget {
  const _HeightInput();

  @override
  Widget build(BuildContext context) {
    var displayError = context
        .select((IntroPatientCubit cubit) => cubit.state.height.displayError);

    return InputField(
      hintText: "Height",
      onChanged: (height) =>
          context.read<IntroPatientCubit>().heightChanged(height),
      keyboardType: TextInputType.number,
      trailingWidget: const Text("cm"),
      errorText: displayError != null ? "Invalid Height" : null,
    );
  }
}

//weight
class _WeightInput extends StatelessWidget {
  const _WeightInput();

  @override
  Widget build(BuildContext context) {
    var displayError = context
        .select((IntroPatientCubit cubit) => cubit.state.weight.displayError);

    return InputField(
      hintText: "Weight",
      onChanged: (weight) =>
          context.read<IntroPatientCubit>().weightChanged(weight),
      keyboardType: TextInputType.number,
      trailingWidget: const Text("kg"),
      errorText: displayError != null ? "Invalid Weight" : null,
    );
  }
}

//age
class _DateOfBirthInput extends StatelessWidget {
  const _DateOfBirthInput();

  @override
  Widget build(BuildContext context) {
    DateFormat formatter = DateFormat('dd/MM/yyyy');
    return DatePicker(
      hint: 'Date of Birth',
      onSelected: (date) {
        context
            .read<IntroPatientCubit>()
            .dateOfBirthChanged(formatter.format(date));
      },
    );
  }
}

class _SexInput extends StatelessWidget {
  const _SexInput();

  @override
  Widget build(BuildContext context) {
    return CustomSimpleDropdown(
      items: const ["Male", "Female"],
      hint: 'Sex',
      onChanged: (value) =>
          context.read<IntroPatientCubit>().sexChanged(value ?? "Male"),
    );
  }
}

class _GetStartedButton extends StatelessWidget {
  const _GetStartedButton();

  @override
  Widget build(BuildContext context) {
    var status = context.select(
      (IntroPatientCubit cubit) => cubit.state.status,
    );

    var isValid = context.select(
      (IntroPatientCubit cubit) => cubit.state.isValid,
    );

    if (status.isInProgress) return const LoadingButton();

    if (status.isSuccess) {
      // return the button with a green background and a tick icon
      // navigate to the navigation screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil<void>(
          NavigationPatientScreen.route(),
          (route) => false,
        );
      });

      return const SuccessButton();
    }

    return ElevatedButton(
      onPressed: isValid
          ? () {
              var email =
                  context.read<IAuthenticationRepository>().currentUser.email;
              var uid =
                  context.read<IAuthenticationRepository>().currentUser.uid;
              context.read<IntroPatientCubit>().createPatient(email, uid);
            }
          : null,
      style: kElevatedButtonStyle,
      child: const Text('Get Started'),
    );
  }
}
