import '../domain/medicine.dart';

abstract final class NotificationMessages {
  static String title(Medicine medicine, {required bool derjaEnabled}) =>
      derjaEnabled
      ? '⏰ Wa9t el dwaa ! ${medicine.name} • ${medicine.dose}'
      : '⏰ Rappel : ${medicine.name} • ${medicine.dose}';

  static String body(
    Medicine medicine, {
    required bool derjaEnabled,
    required String childName,
  }) {
    if (!derjaEnabled) {
      return "C’est l’heure de ${medicine.name} (${medicine.dose}) pour $childName.";
    }

    final reminders = [
      'Hay 9oumi maman 😄 a3ti $childName ${medicine.name} (${medicine.dose}) !',
      'Hey, wa9t el dwaa 💊 ${medicine.name} (${medicine.dose}) lil 7lowa $childName.',
      'Ding ding ! Doudou y9ol : ${medicine.name} (${medicine.dose}) taw, ya maman ✨',
      'Yalla boussa w dwaa 😘 ${medicine.name} (${medicine.dose}) mta3 $childName yestanna.',
      'Maman, ma tenséch 😉 ${medicine.name} (${medicine.dose}) taw lil princesse $childName.',
      'Alert doudou 🧸 : ${medicine.name} (${medicine.dose}) — wa9tou tawa !',
      'Chwaya chwaya, kol chay behi 💛 ${medicine.name} (${medicine.dose}) taw.',
      '9oumou lel mission 💪 ${medicine.name} (${medicine.dose}) pour $childName !',
      'Hé ya maman 🌷 ${medicine.name} (${medicine.dose}) bech n9oulou bravo ba3d.',
      'Doudou 7at rappelou 🧸 ${medicine.name} (${medicine.dose}) wa9tou, yalla !',
    ];
    final now = DateTime.now();
    final seed =
        now.day +
        now.hour +
        medicine.id.codeUnits.fold<int>(0, (sum, unit) => sum + unit);
    return reminders[seed % reminders.length];
  }
}
