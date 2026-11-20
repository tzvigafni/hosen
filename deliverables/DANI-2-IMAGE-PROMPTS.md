# דני 2.0 – מדריך ליצירת תמונות התלת־ממד של הדמויות

המדריך מסביר איך מכינים את התמונות של **דני** (המורה, `TUTOR_CALL_NAME`) ושל **יוסי** (החבר שמשחק איתו בסצנות מהחיים)
בסגנון תלת־ממד מעוצב (stylized 3D), ואיך מכניסים אותן לאפליקציה.

כל עוד אין תמונות, האפליקציה ממשיכה להציג את הדמויות המצוירות (SVG) בדיוק כמו היום, כך ששום דבר לא נשבר.
ברגע שמוסיפים את הקבצים ומעדכנים שורה אחת בקובץ ההגדרות, שיחת הווידאו, מרכז השיחות, דף הנחיתה והסצנות עוברים לתמונות החדשות.

---

## 1. כללים לפני שמתחילים

- **דמויות מעוצבות בלבד.** סגנון של בובת ויניל / פלסטלינה רכה (soft clay / vinyl toy), לא צילום ולא "כמעט צילום".
  אסור להשתמש בצילום של אדם אמיתי, גם לא כ"השראה" שמעלים לכלי.
- **צניעות.** כיפה שחורה, זקן מסודר, חולצה לבנה מכופתרת עם צווארון, וסט כהה. בלי לוגואים, בלי כיתוב, בלי תכשיטים.
- **עיצוב שלנו.** לא מעתיקים דמויות של אפליקציות אחרות. לא כותבים בפרומפט שמות של מותגים, סטודיואים או אפליקציות.
- **אותה דמות בכל התמונות.** זה הדבר החשוב ביותר: התמונות מתחלפות זו בזו בזמן אמת (מצמוץ, תנועת פה), ולכן הראש
  צריך להיות **באותו מקום ובאותו גודל בדיוק** בכל התמונות. ראו "שיטת העבודה" למטה.
- **בלי קבצים מבחוץ בזמן ריצה.** הקבצים נשמרים אצלנו בתיקייה `public/` (מסננים כמו נטפרי ורימון לא רואים צד שלישי).

---

## 2. שיטת העבודה (חשוב לעקביות)

1. **דף דמות (Character sheet).** מייצרים קודם תמונת "דף דמות" עם הפרומפט הראשי (סעיף 3). בוחרים את התוצאה הטובה ביותר
   ושומרים אותה. היא ה"אמת" של הדמות.
2. **תמונת הבסיס – `neutral`.** מעלים לכלי את דף הדמות כתמונת רפרנס ומבקשים את תמונת `neutral` (פרומפט בסעיף 4).
3. **שאר התמונות נעשות כעריכה של `neutral`**, לא כיצירה חדשה: מעלים את `neutral` ומבקשים לשנות רק את מה שצריך
   ("Edit this image: close the eyes only. Keep everything else identical"). בכלים כמו Gemini ו-ChatGPT אפשר להעלות תמונה
   ולבקש עריכה; אם יש אפשרות לסמן אזור (inpainting) – מסמנים רק את העיניים / הפה / היד.
   כך הראש לא זז בין התמונות, וההחלפה ביניהן חלקה.
4. בודקים כל תמונה מול `neutral` (שקיפות 50% אחת מעל השנייה בכל עורך תמונות): הראש, הכתפיים והתאורה צריכים להתאים.

---

## 3. פרומפט ראשי – דף דמות של דני (באנגלית, להעתיק כמו שהוא)

```text
Character design sheet of an original friendly cartoon character, stylized 3D render in a soft clay / matte vinyl toy style,
smooth rounded shapes, slightly oversized head, big warm expressive eyes, gentle smile, warm soft studio lighting,
subtle rim light, soft ambient occlusion, clean and simple, family-friendly.
The character: "Dani", a kind English teacher in his early 30s, Orthodox Jewish modest appearance:
a large black velvet kippah on the crown of the head, short neat dark-brown hair, a short neat full dark-brown beard,
warm light-olive skin, a white buttoned collared shirt, a dark navy vest (waistcoat) over it, no tie, no jewelry,
no logos, no text.
Show: front view head and shoulders, three-quarter view, and a few small facial expressions (neutral, smiling, talking,
thinking). Plain flat light-gray background. Not photorealistic, not a real person, an original design.
```

### דף דמות – יוסי

```text
Character design sheet of an original friendly cartoon character, stylized 3D render in a soft clay / matte vinyl toy style,
the same style and lighting as a companion character set, smooth rounded shapes, slightly oversized head, big kind eyes,
warm soft studio lighting, subtle rim light, family-friendly.
The character: "Yossi", a warm, cheerful man in his 60s, Orthodox Jewish modest appearance:
a large black velvet kippah, short gray hair at the sides, a short full neatly trimmed gray-white beard,
round dark-framed glasses, light skin with gentle smile lines, a white buttoned collared shirt and a dark charcoal vest
(waistcoat) over it, no tie, no jewelry, no logos, no text.
Show: front view head and shoulders, three-quarter view, and a few small facial expressions (neutral, smiling, talking,
thinking). Plain flat light-gray background. Not photorealistic, not a real person, an original design.
```

> טיפ: אם רוצים ששתי הדמויות ייראו "מאותו עולם", מעלים את דף הדמות של דני כרפרנס סגנון כשמייצרים את יוסי
> ("Match the rendering style of the attached image, but a different character").

---

## 4. פרומפט לכל תמונה (frame)

לכל התמונות מוסיפים בסוף את **בלוק המסגור** הזה (זהה בכל פעם):

```text
Framing: square image, 1:1, the same camera for every image: front view, eye level, head and shoulders only,
the head centered horizontally, the top of the kippah about 10% from the top edge, the chin at about 55% of the height,
the shoulders touching the bottom edge. Looking straight at the camera (unless stated otherwise).
Background: one flat solid chroma-green color (#00B140), no shadows on the background, no floor, no props, no text.
Same character, same outfit, same lighting and same render style as the reference image.
```

| קובץ | מה רואים | פרומפט (באנגלית) |
|---|---|---|
| `neutral.webp` | פנים רגועות וידידותיות, פה סגור | `The character from the reference, relaxed friendly neutral expression, soft closed-mouth smile, eyes open, looking at the camera.` |
| `blink.webp` | בדיוק כמו neutral, עיניים עצומות | (עריכה של neutral) `Edit this image: close both eyes naturally (relaxed eyelids, a normal blink). Change nothing else.` |
| `listening.webp` | מקשיב, רכון מעט קדימה, פה סגור | (עריכה של neutral) `Edit this image: an attentive listening expression, eyebrows slightly raised, a small interested smile, mouth closed, head tilted a tiny bit. Keep the head in the same place and size.` |
| `speaking-open.webp` | מדבר, פה פתוח | (עריכה של neutral) `Edit this image: the character is talking, mouth open in a natural "ah" shape showing a little of the upper teeth, lively friendly eyes. Change only the mouth and a little of the cheeks.` |
| `speaking-closed.webp` | מדבר, פה כמעט סגור | (עריכה של neutral) `Edit this image: the character is in the middle of talking, lips almost closed (an "m" or "p" sound), lively friendly eyes, eyebrows slightly raised. Change only the mouth area and eyebrows.` |
| `thinking.webp` | חושב, עיניים למעלה ולצד | (עריכה של neutral) `Edit this image: a thoughtful expression, eyes looking up and to the side, mouth closed in a small pensive line, one eyebrow slightly raised. Keep the head in the same place.` |
| `smiling.webp` | חיוך חם | (עריכה של neutral) `Edit this image: a big warm happy smile, eyes slightly squinting with joy. Keep the head in the same place.` |
| `waving.webp` | מחייך ומנופף ביד | (עריכה של smiling) `Edit this image: the character waves hello with one open hand raised next to the shoulder, palm toward the camera, the white shirt sleeve visible. Keep the head in the same place and size.` |

אותם פרומפטים בדיוק משמשים גם ליוסי (עם דף הדמות של יוסי כרפרנס).

---

## 5. רקע שקוף

האפליקציה מציירת את החדר / המקום מאחורי הדמות, לכן **כל קובץ חייב להיות עם רקע שקוף**.

- אם הכלי מאפשר רקע שקוף (Transparent background / PNG with alpha) – עדיף.
- אחרת, ייצרו עם הרקע הירוק האחיד (`#00B140`) ואז הסירו אותו במחשב שלכם:
  - **GIMP** (חינם): Layer → Transparency → Add Alpha Channel, ואז Select → By Color על הירוק, Delete.
    אחרי זה Select → None, ו-Colors → Color to Alpha על שאריות ירוקות בשוליים אם יש.
  - או כל עורך תמונות אחר עם "Remove background" שעובד על המחשב.
- בודקים שאין הילה ירוקה סביב השיער, הזקן והכיפה.

---

## 6. גודל, שם וייצוא ל-WebP

- **גודל:** 768×768 פיקסלים (ריבוע). אם הכלי יצר גודל אחר, מקטינים לריבוע 768 בלי לחתוך את הדמות.
- **שמות הקבצים** (בדיוק, אותיות קטנות):
  `neutral.webp`, `blink.webp`, `listening.webp`, `speaking-open.webp`, `speaking-closed.webp`, `thinking.webp`, `smiling.webp`, `waving.webp`
- **ייצוא ל-WebP** (שומר על השקיפות):
  - בשורת פקודה, עם הכלי החינמי `cwebp` (חבילת `webp`):
    ```bash
    cwebp -q 80 -alpha_q 90 -resize 768 768 neutral.png -o neutral.webp
    ```
  - או ב-GIMP: File → Export As → `neutral.webp`, איכות 80.
- **תקציב משקל:** כל 8 התמונות של דמות אחת יחד – **עד 600KB** (בערך 60–80KB לתמונה).
  אם יוצא כבד מדי, מורידים איכות ל-70. הבדיקות האוטומטיות נכשלות אם עוברים את התקציב.

---

## 7. איפה שמים את הקבצים ואיך מפעילים

1. שמים את הקבצים בתיקיות:
   - דני: `public/avatar/dani/`
   - יוסי: `public/avatar/yossi/`
2. פותחים את `src/components/avatar/portrait-frames.ts` ומעדכנים את `CHARACTER_FRAMES`: רושמים ב-`available` את התמונות
   שהוספתם, ומעלים את `version` ב-1 (כדי שטלפונים לא יציגו תמונות ישנות מהמטמון). לדוגמה:
   ```ts
   dani: {
     dir: "/avatar/dani",
     available: ["neutral", "blink", "listening", "speaking-open", "speaking-closed", "thinking", "smiling", "waving"],
     version: 2,
   },
   ```
   חובה לפחות `neutral`. תמונה שלא קיימת מוחלפת אוטומטית בקרובה אליה (למשל בלי `thinking` מוצג `neutral`).
3. מריצים בדיקות: `npx vitest run src/components/avatar` – הבדיקה מוודאת שכל קובץ שרשום באמת קיים ושהמשקל בתקציב.
4. בודקים בעין בדף התצוגה **`/app/scenes/avatars`**: כל המצבים של שתי הדמויות, תקריב עגול, ורשימת הקבצים ("מוגדר" / "חסר").
   בודקים גם את שיחת הווידאו (`/app/talk/...`) ואת הסצנות (`/app/scenes`).
5. אם משהו לא נראה טוב – מוחקים את השם מ-`available`, והאפליקציה חוזרת מיד לציור ה-SVG.

---

## 8. רשימת בדיקה לעקביות

- [ ] אותה דמות בכל התמונות: פנים, צבע עור, זקן, שיער, כיפה, משקפיים (יוסי), בגדים.
- [ ] הראש באותו מקום ובאותו גודל (בדיקת שקיפות 50% מול `neutral`). אין "קפיצה" כשמתחלפים `speaking-open` ו-`speaking-closed`.
- [ ] `blink` זהה ל-`neutral` חוץ מהעיניים.
- [ ] אותה תאורה (אור חם מלפנים-למעלה, אור שוליים עדין) ואותו סגנון רינדור (ויניל/פלסטלינה, לא צילום).
- [ ] רקע שקוף, בלי הילה ירוקה, בלי צל על הרקע.
- [ ] כיפה שחורה, חולצה לבנה מכופתרת, וסט כהה. בלי כיתוב, לוגו או תכשיטים.
- [ ] 768×768, WebP, שמות קבצים מדויקים, סך הכל עד 600KB לדמות.
- [ ] נראה טוב גם בתקריב עגול קטן (מרכז השיחות) וגם במסך מלא בטלפון.
- [ ] נבדק במצב כהה ובמצב "עצירת אנימציות" (הדמות עומדת, בלי מצמוץ ותנועה).

---

## 9. איך זה עובד בקוד (לעיון)

- `src/components/avatar/portrait-frames.ts` – רשימת התמונות הקיימות (`CHARACTER_FRAMES`), שמות הקבצים, התקציב,
  והלוגיקה שבוחרת איזו תמונה להציג (`selectFrame`, נבדקת ב-`portrait-frames.test.ts`).
- `src/components/avatar/character-portrait.tsx` – `DaniPortrait` / `YossiPortrait`: טוענים מראש רק את התמונות שהמסך צריך,
  מציגים את ה-SVG עד שהתמונה הראשונה נטענה (או אם נכשלה), מחליפים תמונות בלי הבהוב, ומוסיפים נשימה, הטיית ראש,
  מצמוץ ותנועת פה בזמן דיבור. בלי תנועה כשיש `prefers-reduced-motion` או "עצירת אנימציות".
- `src/components/avatar/daniel-avatar.tsx`, `yossi-avatar.tsx` – הדמויות המצוירות (SVG), שמשמשות גם כגיבוי.
