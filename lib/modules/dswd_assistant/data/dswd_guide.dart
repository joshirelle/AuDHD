import 'package:flutter/material.dart';

import '../../../core/i18n/language_controller.dart';

/// Isang papeles na hinihingi bago makakuha ng Guarantee Letter.
class DswdRequirement {
  const DswdRequirement({
    required this.id,
    required this.icon,
    required this.title,
    required this.body,
  });

  /// Susi sa Hive. Huwag isalin at huwag baguhin — mawawala ang tsek ng
  /// magulang kapag nagbago ito.
  final String id;

  final IconData icon;
  final String title;
  final String body;
}

/// Isang hakbang sa loob ng opisina.
class DswdStep {
  const DswdStep({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;
}

/// Nilalaman ng gabay sa DSWD Guarantee Letter.
///
/// Walang eksaktong halaga ng tulong, walang bilang ng araw ng proseso, at
/// walang oras ng pila dito. Nagkakaiba ito kada opisina at kada panahon, at
/// ang pekeng katiyakan ay naghahanda sa magulang sa maling bagay.
class DswdGuide {
  const DswdGuide._();

  static List<DswdRequirement> get requirements => [
    DswdRequirement(
      id: 'medical_abstract',
      icon: Icons.description_rounded,
      title: tr('Medical Abstract', 'Medical abstract'),
      body: tr(
        'Mula sa developmental o general pediatrician. Siguraduhing may lagda '
            'at License No. ang doktor — ito ang unang tinitingnan.\n\nAng '
            '"Ulat para sa Doktor" ng app na ito ay hindi kapalit nito. Tala '
            'iyon ng nakikita mo sa bahay, hindi dokumentong medikal.',
        'From a developmental or general pediatrician. Make sure it carries the '
            'doctor\'s signature and licence number — that is the first thing '
            'they look at.\n\nThe "Doctor Report" from this app is not a '
            'substitute. That is a record of what you see at home, not a '
            'medical document.',
      ),
    ),
    DswdRequirement(
      id: 'clinical_quotation',
      icon: Icons.receipt_long_rounded,
      title: tr('Quotation o bill', 'Quotation or bill'),
      body: tr(
        'Opisyal na presyo ng pagsusuri o sesyon — developmental evaluation, '
            'BERA, EEG, o therapy. Hingin ito sa billing ng ospital o '
            'klinika.\n\nItanong kung gaano katagal ang bisa nito. May '
            'opisinang tumatanggi sa lumang quotation.',
        'The official cost of the assessment or sessions — developmental '
            'evaluation, BERA, EEG, or therapy. Ask the billing section of the '
            'hospital or clinic for it.\n\nAsk how long it stays valid. Some '
            'offices turn away an old quotation.',
      ),
    ),
    DswdRequirement(
      id: 'barangay_indigency',
      icon: Icons.home_work_rounded,
      title: tr('Certificate of Indigency', 'Certificate of indigency'),
      body: tr(
        'Kunin sa barangay ninyo. Dapat nakapangalan sa magulang o guardian na '
            'mag-aapply, at nakasaad na may kinakailangang tulong pinansyal '
            'para sa anak.\n\nMay barangay na may sariling iskedyul ng '
            'pag-isyu, kaya mas mabuting ito ang unahin.',
        'Get this from your barangay. It should be in the name of the parent or '
            'guardian who will apply, and say that financial help is needed for '
            'the child.\n\nSome barangays only issue these on certain days, so '
            'it is worth starting here.',
      ),
    ),
    DswdRequirement(
      id: 'parent_valid_id',
      icon: Icons.badge_rounded,
      title: tr('Valid ID ng magulang', 'Parent\'s valid ID'),
      body: tr(
        'Government-issued ID ng mag-aapply. Magdala ng orihinal at ilang '
            'photocopy — madalas humihingi ng kopya ang bawat pinagdadaanang '
            'lamesa.',
        'A government-issued ID of whoever is applying. Bring the original and '
            'a few photocopies — each desk you pass tends to ask for one.',
      ),
    ),
    DswdRequirement(
      id: 'child_identity',
      icon: Icons.child_care_rounded,
      title: tr('Papeles ng bata', 'The child\'s papers'),
      body: tr(
        'Birth Certificate mula sa PSA o Local Civil Registrar. Kung may PWD ID '
            'na ang bata, dalhin din ito.\n\nHindi kailangang may PWD ID muna '
            'bago mag-apply. Hindi ito hinihinging kapalit ng birth '
            'certificate.',
        'A birth certificate from the PSA or the local civil registrar. If your '
            'child already has a PWD ID, bring that too.\n\nYou do not need a '
            'PWD ID before you can apply. It is not asked for in place of the '
            'birth certificate.',
      ),
    ),
  ];

  static List<DswdStep> get process => [
    DswdStep(
      icon: Icons.schedule_rounded,
      title: tr('Pumila nang maaga', 'Queue early'),
      body: tr(
        'May pila na bago pa magbukas ang opisina, at may araw na hindi na '
            'umaabot ang lahat. Kung kaya, iwan muna ang bata sa may '
            'magbabantay — mahaba ang paghihintay at walang laruan doon.',
        'There is a queue before the office opens, and on some days not '
            'everyone is reached. If you can, leave your child with someone — '
            'the wait is long and there is nothing there for them.',
      ),
    ),
    DswdStep(
      icon: Icons.record_voice_over_rounded,
      title: tr('Kapanayam ng social worker', 'The social worker interview'),
      body: tr(
        'Tatanungin ang kalagayan ng pamilya, ang kita, at kung para saan ang '
            'hinihinging tulong. Hindi ito pagsubok — paraan ito ng pagsusuri '
            'kung ano ang maibibigay.\n\nDito nakakatulong ang "Ulat para sa '
            'Doktor": ipinapakita nito kung ano ang pinagdadaanan ng anak mo '
            'araw-araw.',
        'You will be asked about your family\'s situation, your income, and '
            'what the help is for. This is not a test — it is how they work out '
            'what can be given.\n\nThe "Doctor Report" helps here: it shows what '
            'your child goes through day to day.',
      ),
    ),
    DswdStep(
      icon: Icons.fact_check_rounded,
      title: tr('Pagsusuri ng papeles', 'The papers are checked'),
      body: tr(
        'Isusumite ang buong set para sa verification. Kapag may kulang, '
            'karaniwang kailangang bumalik — kaya sulit ang dagdag na kopya at '
            'ang pagtsek bago umalis ng bahay.',
        'The whole set is handed over to be verified. If something is missing '
            'you will usually have to come back — which is why the extra '
            'photocopies, and a check before you leave the house, are worth it.',
      ),
    ),
    DswdStep(
      icon: Icons.assignment_turned_in_rounded,
      title: tr('Pagtanggap ng Guarantee Letter', 'Receiving the letter'),
      body: tr(
        'Kapag naaprubahan, may ibibigay na papel — ang Guarantee Letter. '
            'Basahin ang nakasulat na halaga at ang petsa ng bisa bago umalis, '
            'at itanong agad kung may hindi malinaw.',
        'If it is approved you will be handed a sheet of paper — the guarantee '
            'letter. Read the amount and the validity date before you leave, '
            'and ask right there if anything is unclear.',
      ),
    ),
    DswdStep(
      icon: Icons.local_hospital_rounded,
      title: tr('Ibigay sa ospital', 'Give it to the hospital'),
      body: tr(
        'Dalhin ang Guarantee Letter sa billing ng ospital o ng accredited na '
            'diagnostic center para ibawas sa babayaran. Sa ilang pampublikong '
            'ospital ay may Malasakit Center — itanong kung mayroon, dahil '
            'magkakasama roon ang mga tanggapan.',
        'Bring the guarantee letter to the billing section of the hospital or '
            'the accredited diagnostic centre so it can be taken off the bill. '
            'Some public hospitals have a Malasakit Center — ask, because the '
            'offices sit together there.',
      ),
    ),
  ];

  static String get disclaimer => tr(
    'Gabay lang ito, hindi opisyal na patakaran. Nagkakaiba ang hinihinging '
        'papeles kada opisina at nagbabago ito paminsan-minsan. Walang '
        'nakasisiguro na maaaprubahan ang aplikasyon — ang DSWD ang '
        'nagpapasya.',
    'This is a guide, not official policy. What is asked for differs from '
        'office to office and changes from time to time. Nobody can promise an '
        'application will be approved — that is for the DSWD to decide.',
  );
}
