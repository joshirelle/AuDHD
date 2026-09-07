import '../../../core/i18n/language_controller.dart';
import '../../../core/models/schedule_task.dart';
import '../../../data/models/child_profile.dart';

/// Isang handang gawain na maaaring idagdag ng magulang sa araw ng bata.
///
/// HINDI ito awtomatikong pumapasok sa iskedyul. Ang magulang ang pipindot.
/// Ang iskedyul na nagbabago dahil may kinalikot sa ibang screen ay sumisira
/// sa mismong dahilan kung bakit may visual schedule — ang pagiging tiyak.
class TaskSuggestion {
  const TaskSuggestion({
    required this.id,
    required this.titleTagalog,
    required this.titleEnglish,
    required this.iconKey,
    required this.timeOfDay,
    required this.whyFil,
    required this.whyEn,
    this.relevantTo = const {},
  });

  /// Nagiging `ScheduleTask.id` ito kapag idinagdag. Nakatakda at hindi uuid:
  /// hindi nadodoble kapag naipindot nang dalawang beses, at nagkakasundo
  /// pagkatapos ng restore. Susi sa Hive — huwag baguhin.
  final String id;

  final String titleTagalog;
  final String titleEnglish;
  final String iconKey;
  final ScheduleTimeOfDay timeOfDay;

  /// Bakit ito nakakatulong. Isang linya lang — ang mungkahing walang dahilan
  /// ay utos, hindi gabay.
  final String whyFil;
  final String whyEn;

  final Set<SupportFocus> relevantTo;

  String get title => tr(titleTagalog, titleEnglish);
  String get why => tr(whyFil, whyEn);

  /// Bituin ang lahat ng mungkahi: pantay ang halaga ng bawat gawain sa
  /// bata, at hindi natin masasabi kung alin ang mas mahirap para sa kanya.
  ScheduleTask toTask() => ScheduleTask(
    id: id,
    titleTagalog: titleTagalog,
    titleEnglish: titleEnglish,
    iconKey: iconKey,
    timeOfDay: timeOfDay,
  );
}

/// Mga handang gawain, nakaayos ayon sa bahagi ng araw.
///
/// Tatlong panuntunan sa pagsulat dito, gaya ng `GuideCards`:
/// 1. Pananaw ng magulang. Walang sinasabing sanhi, at walang ipinapangakong
///    resulta. Hindi natin sinasabi kung paano ito gumagana sa katawan o utak
///    ng bata — hindi natin trabaho iyon.
/// 2. "Maaaring" at "may batang", hindi "lahat ng bata".
/// 3. Orihinal ang bawat pangungusap.
class TaskSuggestions {
  const TaskSuggestions._();

  static List<TaskSuggestion> get all => [
    // ---------------------------------------------------------------- umaga
    TaskSuggestion(
      id: 'sug_tingnan_araw',
      titleTagalog: 'Tingnan ang Araw',
      titleEnglish: 'Look at the Day',
      iconKey: 'book',
      timeOfDay: ScheduleTimeOfDay.morning,
      whyFil:
          'Dumaan sa iskedyul bago magsimula. Mas magaan ang araw kapag alam '
          'na niya ang susunod.',
      whyEn:
          'Go through the schedule before starting. The day is lighter when '
          'they already know what comes next.',
      relevantTo: {SupportFocus.asd, SupportFocus.adhd},
    ),
    TaskSuggestion(
      id: 'sug_galaw_bago_upo',
      titleTagalog: 'Galaw Bago Umupo',
      titleEnglish: 'Move Before Sitting',
      iconKey: 'run',
      timeOfDay: ScheduleTimeOfDay.morning,
      whyFil:
          'Limang minutong takbo o talon bago ang gawaing nakaupo. May batang '
          'mas nakakaupo nang matagal kapag nakagalaw muna.',
      whyEn:
          'Five minutes of running or jumping before anything that needs '
          'sitting. Some children sit longer when they have moved first.',
      relevantTo: {SupportFocus.adhd, SupportFocus.sensorySensitivity},
    ),
    TaskSuggestion(
      id: 'sug_pili_damit',
      titleTagalog: 'Pumili ng Damit',
      titleEnglish: 'Choose the Clothes',
      iconKey: 'clothes',
      timeOfDay: ScheduleTimeOfDay.morning,
      whyFil:
          'Dalawang pagpipilian lang. Mas kaunti ang away kapag may napili '
          'siya, at maiiwasan ang telang hindi niya kaya.',
      whyEn:
          'Two choices only. There is less of a fight when they picked it, and '
          'it avoids the fabric they cannot bear.',
      relevantTo: {SupportFocus.sensorySensitivity, SupportFocus.asd},
    ),
    TaskSuggestion(
      id: 'sug_pangalanan_almusal',
      titleTagalog: 'Pangalanan ang Almusal',
      titleEnglish: 'Name the Breakfast',
      iconKey: 'breakfast',
      timeOfDay: ScheduleTimeOfDay.morning,
      whyFil:
          'Sabihin ang pangalan ng bawat pagkain habang kumakain. Araw-araw '
          'itong nauulit, kaya pamilyar na ang mga salita.',
      whyEn:
          'Say the name of each food while eating. It repeats every day, so '
          'the words become familiar.',
      relevantTo: {SupportFocus.speechDelay},
    ),
    TaskSuggestion(
      id: 'sug_mahigpit_yakap',
      titleTagalog: 'Mahigpit na Yakap',
      titleEnglish: 'A Firm Hug',
      iconKey: 'hug',
      timeOfDay: ScheduleTimeOfDay.morning,
      whyFil:
          'May batang mas panatag pagkatapos ng mahigpit na yakap o mabigat na '
          'kumot. Subukan ito bago ang bahaging mahirap sa kanya.',
      whyEn:
          'Some children are steadier after a firm hug or a heavy blanket. Try '
          'it before the part of the day they find hard.',
      relevantTo: {SupportFocus.sensorySensitivity, SupportFocus.asd},
    ),
    TaskSuggestion(
      id: 'sug_isahang_utos',
      titleTagalog: 'Isa-isang Utos',
      titleEnglish: 'One Thing at a Time',
      iconKey: 'pencil',
      timeOfDay: ScheduleTimeOfDay.morning,
      whyFil:
          'Isang utos, hintaying matapos, saka ang susunod. Ang tatlong utos '
          'na sabay ay madalas nauuwi sa wala.',
      whyEn:
          'One instruction, wait for it to finish, then the next. Three at '
          'once often ends in none of them.',
      relevantTo: {SupportFocus.adhd, SupportFocus.speechDelay},
    ),
    TaskSuggestion(
      id: 'sug_uminom_tubig',
      titleTagalog: 'Uminom ng Tubig',
      titleEnglish: 'Drink Water',
      iconKey: 'drink',
      timeOfDay: ScheduleTimeOfDay.morning,
      whyFil:
          'Madaling makalimutan kapag abala ang umaga, lalo na sa batang '
          'hindi nagsasabing nauuhaw siya.',
      whyEn:
          'Easy to forget on a busy morning, especially with a child who does '
          'not say they are thirsty.',
    ),
    // ---------------------------------------------------------------- hapon
    TaskSuggestion(
      id: 'sug_tahimik_sulok',
      titleTagalog: 'Tahimik na Sulok',
      titleEnglish: 'The Quiet Corner',
      iconKey: 'sleep',
      timeOfDay: ScheduleTimeOfDay.afternoon,
      whyFil:
          'Sampung minuto sa mahinang ilaw at walang ingay. Nakakatulong ito '
          'bago pa dumating ang mahirap na sandali, hindi pagkatapos.',
      whyEn:
          'Ten minutes with the lights low and no noise. It helps before the '
          'hard moment arrives, not after it.',
      relevantTo: {SupportFocus.sensorySensitivity, SupportFocus.asd},
    ),
    TaskSuggestion(
      id: 'sug_limang_minuto_labas',
      titleTagalog: 'Limang Minuto sa Labas',
      titleEnglish: 'Five Minutes Outside',
      iconKey: 'walk',
      timeOfDay: ScheduleTimeOfDay.afternoon,
      whyFil:
          'Maikling lakad sa gitna ng mahabang gawain. Mas madaling bumalik '
          'kaysa magpatuloy nang hindi na nakakasunod.',
      whyEn:
          'A short walk in the middle of a long task. Coming back is easier '
          'than pushing on after they have lost the thread.',
      relevantTo: {SupportFocus.adhd},
    ),
    TaskSuggestion(
      id: 'sug_kuwento_larawan',
      titleTagalog: 'Kuwento sa Larawan',
      titleEnglish: 'Tell Me the Picture',
      iconKey: 'book',
      timeOfDay: ScheduleTimeOfDay.afternoon,
      whyFil:
          'Tingnan ang isang larawan at magpalitan ng sasabihin tungkol dito. '
          'Walang tama o mali \u2014 ang pagpapalitan ang mahalaga.',
      whyEn:
          'Look at one picture and take turns saying something about it. '
          'There is no right answer — the taking turns is the point.',
      relevantTo: {SupportFocus.speechDelay, SupportFocus.asd},
    ),
    TaskSuggestion(
      id: 'sug_espesyal_interes',
      titleTagalog: 'Oras ng Paboritong Bagay',
      titleEnglish: 'Favourite Thing Time',
      iconKey: 'toy',
      timeOfDay: ScheduleTimeOfDay.afternoon,
      whyFil:
          'Nakatakdang oras para sa pinakagusto niya. Kapag may sariling '
          'puwang ito sa araw, mas madaling ihinto kapag tapos na.',
      whyEn:
          'A set time for the thing they love most. When it has its own place '
          'in the day, stopping it is easier.',
      relevantTo: {SupportFocus.asd},
    ),
    TaskSuggestion(
      id: 'sug_kanta_galaw',
      titleTagalog: 'Kanta at Galaw',
      titleEnglish: 'Sing and Move',
      iconKey: 'music',
      timeOfDay: ScheduleTimeOfDay.afternoon,
      whyFil:
          'Isang kantang may kasamang kilos. Ang paulit-ulit na linya ay mas '
          'madaling sabayan kaysa sa bagong salita.',
      whyEn:
          'One song with actions. A line that repeats is easier to join in on '
          'than a new word.',
      relevantTo: {SupportFocus.speechDelay, SupportFocus.adhd},
    ),
    TaskSuggestion(
      id: 'sug_magligpit',
      titleTagalog: 'Magligpit ng Laruan',
      titleEnglish: 'Put the Toys Away',
      iconKey: 'clean',
      timeOfDay: ScheduleTimeOfDay.afternoon,
      whyFil:
          'Isang kahon, isang lugar. Mas malinaw ang tapos kapag may nakikitang '
          'hangganan.',
      whyEn:
          'One box, one place. Finished is clearer when there is a boundary '
          'they can see.',
      relevantTo: {SupportFocus.asd, SupportFocus.adhd},
    ),
    TaskSuggestion(
      id: 'sug_alaga_hayop',
      titleTagalog: 'Pag-aalaga ng Alagang Hayop',
      titleEnglish: 'Look After the Pet',
      iconKey: 'pets',
      timeOfDay: ScheduleTimeOfDay.afternoon,
      whyFil:
          'Maliit na trabahong sa kanya lang. May batang mas kampante sa '
          'hayop kaysa sa tao, at iyon ay sapat na simula.',
      whyEn:
          'A small job that is theirs alone. Some children are more at ease '
          'with an animal than with people, and that is a fine place to start.',
    ),
    // ----------------------------------------------------------------- gabi
    TaskSuggestion(
      id: 'sug_bag_bukas',
      titleTagalog: 'Ihanda ang Bag Bukas',
      titleEnglish: 'Pack the Bag for Tomorrow',
      iconKey: 'school',
      timeOfDay: ScheduleTimeOfDay.evening,
      whyFil:
          'Gawin ito gabi-gabi habang kalmado pa. Ang umagang nagmamadali ang '
          'pinakamadalas na simula ng masamang araw.',
      whyEn:
          'Do it every night while things are still calm. A rushed morning is '
          'the most common start to a hard day.',
      relevantTo: {SupportFocus.adhd},
    ),
    TaskSuggestion(
      id: 'sug_sabihin_bukas',
      titleTagalog: 'Sabihin ang Bukas',
      titleEnglish: 'Say What Tomorrow Holds',
      iconKey: 'pencil',
      timeOfDay: ScheduleTimeOfDay.evening,
      whyFil:
          'Tatlong bagay lang na mangyayari bukas. Kapag may nabago, ito ang '
          'oras na sabihin \u2014 hindi sa mismong umaga.',
      whyEn:
          'Just three things that will happen tomorrow. If something has '
          'changed, this is when to say it — not in the morning itself.',
      relevantTo: {SupportFocus.asd, SupportFocus.adhd},
    ),
    TaskSuggestion(
      id: 'sug_tatlong_salita',
      titleTagalog: 'Tatlong Salita sa Araw',
      titleEnglish: 'Three Words About Today',
      iconKey: 'hug',
      timeOfDay: ScheduleTimeOfDay.evening,
      whyFil:
          'Isang bagay na masaya, isang mahirap, isang bukas. Kung wala pa '
          'siyang salita, ikaw ang magsabi at siya ang tumango.',
      whyEn:
          'One good thing, one hard thing, one for tomorrow. If they have no '
          'words yet, you say it and let them nod.',
      relevantTo: {SupportFocus.speechDelay, SupportFocus.asd},
    ),
    TaskSuggestion(
      id: 'sug_basa_bago_tulog',
      titleTagalog: 'Basa Bago Matulog',
      titleEnglish: 'A Book Before Bed',
      iconKey: 'book',
      timeOfDay: ScheduleTimeOfDay.evening,
      whyFil:
          'Kahit parehong libro gabi-gabi. Ang pag-uulit ay hindi pagkabagot '
          'para sa bata \u2014 madalas iyon ang gusto niya.',
      whyEn:
          'Even the same book every night. Repetition is not boredom to a '
          'child — it is often the whole point.',
      relevantTo: {SupportFocus.speechDelay, SupportFocus.asd},
    ),
    TaskSuggestion(
      id: 'sug_mabigat_gawain',
      titleTagalog: 'Mabigat na Gawain',
      titleEnglish: 'Heavy Work',
      iconKey: 'run',
      timeOfDay: ScheduleTimeOfDay.evening,
      whyFil:
          'Magbuhat, magtulak, o magtupi ng labada bago maghanda sa pagtulog. '
          'May batang mas mabilis huminahon pagkatapos ng ganito.',
      whyEn:
          'Carrying, pushing, or folding laundry before getting ready for bed. '
          'Some children settle faster after this.',
      relevantTo: {SupportFocus.sensorySensitivity, SupportFocus.adhd},
    ),
    TaskSuggestion(
      id: 'sug_parehong_ayos',
      titleTagalog: 'Parehong Ayos ng Paghiga',
      titleEnglish: 'The Same Way to Bed',
      iconKey: 'sleep',
      timeOfDay: ScheduleTimeOfDay.evening,
      whyFil:
          'Parehong pagkakasunod gabi-gabi: sipilyo, libro, ilaw, tulog. Ang '
          'pagkakasunod mismo ang senyas na oras na.',
      whyEn:
          'The same order every night: brush, book, light, sleep. The order '
          'itself becomes the signal that it is time.',
      relevantTo: {SupportFocus.asd, SupportFocus.adhd},
    ),
    TaskSuggestion(
      id: 'sug_gamot',
      titleTagalog: 'Pag-inom ng Gamot',
      titleEnglish: 'Take the Medicine',
      iconKey: 'medicine',
      timeOfDay: ScheduleTimeOfDay.evening,
      whyFil:
          'Kung may iniinom, ilagay ito sa parehong oras araw-araw para hindi '
          'na kailangang alalahanin.',
      whyEn:
          'If there is something to take, put it at the same time every day so '
          'it no longer has to be remembered.',
    ),
    TaskSuggestion(
      id: 'sug_kausap_pamilya',
      titleTagalog: 'Kuwentuhan sa Hapag',
      titleEnglish: 'Talk at the Table',
      iconKey: 'dinner',
      timeOfDay: ScheduleTimeOfDay.evening,
      whyFil:
          'Isang tanong kada tao habang kumakain. Kahit isang salita lang ang '
          'sagot, nakikita pa rin niya kung paano ito ginagawa.',
      whyEn:
          'One question each while eating. Even a one-word answer means they '
          'are still watching how it is done.',
    ),
  ];

  static List<TaskSuggestion> inTime(ScheduleTimeOfDay time) =>
      all.where((s) => s.timeOfDay == time).toList();
}
