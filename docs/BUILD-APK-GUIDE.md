# מדריך בניית APK אנדרואיד מפרויקט Next.js/PWA

> נוסח מאומת מול הבנייה שעבדה: `GafniPortal.apk` (versionCode 4, 22/06/2026).
> הוא חתום במפתח `CN=Gafni Systems` עם טביעת אצבע
> `36:5C:32:55:BB:27:0F:99:75:79:78:97:1B:AF:28:97:55:52:5A:71:F9:3D:48:02:33:68:3C:21:2E:01:2F:34`
> — זהה לזו שב-`public/.well-known/assetlinks.json`, ומסלול ההפעלה שלו הוא `WebViewActivity`.

---

## 0. התובנה המרכזית — למה TWA רגיל נכשל

Bubblewrap בונה כברירת מחדל **TWA** (Trusted Web Activity). TWA הוא לא דפדפן בעצמו — הוא
"שואל" את Chrome שבמכשיר לרנדר את האתר דרך Custom Tabs. מכאן נובעת הבעיה:

**אם הדפדפן במכשיר מושבת / חסום / מוסר — האפליקציה מנסה לפתוח דפדפן חסום ונופלת.**
זה בדיוק המצב בטלפונים מוגבלים (סינון תוכן, בקרת הורים, טלפונים "כשרים").

**הפתרון שעבד:** להוסיף `WebViewActivity` נייטיב משלנו ולהפוך אותו ל-**launcher**.
הוא מכיל `WebView` שמרנדר את האתר **בתוך האפליקציה**, בלי תלות בדפדפן חיצוני כלל.
`LauncherActivity` של ה-TWA נשאר בפרויקט אבל מנוטרל (`exported="false"`, בלי intent-filters).

זה ההבדל היחיד והמשמעותי בין הנסיונות שנפלו לבין זה שעבד.

---

## 1. דרישות מוקדמות במכונה

| מה | נתיב במכונה הזו |
|---|---|
| JDK 17 | `C:\Program Files\Java\jdk-17` |
| Android SDK | `C:\Android\Sdk` |
| build-tools | `C:\Android\Sdk\build-tools\36.0.0` (יש גם 35/36.1) |
| Bubblewrap CLI | `npm install -g @bubblewrap/cli` |

בדיקה: `bubblewrap doctor`. הקונפיג יושב ב-`~/.bubblewrap/config.json` (`jdkPath` + `androidSdkPath`).

---

## 2. הפרויקט חייב להיות PWA חי על HTTPS

לפני הכל — האתר צריך manifest ו-service worker **בפרודקשן**:

- `src/app/manifest.ts` (App Router) שמחזיר `name`, `short_name`, `display: "standalone"`,
  `theme_color`, `background_color`, `lang: "he"`, `dir: "rtl"`, ואייקונים **192 + 512 PNG**.
- `public/sw.js` (network-first) עם רישום `navigator.serviceWorker.register('/sw.js')`.
- לדחוף, לפרוס, ולאמת שחוזר 200:

```powershell
node -e "fetch('https://<HOST>/manifest.webmanifest').then(r=>console.log(r.status))"
```

אם זה לא 200 — `bubblewrap init` ייכשל. אל תתקדם לפני שזה עובד.

---

## 3. תיקיית בנייה + keystore (מחוץ לריפו!)

```powershell
$build = "C:\Users\This User\Desktop\<proj>-apk"
New-Item -ItemType Directory -Force $build | Out-Null
& "C:\Program Files\Java\jdk-17\bin\keytool.exe" -genkeypair -v `
  -keystore "$build\android.keystore" -alias android `
  -keyalg RSA -keysize 2048 -validity 9125 `
  -storepass <PASS> -keypass <PASS> `
  -dname "CN=Gafni Systems, O=Gafni Systems, L=Tel Aviv, C=IL"
```

⚠️ **ה-keystore הוא נכס קריטי.** בלי אותו מפתח בדיוק אי אפשר להוציא עדכון לאותה אפליקציה —
אנדרואיד יסרב להתקין APK חתום במפתח אחר על גבי התקנה קיימת. גבה אותו למקום בטוח.
אל תכניס אותו ל-git.

---

## 4. יצירת שלד ה-TWA — ב-Git Bash דווקא

```bash
cd "/c/Users/This User/Desktop/<proj>-apk"
export PATH="$PATH:$(npm config get prefix)"
export BUBBLEWRAP_KEYSTORE_PASSWORD=<PASS> BUBBLEWRAP_KEY_PASSWORD=<PASS>
yes '' | bubblewrap init --manifest https://<HOST>/manifest.webmanifest --directory .
```

**למה Git Bash ולא PowerShell:** צינור מחרוזות ב-PowerShell מוסיף **BOM** של UTF-8
בתחילת הקלט, וזה שובר את השאלה הראשונה של bubblewrap בשגיאה
`Minimum length is 1`. `yes '' |` ב-Git Bash מאשר את כל ברירות המחדל בשקט.

אחרי זה, ב-`twa-manifest.json` לוודא/לשנות:

```json
{
  "fallbackType": "webview",
  "orientation": "portrait",
  "minSdkVersion": 21,
  "enableNotifications": true,
  "signingKey": { "path": "android.keystore", "alias": "android" }
}
```

שים לב ל-`packageId` שנוצר (ברירת מחדל `app.vercel.<proj>.twa`) — תצטרך אותו ל-assetlinks.

> הערה: ב-`twa-manifest.json` של הבנייה הזו נתיב ה-keystore נשמר כנתיב **מוחלט**.
> אם מעבירים את התיקייה — חייבים לעדכן אותו (או להעביר ל-`"android.keystore"` יחסי).

---

## 5. ה-WebViewActivity — הלב של הפתרון

צור `app/src/main/java/<pkg>/WebViewActivity.java`. התבנית המלאה והמאומתת נמצאת
ב-skill: `~/.claude/skills/build-apk/SKILL.md`, וקובץ עובד אמיתי ב-
`Desktop\מהשולחן עבודה ווינדוס צבי\gafni-apk\app\src\main\java\app\vercel\gafni_support\twa\WebViewActivity.java`.

מה להחליף: `package`, `URL`, `HOST`, `AUTH_HOST`, צבע status bar, סיומת ה-User-Agent.

**מה הקובץ הזה מטפל בו — וכל סעיף פה הוא באג פוטנציאלי אם תשכח אותו:**

| יכולת | למה זה קריטי |
|---|---|
| `setJavaScriptEnabled(true)` | בלי זה Next.js בכלל לא עולה |
| `setDomStorageEnabled(true)` + `setDatabaseEnabled(true)` | Firebase Auth שומר session ב-localStorage/IndexedDB. בלי זה המשתמש מתנתק כל פתיחה |
| `CookieManager.setAcceptThirdPartyCookies` | נדרש לזרימת Firebase Auth |
| `onShowFileChooser` | **בלי זה העלאת צרופות לא עובדת בכלל** — לחיצה על "בחר קובץ" לא עושה כלום. כולל `getClipData()` לריבוי קבצים |
| `onPermissionRequest` + הרשאת CAMERA | צילום מסך/תמונה מהמצלמה בתוך האפליקציה |
| `onKeyDown` → `webView.goBack()` | בלי זה כפתור "חזור" סוגר את האפליקציה במקום לנווט אחורה |
| `resolveUrl(intent)` + `onNewIntent` | **זה מה שגורם ל-magic link לעבוד** (סעיף 7) |
| `shouldOverrideUrlLoading` | משאיר בתוך ה-WebView את הדומיין שלנו + `firebaseapp.com` + `googleapis.com`, ומוציא החוצה `tel:` / `mailto:` / WhatsApp |
| `setMixedContentMode(COMPATIBILITY_MODE)` | מונע חסימת משאבים מעורבים |

---

## 6. עריכת AndroidManifest.xml

הוסף הרשאות:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

הוסף את `.WebViewActivity` **לפני** `LauncherActivity`:

```xml
<activity android:name=".WebViewActivity"
    android:alwaysRetainTaskState="true"
    android:label="@string/launcherName"
    android:configChanges="orientation|screenSize|keyboardHidden"
    android:launchMode="singleTask"
    android:exported="true">

    <intent-filter>
        <action android:name="android.intent.action.MAIN" />
        <category android:name="android.intent.category.LAUNCHER" />
    </intent-filter>

    <intent-filter android:autoVerify="true">
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:scheme="https" android:host="@string/hostName" />
    </intent-filter>

    <!-- דומיין ה-magic link של Firebase — כדי שהקישור ייפתח באפליקציה -->
    <intent-filter>
        <action android:name="android.intent.action.VIEW"/>
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE"/>
        <data android:scheme="https" android:host="<project>.firebaseapp.com" />
    </intent-filter>
</activity>
```

ועל `LauncherActivity` הקיים:
- `android:exported="false"`
- **להסיר** את ה-`MAIN`/`LAUNCHER` ואת ה-`VIEW` intent-filters שלו (הם עברו ל-WebViewActivity).

אם תשכח להסיר — יהיו שני אייקונים בלאנצ'ר, או שאנדרואיד יפתח את ה-TWA השבור.

`launchMode="singleTask"` + `onNewIntent` הם צמד: בלי זה לחיצה על magic link כשהאפליקציה
פתוחה תיצור instance שני במקום לנווט בקיים.

---

## 7. Deep-link ל-magic link (Firebase) — הנקודה שהכי מבלבלת

המלכודת: המייל של Firebase email-link sign-in **לא** מצביע לדומיין שלך. הוא מצביע ל-
`https://<project>.firebaseapp.com/__/auth/action?...`.

לכן צריך **שני** דברים יחד:
1. intent-filter גם ל-`<project>.firebaseapp.com` (סעיף 6).
2. ב-`WebViewActivity`: `resolveUrl()` שטוען את ה-URL **מה-intent** ולא את דף הבית —
   אחרת האפליקציה תיפתח על הבית והטוקן יאבד.

ואז קובץ האימות בריפו של האתר — `public/.well-known/assetlinks.json`:

```json
[
  {
    "relation": ["delegate_permission/common.handle_all_urls"],
    "target": {
      "namespace": "android_app",
      "package_name": "app.vercel.gafni_support.twa",
      "sha256_cert_fingerprints": [
        "36:5C:32:55:BB:27:0F:99:75:79:78:97:1B:AF:28:97:55:52:5A:71:F9:3D:48:02:33:68:3C:21:2E:01:2F:34"
      ]
    }
  }
]
```

את הטביעה מוציאים מה-keystore:
```powershell
& "C:\Program Files\Java\jdk-17\bin\keytool.exe" -list -v `
  -keystore android.keystore -alias android -storepass <PASS> | findstr SHA256
```

⚠️ הטביעה **חייבת** להיות של המפתח שבו באמת חתמת. `package_name` חייב להתאים ל-`packageId`.
אי-התאמה = ה-App Link לא יאומת והקישור ייפתח בדפדפן (או יציע בחירה) במקום באפליקציה.

לדחוף, לפרוס, ולאמת: `https://<HOST>/.well-known/assetlinks.json` חוזר 200.

בנוסף: Firebase → Authentication → Authorized domains צריך להכיל את `<HOST>`,
ו-Vercel צריך `NEXT_PUBLIC_APP_URL=https://<HOST>`.

---

## 8. בנייה — PowerShell עם gradlew, לא bubblewrap build

```powershell
Set-Location "C:\Users\This User\Desktop\<proj>-apk"
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
& ".\gradlew.bat" assembleRelease
```

פלט: `app\build\outputs\apk\release\app-release-unsigned.apk`

**למה לא `bubblewrap build`:** הוא נכשל ב-`'gradlew.bat' is not recognized`.
הוא מריץ את gradlew בצורה שגויה, במיוחד כשיש רווחים בנתיב (`This User`).
`.\gradlew.bat` ישירות עובד מושלם.

**לפני כל בנייה מחדש — להעלות `versionCode` ו-`versionName` ב-`app/build.gradle`.**
אנדרואיד מסרב להתקין מעל גרסה עם versionCode זהה או גבוה יותר.
(בבנייה הזו: הגרסה הסופית הגיעה ל-`versionCode 4`.)

הגדרות build.gradle של הבנייה שעבדה: `compileSdkVersion 36`, `targetSdkVersion 35`,
`minSdkVersion 21`, `minifyEnabled true`, Gradle **8.11.1**,
`androidbrowserhelper:2.6.2`, Java 1.8 compatibility.

---

## 9. zipalign + חתימה + אימות

ה-build.gradle **לא** מכיל `signingConfigs` — החתימה נעשית ידנית. זה מכוון ופשוט יותר:

```powershell
$bt  = "C:\Android\Sdk\build-tools\36.0.0"
$dir = "C:\Users\This User\Desktop\<proj>-apk"
$env:JAVA_HOME = "C:\Program Files\Java\jdk-17"
$env:Path += ";$env:JAVA_HOME\bin"

# 1) יישור (חייב לפני החתימה!)
& "$bt\zipalign.exe" -p -f 4 `
  "$dir\app\build\outputs\apk\release\app-release-unsigned.apk" `
  "$dir\aligned.apk"

# 2) חתימה
& "$bt\apksigner.bat" sign `
  --ks "$dir\android.keystore" --ks-pass pass:<PASS> --key-pass pass:<PASS> `
  --out "C:\Users\This User\Desktop\<App>.apk" "$dir\aligned.apk"

# 3) אימות — חייב להדפיס "Verified"
& "$bt\apksigner.bat" verify --print-certs "C:\Users\This User\Desktop\<App>.apk"
```

סדר חשוב: **zipalign לפני apksigner**. הפוך — החתימה נשברת.

בדיקה שהכל התחבר נכון (ה-launcher הוא ה-WebViewActivity!):
```powershell
& "$bt\aapt2.exe" dump badging "C:\Users\This User\Desktop\<App>.apk" | Select-String "package:|launchable"
```
אמור להראות `launchable-activity: name='<pkg>.WebViewActivity'`.
אם זה מראה `LauncherActivity` — שכחת להעביר את ה-intent-filters.

---

## 10. התקנה בטלפון

1. **להסיר קודם את הגרסה הישנה** (חתימה/versionCode שונים → ההתקנה תיכשל אחרת).
2. להעביר את ה-APK (כבל / Drive / וואטסאפ לעצמך).
3. לאשר "התקנת אפליקציות ממקורות לא ידועים" למקור שממנו פותחים.
4. להתקין.
5. בפעם הראשונה שלוחצים על magic link — אם אנדרואיד שואל "פתח באמצעות", לבחור
   את האפליקציה ו**"תמיד"**.

---

## צ'קליסט מהיר לפרויקט חדש

```
[ ] PWA חי: manifest.webmanifest מחזיר 200 + sw.js רשום + אייקונים 192/512
[ ] keystore נוצר מחוץ לריפו + מגובה
[ ] bubblewrap init מ-Git Bash עם  yes '' |
[ ] twa-manifest.json: fallbackType=webview, orientation, minSdk 21
[ ] WebViewActivity.java נוצר, עם HOST/AUTH_HOST/צבע מעודכנים
[ ] AndroidManifest: הרשאות INTERNET/CAMERA/POST_NOTIFICATIONS
[ ] AndroidManifest: WebViewActivity = launcher + 3 intent-filters
[ ] AndroidManifest: LauncherActivity → exported=false, ללא intent-filters
[ ] versionCode הועלה
[ ] .\gradlew.bat assembleRelease  (לא bubblewrap build)
[ ] zipalign → apksigner sign → apksigner verify = Verified
[ ] aapt2 badging מאשר launchable = WebViewActivity
[ ] assetlinks.json עם ה-SHA-256 האמיתי + packageId, נדחף ופרוס, מחזיר 200
[ ] Firebase Authorized domains כולל את ה-HOST
[ ] נבדק בטלפון: נפתח, התחברות, העלאת קובץ, כפתור חזור, magic link
```

---

## קבצי התייחסות במכונה

- **Skill מלא עם תבנית Java:** `~/.claude/skills/build-apk/SKILL.md`
- **פרויקט עובד (גפני):** `Desktop\מהשולחן עבודה ווינדוס צבי\gafni-apk\`
- **APK סופי שעבד:** `Desktop\מהשולחן עבודה ווינדוס צבי\GafniPortal.apk`
- **דוגמאות נוספות:** `Desktop\k300-twa`, `Desktop\yesodot-twa`
  (שתיהן `fallbackType: customtabs` — כלומר TWA רגיל, **בלי** תיקון ה-WebView)

---

## נספח: הדרך הקצרה יותר (פרויקט "דבר", 07/10/2026) — בלי TWA בכלל

בפרויקט דבר לא השתמשנו ב-Bubblewrap/TWA. במקום לבנות TWA ואז "לנטרל" אותו, יש פרויקט
אנדרואיד נקי (`android/` בריפו english-app) עם **WebViewActivity אחד בלבד** שהוא ה-launcher.
אותה תוצאה כמו גפני (אפס תלות בכרום), פחות חלקים זזים, ובנייה מלאה גם בלינוקס/בענן.

**בנייה (לינוקס, בלי Android Studio):**
```bash
# SDK: commandlinetools -> sdkmanager "platforms;android-35" "build-tools;35.0.0"
cd android && echo "sdk.dir=$ANDROID_HOME" > local.properties
./gradlew assembleRelease          # אם Maven Central מחזיר 429 — פשוט להריץ שוב
BT=$ANDROID_HOME/build-tools/35.0.0
$BT/zipalign -p -f 4 app/build/outputs/apk/release/app-release-unsigned.apk aligned.apk
$BT/apksigner sign --ks dabber-release.keystore --ks-key-alias dabber --out Dabber.apk aligned.apk
$BT/apksigner verify --print-certs Dabber.apk
$BT/aapt2 dump badging Dabber.apk | grep launchable   # חייב: WebViewActivity
```

**מה WebView לא עושה לבד — וחייבים לגשר (ב-`assets/bridge.js` + `JavascriptInterface`):**

| חסר ב-WebView | הפתרון |
|---|---|
| `speechSynthesis` (הקראה) | polyfill שמפעיל `TextToSpeech` של אנדרואיד |
| `SpeechRecognition` (זיהוי דיבור) | polyfill שמפעיל `SpeechRecognizer` + בקשת הרשאת מיקרופון בזמן ריצה |
| `window.print()` (הדפסה / שמירה כ-PDF) | `PrintManager` + `webView.createPrintDocumentAdapter` |
| התחברות Google (גוגל חוסמת ב-WebView) | ה-User-Agent מקבל סיומת `DabberApp/<גרסה>` והאתר מסתיר את כפתור Google ומשאיר אימייל+סיסמה |

הסקריפט מוזרק **לפני** קוד האתר (`WebViewCompat.addDocumentStartJavaScript`, ספריית
`androidx.webkit`), כדי שהאתר "יראה" את ה-API כבר בטעינה. בלי זה הקוד של האתר בודק, לא מוצא,
ומציג "הדפדפן לא תומך".

**עוד דברים ששווה לדעת:**
- **גרסת WebView:** אתר עם Tailwind 4 צריך WebView 111+ (`@layer`, `color-mix`). בטלפון
  המסונן של צבי זה עובד (פורטל גפני, גם הוא Tailwind 4, עבד שם). בטלפון עם WebView ישן מאוד
  העיצוב יישבר — זה הדבר הראשון לבדוק אם "הכל לבן ומבולגן".
- **מסך שגיאה עם פרטים טכניים** (גרסת אנדרואיד, גרסת WebView, קוד שגיאה) — צילום מסך אחד
  מספיק כדי לאבחן בעיה בלי סבבים.
- **כל קישורי http/https נשארים בתוך האפליקציה** (בטלפון מסונן אין דפדפן להעביר אליו).
  רק `tel:` / `mailto:` / WhatsApp יוצאים, עם הודעה ידידותית אם אין אפליקציה מתאימה.
- **ה-keystore לא בגיט.** נשמר אצל צבי. בלי אותו קובץ + סיסמה אי אפשר לעדכן את האפליקציה.
