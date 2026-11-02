import 'package:flutter/material.dart';
import '../models/kitchen_model.dart';

class KitchenComplianceItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final bool isSubmitted;
  final ChefCertificate? certificate;
  final String? documentUrl;
  final String statusText;

  const KitchenComplianceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isSubmitted,
    this.certificate,
    this.documentUrl,
    required this.statusText,
  });
}

class KitchenComplianceHelper {
  static const List<Map<String, dynamic>> standardCredentialTypes = [
    {
      'id': 'kitchen_verified',
      'title': 'Kitchen Verified',
      'type': 'Kitchen Verified',
      'desc': 'Facility location & kitchen environment verified by GoChef',
      'icon': Icons.verified_user,
    },
    {
      'id': 'mehko',
      'title': 'MEHKO Permit',
      'type': 'MEHKO Permit',
      'desc': 'Microenterprise Home Kitchen Operation Permit approved by local health jurisdiction',
      'icon': Icons.home_work_outlined,
    },
    {
      'id': 'safe_serv',
      'title': 'Safe Serv Certification',
      'type': 'Safe Serv',
      'desc': 'ServSafe Food Protection Manager / Food Handler certification',
      'icon': Icons.health_and_safety_outlined,
    },
    {
      'id': 'health_permit',
      'title': 'Health Permit',
      'type': 'Health Permit',
      'desc': 'County Environmental Health Department operating permit',
      'icon': Icons.assignment_turned_in_outlined,
    },
    {
      'id': 'cottage_food',
      'title': 'Cottage Food Permit',
      'type': 'Cottage Food Permit',
      'desc': 'Cottage Food Operation (CFO) Class A/B state registration',
      'icon': Icons.bakery_dining_outlined,
    },
    {
      'id': 'biz_license',
      'title': 'Business License (Biz License)',
      'type': 'Biz License',
      'desc': 'Municipal or County registered business tax license',
      'icon': Icons.badge_outlined,
    },
    {
      'id': 'insurance',
      'title': 'Insurance Certificate',
      'type': 'Insurance Certificate',
      'desc': 'Commercial general liability & food product liability coverage',
      'icon': Icons.security_outlined,
    },
    {
      'id': 'inspection',
      'title': 'Latest Inspection',
      'type': 'Latest Inspection',
      'desc': 'Official sanitation & environmental safety inspection report',
      'icon': Icons.fact_check_outlined,
    },
    {
      'id': 'commissioners_agreement',
      'title': 'Commissioners Agreement',
      'type': 'Commissioners Agreement',
      'desc': 'Agricultural commissioner or food authority compliance agreement',
      'icon': Icons.handshake_outlined,
    },
    {
      'id': 'kitchen_photos',
      'title': '3 Kitchen Photos',
      'type': 'Kitchen Photos',
      'desc': 'Preparation, cooking, and sanitation area photos uploaded',
      'icon': Icons.photo_library_outlined,
    },
  ];

  static List<KitchenComplianceItem> getComplianceItems(KitchenModel kitchen) {
    List<KitchenComplianceItem> items = [];

    for (final spec in standardCredentialTypes) {
      final id = spec['id'] as String;
      final title = spec['title'] as String;
      final desc = spec['desc'] as String;
      final icon = spec['icon'] as IconData;

      bool isSubmitted = false;
      ChefCertificate? matchingCert;
      String statusText = 'Not Provided';
      String? docUrl;

      if (id == 'kitchen_photos') {
        final count = kitchen.atmosphereImages.length;
        isSubmitted = count >= 3;
        statusText = isSubmitted ? '$count Photos Provided' : '$count/3 Photos Provided';
        docUrl = kitchen.atmosphereImages.isNotEmpty ? kitchen.atmosphereImages.first : null;
      } else if (id == 'kitchen_verified') {
        matchingCert = _findCertificate(kitchen.certificates, ['kitchen verified', 'facility', 'verified']);
        isSubmitted = kitchen.isVerified || matchingCert != null || kitchen.atmosphereImages.isNotEmpty;
        statusText = isSubmitted ? 'Verified by GoChef' : 'Pending Verification';
        docUrl = matchingCert?.url;
      } else if (id == 'mehko') {
        matchingCert = _findCertificate(kitchen.certificates, ['mehko']);
        isSubmitted = matchingCert != null;
        statusText = isSubmitted ? 'MEHKO Approved' : 'Not Provided';
        docUrl = matchingCert?.url;
      } else if (id == 'safe_serv') {
        matchingCert = _findCertificate(kitchen.certificates, ['safe serv', 'safeserv', 'servsafe', 'serv safe', 'food handler', 'food safety', 'food safety & hygiene']);
        isSubmitted = matchingCert != null;
        statusText = isSubmitted ? 'Safe Serv Active' : 'Not Provided';
        docUrl = matchingCert?.url;
      } else if (id == 'health_permit') {
        matchingCert = _findCertificate(kitchen.certificates, ['health permit', 'health']);
        isSubmitted = matchingCert != null;
        statusText = isSubmitted ? 'Health Permit Active' : 'Not Provided';
        docUrl = matchingCert?.url;
      } else if (id == 'cottage_food') {
        matchingCert = _findCertificate(kitchen.certificates, ['cottage']);
        isSubmitted = matchingCert != null;
        statusText = isSubmitted ? 'Cottage Permit Active' : 'Not Provided';
        docUrl = matchingCert?.url;
      } else if (id == 'biz_license') {
        matchingCert = _findCertificate(kitchen.certificates, ['biz', 'business license', 'business permit', 'license']);
        isSubmitted = matchingCert != null;
        statusText = isSubmitted ? 'Biz License Active' : 'Not Provided';
        docUrl = matchingCert?.url;
      } else if (id == 'insurance') {
        matchingCert = _findCertificate(kitchen.certificates, ['insurance']);
        isSubmitted = matchingCert != null;
        statusText = isSubmitted ? 'Insured & Covered' : 'Not Provided';
        docUrl = matchingCert?.url;
      } else if (id == 'inspection') {
        matchingCert = _findCertificate(kitchen.certificates, ['inspection']);
        isSubmitted = matchingCert != null;
        statusText = isSubmitted ? 'Passed & Current' : 'Not Provided';
        docUrl = matchingCert?.url;
      } else if (id == 'commissioners_agreement') {
        matchingCert = _findCertificate(kitchen.certificates, ['commissioner']);
        isSubmitted = matchingCert != null;
        statusText = isSubmitted ? 'Agreement Signed' : 'Not Provided';
        docUrl = matchingCert?.url;
      }

      items.add(KitchenComplianceItem(
        id: id,
        title: title,
        description: desc,
        icon: icon,
        isSubmitted: isSubmitted,
        certificate: matchingCert,
        documentUrl: docUrl,
        statusText: statusText,
      ));
    }

    // Include custom certificates that didn't match the standard 10
    final matchedCerts = items.map((i) => i.certificate).where((c) => c != null).toSet();
    for (final cert in kitchen.certificates) {
      if (!matchedCerts.contains(cert)) {
        items.add(KitchenComplianceItem(
          id: 'custom_${cert.title.hashCode}',
          title: cert.title,
          description: cert.type.isNotEmpty ? cert.type : 'Verified Credential',
          icon: Icons.workspace_premium_outlined,
          isSubmitted: true,
          certificate: cert,
          documentUrl: cert.url,
          statusText: 'Verified & Provided',
        ));
      }
    }

    return items;
  }

  static ChefCertificate? _findCertificate(List<ChefCertificate> list, List<String> keywords) {
    for (final cert in list) {
      final t = cert.title.toLowerCase();
      final type = cert.type.toLowerCase();
      for (final kw in keywords) {
        if (t.contains(kw) || type.contains(kw)) {
          return cert;
        }
      }
    }
    return null;
  }

  static int countSubmitted(KitchenModel kitchen) {
    return getComplianceItems(kitchen).where((item) => item.isSubmitted).length;
  }
}

