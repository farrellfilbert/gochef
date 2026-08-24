import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.midnight,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Privacy Policy',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Badge Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Icon(Icons.privacy_tip_outlined, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'GOCHEF TECHNOLOGIES',
                              style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 16),
                            ),
                            Text(
                              'The GRUB Next Door!',
                              style: AppTextStyles.labelSm(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 14, color: Colors.white60),
                      const SizedBox(width: 6),
                      Text('Effective Date: August 14, 2026', style: AppTextStyles.labelSm(color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.update, size: 14, color: Colors.white60),
                      const SizedBox(width: 6),
                      Text('Last Updated: August 14, 2026', style: AppTextStyles.labelSm(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Intro Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Text(
                'GoChef Technologies ("GoChef," "we," "our," or "us") respects the privacy of the individuals and businesses that use our technology.\n\nThis Privacy Policy explains how GoChef collects, uses, discloses, retains and protects personal information when individuals interact with the GoChef mobile application, websites, marketplace, payment features, communications tools and related services (collectively, the "GoChef Platform").\n\nThis Privacy Policy applies to Customers, independent chefs, cooks, food vendors, restaurants, caterers, home-kitchen operators and other persons using the GoChef Platform ("Users").',
                style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.55),
              ),
            ),
            const SizedBox(height: 24),

            _buildSection('1. INFORMATION WE COLLECT',
                'The information GoChef processes depends upon how you interact with the Platform.\n\nA. Account Information\nWe may collect:\n• name;\n• username;\n• email address;\n• telephone number;\n• password or authentication credentials;\n• profile photograph;\n• date of birth or age verification information where required;\n• account preferences;\n• language;\n• communication preferences; and\n• account status.'),

            _buildSection('2. CUSTOMER ORDER INFORMATION',
                'When you place or receive an order, we may process:\n• items ordered;\n• Provider information;\n• order value;\n• fees;\n• taxes;\n• tips;\n• promotional discounts;\n• pickup or delivery preference;\n• delivery address;\n• delivery instructions;\n• order timestamps;\n• order status;\n• refunds;\n• cancellations;\n• complaints;\n• ratings;\n• reviews; and\n• transaction history.'),

            _buildSection('3. PROVIDER INFORMATION',
                'Providers may provide additional information necessary to operate through GoChef, including:\n• legal or business name;\n• business address;\n• service location;\n• telephone number;\n• email;\n• menu information;\n• food photographs;\n• business descriptions;\n• operating hours;\n• service areas;\n• pricing;\n• permit or license information;\n• food-handler certifications;\n• insurance information;\n• tax information;\n• identity verification information;\n• payment-account information;\n• banking or payout information;\n• business registration information; and\n• other information required to verify eligibility to use Provider functionality.\n\nCertain sensitive payment, banking, identity or tax information may be collected directly by a third-party payment or verification provider rather than stored directly by GoChef.'),

            _buildSection('4. PAYMENT INFORMATION',
                'Payments may be processed by third-party payment processors.\n\nDepending on the payment system, GoChef may receive information such as:\n• payment confirmation;\n• transaction identifiers;\n• payment method type;\n• billing information;\n• card brand;\n• limited card information such as the last four digits;\n• refund status;\n• chargeback information; and\n• fraud or risk indicators.\n\nGoChef does not intend to independently store complete credit-card numbers or security codes when those credentials are processed directly by an authorized payment processor.'),

            _buildSection('5. LOCATION INFORMATION',
                'Depending upon your settings and Platform features, we may collect or infer:\n• delivery location;\n• pickup location;\n• Provider location;\n• approximate location;\n• IP-based location; and\n• with appropriate device permissions, precise device location.\n\nLocation information may be used to show nearby Providers; calculate service areas; facilitate delivery or pickup; provide estimated distances; prevent fraud; support marketplace functionality; and improve Platform operations.\n\nYou may control certain location permissions through your device settings, although disabling them may limit Platform functionality.'),

            _buildSection('6. DEVICE AND TECHNICAL INFORMATION',
                'We may automatically receive information such as:\n• IP address;\n• device type;\n• operating system;\n• browser;\n• device identifiers;\n• application version;\n• language;\n• time zone;\n• network information;\n• crash reports;\n• diagnostic information;\n• referring URLs;\n• pages or screens viewed;\n• buttons or features used;\n• timestamps;\n• session information; and\n• other technical information related to use of the Platform.'),

            _buildSection('7. COMMUNICATIONS',
                'When Customers, Providers or GoChef communicate through the Platform, we may process information relating to those communications.\n\nThis may include:\n• in-app messages;\n• customer-support messages;\n• email correspondence;\n• transactional SMS messages;\n• reported incidents;\n• complaints;\n• photographs submitted to support; and\n• other communications voluntarily submitted to GoChef.\n\nWhere GoChef enables calling or messaging tools, technical information regarding those communications may be processed for security, support, fraud prevention and marketplace operation.'),

            _buildSection('8. USER CONTENT',
                'We may process content you choose to submit publicly or privately through the Platform, including:\n• profile photographs;\n• food photographs;\n• videos;\n• menus;\n• ratings;\n• reviews;\n• comments;\n• business descriptions;\n• responses to reviews; and\n• customer-support submissions.\n\nPublic content may be visible to other Users and, depending upon Platform design, may be visible outside the Platform.'),

            _buildSection('9. INFORMATION FROM THIRD PARTIES',
                'We may receive information from third parties such as:\n• payment processors;\n• identity-verification services;\n• fraud-prevention services;\n• delivery providers;\n• mapping providers;\n• authentication providers;\n• social-login providers;\n• analytics providers;\n• business partners;\n• marketing partners;\n• government authorities;\n• publicly available sources; and\n• Users who provide information concerning another person in connection with a legitimate transaction.\n\nFor example, a Customer arranging delivery for another person may provide that person\'s name, address or telephone number. The Customer represents that they have authority to provide that information.'),

            _buildSection('10. HOW WE USE PERSONAL INFORMATION',
                'GoChef may use personal information to:\n• create and maintain accounts;\n• connect Customers and Providers;\n• process orders;\n• display nearby Providers;\n• facilitate pickup and delivery;\n• process payments and payouts;\n• calculate fees;\n• provide receipts;\n• send order notifications;\n• enable communications;\n• provide customer support;\n• investigate complaints;\n• process refunds;\n• verify identity;\n• verify Provider eligibility;\n• prevent fraud;\n• protect account security;\n• enforce GoChef\'s Terms;\n• detect prohibited activity;\n• comply with legal obligations;\n• respond to food-safety incidents;\n• respond to government requests;\n• improve Platform functionality;\n• analyze marketplace performance;\n• develop new products;\n• personalize user experiences;\n• provide recommendations;\n• measure marketing;\n• communicate promotions where permitted;\n• protect GoChef\'s rights; and\n• support corporate transactions.'),

            _buildSection('11. FOOD-SAFETY INFORMATION',
                'If a User reports food poisoning, an allergic reaction, food contamination or another health or safety incident, GoChef may process information associated with that report.\n\nThis may include voluntarily submitted health-related details regarding the incident.\n\nWe use such information only as reasonably appropriate to:\n• investigate the complaint;\n• provide customer support;\n• identify the relevant Provider or transaction;\n• restrict or investigate accounts;\n• detect patterns of safety incidents;\n• work with insurers or claims administrators;\n• comply with law; and\n• cooperate with public-health or governmental authorities where appropriate.\n\nGoChef is not a healthcare provider. Users should not provide medical records or highly sensitive health information unless reasonably necessary for the reported matter.'),

            _buildSection('12. PROVIDER VERIFICATION AND FRAUD PREVENTION',
                'GoChef may use identity, transaction, device, account, payment and other information to identify suspicious activity.\n\nWe may use third-party databases or service providers to help verify identity; business information; payment information; Provider qualifications; account authenticity; or suspected fraudulent conduct.\n\nGoChef may suspend, restrict or require additional verification where suspicious activity is detected.'),

            _buildSection('13. AUTOMATED SYSTEMS',
                'GoChef may use automated systems or algorithms to assist with functions such as search ranking; Provider recommendations; fraud detection; location matching; order processing; marketplace analytics; safety monitoring; and Platform personalization.\n\nWhere applicable law grants rights relating to solely automated decisions producing significant legal effects, GoChef will comply with those requirements to the extent they apply to GoChef\'s actual practices.'),

            _buildSection('14. HOW WE DISCLOSE INFORMATION',
                'GoChef does not disclose personal information Users provide indiscriminately. We may disclose information where necessary to operate the Platform or for the purposes described below.'),

            _buildSection('15. INFORMATION SHARED WITH PROVIDERS',
                'When a Customer orders from a Provider, GoChef may provide that Provider information reasonably necessary to complete the transaction, such as:\n• Customer first name or account identifier;\n• order information;\n• special instructions;\n• pickup information;\n• delivery information;\n• relevant contact information; and\n• allergy or dietary information voluntarily supplied in connection with the order.\n\nProviders may use that information only for lawful purposes associated with the transaction and their legitimate business obligations.'),

            _buildSection('16. INFORMATION SHARED WITH CUSTOMERS',
                'GoChef may display Provider information necessary to operate the marketplace, including:\n• Provider name;\n• business name;\n• profile;\n• photographs;\n• menu;\n• general location;\n• ratings;\n• reviews;\n• pricing;\n• operating hours; and\n• available credential or permit indicators.\n\nGoChef will not intentionally publish Provider Social Security numbers, full banking credentials or similar highly sensitive information.'),

            _buildSection('17. DELIVERY PROVIDERS',
                'Where an independent third-party delivery provider is used, GoChef may provide information reasonably required to complete delivery.\n\nThis may include pickup location; delivery location; recipient name; recipient contact details; delivery instructions; order identifiers; and status information.\n\nThird-party delivery companies may independently process data under their own privacy policies.'),

            _buildSection('18. PAYMENT PROCESSORS',
                'GoChef may disclose transaction information to payment processors, financial institutions, payout providers and fraud-prevention providers as necessary to authorize charges; process payments; pay Providers; issue refunds; address disputes; detect fraud; and comply with financial laws.\n\nThese companies may independently collect information directly from Users.'),

            _buildSection('19. SERVICE PROVIDERS',
                'GoChef may use vendors that support functions such as:\n• cloud hosting;\n• data storage;\n• cybersecurity;\n• customer support;\n• email;\n• SMS;\n• mapping;\n• analytics;\n• software infrastructure;\n• identity verification;\n• fraud prevention;\n• payments;\n• delivery integration;\n• application monitoring; and\n• professional services.\n\nThese providers receive information only as reasonably necessary for their functions and subject to contractual or legal protections where required.'),

            _buildSection('20. ADVERTISING AND ANALYTICS',
                'GoChef may use analytics and advertising technologies to understand Platform usage, measure campaigns and reach prospective Users.\n\nThese technologies may process device identifiers; cookie identifiers; IP addresses; approximate location; application activity; website activity; advertising interactions; and similar information.\n\nGoChef does not intend to sell personal information to third parties for money.\n\nHowever, certain disclosures to advertising or analytics providers can qualify as a "sale," "sharing," "targeted advertising" or similar activity under some state privacy laws even when no money is exchanged. Where such laws apply, GoChef will provide legally required opt-out mechanisms.'),

            _buildSection('21. COOKIES AND SIMILAR TECHNOLOGIES',
                'GoChef websites and applications may use cookies; software development kits; pixels; local storage; mobile advertising identifiers; and comparable technologies.\n\nThese may be used for authentication; fraud prevention; preferences; security; analytics; Platform performance; marketing attribution; and advertising where permitted.\n\nUsers may have controls through device settings, browser settings, GoChef privacy settings or legally required opt-out tools.'),

            _buildSection('22. GLOBAL PRIVACY CONTROL',
                'Where GoChef is legally required to honor browser-based opt-out preference signals such as Global Privacy Control ("GPC"), GoChef will treat recognized qualifying signals as an opt-out request for the applicable browser or device as required by law.'),

            _buildSection('23. LEGAL AND SAFETY DISCLOSURES',
                'GoChef may disclose information where reasonably necessary to comply with law; respond to court orders; respond to subpoenas; respond to legitimate governmental requests; cooperate with public-health authorities; investigate suspected criminal activity; investigate food-safety incidents; enforce agreements; detect fraud; protect Users; protect GoChef employees; protect property; prevent imminent harm; or establish, exercise or defend legal claims.\n\nGoChef evaluates government requests according to applicable law.'),

            _buildSection('24. BUSINESS TRANSFERS',
                'If GoChef participates in a merger; acquisition; investment; financing; restructuring; bankruptcy; sale of assets; sale of equity; joint venture; or similar corporate transaction, personal information may be disclosed to advisors, investors, purchasers or other parties involved in the transaction, subject to appropriate confidentiality protections and applicable law.\n\nAny successor may continue processing information consistent with this Privacy Policy unless Users are provided legally required notice of a material change.'),

            _buildSection('25. GOCHEF AFFILIATES',
                'GoChef may disclose information among corporate affiliates where reasonably necessary to operate, secure, develop or administer our business and services, subject to applicable law.'),

            _buildSection('26. INFORMATION WE DO NOT INTENTIONALLY REQUEST',
                'Unless necessary for a specific lawful purpose, GoChef does not intentionally request that Customers provide:\n• Social Security numbers;\n• genetic data;\n• religious beliefs;\n• political affiliation;\n• sexual-orientation information;\n• complete medical files; or\n• biometric identifiers used to uniquely identify a person.\n\nProviders may be required to provide tax identifiers or other government information to payment or verification providers where necessary for payouts, legal compliance or identity verification.\n\nIf GoChef later introduces biometric verification or another feature involving legally protected sensitive data, GoChef will provide disclosures and obtain consent where required before using that feature.'),

            _buildSection('27. CHILDREN\'S PRIVACY',
                'The GoChef Platform is not intended to be independently used by children under 13.\n\nGoChef does not knowingly collect personal information directly from children under 13 through a child-directed service.\n\nIf GoChef learns that personal information from a child under 13 was collected contrary to applicable law, GoChef will take reasonable steps to delete or otherwise address the information.\n\nParents or legal guardians who believe a child has provided information improperly may contact GoChef at the privacy contact listed below.'),

            _buildSection('28. DATA SECURITY',
                'GoChef uses administrative, technical and organizational safeguards designed to protect personal information against unauthorized access, loss, misuse, alteration and disclosure.\n\nDepending upon the system and information involved, safeguards may include:\n• encryption;\n• access controls;\n• authentication;\n• role-based permissions;\n• logging;\n• monitoring;\n• secure hosting;\n• payment tokenization;\n• security testing;\n• vendor controls; and\n• incident-response procedures.\n\nNo internet-connected system can be guaranteed to be completely secure. Accordingly, GoChef cannot promise that unauthorized parties will never defeat security measures.\n\nUsers should use unique passwords, safeguard authentication credentials and promptly notify GoChef of suspicious account activity.'),

            _buildSection('29. DATA BREACH RESPONSE',
                'If GoChef discovers unauthorized access to personal information, GoChef will investigate and take actions appropriate to the circumstances.\n\nWhere legally required, GoChef will notify affected individuals and applicable governmental authorities.\n\nGoChef may work with cybersecurity firms, law enforcement, insurers, attorneys and other specialists in investigating or responding to an incident.'),

            _buildSection('30. DATA RETENTION',
                'GoChef retains personal information for as long as reasonably necessary for the purposes for which it was collected and for legitimate legal, operational and security requirements.\n\nRetention periods may depend on the type of information; whether an account remains active; transaction history; tax obligations; accounting obligations; fraud prevention; food-safety investigations; legal disputes; chargebacks; security needs; regulatory requirements; and applicable statutes of limitation.\n\nInformation may be retained after account deletion where reasonably necessary or legally required. When information is no longer reasonably necessary, GoChef may delete, anonymize or aggregate it.'),

            _buildSection('31. ACCOUNT DELETION',
                'Users may request deletion of their GoChef account through available account tools or by contacting GoChef.\n\nDeleting an account does not necessarily require GoChef to immediately delete every record associated with the account.\n\nGoChef may retain information where necessary to complete transactions; detect fraud; prevent abuse; comply with law; resolve disputes; enforce agreements; maintain financial records; respond to food-safety matters; or protect legal rights.'),

            _buildSection('32. PRIVACY RIGHTS',
                'Depending upon where you live, applicable law may provide rights regarding your personal information.\n\nThese may include the right to:\n• access information;\n• know categories of information collected;\n• obtain copies of information;\n• request deletion;\n• request correction;\n• withdraw consent;\n• object to certain processing;\n• limit certain sensitive-data processing;\n• opt out of qualifying sale or sharing;\n• opt out of targeted advertising; and\n• receive non-discriminatory treatment for exercising privacy rights.\n\nGoChef will honor verified requests where legally required.'),

            _buildSection('33. CALIFORNIA PRIVACY RIGHTS',
                'If the California Consumer Privacy Act, as amended ("CCPA"), applies to GoChef and to your information, qualifying California residents may exercise applicable rights including:\n\n• Right to Know: You may request information regarding categories or specific pieces of personal information GoChef has collected about you, subject to legal limitations.\n\n• Right to Delete: You may request deletion of qualifying personal information, subject to statutory exceptions.\n\n• Right to Correct: You may request correction of inaccurate qualifying personal information.\n\n• Right to Opt Out of Sale or Sharing: You may direct a covered business not to sell or share qualifying personal information as those terms are defined by California law.\n\n• Right to Limit Use of Sensitive Personal Information: Where GoChef uses sensitive personal information in a manner subject to this right, qualifying Users may request applicable limitations.\n\n• Right to Non-Discrimination: GoChef will not unlawfully discriminate against a User for exercising privacy rights.'),

            _buildSection('34. CATEGORIES OF PERSONAL INFORMATION FOR CALIFORNIA USERS',
                'Depending upon your interaction with GoChef, categories collected may include:\n• Identifiers: name, username, email, telephone number, IP address, account identifiers and similar information.\n• Customer Records: contact information, payment-related information and transaction records.\n• Commercial Information: orders, purchases, Provider activity, transaction history and preferences.\n• Internet or Electronic Activity: device information, application activity, website interactions and analytics information.\n• Geolocation Information: pickup, delivery, approximate location and, where authorized, precise location.\n• Audio/Electronic Information: communications or recordings if a disclosed feature generates them.\n• Professional or Employment-Related Information: Provider business information and qualifications.\n• Sensitive Personal Information: potentially including precise geolocation, account login credentials and financial information to the extent processed.\n• Inferences: preferences or recommendations derived from Platform interactions.\n\nThe categories actually collected depend upon Platform features and User activity.'),

            _buildSection('35. SOURCES OF CALIFORNIA PERSONAL INFORMATION',
                'GoChef may collect information directly from Users; automatically through websites or applications; from Providers; from Customers; from payment processors; from delivery providers; from identity and fraud-prevention vendors; from social authentication providers; from analytics services; from business partners; and from public or governmental sources where lawful.'),

            _buildSection('36. PURPOSES OF CALIFORNIA PERSONAL INFORMATION PROCESSING',
                'GoChef may use the categories above for providing services; processing transactions; security; fraud prevention; customer support; marketplace matching; location services; payments; analytics; legal compliance; food-safety investigations; quality improvement; communications; personalization; and marketing where permitted.'),

            _buildSection('37. CALIFORNIA SALE AND SHARING DISCLOSURE',
                'GoChef does not intend to sell personal information in exchange for money.\n\nSome analytics, advertising or digital-marketing practices may potentially constitute "sharing" or "sale" under California\'s broad statutory definitions.\n\nIf GoChef engages in activity legally classified as sale or sharing and the CCPA applies, GoChef will provide required disclosures and opt-out mechanisms, including honoring legally recognized opt-out preference signals where applicable.\n\nGoChef does not knowingly sell or share personal information of individuals under 16 in circumstances requiring affirmative authorization.'),

            _buildSection('38. SENSITIVE PERSONAL INFORMATION',
                'GoChef uses sensitive personal information only for purposes reasonably necessary to provide, secure and administer the Platform unless additional processing is disclosed and permitted by applicable law.\n\nSensitive information may include account credentials; precise geolocation when enabled; certain financial account information; tax information from Providers; or voluntarily provided information concerning a health or allergy incident.\n\nWhere applicable law grants a right to limit certain uses of sensitive personal information, GoChef will provide the legally required mechanism.'),

            _buildSection('39. SUBMITTING A PRIVACY REQUEST',
                'Privacy requests may be submitted through:\n\nPrivacy Email: privacy@thegrubnextdoor.com\nOnline Privacy Request: https://thegrubnextdoor.com/privacy\n\nMail:\nGoChef Technologies\nAttn: Privacy Department\n12400 Ventura Blvd, Studio City, CA 91604\n\nIf GoChef is legally required to provide additional submission methods, including a toll-free number, those methods will be displayed in this Privacy Policy or GoChef\'s privacy center.'),

            _buildSection('40. IDENTITY VERIFICATION',
                'Before responding to certain privacy requests, GoChef may verify the requester\'s identity.'),

            _buildSection('41. AUTHORIZED AGENTS',
                'Where applicable law permits an authorized agent to make a privacy request on behalf of another person, GoChef may require evidence that the agent has authority to act for the User and may independently verify the User\'s identity where legally permitted.'),

            _buildSection('42. RESPONSE TIMES',
                'GoChef will respond to verified privacy requests within the period required by applicable law. Where legally permitted, GoChef may extend the response period when reasonably necessary and will provide notice of the extension.'),

            _buildSection('43. NON-DISCRIMINATION',
                'GoChef will not unlawfully discriminate against Users for exercising applicable privacy rights.\n\nCertain information is necessary to provide Platform services. If a User requests deletion or restriction of information essential to account operation, GoChef may be unable to continue providing some services.'),

            _buildSection('44. OTHER U.S. STATE PRIVACY RIGHTS',
                'Residents of states with comprehensive privacy laws may have additional rights where those laws apply to GoChef.\n\nDepending on the jurisdiction, these rights may include access; correction; deletion; portability; opt-out of targeted advertising; opt-out of qualifying sales; opt-out of certain profiling; and appeal of a denied privacy request.\n\nGoChef will provide rights required by applicable state law.'),

            _buildSection('45. MARKETING COMMUNICATIONS',
                'Users may opt out of promotional emails using the unsubscribe mechanism contained in those communications.\n\nUsers may also adjust certain marketing preferences through available account settings.\n\nEven after opting out of marketing, GoChef may continue sending non-promotional communications such as order information; security notices; legal notices; payment notices; support communications; and account-related messages.'),

            _buildSection('46. PUSH NOTIFICATIONS',
                'Users may control mobile push notifications through device settings or Platform settings where available.\n\nDisabling push notifications may prevent certain real-time alerts but will not necessarily disable other communications required to operate an account or complete transactions.'),

            _buildSection('47. THIRD-PARTY LINKS',
                'The GoChef Platform may contain links to websites, applications or services operated by third parties.\n\nGoChef does not control those third parties\' independent privacy practices.\n\nUsers should review the privacy policies of third-party services before providing information directly to them.'),

            _buildSection('48. INTERNATIONAL USERS',
                'GoChef may initially focus on particular markets but may become accessible from additional jurisdictions.\n\nWhere information is transferred between countries, privacy and data-protection requirements may differ.\n\nGoChef will implement legally required safeguards for international transfers where applicable.'),

            _buildSection('49. CHANGES TO THIS PRIVACY POLICY',
                'GoChef may update this Privacy Policy to reflect new Platform features; new technology; changes in business practices; changes in vendors; new legal requirements; or other developments.\n\nThe "Last Updated" date will identify the most recent revision.\n\nWhere applicable law requires additional notice or consent for a material change, GoChef will provide it.'),

            _buildSection('50. CONTACT GOCHEF ABOUT PRIVACY',
                'Questions or requests concerning this Privacy Policy may be directed to:\n\nGoChef Technologies\nThe GRUB Next Door!\nAttn: Privacy Department\n12400 Ventura Blvd, Studio City, CA 91604\nPrivacy: privacy@thegrubnextdoor.com\nSupport: support@thegrubnextdoor.com\nLegal: legal@thegrubnextdoor.com'),

            const SizedBox(height: 12),

            // Privacy Commitment Box
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white30),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRIVACY COMMITMENT',
                    style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'GoChef\'s business is connecting people through technology.\n\nGoChef will use personal information for legitimate marketplace, security, payment, safety, support, legal and business purposes consistent with this Privacy Policy and applicable law.\n\nGoChef will not intentionally make sensitive personal information publicly available merely because an individual uses the GoChef Platform.\n\nGoChef expects Providers, vendors and service providers handling User information to respect applicable privacy and security requirements.\n\nThe GRUB Next Door! - Powered by GoChef Technologies.',
                    style: TextStyle(color: Colors.white, fontSize: 12, height: 1.55, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.headlineMd(color: Colors.white).copyWith(fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
