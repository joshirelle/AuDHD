import '../../modules/milestones/models/milestone.dart';
import '../i18n/language_controller.dart';

/// Salin ng CDC "Learn the Signs. Act Early." milestone checklists.
///
/// Kundisyon ng CDC ang hindi pagbabago ng nilalaman, kaya ang `titleEng` ay
/// dapat eksaktong katulad ng nasa cdc.gov/ActEarly. Ang `titleFil` lang ang
/// atin. Kapag may nakita kang dapat ayusin, ang salin lang ang puwede.
class MilestoneConstants {
  /// Kailan huling kinuha mula sa cdc.gov/ActEarly. Hinihikayat ng CDC ang
  /// pag-link imbes na pagkopya, pero offline ang app — kaya kailangang
  /// balikan ang pahina nila paminsan-minsan gamit ang petsang ito.
  static const String cdcVersion = '2026-08';

  /// Nasa checklist ng CDC sa ilang edad. Hindi ito panukat — walang tanong,
  /// walang iskor. Sinasabi lang nito kung kailan hihingi sa doktor.
  static const Map<int, String> _screeningFil = {
    24:
        'Sa edad na dalawang (2) taon, napapanahon na ang iyong anak para sa '
        'isang screening ng autismo, ayon sa inirerekomenda para sa lahat ng '
        'mga bata ng American Academy of Pediatrics. Tanungin ang doktor '
        'tungkol sa developmental screening ng iyong anak.',
    30:
        'Sa 30 buwan, napapanahon na ang iyong anak para sa pangkalahatang '
        'screening na pag-unlad gaya ng inirerekomenda ng American Academy of '
        'Pediatrics para sa lahat ng bata. Tanungin ang doktor tungkol sa '
        'screening na pag-unlad ng iyong anak.',
  };

  static const Map<int, String> _screeningEng = {
    24:
        'At age 2, your child is due for a screening for autism, as '
        'recommended for all children by the American Academy of Pediatrics. '
        'Ask the doctor about your child\'s developmental screening.',
    30:
        'At 30 months, your child is due for a general developmental '
        'screening, as recommended for all children by the American Academy '
        'of Pediatrics. Ask the doctor about your child\'s developmental '
        'screening.',
  };

  static String? screeningNotice(int months) {
    final fil = _screeningFil[months];
    if (fil == null) return null;
    return tr(fil, _screeningEng[months] ?? fil);
  }

  static const List<Milestone> milestones = [
    // --- 2 TAON ---
    Milestone(
      id: 'cdc_24_se_1',
      titleFil:
          'Napapansin kapag nasaktan o nabalisa ang iba, tulad ng paghinto ng '
          'sandali o pagtingin na malungkot kapag may umiiyak',
      titleEng:
          'Notices when others are hurt or upset, like pausing or looking sad '
          'when someone is crying',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 24,
    ),
    Milestone(
      id: 'cdc_24_se_2',
      titleFil:
          'Tinitingnan ang iyong mukha upang makita kung paano ang reaksyon sa '
          'isang bagong sitwasyon',
      titleEng: 'Looks at your face to see how to react in a new situation',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 24,
    ),
    Milestone(
      id: 'cdc_24_lc_1',
      titleFil:
          'Itinuturo ang mga bagay sa isang libro kapag tinatanong mo, tulad '
          'ng "Nasaan ang oso?"',
      titleEng:
          'Points to things in a book when you ask, like "Where is the bear?"',
      domain: MilestoneDomain.language,
      targetAgeMonths: 24,
    ),
    Milestone(
      id: 'cdc_24_lc_2',
      titleFil:
          'Nagsasabi ng hindi bababa sa dalawang salita nang magkasama, tulad '
          'ng "Gatas pa."',
      titleEng: 'Says at least two words together, like "More milk."',
      domain: MilestoneDomain.language,
      targetAgeMonths: 24,
    ),
    Milestone(
      id: 'cdc_24_lc_3',
      titleFil:
          'Itinuturo sa hindi bababa sa dalawang bahagi ng katawan kapag '
          'hiniling mo sa kanya para ipakita ito sa iyo',
      titleEng:
          'Points to at least two body parts when you ask him to show you',
      domain: MilestoneDomain.language,
      targetAgeMonths: 24,
    ),
    Milestone(
      id: 'cdc_24_lc_4',
      titleFil:
          'Gumagamit ng higit pang mga pagkilos kaysa sa pagkaway at pagtuturo '
          'lang, tulad ng pag-ihip ng halik o pagtango ng oo',
      titleEng:
          'Uses more gestures than just waving and pointing, like blowing a '
          'kiss or nodding yes',
      domain: MilestoneDomain.language,
      targetAgeMonths: 24,
    ),
    Milestone(
      id: 'cdc_24_cg_1',
      titleFil:
          'Humahawak ng isang bagay sa isang kamay habang ginagamit ang '
          'kabilang kamay; halimbawa, may hawak na lalagyan at tinatanggal ang '
          'takip',
      titleEng:
          'Holds something in one hand while using the other hand; for '
          'example, holding a container and taking the lid off',
      domain: MilestoneDomain.cognitive,
      targetAgeMonths: 24,
    ),
    Milestone(
      id: 'cdc_24_cg_2',
      titleFil:
          'Sinusubukang gumamit ng mga switch, knob, o pindutan sa isang '
          'laruan',
      titleEng: 'Tries to use switches, knobs, or buttons on a toy',
      domain: MilestoneDomain.cognitive,
      targetAgeMonths: 24,
    ),
    Milestone(
      id: 'cdc_24_cg_3',
      titleFil:
          'Naglalaro ng higit sa isang laruan nang sabay sabay, tulad ng '
          'paglalagay ng laruang pagkain sa laruang plato',
      titleEng:
          'Plays with more than one toy at the same time, like putting toy '
          'food on a toy plate',
      domain: MilestoneDomain.cognitive,
      targetAgeMonths: 24,
    ),
    Milestone(
      id: 'cdc_24_mv_1',
      titleFil: 'Sumisipa ng bola',
      titleEng: 'Kicks a ball',
      domain: MilestoneDomain.movement,
      targetAgeMonths: 24,
    ),
    Milestone(
      id: 'cdc_24_mv_2',
      titleFil: 'Tumatakbo',
      titleEng: 'Runs',
      domain: MilestoneDomain.movement,
      targetAgeMonths: 24,
    ),
    Milestone(
      id: 'cdc_24_mv_3',
      titleFil:
          'Naglalakad (hindi umaakyat) sa ilang hagdan nang mayroon o walang '
          'tulong',
      titleEng: 'Walks (not climbs) up a few stairs with or without help',
      domain: MilestoneDomain.movement,
      targetAgeMonths: 24,
    ),
    Milestone(
      id: 'cdc_24_mv_4',
      titleFil: 'Kumakain gamit ang kutsara',
      titleEng: 'Eats with a spoon',
      domain: MilestoneDomain.movement,
      targetAgeMonths: 24,
    ),

    // --- 30 BUWAN ---
    Milestone(
      id: 'cdc_30_se_1',
      titleFil:
          'Naglalaro sa tabi ng ibang bata at minsan ay nakikipaglaro sa '
          'kanila',
      titleEng: 'Plays next to other children and sometimes plays with them',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 30,
    ),
    Milestone(
      id: 'cdc_30_se_2',
      titleFil:
          'Ipinapakita sa iyo ang kaya niyang gawin sa pamamagitan ng '
          'pagsasabing, "Tingnan mo ako!"',
      titleEng: 'Shows you what she can do by saying, "Look at me!"',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 30,
    ),
    Milestone(
      id: 'cdc_30_se_3',
      titleFil:
          'Sinusundan ang mga simpleng gawain kapag sinabihan, tulad ng '
          'pagtulong sa pagpulot ng mga laruan kapag sinabi mong, "Oras na ng '
          'paglilinis."',
      titleEng:
          'Follows simple routines when told, like helping to pick up toys '
          'when you say, "It\'s clean-up time."',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 30,
    ),
    Milestone(
      id: 'cdc_30_lc_1',
      titleFil: 'Nakakapagsalita ng halos limampung (50) salita',
      titleEng: 'Says about 50 words',
      domain: MilestoneDomain.language,
      targetAgeMonths: 30,
    ),
    Milestone(
      id: 'cdc_30_lc_2',
      titleFil:
          'Nagsasabi ng dalawang salita o higit pa, na may isang salita ng '
          'pagkilos, tulad ng "Takbo ang aso"',
      titleEng:
          'Says two or more words together, with one action word, like '
          '"Doggie run"',
      domain: MilestoneDomain.language,
      targetAgeMonths: 30,
    ),
    Milestone(
      id: 'cdc_30_lc_3',
      titleFil:
          'Pinapangalanan ang mga bagay sa isang libro kapag itinuro at '
          'itinanong mo at sabihing, "Ano ito?"',
      titleEng:
          'Names things in a book when you point and ask, "What is this?"',
      domain: MilestoneDomain.language,
      targetAgeMonths: 30,
    ),
    Milestone(
      id: 'cdc_30_lc_4',
      titleFil: 'Nagsasabi ng mga salita tulad ng "ako," o "tayo"',
      titleEng: 'Says words like "I," "me," or "we"',
      domain: MilestoneDomain.language,
      targetAgeMonths: 30,
    ),
    Milestone(
      id: 'cdc_30_cg_1',
      titleFil:
          'Gumagamit ng mga bagay para magpanggap, tulad ng pagpapakain ng '
          'bloke sa isang manika na parang pagkain',
      titleEng:
          'Uses things to pretend, like feeding a block to a doll as if it '
          'were food',
      domain: MilestoneDomain.cognitive,
      targetAgeMonths: 30,
    ),
    Milestone(
      id: 'cdc_30_cg_2',
      titleFil:
          'Nagpapakita ng mga simpleng kakayanan sa paglutas ng problema, '
          'tulad ng pagtayo sa isang bangkito upang maabot ang isang bagay',
      titleEng:
          'Shows simple problem-solving skills, like standing on a small '
          'stool to reach something',
      domain: MilestoneDomain.cognitive,
      targetAgeMonths: 30,
    ),
    Milestone(
      id: 'cdc_30_cg_3',
      titleFil:
          'Sumusunod sa dalawang hakbang na tagubilin tulad ng "Ibaba ang '
          'laruan at isara ang pinto."',
      titleEng:
          'Follows two-step instructions like "Put the toy down and close the '
          'door."',
      domain: MilestoneDomain.cognitive,
      targetAgeMonths: 30,
    ),
    Milestone(
      id: 'cdc_30_cg_4',
      titleFil:
          'Ipinapakita na alam niya ang isang kulay, tulad ng pagturo sa '
          'pulang krayola kapag tinanong mo, "Alin ang pula?"',
      titleEng:
          'Shows he knows at least one color, like pointing to a red crayon '
          'when you ask, "Which one is red?"',
      domain: MilestoneDomain.cognitive,
      targetAgeMonths: 30,
    ),
    Milestone(
      id: 'cdc_30_mv_1',
      titleFil:
          'Gumagamit ng mga kamay upang ipihit ang mga bagay, tulad ng '
          'pagpihit ng mga doorknob o pagtanggal ng takip',
      titleEng:
          'Uses hands to twist things, like turning doorknobs or unscrewing '
          'lids',
      domain: MilestoneDomain.movement,
      targetAgeMonths: 30,
    ),
    Milestone(
      id: 'cdc_30_mv_2',
      titleFil:
          'Naghuhubad ng ilang damit na mag-isa, tulad ng maluwag na pantalon '
          'o isang bukas na jacket',
      titleEng:
          'Takes some clothes off by himself, like loose pants or an open '
          'jacket',
      domain: MilestoneDomain.movement,
      targetAgeMonths: 30,
    ),
    Milestone(
      id: 'cdc_30_mv_3',
      titleFil: 'Tumatalon sa sahig gamit ang dalawang paa',
      titleEng: 'Jumps off the ground with both feet',
      domain: MilestoneDomain.movement,
      targetAgeMonths: 30,
    ),
    Milestone(
      id: 'cdc_30_mv_4',
      titleFil:
          'Inililipat ang mga pahina ng libro, isa-isa, kapag binasahan mo '
          'siya',
      titleEng: 'Turns book pages, one at a time, when you read to her',
      domain: MilestoneDomain.movement,
      targetAgeMonths: 30,
    ),

    // --- 3 TAON ---
    Milestone(
      id: 'cdc_36_se_1',
      titleFil:
          'Huminahon sa loob ng sampung (10) minuto pagkatapos mo siyang '
          'iwanan, tulad ng pag-iwan sa childcare',
      titleEng:
          'Calms down within 10 minutes after you leave her, like at a '
          'childcare drop off',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 36,
    ),
    Milestone(
      id: 'cdc_36_se_2',
      titleFil:
          'Napapansin ang ibang mga bata at sinasamahan niya sila sa '
          'paglalaro',
      titleEng: 'Notices other children and joins them to play',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 36,
    ),
    Milestone(
      id: 'cdc_36_lc_1',
      titleFil:
          'Nakikipag-usap sa iyo sa pag-uusap gamit ang hindi bababa sa '
          'dalawang pabalik-balik na pagpapalitan',
      titleEng:
          'Talks with you in conversation using at least two back-and-forth '
          'exchanges',
      domain: MilestoneDomain.language,
      targetAgeMonths: 36,
    ),
    Milestone(
      id: 'cdc_36_lc_2',
      titleFil:
          'Nagtatanong ng "sino," "ano," "saan," o "bakit", tulad ng "Nasaan '
          'si mommy/daddy?"',
      titleEng:
          'Asks "who," "what," "where," or "why" questions, like "Where is '
          'mommy/daddy?"',
      domain: MilestoneDomain.language,
      targetAgeMonths: 36,
    ),
    Milestone(
      id: 'cdc_36_lc_3',
      titleFil:
          'Sinasabi kung anong aksyon ang nangyayari sa isang larawan o libro '
          'kapag tinanong, tulad ng "tumatakbo," "kumakain," o "naglalaro"',
      titleEng:
          'Says what action is happening in a picture or book when asked, '
          'like "running," "eating," or "playing"',
      domain: MilestoneDomain.language,
      targetAgeMonths: 36,
    ),
    Milestone(
      id: 'cdc_36_lc_4',
      titleFil: 'Sinasabi ang pangalan, kapag tinatanong',
      titleEng: 'Says first name, when asked',
      domain: MilestoneDomain.language,
      targetAgeMonths: 36,
    ),
    Milestone(
      id: 'cdc_36_lc_5',
      titleFil:
          'Nakakapagsalita nang maayos para maintindihan ng iba, sa '
          'tuwi-tuwina',
      titleEng: 'Talks well enough for others to understand, most of the time',
      domain: MilestoneDomain.language,
      targetAgeMonths: 36,
    ),
    Milestone(
      id: 'cdc_36_cg_1',
      titleFil: 'Gumuguhit ng bilog, kapag ipinakita mo sa kanya kung paano',
      titleEng: 'Draws a circle, when you show him how',
      domain: MilestoneDomain.cognitive,
      targetAgeMonths: 36,
    ),
    Milestone(
      id: 'cdc_36_cg_2',
      titleFil:
          'Iniiwasang hawakan ang mga maiinit na bagay, tulad ng kalan, kapag '
          'binalaan mo siya',
      titleEng: 'Avoids touching hot objects, like a stove, when you warn her',
      domain: MilestoneDomain.cognitive,
      targetAgeMonths: 36,
    ),
    Milestone(
      id: 'cdc_36_mv_1',
      titleFil:
          'Pinagsasama-sama ang mga bagay, tulad ng malalaking beads o '
          'macaroni',
      titleEng: 'Strings items together, like large beads or macaroni',
      domain: MilestoneDomain.movement,
      targetAgeMonths: 36,
    ),
    Milestone(
      id: 'cdc_36_mv_2',
      titleFil:
          'Nagsusuot ng ilang damit na mag-isa, tulad ng maluwag na pantalon '
          'o isang jacket',
      titleEng: 'Puts on some clothes by himself, like loose pants or a jacket',
      domain: MilestoneDomain.movement,
      targetAgeMonths: 36,
    ),
    Milestone(
      id: 'cdc_36_mv_3',
      titleFil: 'Gumagamit ng tinidor',
      titleEng: 'Uses a fork',
      domain: MilestoneDomain.movement,
      targetAgeMonths: 36,
    ),

    // --- 4 TAON ---
    Milestone(
      id: 'cdc_48_se_1',
      titleFil: 'Nagpapanggap na iba habang naglalaro (guro, superhero, aso)',
      titleEng:
          'Pretends to be something else during play (teacher, superhero, '
          'dog)',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 48,
    ),
    Milestone(
      id: 'cdc_48_se_2',
      titleFil:
          'Humihiling na makipaglaro sa mga bata kung walang kalaro, tulad ng '
          '"Pwede ba akong makipaglaro kay Alex?"',
      titleEng:
          'Asks to go play with children if none are around, like "Can I play '
          'with Alex?"',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 48,
    ),
    Milestone(
      id: 'cdc_48_se_3',
      titleFil:
          'Inaaliw ang iba na nasaktan o nalulungkot, tulad ng pagyakap sa '
          'umiiyak na kaibigan',
      titleEng:
          'Comforts others who are hurt or sad, like hugging a crying friend',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 48,
    ),
    Milestone(
      id: 'cdc_48_se_4',
      titleFil:
          'Iniiwasan ang panganib, tulad ng hindi pagtalon mula sa matataas '
          'na lugar sa playground',
      titleEng:
          'Avoids danger, like not jumping from tall heights at the '
          'playground',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 48,
    ),
    Milestone(
      id: 'cdc_48_se_5',
      titleFil: 'Gustong tumulong',
      titleEng: 'Likes to be a "helper"',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 48,
    ),
    Milestone(
      id: 'cdc_48_se_6',
      titleFil:
          'Inaayon ang pag-uugali batay sa kung nasaan siya (lugar ng '
          'pagsamba, aklatan, palaruan)',
      titleEng:
          'Changes behavior based on where she is (place of worship, library, '
          'playground)',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 48,
    ),
    Milestone(
      id: 'cdc_48_lc_1',
      titleFil: 'Nagsasabi ng mga pangungusap na may apat o higit pang salita',
      titleEng: 'Says sentences with four or more words',
      domain: MilestoneDomain.language,
      targetAgeMonths: 48,
    ),
    Milestone(
      id: 'cdc_48_lc_2',
      titleFil:
          'Nagsasabi ng ilang salita mula sa isang kanta, kuwento, o '
          'nursery rhyme',
      titleEng: 'Says some words from a song, story, or nursery rhyme',
      domain: MilestoneDomain.language,
      targetAgeMonths: 48,
    ),
    Milestone(
      id: 'cdc_48_lc_3',
      titleFil:
          'Nagku-kwento ng kahit isang bagay na nangyari sa kanyang araw, '
          'tulad ng "Naglaro ako ng soccer."',
      titleEng:
          'Talks about at least one thing that happened during her day, like '
          '"I played soccer."',
      domain: MilestoneDomain.language,
      targetAgeMonths: 48,
    ),
    Milestone(
      id: 'cdc_48_lc_4',
      titleFil:
          'Sumasagot sa mga simpleng tanong tulad ng "Para saan ang '
          'dyaket?" o "Para saan ang krayola?"',
      titleEng:
          'Answers simple questions like "What is a coat for?" or "What is a '
          'crayon for?"',
      domain: MilestoneDomain.language,
      targetAgeMonths: 48,
    ),
    Milestone(
      id: 'cdc_48_cg_1',
      titleFil: 'Nagpapangalan ng ilang kulay ng mga bagay',
      titleEng: 'Names a few colors of items',
      domain: MilestoneDomain.cognitive,
      targetAgeMonths: 48,
    ),
    Milestone(
      id: 'cdc_48_cg_2',
      titleFil:
          'Sinasabi ang susunod na mangyayari sa isang popular na '
          'kuwento',
      titleEng: 'Tells what comes next in a well-known story',
      domain: MilestoneDomain.cognitive,
      targetAgeMonths: 48,
    ),
    Milestone(
      id: 'cdc_48_cg_3',
      titleFil: 'Gumuguhit ng tao na may tatlo o higit pang bahagi ng katawan',
      titleEng: 'Draws a person with three or more body parts',
      domain: MilestoneDomain.cognitive,
      targetAgeMonths: 48,
    ),
    Milestone(
      id: 'cdc_48_mv_1',
      titleFil: 'Nasasalo ang malaking bola sa halos lahat ng pagkakataon',
      titleEng: 'Catches a large ball most of the time',
      domain: MilestoneDomain.movement,
      targetAgeMonths: 48,
    ),
    Milestone(
      id: 'cdc_48_mv_2',
      titleFil:
          'Naghahain ng sarili niyang pagkain o nagbubuhos ng tubig, nang may '
          'tulong ng matanda',
      titleEng: 'Serves herself food or pours water, with adult supervision',
      domain: MilestoneDomain.movement,
      targetAgeMonths: 48,
    ),
    Milestone(
      id: 'cdc_48_mv_3',
      titleFil: 'Tinatanggal ang ilang mga butones',
      titleEng: 'Unbuttons some buttons',
      domain: MilestoneDomain.movement,
      targetAgeMonths: 48,
    ),
    Milestone(
      id: 'cdc_48_mv_4',
      titleFil:
          'Humahawak ng krayola o lapis sa pagitan ng mga daliri at hinlalaki '
          '(hindi kamao)',
      titleEng: 'Holds crayon or pencil between fingers and thumb (not a fist)',
      domain: MilestoneDomain.movement,
      targetAgeMonths: 48,
    ),

    // --- 5 TAON ---
    Milestone(
      id: 'cdc_60_se_1',
      titleFil:
          'Sumusunod sa mga patakaran o nakikipagsalitan kapag nakikipaglaro '
          'sa ibang mga bata',
      titleEng:
          'Follows rules or takes turns when playing games with other '
          'children',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 60,
    ),
    Milestone(
      id: 'cdc_60_se_2',
      titleFil: 'Kumakanta, sumasayaw, o umaarte para sa iyo',
      titleEng: 'Sings, dances, or acts for you',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 60,
    ),
    Milestone(
      id: 'cdc_60_se_3',
      titleFil:
          'Gumagawa ng mga simpleng gawain sa bahay, tulad ng pagpares ng '
          'medyas o paglilinis ng lamesa pagkatapos kumain',
      titleEng:
          'Does simple chores at home, like matching socks or clearing the '
          'table after eating',
      domain: MilestoneDomain.socialEmotional,
      targetAgeMonths: 60,
    ),
    Milestone(
      id: 'cdc_60_lc_1',
      titleFil:
          'Nagkukuwento ng narinig niya o binuo na hindi bababa sa dalawang '
          'pangyayari. Halimbawa, naipit ang isang pusa sa isang puno at '
          'iniligtas ito ng isang bumbero',
      titleEng:
          'Tells a story she heard or made up with at least two events. For '
          'example, a cat was stuck in a tree and a firefighter saved it',
      domain: MilestoneDomain.language,
      targetAgeMonths: 60,
    ),
    Milestone(
      id: 'cdc_60_lc_2',
      titleFil:
          'Sumasagot sa mga simpleng tanong tungkol sa isang libro o kwento '
          'pagkatapos mong basahin o sabihin sa kanya',
      titleEng:
          'Answers simple questions about a book or story after you read or '
          'tell it to him',
      domain: MilestoneDomain.language,
      targetAgeMonths: 60,
    ),
    Milestone(
      id: 'cdc_60_lc_3',
      titleFil:
          'Nagpapanatili ng pag-uusap nang may higit sa tatlong pagpapalitan',
      titleEng:
          'Keeps a conversation going with more than three back-and-forth '
          'exchanges',
      domain: MilestoneDomain.language,
      targetAgeMonths: 60,
    ),
    Milestone(
      id: 'cdc_60_lc_4',
      titleFil:
          'Gumagamit o nakakakilala ng mga simpleng tula (bat-cat, ball-tall)',
      titleEng: 'Uses or recognizes simple rhymes (bat-cat, ball-tall)',
      domain: MilestoneDomain.language,
      targetAgeMonths: 60,
      noteFil:
          'Ingles ang halimbawa dahil walang direktang salin — hindi na '
          'nagtutugma kapag isinalin. Sa Filipino, ang katulad nito ay '
          '"bata-mata" o "bola-tula."',
    ),
    Milestone(
      id: 'cdc_60_cg_1',
      titleFil: 'Nagbibilang nang hanggang sampu (10)',
      titleEng: 'Counts to 10',
      domain: MilestoneDomain.cognitive,
      targetAgeMonths: 60,
    ),
    Milestone(
      id: 'cdc_60_cg_2',
      titleFil:
          'Nagpapangalan ng ilang numero sa pagitan ng isa (1) at lima (5) '
          'kapag itinuro sa kanya',
      titleEng: 'Names some numbers between 1 and 5 when you point to them',
      domain: MilestoneDomain.cognitive,
      targetAgeMonths: 60,
    ),
    Milestone(
      id: 'cdc_60_cg_3',
      titleFil:
          'Gumagamit ng mga salita tungkol sa oras, tulad ng "kahapon," '
          '"bukas," "umaga," o "gabi"',
      titleEng:
          'Uses words about time, like "yesterday," "tomorrow," "morning," or '
          '"night"',
      domain: MilestoneDomain.cognitive,
      targetAgeMonths: 60,
    ),
    Milestone(
      id: 'cdc_60_cg_4',
      titleFil:
          'Nagtutuon ng atensiyon sa loob ng lima (5) hanggang sampung (10) '
          'minuto sa mga aktibidad. Halimbawa, sa panahon ng kwento o paggawa '
          'ng sining at crafts (hindi binibilang ang oras ng screen)',
      titleEng:
          'Pays attention for 5 to 10 minutes during activities. For example, '
          'during story time or making arts and crafts (screen time does not '
          'count)',
      domain: MilestoneDomain.cognitive,
      targetAgeMonths: 60,
    ),
    Milestone(
      id: 'cdc_60_cg_5',
      titleFil: 'Sumusulat ng ilang mga titik sa kanyang pangalan',
      titleEng: 'Writes some letters in her name',
      domain: MilestoneDomain.cognitive,
      targetAgeMonths: 60,
    ),
    Milestone(
      id: 'cdc_60_cg_6',
      titleFil:
          'Pinapangalanan ang ilang mga titik kapag itinuro mo ang mga '
          'ito',
      titleEng: 'Names some letters when you point to them',
      domain: MilestoneDomain.cognitive,
      targetAgeMonths: 60,
    ),
    Milestone(
      id: 'cdc_60_mv_1',
      titleFil: 'Ibinu-butones ang ilang mga butones',
      titleEng: 'Buttons some buttons',
      domain: MilestoneDomain.movement,
      targetAgeMonths: 60,
    ),
    Milestone(
      id: 'cdc_60_mv_2',
      titleFil: 'Tumatalon sa isang paa',
      titleEng: 'Hops on one foot',
      domain: MilestoneDomain.movement,
      targetAgeMonths: 60,
    ),
  ];

  /// Naka-sunod-sunod na ang magkakaedad dahil sa pagkakasulat sa itaas.
  static List<Milestone> inDomain(MilestoneDomain? domain) => domain == null
      ? milestones
      : milestones.where((m) => m.domain == domain).toList();
}
