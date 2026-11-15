/// MintTalk Terms & Conditions (User and Host Terms of Service), transcribed
/// from `Mint_Talk_Terms_and_Conditions_Revised_Draft.docx`. Internal drafting
/// notes and the publication checklist from that draft are intentionally left
/// out.
class TermsSection {
  final int number;
  final String title;
  final List<TermsBlock> blocks;

  const TermsSection({
    required this.number,
    required this.title,
    required this.blocks,
  });
}

sealed class TermsBlock {
  const TermsBlock();
}

class TermsParagraph extends TermsBlock {
  final String text;

  const TermsParagraph(this.text);
}

class TermsBullets extends TermsBlock {
  final List<String> items;

  const TermsBullets(this.items);
}

/// A bolded term followed by its description, e.g. "Coins: the in-app ...".
class TermsDefinition extends TermsBlock {
  final String term;
  final String text;

  const TermsDefinition(this.term, this.text);
}

class TermsAndConditions {
  TermsAndConditions._();

  static const String operator = 'NODONODE TECHNOLOGIES PRIVATE LIMITED';
  static const String contact = 'info@nodonode.com  |  +91 8921355574';

  static const List<TermsSection> sections = [
    TermsSection(
      number: 1,
      title: 'Introduction and Acceptance',
      blocks: [
        TermsParagraph(
          'These Terms & Conditions ("Terms") govern your access to and use of the MintTalk mobile application, website (if available), features and related services (collectively, the "Service"). The Service is operated by NODONODE TECHNOLOGIES PRIVATE LIMITED ("MintTalk", "Company", "we", "us" or "our").',
        ),
        TermsParagraph(
          'By creating an account, accessing the app, purchasing coins, applying to become a Host, accepting or making a call, or otherwise using the Service, you confirm that you have read and agree to these Terms and the applicable Privacy Policy. If you do not agree, do not access or use the Service.',
        ),
        TermsParagraph(
          'These Terms apply to both users who make calls ("Users") and persons approved by MintTalk to receive calls ("Hosts"), except where a provision expressly applies to only one group. Additional Host-specific terms, policies or agreements may also apply.',
        ),
      ],
    ),
    TermsSection(
      number: 2,
      title: 'About MintTalk',
      blocks: [
        TermsParagraph(
          'MintTalk is a communication platform that enables Users to connect with Hosts through audio and/or video calls. Users may use the Service to talk, share thoughts and experiences, and have conversations in a respectful environment.',
        ),
        TermsParagraph(
          'MintTalk is not a medical, psychological, psychiatric, counselling, crisis-intervention, legal, financial or other professional advisory service. Unless expressly stated otherwise, Hosts must not present themselves as licensed professionals or provide professional advice through the Service. Conversations are not a substitute for qualified professional assistance.',
        ),
        TermsParagraph(
          'The Company may facilitate access to the platform and administer its features. The Company does not guarantee that a particular Host will be available, that a call will connect successfully, or that a conversation will produce any particular result.',
        ),
      ],
    ),
    TermsSection(
      number: 3,
      title: 'Definitions',
      blocks: [
        TermsDefinition(
          'Account',
          'the registered MintTalk profile associated with a User or Host.',
        ),
        TermsDefinition(
          'Coins',
          'the in-app virtual units that a User purchases or receives, where supported, and uses to access chargeable call services.',
        ),
        TermsDefinition(
          'Host',
          'a person approved, engaged, appointed or otherwise authorised by the Company to receive calls through MintTalk as an employee or representative, subject to the applicable Host terms or arrangement.',
        ),
        TermsDefinition(
          'User',
          'a person who registers for or uses MintTalk to access the Service, including to make calls.',
        ),
        TermsDefinition(
          'Wallet',
          'the in-app balance or ledger that records Coins and relevant transactions.',
        ),
        TermsDefinition(
          'Call',
          'an audio or video communication session initiated or received through MintTalk.',
        ),
      ],
    ),
    TermsSection(
      number: 4,
      title: 'Eligibility and Age',
      blocks: [
        TermsParagraph(
          'You must be at least 18 years old to create an account or use MintTalk. By using the Service, you represent and warrant that you are 18 years of age or older and legally capable of entering into these Terms.',
        ),
        TermsParagraph(
          'MintTalk may request information or documents reasonably required to verify age, identity, account ownership or eligibility. We may restrict or suspend access where eligibility cannot be verified or where we reasonably believe an account is being used by a person under 18.',
        ),
      ],
    ),
    TermsSection(
      number: 5,
      title: 'Account Registration and Security',
      blocks: [
        TermsParagraph(
          'You must provide accurate, current and complete information when registering and keep your account details updated. You are responsible for maintaining the confidentiality of your login credentials and for activity carried out through your account, except to the extent an incident is caused by the Company\'s failure to meet its legal obligations.',
        ),
        TermsParagraph(
          'Do not create an account using another person\'s identity, share or sell your account, or allow another person to use your account. Notify MintTalk promptly if you suspect unauthorised access, misuse or a security incident.',
        ),
        TermsParagraph(
          'We may conduct reasonable verification and fraud-prevention checks and may request additional information where necessary to protect Users, Hosts or the Service.',
        ),
      ],
    ),
    TermsSection(
      number: 6,
      title: 'User Responsibilities',
      blocks: [
        TermsParagraph(
          'Users agree to use MintTalk lawfully and respectfully. In particular, Users must not:',
        ),
        TermsBullets([
          'harass, threaten, bully, intimidate, stalk, exploit or abuse a Host or another person;',
          'make unwanted sexual, discriminatory, hateful or violent remarks, or engage in conduct that is abusive or unlawful;',
          'request or encourage a Host to move a conversation off the platform, exchange personal contact details, or accept direct payments;',
          'share another person\'s private, confidential or identifying information without lawful authority;',
          'impersonate another person, misrepresent identity or age, manipulate transactions, or engage in fraud;',
          'use the Service to promote illegal activity, solicit money, distribute malware, or interfere with the app or its security.',
        ]),
        TermsParagraph(
          'Users should avoid sharing passwords, financial credentials, government identification numbers, precise location details or other sensitive information during calls. You are responsible for information you voluntarily disclose to another participant.',
        ),
      ],
    ),
    TermsSection(
      number: 7,
      title: 'Host Responsibilities',
      blocks: [
        TermsParagraph(
          'Hosts must comply with these Terms, all applicable Host instructions and policies, and any separate employment, engagement or representation arrangement with the Company. Hosts must act professionally, respectfully and lawfully when using MintTalk.',
        ),
        TermsParagraph('Hosts must not:'),
        TermsBullets([
          'request, collect, store, use or disclose a User\'s personal information except as expressly authorised by the Company and permitted by law;',
          'ask Users to communicate, transact or make payments outside MintTalk, or provide personal phone numbers, social media handles, bank details or other private contact information for off-platform dealings;',
          'record, photograph, capture, publish, distribute or disclose call content or a User\'s information without lawful authority and any consent required by law and Company policy;',
          'misrepresent their qualifications, identity, role or the nature of MintTalk;',
          'harass, threaten, exploit, discriminate against or otherwise mistreat a User;',
          'use the Service for personal solicitation, fraud, unlawful activity or any purpose unrelated to the authorised Host role.',
        ]),
        TermsParagraph(
          'Hosts must promptly report safety concerns, suspected fraud, technical issues and policy violations through the Company\'s designated support channels. Host access and payments may be subject to verification and applicable Host-specific terms.',
        ),
      ],
    ),
    TermsSection(
      number: 8,
      title: 'Audio and Video Calling Services',
      blocks: [
        TermsParagraph(
          'MintTalk may offer audio calls, video calls or both, depending on app features, device compatibility, availability and the options selected by the Host. Call availability and connection quality may be affected by internet connectivity, device settings, third-party infrastructure or other factors outside the Company\'s reasonable control.',
        ),
        TermsParagraph(
          'MintTalk does not record audio or video calls. However, the Company cannot guarantee that another participant will not use an external device, software, camera, screen recorder or other method to capture a conversation. Do not share information during a call unless you are comfortable disclosing it to the other participant. Recording or sharing another person\'s conversation may be restricted by law and these Terms.',
        ),
        TermsParagraph(
          'By joining a call, you acknowledge that the other participant can hear or, in a video call, see you. You should end the call and use the report or block feature if you feel unsafe or uncomfortable.',
        ),
        TermsParagraph(
          'MintTalk may use call-related technical information, such as call initiation time, duration, connection status and transaction records, for billing, support, security, fraud prevention and service operation. The applicable Privacy Policy explains the handling of personal data.',
        ),
      ],
    ),
    TermsSection(
      number: 9,
      title: 'Wallet and Coin Usage',
      blocks: [
        TermsParagraph(
          'Certain calls are charged using Coins deducted from the User\'s Wallet. The applicable Coin rate, call type and other relevant charges will be displayed in the app before or when the User accesses the relevant service. The rate shown in the app at the time of use will apply to that transaction.',
        ),
        TermsParagraph(
          'Coins are virtual in-app units only. They are not cash, a bank deposit, stored-value payment instrument, investment, or property that can be redeemed or transferred except where the Company expressly provides otherwise or applicable law requires.',
        ),
        TermsParagraph(
          'Coins are non-transferable between accounts and may not be sold, exchanged, gifted or converted into cash by Users. Users must not attempt to manipulate, reverse-engineer or interfere with the Wallet or transaction system.',
        ),
        TermsParagraph(
          'The Wallet balance and transaction history shown in the app are the primary reference for in-app Coin transactions. If you believe a deduction or balance is incorrect, contact support with the transaction details so that the issue can be reviewed.',
        ),
        TermsParagraph(
          'The Company may update Coin packages, rates or usage rules prospectively. Any applicable rates will be displayed in the app before a new purchase or chargeable call. Changes will not retrospectively alter a completed transaction except to correct an error or as required by law.',
        ),
      ],
    ),
    TermsSection(
      number: 10,
      title: 'Payments and Coin Purchases',
      blocks: [
        TermsParagraph(
          'Coin packages may be purchased through payment methods made available in MintTalk, including supported app-store billing or payment service providers. All purchases must be made through the official payment flow presented in the app. Do not send money directly to a Host or to an individual claiming to represent MintTalk.',
        ),
        TermsParagraph(
          'A purchase will ordinarily be credited after the payment provider confirms the transaction. Processing times may vary. If payment is debited but Coins are not credited, contact support and provide the transaction reference, date, amount and relevant evidence. The Company will investigate and take appropriate corrective action where a payment or crediting error is confirmed.',
        ),
        TermsParagraph(
          'You are responsible for ensuring that payment details are accurate and that you are authorised to use the selected payment method. Third-party payment providers may apply their own terms, processing rules and privacy policies.',
        ),
      ],
    ),
    TermsSection(
      number: 11,
      title: 'Host Payments and Withdrawals',
      blocks: [
        TermsParagraph(
          'Host compensation, earnings calculations, eligibility, applicable rates, deductions, verification requirements and other payment conditions are governed by the Host\'s applicable agreement, policies and information communicated by MintTalk.',
        ),
        TermsParagraph(
          'Hosts may submit a withdrawal request through the process made available by MintTalk. Host payments are processed upon a withdrawal request, subject to account and identity verification, confirmation of the payable balance, any applicable minimum threshold or other communicated conditions, and applicable legal or compliance checks.',
        ),
        TermsParagraph(
          'Processing time may depend on verification, banking or payment-provider processing, holidays, incorrect payment details, suspected fraud or other operational circumstances. Hosts must provide accurate bank or payment details through the authorised channel and promptly update any changes.',
        ),
        TermsParagraph(
          'The Company may pause or review a withdrawal where reasonably necessary to investigate suspected fraud, duplicate transactions, policy violations, legal restrictions or a payment discrepancy. Any such review will be handled in accordance with applicable law and the relevant Host arrangement.',
        ),
        TermsParagraph(
          'Hosts are responsible for any taxes or statutory obligations applicable to their earnings, subject to any withholding or reporting obligations the Company is required to perform under law.',
        ),
      ],
    ),
    TermsSection(
      number: 12,
      title: 'Refunds, Cancellations and Payment Corrections',
      blocks: [
        TermsParagraph(
          'Except where a refund or reversal is required by applicable law or where the Company determines that a payment correction is appropriate, purchases of Coins are final and non-refundable. Unused Coins are not ordinarily refundable or redeemable for cash.',
        ),
        TermsParagraph(
          'This no-refund rule does not limit rights or remedies that cannot lawfully be excluded. The Company will review and, where appropriate or legally required, correct or refund cases such as duplicate charges, payment debits where the purchase was not completed, Coins not credited due to a confirmed system or payment error, or an incorrect deduction caused by a technical or billing issue.',
        ),
        TermsParagraph(
          'To report a payment issue, contact info@nodonode.com or +91 8921355574 and include the registered mobile number or account identifier, transaction reference, date, amount and a clear description of the issue. Do not send passwords, OTPs or full card details.',
        ),
        TermsParagraph(
          'A request will be reviewed using available transaction, call and payment-provider records. Where a refund is approved, it will generally be returned through the original payment method or another lawful method where required or technically necessary. The time taken for the amount to appear depends on the payment provider and financial institution.',
        ),
        TermsParagraph(
          'Calls are not appointment bookings unless a specific feature expressly says otherwise. Any cancellation or call-connection adjustment will be handled under the in-app billing information and applicable law.',
        ),
      ],
    ),
    TermsSection(
      number: 13,
      title: 'Safety, Blocking and Reporting',
      blocks: [
        TermsParagraph(
          'MintTalk may provide in-app tools to block or report another account. Use these tools where you experience or witness harassment, inappropriate conduct, suspected fraud, threats, safety risks or other violations.',
        ),
        TermsParagraph(
          'You may also contact the Company at info@nodonode.com or +91 8921355574. Please provide relevant details, such as the date and approximate time of the incident, the account involved and a description of the concern. Share supporting material only where it is safe and lawful to do so.',
        ),
        TermsParagraph(
          'MintTalk may review reports, restrict contact, remove content where applicable, suspend or terminate accounts, or take other reasonable action. We may be unable to disclose confidential details of an investigation or action taken against another account.',
        ),
        TermsParagraph(
          'Report urgent threats to personal safety or suspected criminal conduct to the appropriate local emergency or law-enforcement authority. MintTalk is not an emergency-response service.',
        ),
      ],
    ),
    TermsSection(
      number: 14,
      title: 'Privacy and Data Protection',
      blocks: [
        TermsParagraph(
          'The Company\'s collection, use, storage, sharing, retention and protection of personal data are described in the MintTalk Privacy Policy, which should be read together with these Terms.',
        ),
        TermsParagraph(
          'MintTalk does not record audio or video calls. This does not mean that no information is processed in connection with a call. The app may process account information, device and diagnostic data, call metadata, payment and transaction records, support communications, security logs and other information described in the Privacy Policy.',
        ),
        TermsParagraph(
          'Hosts are not authorised to access or use a User\'s personal data except through the features and information made available for their authorised role. Hosts must not seek to obtain or retain personal information outside those authorised purposes.',
        ),
        TermsParagraph(
          'You should not disclose sensitive personal or financial information during calls. Personal information shared directly with another participant may be outside the Company\'s control once disclosed, subject to applicable law and the Company\'s policies.',
        ),
        TermsParagraph(
          'Account deletion requests and data retention are handled in accordance with the Privacy Policy and applicable law. Certain transaction, security, tax or compliance records may need to be retained for a legally permitted or required period.',
        ),
      ],
    ),
    TermsSection(
      number: 15,
      title: 'Prohibited Activities',
      blocks: [
        TermsParagraph(
          'In addition to the conduct restrictions above, you must not:',
        ),
        TermsBullets([
          'use MintTalk in violation of any applicable law, regulation, court order or third-party right;',
          'probe, scan or test the vulnerability of the Service, bypass security, or disrupt servers, networks or other users;',
          'introduce viruses, malicious code, bots or automated systems that interfere with the Service;',
          'scrape, copy, harvest or collect account information or data from the Service without authorisation;',
          'reverse engineer, decompile, modify or create derivative works of the app except to the extent such restriction is prohibited by law;',
          'misuse promotions, referral programmes, Coin offers, payment flows or withdrawal systems.',
        ]),
        TermsParagraph(
          'We may investigate suspected violations and take proportionate action, including restricting features, cancelling fraudulent transactions where legally permitted, suspending accounts or referring matters to the appropriate authorities.',
        ),
      ],
    ),
    TermsSection(
      number: 16,
      title: 'Account Suspension and Termination',
      blocks: [
        TermsParagraph(
          'You may stop using MintTalk at any time and may request deletion of your account using the in-app account deletion feature, where available.',
        ),
        TermsParagraph(
          'MintTalk may restrict, suspend or terminate an account where we reasonably believe that the account has violated these Terms, presents a safety or security risk, is involved in fraud or unlawful activity, or where action is required by law or a platform provider. Where reasonably practicable and legally permitted, we may provide notice or an opportunity to address the issue.',
        ),
        TermsParagraph(
          'Suspension or termination does not remove obligations or liabilities that arose before the effective date of suspension or termination. Outstanding Host payments, Wallet balances, refunds, disputes and data retention will be handled in accordance with these Terms, applicable agreements and law.',
        ),
      ],
    ),
    TermsSection(
      number: 17,
      title: 'Account Deletion',
      blocks: [
        TermsParagraph(
          'Users may initiate account deletion through the in-app account deletion option, subject to any confirmation steps displayed in the app. If you cannot access that option, contact MintTalk using the details in the Contact section.',
        ),
        TermsParagraph(
          'Deleting the app from your device does not by itself delete your account. Once an account deletion request is completed, access to the account and associated services may cease.',
        ),
        TermsParagraph(
          'Account deletion does not automatically create an entitlement to a cash refund for purchased Coins. Any remaining Wallet balance will be handled in accordance with the refund provisions above and applicable law. The Company may retain information that it is legally required or permitted to retain, including certain payment, tax, fraud-prevention, dispute and security records, for the applicable retention period.',
        ),
      ],
    ),
    TermsSection(
      number: 18,
      title: 'Third-Party Services',
      blocks: [
        TermsParagraph(
          'MintTalk may rely on third-party providers for app distribution, cloud hosting, communications, analytics, identity verification, payment processing, customer support or other technical services. Your use of third-party services may also be subject to the relevant provider\'s terms and privacy policy.',
        ),
        TermsParagraph(
          'The Company is not responsible for independent third-party services to the extent they are outside its reasonable control. This does not exclude any responsibility that the Company cannot lawfully exclude, or its responsibility for selecting, integrating or managing providers where required by applicable law.',
        ),
      ],
    ),
    TermsSection(
      number: 19,
      title: 'Intellectual Property',
      blocks: [
        TermsParagraph(
          'The MintTalk app, branding, logos, software, design, text, graphics and other materials owned or licensed by the Company are protected by applicable intellectual property laws. Except for the limited right to use the Service in accordance with these Terms, no ownership rights are transferred to you.',
        ),
        TermsParagraph(
          'You must not copy, modify, distribute, sell, lease, reverse engineer or commercially exploit any part of the Service except where expressly authorised by the Company or permitted by applicable law.',
        ),
        TermsParagraph(
          'If you submit feedback or suggestions, you grant the Company a non-exclusive, worldwide, royalty-free right to use that feedback to improve the Service, without requiring payment or attribution. This does not transfer ownership of your personal data or other materials in a manner inconsistent with applicable law.',
        ),
      ],
    ),
    TermsSection(
      number: 20,
      title: 'Service Availability and Updates',
      blocks: [
        TermsParagraph(
          'We may update, modify, suspend or discontinue features of MintTalk to maintain, improve or protect the Service, or to comply with legal or platform requirements. We will provide notice where required by law or reasonably practicable.',
        ),
        TermsParagraph(
          'The Service may be temporarily unavailable due to maintenance, network issues, third-party outages, device incompatibility or events beyond the Company\'s reasonable control. We do not guarantee uninterrupted or error-free operation.',
        ),
        TermsParagraph(
          'You are responsible for maintaining a compatible device, operating system and internet connection. App updates may be required to continue using some features.',
        ),
      ],
    ),
    TermsSection(
      number: 21,
      title: 'Disclaimers',
      blocks: [
        TermsParagraph(
          'To the maximum extent permitted by applicable law, the Service is provided on an "as available" basis. MintTalk does not guarantee uninterrupted access, uninterrupted calls, a particular Host\'s availability, or any particular outcome from a conversation.',
        ),
        TermsParagraph(
          'MintTalk is not a healthcare, counselling, crisis, legal or financial advisory provider. Hosts\' conversations must not be relied upon as a substitute for qualified professional advice or emergency assistance.',
        ),
        TermsParagraph(
          'Nothing in these Terms excludes or limits any warranty, representation, consumer right or remedy that cannot be excluded or limited under applicable law.',
        ),
      ],
    ),
    TermsSection(
      number: 22,
      title: 'Limitation of Liability',
      blocks: [
        TermsParagraph(
          'To the maximum extent permitted by applicable law, the Company will not be liable for indirect or consequential loss arising from your use of, or inability to use, the Service, including loss of profits, business opportunity or data, except where such exclusion is prohibited by law.',
        ),
        TermsParagraph(
          'The Company is not responsible for statements, conduct or information voluntarily shared by another participant, or for off-platform communications or payments that violate these Terms, except to the extent liability arises from the Company\'s own breach of law or obligations that cannot be excluded.',
        ),
        TermsParagraph(
          'Nothing in these Terms limits liability for fraud, wilful misconduct, gross negligence where such limitation is prohibited, death or personal injury caused by negligence where liability cannot be excluded, or any other liability that cannot lawfully be limited. Your statutory rights remain unaffected.',
        ),
      ],
    ),
    TermsSection(
      number: 23,
      title: 'Indemnification',
      blocks: [
        TermsParagraph(
          'To the extent permitted by law, you agree to indemnify the Company and its directors, officers, employees and authorised representatives against third-party claims, losses and reasonable costs arising directly from your unlawful use of the Service, your material breach of these Terms, or your infringement of another person\'s rights. This clause does not apply to the extent a claim results from the Company\'s own unlawful act, negligence or breach of these Terms.',
        ),
      ],
    ),
    TermsSection(
      number: 24,
      title: 'Changes to These Terms',
      blocks: [
        TermsParagraph(
          'We may revise these Terms to reflect changes to the Service, our policies or applicable law. The updated version will be made available through the app or another appropriate channel and will state its effective date. Where required by law, we will provide advance notice or seek renewed consent.',
        ),
        TermsParagraph(
          'Your continued use of MintTalk after the revised Terms take effect indicates acceptance of the updated Terms, to the extent permitted by law. If you do not agree, stop using the Service and you may request account deletion.',
        ),
      ],
    ),
    TermsSection(
      number: 25,
      title: 'Governing Law and Dispute Resolution',
      blocks: [
        TermsParagraph(
          'These Terms are governed by the laws of India, subject to applicable consumer protection and other mandatory legal rights.',
        ),
        TermsParagraph(
          'If you have a concern or dispute, please first contact MintTalk using the details below so that we can attempt to resolve it. Nothing in this section prevents you from approaching a consumer commission, regulator, court or other authority that has jurisdiction, or from exercising a statutory remedy.',
        ),
      ],
    ),
    TermsSection(
      number: 26,
      title: 'General Provisions',
      blocks: [
        TermsParagraph(
          'If any provision of these Terms is held invalid or unenforceable, the remaining provisions will continue to apply to the extent permitted by law. A failure or delay by the Company in enforcing a provision does not waive its right to enforce that provision later.',
        ),
        TermsParagraph(
          'These Terms, together with the Privacy Policy and any applicable Host-specific agreement or in-app policy, form the agreement governing your use of MintTalk. If there is a conflict between these Terms and a mandatory legal requirement, the legal requirement will prevail.',
        ),
        TermsParagraph(
          'You may not assign or transfer your rights or obligations under these Terms without the Company\'s prior written consent. The Company may assign its rights and obligations as part of a lawful corporate restructuring, merger or transfer of the Service, subject to applicable law.',
        ),
      ],
    ),
    TermsSection(
      number: 27,
      title: 'Contact and Grievance Support',
      blocks: [
        TermsParagraph(
          'For questions, account issues, payment concerns, safety reports or complaints relating to MintTalk, contact:',
        ),
        TermsDefinition('Company', 'NODONODE TECHNOLOGIES PRIVATE LIMITED'),
        TermsDefinition('Email', 'info@nodonode.com'),
        TermsDefinition('Phone', '+91 8921355574'),
        TermsDefinition('Website', 'https://www.nodonode.com/'),
        TermsDefinition(
          'Address',
          'Kalloor House, AIMS, Kochi, near SBI, Ponekkara–Valeppally Road, Kerala – 682041',
        ),
        TermsParagraph(
          'Please include sufficient details for us to identify and review your concern. Do not include passwords, OTPs or complete payment-card details in your complaint.',
        ),
      ],
    ),
  ];
}
