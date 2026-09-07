import '../../data/models/child_profile.dart';

/// Ang mga tag na may sinasabi tungkol sa nilalaman.
///
/// Wala rito ang `underEvaluation` at ang `other`: walang itinuturo ang
/// "Sinusuri pa", kaya wala rin itong dapat baguhin sa nakikita ng magulang.
const Set<SupportFocus> tagsThatSort = {
  SupportFocus.asd,
  SupportFocus.adhd,
  SupportFocus.speechDelay,
  SupportFocus.sensorySensitivity,
};

/// Hinahati ang listahan: ang tumutugma sa tag ng bata muna, tapos ang iba.
///
/// Nandito at hindi sa bawat feature para iisa ang tuntunin. Kapag dalawa ang
/// kopya nito, darating ang araw na ang isa ay magsasala at ang isa ay
/// mag-aayos lang.
///
/// WALANG naitatago. Blangko ang unang bahagi kapag walang tag ang bata — at
/// ganoon ang kalahati ng gumagamit ng app na ito.
(List<T> forChild, List<T> rest) splitByFocus<T>(
  List<T> items,
  List<SupportFocus> childTags,
  Set<SupportFocus> Function(T item) focusOf,
) {
  final tags = childTags.where(tagsThatSort.contains).toSet();
  if (tags.isEmpty) return (<T>[], items);

  final forChild = <T>[];
  final rest = <T>[];
  for (final item in items) {
    if (focusOf(item).any(tags.contains)) {
      forChild.add(item);
    } else {
      rest.add(item);
    }
  }
  return (forChild, rest);
}
