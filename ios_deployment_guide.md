# iOS Deployment Guide for Windows Users 📱

Since you are developing on **Windows**, you cannot build the iOS app directly from your machine. Flutter's iOS tools require **macOS** and **Xcode**.

However, you have two great options to get Vinta on your iPhone:

## Option 1: The "No Mac" Route (Cloud Build) ☁️
You can use a service like **Codemagic** or **Appcircle**. These services connect to your GitHub repository and build the iOS file (.ipa) for you on their cloud Macs.

1.  Push your code to **GitHub**.
2.  Create a free account on [Codemagic](https://codemagic.io/).
3.  Connect your repository.
4.  Select **iOS build**.
5.  It will generate a link you can open on your iPhone to install the app via **TestFlight**.

## Option 2: The "Mac in the Cloud" Route 🖥️
You can rent a "Mac Mini" in the cloud (like [MacInCloud](https://www.macincloud.com/)) for a few hours.
1.  Log in to the remote Mac.
2.  Clone your code.
3.  Run `flutter build ios`.

## Option 3: Local Build (Requires a Mac) 💻
If you have access to a Mac:
1.  Install Flutter and Xcode.
2.  Run `open ios/Runner.xcworkspace`.
3.  In Xcode, go to **Signing & Capabilities** and select your Development Team.
4.  Plug in your iPhone and run `flutter run --release`.

---

### 💡 Recommendation for Now:
Since you are currently testing on **Web**, the easiest way to see the app on your iPhone <u>today</u> is to host the Web version:
1.  Deploy the web folder (`build/web`) to **Firebase Hosting** or **Vercel** (both have free tiers).
2.  Open the link in your iPhone's **Safari**.
3.  Tap **"Add to Home Screen"** to make it feel like a real app!

> [!TIP]
> **Android is easier!** If you have an Android phone, you can run `flutter build apk` right now on your Windows machine and send the file to your phone.
