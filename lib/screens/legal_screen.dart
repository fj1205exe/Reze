import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets.dart';

class LegalScreen extends StatelessWidget {
  final String title;
  final String content;
  final VoidCallback onBack;
  const LegalScreen({super.key, required this.title, required this.content, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: C.bg,
      child: Column(
        children: [
          MLabHeader(label: title, onBack: onBack),
          Expanded(
            child: SingleChildScrollView(
              padding: S.screenPad,
              child: FadeSlideIn(
                child: Text(content, style: inter(fontSize: 14, color: C.muted, height: 1.7)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const privacyPolicyText = '''MLab Privacy Policy
Last updated: November 2026

1. What We Collect
We collect only what is necessary to provide the app:
- Email address (for account creation and login)
- Display name (chosen by you, shown on leaderboards)
- Learning progress (which concepts you completed, challenge scores)
- Goal preference (fundamentals, math, or prep)

We do not collect location data, device identifiers, contacts, photos, or any other personal information.

2. How We Use Your Data
Your data is used solely to:
- Authenticate your account
- Sync your learning progress across devices
- Display your scores on leaderboards
- Personalize the app experience based on your goal choice

We do not sell, share, or transfer your data to third parties.

3. Third-Party Services
MLab uses Supabase for authentication and data storage. Supabase processes your data under their privacy policy. No other third-party services receive your data. We do not use analytics, advertising, or tracking SDKs.

4. Data Storage and Security
Your data is stored in Supabase (hosted on AWS ap-southeast-2). All data is transmitted over HTTPS. Passwords are hashed using bcrypt and never stored in plaintext.

5. Your Rights
You can at any time:
- Export all your data (Account > Export Data)
- Delete your account and all associated data (Account > Delete Account)
- Update your display name
- Contact us to request data correction

Account deletion is permanent and immediate. All your data including progress, scores, and profile information is permanently removed.

6. Children
MLab is designed for learners of all ages. We do not knowingly collect data from children under 13 without parental consent. If you are under 13, please have a parent or guardian create an account on your behalf.

7. Changes
We may update this policy. Continued use of the app after changes constitutes acceptance.

8. Contact
For privacy questions or data requests, reach us at the email listed on our app store page.''';

const termsOfServiceText = '''MLab Terms of Service
Last updated: November 2026

1. Acceptance
By using MLab, you agree to these terms. If you do not agree, do not use the app.

2. The Service
MLab is a free educational app that teaches machine learning concepts through interactive exercises. We provide the service as-is with no guarantees of availability or accuracy.

3. Accounts
You may use MLab as a guest without an account. Creating an account requires a valid email address. You are responsible for maintaining the security of your account credentials. One account per person.

4. Acceptable Use
You agree not to:
- Attempt to access other users data
- Reverse engineer the app
- Use automated tools to interact with the service
- Submit false information

5. Intellectual Property
All content, design, and code in MLab is owned by MLab. You may not reproduce or distribute app content without permission.

6. Leaderboards
Display names on leaderboards are visible to other users. Do not use offensive or misleading display names. We reserve the right to remove inappropriate names.

7. Data and Privacy
Your use of data is governed by our Privacy Policy. You can delete your account and all data at any time from the Account screen.

8. Limitation of Liability
MLab is provided for educational purposes only. We are not liable for any decisions made based on concepts learned through the app. The app is provided as-is without warranty.

9. Changes
We may update these terms. Continued use after changes constitutes acceptance.

10. Contact
For questions about these terms, reach us at the email listed on our app store page.''';
