import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

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
          'Terms of Service',
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
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.gavel, color: AppColors.primary, size: 24),
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
                              style: AppTextStyles.labelSm(color: AppColors.primary).copyWith(fontWeight: FontWeight.bold),
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

            // Important Notice Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: Text(
                'PLEASE READ THESE TERMS OF SERVICE CAREFULLY. THEY CONTAIN IMPORTANT INFORMATION REGARDING YOUR LEGAL RIGHTS, REMEDIES, RESPONSIBILITIES, LIMITATIONS OF LIABILITY, ASSUMPTION OF RISK, INDEMNIFICATION OBLIGATIONS, AND AN AGREEMENT TO RESOLVE CERTAIN DISPUTES THROUGH INDIVIDUAL BINDING ARBITRATION RATHER THAN IN COURT.\n\nBy creating an account, accessing or using the GoChef mobile application, website, software, marketplace, payment features, communications tools, ordering system, delivery integrations, or related services, you agree to these Terms of Service.\n\nIf you do not agree, do not access or use the GoChef Platform.',
                style: const TextStyle(color: Colors.amberAccent, fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 24),

            _buildSection('1. ABOUT GOCHEF',
                'GoChef Technologies ("GoChef," "we," "our," or "us"), operating under the brand GoChef Technologies - The GRUB Next Door!, provides a technology platform designed to connect consumers seeking food and related services with independent chefs, cooks, caterers, restaurants, food entrepreneurs, permitted home-kitchen operators, food vendors and other independent food providers.\n\nThe GoChef application, websites, software, communications systems, payment functionality, marketplace technology and related services are referred to collectively as the "GoChef Platform."\n\nIndividuals or businesses offering food, cooking, catering or related services through the GoChef Platform are referred to as "Providers."\n\nIndividuals purchasing or requesting food or services through the GoChef Platform are referred to as "Customers." Providers and Customers may collectively be referred to as "Users."'),

            _buildSection('2. GOCHEF IS A TECHNOLOGY MARKETPLACE',
                '**GOCHEF IS A TECHNOLOGY COMPANY. GOCHEF DOES NOT PREPARE, MANUFACTURE, COOK, PACKAGE OR SERVE FOOD SOLD BY INDEPENDENT PROVIDERS UNLESS GOCHEF EXPRESSLY STATES OTHERWISE IN WRITING FOR A SPECIFIC PRODUCT OR SERVICE.**\n\nThe GoChef Platform allows Customers and independent Providers to discover one another, communicate, transact, arrange orders and, where available, coordinate pickup or delivery.\n\nUnless expressly stated otherwise:\n• GoChef is not the seller or manufacturer of food offered by a Provider.\n• GoChef does not own or operate Providers\' kitchens.\n• GoChef does not employ Providers merely because they use the GoChef Platform.\n• GoChef does not direct how a Provider cooks, prepares, handles or stores food.\n• GoChef is not a restaurant, commercial kitchen, caterer, grocery store or food manufacturer merely by operating the Platform.\n• GoChef is not a medical, nutrition, dietary or allergy-advisory service.\n• GoChef does not independently guarantee the accuracy of every menu, ingredient list, photograph, description, certification, license or representation made by a Provider.\n• GoChef does not guarantee that any Provider will accept or complete a particular order.\n\nProviders are independent third parties and are not employees, partners, joint venturers, actual agents, apparent agents or representatives of GoChef solely by virtue of using the Platform.\n\nAny tools, guidelines, ratings systems, background checks, verification procedures, safety requirements, food-safety policies, quality controls or standards that GoChef may implement are intended to support marketplace quality and safety. They do not create an employment or agency relationship and do not constitute a guarantee that a Provider, meal, kitchen or service is safe, lawful, suitable or free from risk.'),

            _buildSection('3. THE PROVIDER IS RESPONSIBLE FOR THE FOOD',
                'Every Provider is solely responsible for the food and food-related services the Provider offers.\n\nProviders are responsible for, among other things: food preparation; ingredient selection; sourcing; sanitation; cleanliness; refrigeration; cooking temperatures; food storage; cross-contamination prevention; allergy precautions; packaging; labeling; food handling; transportation before pickup; expiration and spoilage management; portioning; menu accuracy; kitchen safety; compliance with food-safety rules; permits; business licenses; certifications; taxes; insurance; and compliance with federal, state, county and local laws.\n\nWhere applicable, Providers operating as Microenterprise Home Kitchen Operations ("MEHKOs"), cottage food operations or similar home-based food businesses are solely responsible for obtaining and maintaining all permits, registrations, inspections, approvals and certifications required by the applicable governmental authority.\n\nGoChef may request documentation regarding a Provider\'s eligibility to operate, but GoChef\'s receipt, review, display or verification of documentation does not constitute a warranty regarding the Provider\'s ongoing compliance.\n\nA Provider must immediately stop offering food through GoChef if the Provider loses a required permit, authorization or legal right to operate.'),

            _buildSection('4. FOODBORNE ILLNESS, INJURY AND FOOD SAFETY',
                'FOOD IS PREPARED AND PROVIDED BY INDEPENDENT THIRD-PARTY PROVIDERS.\n\nTo the fullest extent permitted by applicable law, GoChef and its founders, owners, shareholders, members, directors, officers, employees, affiliates, contractors, representatives, successors and agents ("GoChef Protected Parties") are not responsible for injury, illness, death, property damage or other harm caused by or allegedly arising from food or services supplied by a Provider.\n\nThis includes claims involving:\n• food poisoning or foodborne illness;\n• bacterial, viral, fungal or parasitic contamination;\n• salmonella, E. coli, listeria or other pathogens;\n• allergic reactions;\n• allergen cross-contact;\n• undisclosed ingredients;\n• choking;\n• bones, shells or foreign objects;\n• undercooked food;\n• spoiled food;\n• improper food temperatures;\n• contamination;\n• sanitation failures;\n• unsafe food storage;\n• improper handling;\n• incorrect labeling;\n• nutritional inaccuracies;\n• dietary restrictions;\n• packaging failures;\n• burns;\n• cuts;\n• bodily injury;\n• poisoning;\n• adverse health reactions;\n• illness occurring after consumption; or\n• death associated with food or services obtained from an independent Provider.\n\nThe Provider who prepares or supplies the food remains responsible for that Provider\'s food preparation, ingredients, handling, sanitation and legal compliance.\n\nNothing in these Terms excludes liability that applicable law prohibits GoChef from excluding.'),

            _buildSection('5. ALLERGIES AND SPECIAL DIETS',
                'Customers with allergies, food sensitivities, medical dietary requirements, religious dietary restrictions or other special dietary needs are responsible for evaluating whether a Provider and particular food item are appropriate for them.\n\nProvider descriptions such as "allergy friendly," "gluten free," "nut free," "vegan," "kosher," "halal," "organic," "keto," "dairy free" or similar descriptions are representations made by the Provider unless GoChef expressly states otherwise.\n\nGoChef does not independently certify those representations.\n\nGOCHEF CANNOT GUARANTEE THAT ANY FOOD IS FREE FROM ALLERGENS OR CROSS-CONTACT.\n\nCustomers with severe or life-threatening allergies should communicate directly with the Provider before ordering and should exercise independent judgment regarding whether to consume the food.\n\nProviders must accurately disclose known ingredients and allergens when required by law or GoChef policy.'),

            _buildSection('6. PROVIDER REPRESENTATIONS AND WARRANTIES',
                'By offering food through GoChef, each Provider represents and warrants that:\n1. the Provider has legal authority to operate the food business being offered;\n2. all required licenses, registrations, permits and food-handler certifications have been obtained and will remain current;\n3. the Provider will comply with applicable food safety, health, sanitation and consumer-protection laws;\n4. all food will be lawfully sourced;\n5. menu descriptions will be materially accurate;\n6. known allergens and ingredients will not intentionally be misrepresented;\n7. the Provider will not offer prohibited, adulterated, recalled, unsafe or unlawfully prepared products;\n8. photographs and descriptions will not materially mislead Customers;\n9. prices and availability information supplied by the Provider will be accurate to the Provider\'s knowledge;\n10. the Provider will comply with all applicable tax obligations;\n11. the Provider has authority to grant GoChef the licenses described in these Terms regarding Provider content;\n12. the Provider will maintain insurance where required by law or by GoChef\'s Provider requirements; and\n13. the Provider will immediately notify GoChef of any serious food-safety incident, government investigation, permit suspension, recall, contamination event or significant Customer injury associated with food sold through the Platform.'),

            _buildSection('7. CUSTOMER RESPONSIBILITIES',
                'Customers agree to provide accurate account and delivery information; use valid payment methods; inspect orders upon receipt when reasonably possible; follow appropriate food-storage and reheating instructions; communicate legitimate allergies or dietary concerns directly to Providers; avoid fraudulent complaints, refunds or chargebacks; and use the Platform lawfully.\n\nCustomers must not knowingly order products they are legally prohibited from purchasing.'),

            _buildSection('8. ELIGIBILITY AND ACCOUNTS',
                'You must be at least 18 years old and legally capable of entering into a binding agreement to independently create and operate a GoChef account.\n\nA minor may consume food obtained through GoChef under the supervision and responsibility of a parent or legal guardian, but may not independently enter into transactions where prohibited by law.\n\nYou agree to provide accurate information and maintain the security of your login credentials.\n\nYou are responsible for activity occurring through your account unless caused by circumstances for which applicable law makes GoChef responsible.\n\nYou must promptly notify GoChef if you believe your account has been compromised.\n\nGoChef may require identity, age, business, tax, banking, food-permit or other verification.'),

            _buildSection('9. ORDERS',
                'Placing an order through the Platform constitutes an offer to purchase food or services from the applicable Provider.\n\nAn order may be subject to Provider acceptance, availability, payment authorization, fraud review and other applicable requirements.\n\nProviders may reject an order where permitted by law.\n\nMenu items may become unavailable.\n\nGoChef does not guarantee that a Provider will accept, prepare or complete every order.\n\nEstimated preparation, pickup and delivery times are estimates rather than guarantees.'),

            _buildSection('10. PRICING AND FEES',
                'Prices for food are generally established by Providers.\n\nGoChef may charge service fees, technology fees, marketplace fees, delivery-related fees, taxes, regulatory fees, cancellation charges or other charges disclosed before checkout.\n\nPrices and fees may vary based on location, demand, promotions, delivery arrangements, Provider pricing or other factors.\n\nThe total amount presented before final checkout will govern the transaction, subject to lawful adjustments, substitutions, refunds or authorization changes.\n\nProviders may pay GoChef commissions, marketplace fees or other agreed compensation.'),

            _buildSection('11. PAYMENT PROCESSING',
                'GoChef may use independent third-party payment processors or payment facilitators.\n\nBy providing a payment method, you authorize GoChef and its payment providers to process authorized charges associated with your transactions.\n\nGoChef generally does not need to store complete payment-card numbers where payment information is handled directly by a payment processor.\n\nProviders may be required to establish payment accounts with third-party providers and provide banking, tax or identity information directly to those providers.\n\nUse of payment services may also be governed by the payment provider\'s own terms and privacy policy.'),

            _buildSection('12. PROVIDER EARNINGS',
                'Where GoChef facilitates Provider payouts, the amount payable to a Provider will be determined according to the Provider\'s applicable commercial arrangement with GoChef.\n\nProvider earnings may be reduced by agreed platform fees, refunds, chargebacks, adjustments, taxes, penalties resulting from Provider conduct, or other legally permissible amounts.\n\nProviders are independent businesses and are responsible for their own taxes, expenses, equipment, ingredients, labor, insurance and business costs except where law requires otherwise.'),

            _buildSection('13. TAXES',
                'Users are responsible for taxes legally imposed upon them.\n\nGoChef may calculate, collect, report or remit taxes when required by applicable law.\n\nProviders remain responsible for tax obligations that are not legally required to be collected or remitted by GoChef.\n\nNothing provided by GoChef constitutes tax advice.'),

            _buildSection('14. CANCELLATIONS, REFUNDS AND CHARGEBACKS',
                'Cancellation and refund eligibility may depend on when an order was canceled, whether preparation had begun, whether food had been purchased or prepared, Provider policies, delivery status, food-safety issues and applicable law.\n\nGoChef may issue refunds, credits or adjustments in its discretion where permitted by law.\n\nIssuing a courtesy refund does not constitute an admission that GoChef was responsible for the underlying event.\n\nUsers must not initiate fraudulent chargebacks.\n\nGoChef may suspend accounts associated with chargeback abuse, payment fraud, refund fraud or repeated misconduct.\n\nNothing in this section limits legally mandated refund rights.'),

            _buildSection('15. PICKUP AND DELIVERY',
                'Orders may be picked up directly from Providers or delivered using Providers, independent couriers or third-party delivery networks.\n\nWhere delivery is provided by a third party, that delivery provider is an independent service provider unless expressly stated otherwise.\n\nGoChef does not guarantee exact delivery times; courier availability; uninterrupted delivery coverage; a particular delivery route; or that third-party delivery providers will perform without delay or error.\n\nCustomers are responsible for providing accurate addresses, gate codes, contact information and delivery instructions.\n\nProviders are responsible for packaging food appropriately for the chosen delivery or pickup method.'),

            _buildSection('16. COMMUNICATIONS BETWEEN USERS',
                'GoChef may provide messaging, calling or other communication tools enabling Customers and Providers to communicate.\n\nCommunications may be processed, stored, reviewed or analyzed as reasonably necessary to operate the Platform; prevent fraud; investigate complaints; enforce policies; improve safety; provide customer support; resolve transactions; comply with law; or protect Users and GoChef.\n\nUsers may not use Platform communications to harass, threaten, discriminate against, defraud or exploit another person.'),

            _buildSection('17. RATINGS, REVIEWS AND USER CONTENT',
                'Users may be permitted to submit reviews, ratings, comments, photographs, videos, menus, logos, names, descriptions and other content ("User Content").\n\nYou retain ownership of your User Content.\n\nBy submitting User Content, you grant GoChef a worldwide, non-exclusive, royalty-free, sublicensable and transferable license to host, reproduce, display, distribute, format, adapt and use that content for operating, improving, promoting and marketing the GoChef Platform and the applicable listing, subject to applicable law and the Privacy Policy.\n\nYou represent that you have the right to submit your User Content.\n\nYou may not submit defamatory, fraudulent, discriminatory, illegal, infringing, obscene, threatening or intentionally misleading content.\n\nGoChef may remove User Content that violates these Terms or Platform policies.'),

            _buildSection('18. INTELLECTUAL PROPERTY',
                'The GoChef Platform, GoChef branding, software, interface, design, code, databases, graphics, logos, trademarks, trade dress and other proprietary materials are owned by or licensed to GoChef and are protected by applicable intellectual-property laws.\n\nExcept as expressly authorized, Users may not copy, reverse engineer, reproduce, scrape, sell, sublicense, distribute or commercially exploit the GoChef Platform or proprietary materials.\n\nNo rights are granted except those expressly stated in these Terms.'),

            _buildSection('19. PROHIBITED USE',
                'Users may not use the Platform unlawfully; impersonate another person; create fraudulent accounts; attempt unauthorized access; interfere with Platform security; scrape data without authorization; upload malicious code; manipulate ratings; engage in payment fraud; discriminate unlawfully; threaten another User; sell prohibited products; knowingly offer unsafe or adulterated food; circumvent GoChef fees through misuse of Platform functionality; infringe intellectual-property rights; or use GoChef to facilitate criminal activity.'),

            _buildSection('20. BACKGROUND CHECKS, LICENSE VERIFICATION AND SAFETY FEATURES',
                'GoChef may, but is not obligated except where legally required, to use background screening, identity verification, food-permit verification, safety education or other screening measures.\n\nNO SCREENING PROCESS IS PERFECT.\n\nA verification badge, completed background review, food-handler credential, permit indicator, rating or other Platform designation is not a guarantee that a person or business is safe, competent, properly licensed at all times or suitable for any specific Customer.\n\nUsers should exercise reasonable judgment when interacting with one another.'),

            _buildSection('21. THIRD-PARTY SERVICES',
                'The Platform may integrate with services operated by companies such as payment processors, mapping providers, authentication providers, cloud providers, analytics companies and delivery networks.\n\nThose third-party services are operated independently and may have separate terms and privacy policies.\n\nGoChef is not responsible for a third party\'s independent systems, outages or conduct except to the extent applicable law provides otherwise.'),

            _buildSection('22. PLATFORM AVAILABILITY',
                'The GoChef Platform is provided on an "AS IS" and "AS AVAILABLE" basis to the fullest extent permitted by law.\n\nGoChef does not warrant that the Platform will always be uninterrupted, secure, error-free or available in every geographic area.\n\nTechnology services may experience maintenance, outages, communications failures, bugs, cyberattacks, internet disruptions or third-party failures.'),

            _buildSection('23. NO WARRANTY REGARDING PROVIDERS OR FOOD',
                'TO THE MAXIMUM EXTENT PERMITTED BY LAW, GOCHEF DISCLAIMS EXPRESS AND IMPLIED WARRANTIES REGARDING FOOD, GOODS OR SERVICES PROVIDED BY INDEPENDENT PROVIDERS, INCLUDING IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT TO THE EXTENT SUCH WARRANTIES MAY LEGALLY BE DISCLAIMED.\n\nGOCHEF DOES NOT WARRANT OR GUARANTEE the quality of a Provider\'s food; taste; nutritional value; portion size; preparation method; sanitation; ingredient sourcing; licensing status; dietary suitability; allergen safety; service quality; timeliness; legal compliance; or fitness for a particular Customer.'),

            _buildSection('24. ASSUMPTION OF RISK',
                'Food preparation, food consumption, pickup, delivery and in-person interactions contain inherent risks.\n\nTo the fullest extent permitted by law, Customers voluntarily assume risks ordinarily associated with purchasing and consuming food prepared by independent third parties.\n\nProviders voluntarily assume risks ordinarily associated with operating an independent food business and interacting with Customers and delivery providers.\n\nThis assumption of risk does not waive rights that cannot lawfully be waived.'),

            _buildSection('25. LIMITATION OF LIABILITY',
                '**TO THE MAXIMUM EXTENT PERMITTED BY APPLICABLE LAW, THE GOCHEF PROTECTED PARTIES SHALL NOT BE LIABLE FOR INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, PUNITIVE OR CONSEQUENTIAL DAMAGES, LOST PROFITS, LOST BUSINESS, LOST REVENUE, LOST DATA OR LOSS OF GOODWILL RESULTING FROM OR RELATING TO USE OF THE PLATFORM OR THIRD-PARTY FOOD OR SERVICES.**\n\nTo the fullest extent permitted by law, the GoChef Protected Parties are not liable for damages arising from the preparation, manufacture, handling, storage, packaging, labeling, delivery or consumption of food supplied by a Provider; foodborne illness; allergic reactions; cross-contamination; personal injury; property damage; Provider misconduct; Customer misconduct; third-party courier conduct; inaccurate Provider information; delivery delays; cancelled orders; third-party system failures; unauthorized conduct outside GoChef\'s reasonable control; or transactions or relationships between Users and independent Providers.\n\nWhere applicable law allows a contractual monetary limitation but does not permit complete exclusion, GoChef\'s aggregate liability arising from the Platform shall not exceed the greater of:\n(a) the amount of GoChef service fees actually paid by the claimant to GoChef during the six months preceding the event giving rise to the claim; or\n(b) \$500.\n\nThis limitation applies regardless of the legal theory asserted to the maximum extent permitted by law.\n\nNothing in these Terms excludes liability for fraud, willful misconduct, gross negligence or other liability that applicable law does not permit to be excluded or limited.'),

            _buildSection('26. RELEASE REGARDING PROVIDER DISPUTES',
                'To the fullest extent permitted by law, if a dispute arises between a Customer and Provider, or between Users and an independent delivery provider or other third party, the parties involved remain principally responsible for resolving the dispute.\n\nUsers release the GoChef Protected Parties from claims arising solely from independent third-party conduct to the extent such claims may lawfully be released.\n\nThis does not release GoChef from obligations imposed directly upon it by applicable law.'),

            _buildSection('27. CUSTOMER INDEMNIFICATION',
                'To the extent permitted by law, Customers agree to indemnify and hold the GoChef Protected Parties harmless from third-party claims, liabilities, losses, damages and reasonable legal expenses arising from the Customer\'s unlawful use of the Platform; fraud; material breach of these Terms; violation of another person\'s rights; or Customer User Content.\n\nThis provision does not require a consumer to indemnify GoChef for liability that applicable law prohibits GoChef from shifting to the consumer.'),

            _buildSection('28. PROVIDER INDEMNIFICATION',
                'EACH PROVIDER AGREES TO DEFEND, INDEMNIFY AND HOLD HARMLESS THE GOCHEF PROTECTED PARTIES from and against claims, lawsuits, demands, investigations, regulatory actions, judgments, settlements, penalties, damages, losses, liabilities and reasonable attorneys\' fees arising from or related to:\n1. food prepared, sold, handled or supplied by the Provider;\n2. foodborne illness;\n3. allergic reactions or allergen cross-contact;\n4. bodily injury, illness or death associated with Provider food;\n5. contamination or adulteration;\n6. Provider negligence or misconduct;\n7. Provider employees, helpers, contractors or agents;\n8. violations of food-safety law;\n9. failure to obtain required permits or licenses;\n10. misrepresentation of ingredients or menu items;\n11. tax obligations;\n12. employment or contractor claims involving Provider personnel;\n13. infringement caused by Provider content;\n14. violation of Customer rights;\n15. Provider\'s breach of these Terms; or\n16. any product recall, health-department action or governmental investigation resulting from Provider operations.\n\nThis section is intended to allocate responsibility for Provider operations to the Provider who controls those operations.'),

            _buildSection('29. INSURANCE',
                'Providers are responsible for maintaining insurance required by law and any additional insurance required under separate GoChef Provider standards or agreements.\n\nGoChef may request proof of insurance.\n\nGoChef\'s request, review or failure to request proof of insurance does not make GoChef the Provider\'s insurer and does not transfer the Provider\'s liabilities to GoChef.'),

            _buildSection('30. HEALTH AND SAFETY INCIDENTS',
                'Users should seek appropriate medical attention immediately if they believe they are experiencing a medical emergency or serious foodborne illness.\n\nGoChef is not a medical provider and cannot diagnose medical conditions.\n\nUsers may report suspected food-safety incidents to GoChef so that GoChef may investigate Platform-related concerns, preserve information, restrict accounts or cooperate with appropriate authorities.\n\nGoChef\'s investigation of an incident does not constitute an admission of liability.'),

            _buildSection('31. RECALLS AND GOVERNMENT REQUESTS',
                'GoChef may remove listings, suspend Providers, cancel transactions, notify Users or disclose relevant information to government authorities where reasonably necessary to respond to product recalls; public-health concerns; food-safety incidents; court orders; subpoenas; valid legal requests; fraud; emergencies; or suspected illegal activity.\n\nProviders must cooperate with legitimate food-safety investigations regarding products offered through the Platform.'),

            _buildSection('32. ACCOUNT SUSPENSION AND TERMINATION',
                'GoChef may restrict, suspend or terminate access where reasonably necessary because of fraud; safety concerns; foodborne illness reports; permit problems; repeated complaints; criminal conduct; misuse; nonpayment; chargebacks; intellectual-property violations; harassment; breach of these Terms; legal requirements; or threats to GoChef, Users or the public.\n\nWhere appropriate and legally required, GoChef may provide notice or an opportunity to appeal.\n\nUsers may discontinue use of GoChef at any time.\n\nSections that by their nature should survive termination - including intellectual property, payment obligations, indemnification, dispute resolution, limitations of liability and applicable privacy obligations - will survive.'),

            _buildSection('33. ELECTRONIC COMMUNICATIONS',
                'By creating an account, you agree that GoChef may send transactional electronic communications regarding your account, orders, security, customer support and these Terms.\n\nMarketing communications will be subject to applicable law and available opt-out mechanisms.\n\nConsent to receive marketing communications is not a condition of purchasing food unless expressly and lawfully stated.'),

            _buildSection('34. MOBILE MESSAGING',
                'If you provide a mobile number, GoChef may send messages reasonably related to account verification, order status, delivery, security, support and other requested services.\n\nWhere GoChef sends marketing text messages requiring consent under applicable law, GoChef will obtain the required consent.\n\nMessage and data rates may apply.\n\nUsers may opt out of applicable marketing texts using the instructions provided with those messages.'),

            _buildSection('35. APP STORES',
                'If the GoChef application is downloaded from Apple, Google or another application marketplace, use of that marketplace may also be governed by the marketplace\'s terms.\n\nThe application marketplace is not responsible for food sold by Providers through GoChef.\n\nWhere required by an application marketplace\'s terms, that marketplace and its affiliates may be third-party beneficiaries of applicable mobile application provisions.'),

            _buildSection('36. PRIVACY',
                'GoChef\'s collection and use of personal information are governed by the GoChef Privacy Policy.\n\nBy using the Platform, you acknowledge that information necessary to process orders may be shared with applicable Providers, payment processors, delivery services and other service providers as described in the Privacy Policy.'),

            _buildSection('37. CHANGES TO THESE TERMS',
                'GoChef may update these Terms to reflect changes in law, technology, business operations, Platform features or risk-management requirements.\n\nMaterial changes will be communicated as required by applicable law.\n\nThe revised Terms will state their effective date.\n\nContinued use after legally effective changes constitutes acceptance where permitted by law.\n\nIf applicable law requires affirmative consent to a material change, GoChef will request it.'),

            _buildSection('38. DISPUTE RESOLUTION - INFORMAL RESOLUTION',
                'Before initiating arbitration or litigation, you and GoChef agree to make a good-faith effort to resolve the dispute informally.\n\nA claimant should provide written notice describing the claimant\'s name and account information; the facts giving rise to the dispute; the legal basis of the claim, if known; the relief requested; and sufficient information for GoChef to investigate.\n\nNotices to GoChef should be sent to:\nGoChef Technologies\nAttn: Legal Department\n12400 Ventura Blvd, Studio City, CA 91604\nlegal@thegrubnextdoor.com\n\nThe parties will have at least 30 days after receipt of a complete notice to attempt informal resolution unless applicable law requires otherwise.'),

            _buildSection('39. BINDING INDIVIDUAL ARBITRATION',
                'PLEASE READ THIS SECTION CAREFULLY.\n\nExcept for disputes that applicable law prohibits from mandatory arbitration and the exceptions described below, you and GoChef agree that disputes arising out of or relating to these Terms; the Platform; an account; a transaction; a relationship between you and GoChef; or services facilitated through GoChef will be resolved through final and binding arbitration on an individual basis rather than by a judge or jury.\n\nThe Federal Arbitration Act will govern the interpretation and enforcement of this arbitration agreement to the extent applicable.\n\nUnless the parties agree otherwise, arbitration shall be administered by the American Arbitration Association ("AAA") under rules applicable to the dispute.\n\nIf AAA is unavailable or unwilling to administer the arbitration, a mutually acceptable arbitration administrator will be selected or a court of competent jurisdiction may appoint one.\n\nNothing prevents an eligible party from pursuing an individual claim in small claims court.\n\nNothing in these Terms prevents either party from seeking temporary injunctive relief where legally available to protect intellectual-property rights, accounts, security or confidential information.'),

            _buildSection('40. JURY TRIAL WAIVER',
                'TO THE EXTENT PERMITTED BY LAW, YOU AND GOCHEF WAIVE THE RIGHT TO HAVE DISPUTES SUBJECT TO ARBITRATION DECIDED BY A JUDGE OR JURY.\n\nAn arbitrator, rather than a judge or jury, will decide such disputes.'),

            _buildSection('41. CLASS ACTION WAIVER',
                'TO THE MAXIMUM EXTENT PERMITTED BY LAW, YOU AND GOCHEF AGREE THAT CLAIMS SUBJECT TO ARBITRATION WILL BE BROUGHT ONLY IN AN INDIVIDUAL CAPACITY AND NOT AS A PLAINTIFF OR CLASS MEMBER IN A CLASS, COLLECTIVE, CONSOLIDATED OR REPRESENTATIVE PROCEEDING.\n\nThe arbitrator may award relief only to the individual party seeking relief and only to the extent necessary to resolve that person\'s individual claim, except where applicable law requires otherwise.\n\nIf a final court ruling determines that a portion of this waiver cannot lawfully be enforced, the unenforceable portion will be severed while the remainder is enforced to the fullest extent permitted by law.'),

            _buildSection('42. ARBITRATION OPT-OUT',
                'A new User may opt out of the arbitration agreement by providing GoChef written notice within 30 days after first accepting these Terms.\n\nThe notice must clearly state that the User wishes to opt out of arbitration and must provide sufficient identifying information to locate the User\'s account.\n\nOpting out of arbitration will not affect the User\'s ability to use the Platform solely because of the opt-out.\n\nSend arbitration opt-out notices to:\nGoChef Technologies - Arbitration Opt-Out\n12400 Ventura Blvd, Studio City, CA 91604\nlegal@thegrubnextdoor.com'),

            _buildSection('43. GOVERNING LAW',
                'Except to the extent otherwise required by applicable law or the arbitration provisions above, these Terms are governed by the laws applicable to the jurisdiction in which the dispute arose.\n\nFor corporate and contractual matters for which the parties may lawfully select California law, the laws of the State of California will apply without regard to conflict-of-law principles.\n\nNothing in this provision deprives a consumer of mandatory protections provided by the law of the consumer\'s jurisdiction.'),

            _buildSection('44. FORCE MAJEURE',
                'GoChef will not be liable for delay or failure to perform caused by events beyond its reasonable control, including natural disasters; fires; floods; earthquakes; pandemics; epidemics; governmental restrictions; strikes; civil unrest; war; terrorism; communications failures; internet outages; cloud-provider outages; payment-system outages; cyberattacks; utility failures; transportation disruptions; or other force-majeure events.'),

            _buildSection('45. NO AGENCY OR PARTNERSHIP',
                'Except for any limited payment-collection relationship expressly documented separately, nothing in these Terms creates a partnership, franchise, employment relationship, joint venture, fiduciary relationship or agency relationship between GoChef and a User.'),

            _buildSection('46. ASSIGNMENT',
                'Users may not transfer their accounts or assign these Terms without GoChef\'s written consent.\n\nGoChef may assign these Terms in connection with a merger, acquisition, corporate restructuring, financing, sale of assets, sale of equity or transfer to an affiliate or successor, subject to applicable law.'),

            _buildSection('47. SEVERABILITY',
                'If any provision of these Terms is determined to be invalid or unenforceable, it will be modified or severed to the minimum extent necessary while the remaining Terms continue in effect.'),

            _buildSection('48. NO WAIVER',
                'Failure by GoChef to enforce a provision on one occasion does not waive GoChef\'s right to enforce that provision later.'),

            _buildSection('49. ENTIRE AGREEMENT',
                'These Terms, the GoChef Privacy Policy, applicable Provider agreements, checkout terms, promotional terms and policies expressly incorporated by reference constitute the agreement governing use of the Platform.\n\nA separate written agreement signed by GoChef may supplement or supersede portions of these Terms for particular Providers or business partners.'),

            _buildSection('50. CONTACT',
                'Questions regarding these Terms may be directed to:\n\nGoChef Technologies\nThe GRUB Next Door!\nAttn: Legal Department\n12400 Ventura Blvd, Studio City, CA 91604\nLegal: legal@thegrubnextdoor.com\nSupport: support@thegrubnextdoor.com'),

            const SizedBox(height: 12),

            // Acknowledgment Box
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ACKNOWLEDGMENT',
                    style: AppTextStyles.headlineMd(color: AppColors.primary).copyWith(fontSize: 15),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'BY CLICKING "ACCEPT," CREATING AN ACCOUNT, PLACING AN ORDER, OPENING A KITCHEN, LISTING FOOD, ACCEPTING AN ORDER OR OTHERWISE USING THE GOCHEF PLATFORM, YOU ACKNOWLEDGE THAT YOU HAVE READ AND AGREE TO THESE TERMS.\n\nYOU FURTHER ACKNOWLEDGE THAT GOCHEF PROVIDES TECHNOLOGY THAT CONNECTS CUSTOMERS WITH INDEPENDENT FOOD PROVIDERS AND, EXCEPT WHERE EXPRESSLY STATED OR REQUIRED BY LAW, GOCHEF DOES NOT PREPARE THE FOOD AND IS NOT RESPONSIBLE FOR THE PREPARATION, INGREDIENTS, SANITATION, HANDLING OR SAFETY OF FOOD PREPARED BY INDEPENDENT PROVIDERS.',
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
            style: const TextStyle(
              color: AppColors.onSurfaceVariant,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
