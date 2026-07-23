import 'package:flutter/material.dart';

class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
        ),
      ),
    );
  }
}

// Sample contents
const String privacyPolicyContent = '''
Privacy Policy

Last updated: [Date]

This Privacy Policy describes our policies and procedures on the collection, use and disclosure of your information when you use the service and tells you about your privacy rights and how the law protects you.

We use your Personal data to provide and improve the service. By using the service, you agree to the collection and use of information in accordance with this Privacy Policy.

All your data (Notes, Images, Voice Notes, Bookmarks, and Documents) is stored locally on your device. We do not transmit or store your personal data on external servers. 

Your privacy is our primary concern. Since the application operates offline, you have complete control over your data.

Changes to this Privacy Policy:
We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new Privacy Policy on this page.
''';

const String termsOfServiceContent = '''
Terms of Service

Last updated: [Date]

Please read these terms and conditions carefully before using our service.

Acknowledgment:
These are the Terms and Conditions governing the use of this service and the agreement that operates between you and the company.

By accessing or using the service you agree to be bound by these Terms and Conditions. If you disagree with any part of these Terms and Conditions then you may not access the service.

Your data is stored locally. We are not responsible for any data loss, corruption, or unintentional deletion of your data. It is your responsibility to maintain backups of your information if necessary.

Changes:
We reserve the right, at our sole discretion, to modify or replace these Terms at any time.
''';
