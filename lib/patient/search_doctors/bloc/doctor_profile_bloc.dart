import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'doctor_profile_event.dart';
part 'doctor_profile_state.dart';

@injectable
class DoctorProfileBloc extends Bloc<DoctorProfileEvent, DoctorProfileState> {
  DoctorProfileBloc() : super(const DoctorProfileState()) {
    on<LoadDoctorProfile>(_onLoadDoctorProfile);
  }

  Future<void> _onLoadDoctorProfile(
    LoadDoctorProfile event,
    Emitter<DoctorProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // This would normally come from an API call
      final doctorProfile = await _fetchDoctorProfileData(event.doctorId);

      emit(state.copyWith(
        isLoading: false,
        doctorProfilePicture: doctorProfile['profilePicture'],
        doctorBiography: doctorProfile['biography'],
        doctorRating: doctorProfile['rating'],
        reviewCount: doctorProfile['reviewCount'],
        doctorAge: doctorProfile['age'],
        doctorGender: doctorProfile['gender'],
        doctorQualifications: doctorProfile['specializations'],
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load doctor profile: ${e.toString()}',
      ));
    }
  }

  // Mock data fetching - this would normally be a repository call
  Future<Map<String, dynamic>> _fetchDoctorProfileData(String doctorId) async {
    // Mocked response
    return {
      'profilePicture': null,
      // This would be an image URL in a real application
      'biography': 'Dr. Smith is a board-certified cardiologist with over 15 years of clinical experience. '
          'He specializes in preventive cardiology, heart failure management, and interventional procedures. '
          'His approach to patient care combines the latest evidence-based medicine with personalized treatment plans. '
          'Dr. Smith is passionate about patient education and believes that informed patients achieve better health outcomes. '
          'Outside of his medical practice, he enjoys hiking, playing classical piano, and volunteering at community health clinics.',
      'rating': 4.8,
      'reviewCount': 142,
      'age': 48,
      'gender': 'Male',
      'languages': ['English', 'Spanish', 'French'],
      'specializations': [
        'Cardiology',
        'Interventional Cardiology',
        'Preventive Medicine',
        'Heart Failure Management'
      ],
      'education': [
        {
          'degree': 'Doctor of Medicine (MD)',
          'institution': 'Harvard Medical School',
          'startYear': 2000,
          'endYear': 2004,
          'description':
              'Graduated with honors, focusing on cardiovascular studies.'
        },
        {
          'degree': 'Residency in Internal Medicine',
          'institution': 'Massachusetts General Hospital',
          'startYear': 2004,
          'endYear': 2007,
          'description':
              'Completed comprehensive training in internal medicine with rotations in cardiology.'
        },
        {
          'degree': 'Fellowship in Cardiology',
          'institution': 'Stanford University Medical Center',
          'startYear': 2007,
          'endYear': 2010,
          'description':
              'Specialized training in advanced cardiac care and interventional procedures.'
        }
      ],
      'certifications': [
        {
          'name': 'Board Certification in Cardiology',
          'issuingOrganization': 'American Board of Internal Medicine',
          'issueDate': '2011-05-15',
          'expiryDate': '2031-05-15',
          'credentialId': 'ABIM-CARD-123456'
        },
        {
          'name': 'Advanced Cardiac Life Support (ACLS)',
          'issuingOrganization': 'American Heart Association',
          'issueDate': '2020-03-10',
          'expiryDate': '2024-03-10',
          'credentialId': 'AHA-ACLS-789012'
        },
        {
          'name': 'Certification in Advanced Echocardiography',
          'issuingOrganization': 'National Board of Echocardiography',
          'issueDate': '2012-11-22',
          'expiryDate': null,
          'credentialId': 'NBE-ECHO-345678'
        }
      ],
      'experience': [
        {
          'position': 'Chief of Cardiology',
          'organization': 'Metro Hospital',
          'startDate': '2018-07-01',
          'endDate': null,
          'isCurrentPosition': true,
          'location': 'Boston, MA',
          'description':
              'Leading the cardiology department, overseeing clinical operations, and implementing new treatment protocols. Supervising a team of 12 cardiologists and 25 support staff.'
        },
        {
          'position': 'Associate Professor of Medicine',
          'organization': 'Boston University School of Medicine',
          'startDate': '2015-09-01',
          'endDate': null,
          'isCurrentPosition': true,
          'location': 'Boston, MA',
          'description':
              'Teaching medical students and residents about cardiovascular medicine. Conducting clinical research on heart failure treatments.'
        },
        {
          'position': 'Attending Cardiologist',
          'organization': 'City Medical Center',
          'startDate': '2010-08-15',
          'endDate': '2018-06-30',
          'isCurrentPosition': false,
          'location': 'Chicago, IL',
          'description':
              'Provided comprehensive cardiac care including consultations, diagnostic testing, and follow-up care. Performed interventional procedures and managed the cardiac ICU.'
        }
      ],
      'publications': [
        {
          'title':
              'Long-term Outcomes of Early Intervention in Acute Coronary Syndrome',
          'publisher': 'Journal of the American College of Cardiology',
          'publicationDate': '2019-04-10',
          'abstract':
              'This study examined the 5-year outcomes of patients who received early intervention for acute coronary syndrome compared to those with delayed treatment. Our findings suggest significant improvements in mortality and quality of life metrics for the early intervention group.',
          'url': 'https://example.com/publication1',
          'coAuthors': ['Dr. Jane Williams', 'Dr. Robert Chen']
        },
        {
          'title': 'Novel Biomarkers for Predicting Heart Failure Progression',
          'publisher': 'New England Journal of Medicine',
          'publicationDate': '2017-09-22',
          'abstract':
              'We identified three novel biomarkers that show promise in predicting the progression of heart failure in patients with reduced ejection fraction. These markers may help identify patients who would benefit from more aggressive treatment approaches.',
          'url': 'https://example.com/publication2',
          'coAuthors': [
            'Dr. Michael Johnson',
            'Dr. Lisa Zhang',
            'Dr. Thomas Brown'
          ]
        },
        {
          'title':
              'The Impact of Lifestyle Modifications on Cardiovascular Risk Reduction',
          'publisher': 'American Heart Journal',
          'publicationDate': '2020-01-15',
          'abstract':
              'This comprehensive review analyzes the comparative effectiveness of various lifestyle interventions in reducing cardiovascular risk factors. Our analysis suggests that combined dietary changes and structured exercise programs yield the most significant improvements.',
          'url': 'https://example.com/publication3',
          'coAuthors': ['Dr. Emily Parker']
        }
      ],
    };
  }
}
