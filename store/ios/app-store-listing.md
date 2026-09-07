# App Store Connect — AuDHD (English, primary)

Kopyahin ang bawat bahagi papunta sa katumbas nitong field. Nasa dulo ng bawat
pamagat ang limitasyon ng character at ang aktwal na bilang.

---

## App Name (30) — 5

```
AuDHD
```

## Subtitle (30) — 24

```
Autism & ADHD home guide
```

Hindi inuulit ang "AuDHD" dito. Ini-index ng Apple ang name at subtitle nang
magkasama, kaya sayang ang espasyo kung uulitin.

## Promotional Text (170) — 152

Napapalitan ito anumang oras nang walang bagong build. Gamitin para sa
anunsyo ng bagong tampok.

```
Track routines, moods, behavior and milestones, then hand your doctor a clear PDF. Works fully offline. No account, no ads, nothing leaves your phone.
```

## Keywords (100) — 98

Walang espasyo pagkatapos ng comma — sayang ang character. Wala rito ang
"autism", "ADHD", at "guide" dahil nasa name at subtitle na iyon.

```
child development,routine,visual schedule,sensory,milestones,behavior,special needs,therapy,parent
```

## Description (4000) — 2074

```
AuDHD is a calm, offline companion for parents raising a child with autism or ADHD. It turns the everyday work of parenting into something you can see, keep, and share with your child's doctor.

Everything stays on your phone. There is no account to create, no server, no ads, and no analytics.

A DAY YOUR CHILD CAN SEE
Build a picture schedule from morning to evening. Each finished task earns a star, and the stars add up to rewards that you choose yourself. Children who struggle with transitions can look at the next step instead of being told about it.

THINGS TO DO AT HOME
Dozens of activities using what you already own: clothespins, tape, a towel, a spoon. Each one lists how long it takes and which sense it works on, so you can pick what fits the mood of the day.

MILESTONES THAT FOLLOW YOUR CHILD
Track growth against age-appropriate developmental milestones. Nothing is scored or graded. It is a record of what your child can do, kept in one place.

BEHAVIOR YOU CAN EXPLAIN
Note what happened before, what your child did, and what happened after. Over weeks, patterns appear that are hard to notice day to day.

A SENSORY PROFILE
A checklist that shows whether your child seeks or avoids each kind of sensation, with practical suggestions for each result.

A REPORT FOR THE DOCTOR
One tap builds a PDF covering mood, behavior, sensory profile and routine over the last 30, 60 or 90 days. Share it or print it. Appointments are short. Walking in with a written record changes the conversation.

FOR THE PARENT TOO
Short notes to help you understand what your child is doing and why, plus small reminders that you need looking after as well.

PRIVACY
AuDHD works with no internet connection. Your child's name, photo, and records never leave your phone. You can delete everything at any time.

IMPORTANT
AuDHD is an observation tool for use at home. It is not a diagnosis and it does not replace a professional assessment. It cannot tell you whether your child has autism or ADHD. Please consult a licensed developmental pediatrician. Milestone content is based on publicly available CDC developmental milestones.
```

## What's New in This Version (4000)

```
First release on iPhone.

AuDHD has been available on Android and is now here. Everything works the same: your child's schedule, home activities, milestones, behavior notes, sensory profile, and the PDF report for your doctor. All of it offline.
```

---

## Mga URL

| Field | Halaga |
| --- | --- |
| Privacy Policy URL | `https://joshirelle.github.io/AuDHD/privacy-policy` |
| Support URL | `https://joshirelle.github.io/AuDHD/` |
| Marketing URL | iwanang blangko |

---

## App Review Notes

Ito ang basahin ng reviewer. Sinusagot nito ang mga tanong bago pa niya
maitanong — lalo na ang tungkol sa medikal na nilalaman.

```
AuDHD is an offline observation and routine tool for parents of children with autism or ADHD. It is not a diagnostic app.

NO SIGN-IN REQUIRED
There is no account, no server, and no login. Launch the app, create a local child profile with any name, and every feature is available. All data is stored on the device using Hive. Nothing is transmitted anywhere.

MEDICAL CONTENT
The app does not diagnose, screen, or score. It records what the parent observes.
- Milestone content is based on publicly available CDC developmental milestone guidance and is attributed in-app.
- The Milestones screen notes that the American Academy of Pediatrics recommends developmental screening for all children. This is a factual statement encouraging parents to see a professional. We do not claim endorsement by, or affiliation with, the CDC or the AAP.
- A medical disclaimer is shown during onboarding and is available at any time from the Profile screen. It states that the app is not a diagnosis and that parents should consult a licensed developmental pediatrician.

PERMISSIONS
- Camera and Photo Library: optional, only to attach a profile photo of the child. The photo is stored in the app's private folder and is never uploaded.
- Face ID: optional, as an alternative to a locally stored PIN for locking the app.
All three are optional. The app is fully usable if every permission is denied.

DOCTOR'S REPORT
The Doctor's Report screen builds a PDF on the device and offers the standard iOS share sheet and print dialog. The parent chooses the destination. Nothing is sent automatically.

EXTERNAL LINKS
The app links to a Facebook group for parents and to the App Store listing for rating. Both open outside the app and send no data.

The app is developed in the Philippines and is currently live on Google Play. Its content is available in English and Filipino; the language can be changed in Profile.
```

---

## App Privacy (Data Not Collected)

Sagutin sa App Store Connect: **"Data Not Collected"** sa lahat.

Kung magtanong tungkol sa litrato at profile ng bata: iniimbak ito sa device
at hindi ito "collection" sa depinisyon ng Apple, dahil walang natatanggap na
datos ang developer o kahit sinong ikatlong partido.

---

## Age Rating

Sagutin nang tapat ang questionnaire. Ang mahalaga:

- **Medical/Treatment Information** — Infrequent/Mild. May nilalaman tungkol sa
  developmental milestones at paalalang medikal, pero walang treatment advice.
- Walang violence, walang user-generated content sa loob ng app, walang
  gambling, walang in-app purchase.
- Ang link papunta sa Facebook group ay lalabas ng app; ideklara ito kung
  may tanong tungkol sa unrestricted web access.

---

## Bago i-submit

- [ ] Punan ang `appStoreAppId` sa `lib/widgets/play_store_link.dart` gamit ang
      Apple ID mula sa App Store Connect, tapos gumawa ng bagong build.
- [ ] I-upload ang limang screenshot mula sa `store/ios/` (1320x2868).
- [ ] I-upload ang icon na `ios/Runner/Assets.xcassets/AppIcon.appiconset/Icon-App-1024x1024@1x.png`.
- [ ] Piliin ang **Philippines** bilang primary territory kung iyon ang unahin.
- [ ] Ipadala muna sa TestFlight para masubukan ng mga magulang habang nasa review.
