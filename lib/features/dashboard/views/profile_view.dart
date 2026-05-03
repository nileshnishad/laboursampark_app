import 'package:flutter/material.dart';

import '../widgets/profile_widgets.dart';

class ProfileView extends StatelessWidget {
  final String fullName;
  final String userType;
  final Map<String, dynamic>? profileData;
  final bool subscriptionActive;
  final bool profileLoading;
  final String? profileError;
  final Map<String, dynamic>? subscriptionPlan;
  final VoidCallback onRetry;
  final void Function(Map<String, dynamic>? plan) onShowSubscription;
  final VoidCallback onSettings;
  final VoidCallback onLogout;

  const ProfileView({
    super.key,
    required this.fullName,
    required this.userType,
    required this.profileData,
    required this.subscriptionActive,
    required this.profileLoading,
    required this.profileError,
    required this.subscriptionPlan,
    required this.onRetry,
    required this.onShowSubscription,
    required this.onSettings,
    required this.onLogout,
  });

  String _roleLabel(String ut) {
    switch (ut.toLowerCase()) {
      case 'labour':
        return 'Labour Worker';
      case 'sub_contractor':
        return 'Sub Contractor';
      case 'contractor':
        return 'Contractor';
      default:
        return 'User';
    }
  }

  List<String> _asStringList(dynamic value) {
    if (value is List) {
      return value
          .where((item) => item != null)
          .map((item) => item.toString().trim())
          .where((item) => item.isNotEmpty)
          .toList();
    }
    return const [];
  }

  String _formatDate(String isoDate) {
    if (isoDate.trim().isEmpty) return 'Not available';
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return 'Not available';
    final day = parsed.day.toString().padLeft(2, '0');
    final month = parsed.month.toString().padLeft(2, '0');
    final year = parsed.year.toString();
    final hour = parsed.hour.toString().padLeft(2, '0');
    final minute = parsed.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final profilePhotoUrl = (profileData?['profilePhotoUrl'] ?? '').toString();
    final companyLogoUrl = (profileData?['companyLogoUrl'] ?? '').toString();
    final companyName = (profileData?['companyName'] ?? '').toString();
    final about = (profileData?['bio'] ?? profileData?['about'] ?? '').toString();
    final age = (profileData?['age'] ?? '').toString();
    final experience =
        (profileData?['experience'] ?? profileData?['experienceRange'] ?? '').toString();
    final email = (profileData?['email'] ?? '').toString();
    final mobile = (profileData?['mobile'] ?? '').toString();
    final location = profileData?['location'] as Map<String, dynamic>?;
    final city = (profileData?['city'] ?? location?['city'] ?? '').toString();
    final state = (profileData?['state'] ?? location?['state'] ?? '').toString();
    final address = (location?['address'] ?? '').toString();
    final createdAt = _formatDate((profileData?['createdAt'] ?? '').toString());
    final lastLogin = _formatDate((profileData?['lastLogin'] ?? '').toString());
    final skills = _asStringList(profileData?['skills']);
    final workingHours = (profileData?['workingHours'] ?? '').toString();
    final workTypes = _asStringList(profileData?['workTypes']);
    final serviceCategories = _asStringList(profileData?['serviceCategories']);
    final languages = _asStringList(profileData?['languages']);
    final rawId = (profileData?['userId'] ?? profileData?['_id'] ?? '').toString();
    final shortId = rawId.length > 6
        ? 'ID: #${rawId.substring(0, 6).toUpperCase()}'
        : (rawId.isNotEmpty ? 'ID: #$rawId' : '');

    final displayVerified = (profileData?['display'] as bool?) ?? false;
    final emailVerified = (profileData?['emailVerified'] as bool?) ?? false;
    final mobileVerified = (profileData?['mobileVerified'] as bool?) ?? false;
    final aadharVerified = (profileData?['aadharVerified'] as bool?) ?? false;
    final availability = (profileData?['availability'] as bool?) ?? false;

    final isContractor = userType.toLowerCase() == 'contractor';
    final isSubContractor = userType.toLowerCase() == 'sub_contractor';
    final avatarColor = isContractor
        ? const Color(0xFF059669)
        : isSubContractor
            ? const Color(0xFF7C3AED)
            : const Color(0xFF2563EB);

    final nameParts = fullName.trim().split(RegExp(r'\s+'));
    final initials = nameParts.length >= 2
        ? '${nameParts[0][0]}${nameParts[1][0]}'.toUpperCase()
        : (fullName.isNotEmpty
            ? fullName.substring(0, fullName.length > 1 ? 2 : 1).toUpperCase()
            : 'LS');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (profileLoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: LinearProgressIndicator(color: Color(0xFF2563EB)),
          ),
        if (profileError != null)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFCA5A5)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded,
                    color: Color(0xFFDC2626), size: 18),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(profileError!,
                        style: const TextStyle(
                            color: Color(0xFF991B1B), fontSize: 13))),
                TextButton(
                  onPressed: onRetry,
                  style: TextButton.styleFrom(
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),

        // Subscription banner
        if (!subscriptionActive)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF9C3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFDE047)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFB45309), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Attention Required',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF92400E),
                              fontSize: 14)),
                      const SizedBox(height: 4),
                      RichText(
                        text: const TextSpan(
                          style: TextStyle(
                              color: Color(0xFF92400E), fontSize: 13, height: 1.4),
                          children: [
                            TextSpan(text: 'Your profile is currently '),
                            TextSpan(
                                text: 'hidden',
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFDC2626))),
                            TextSpan(
                                text:
                                    '. To make your account visible and access all features, please pay the subscription amount.'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => onShowSubscription(subscriptionPlan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                  child: const Text('Pay\nSubscription', textAlign: TextAlign.center),
                ),
              ],
            ),
          ),

        // Profile hero card
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: avatarColor,
                          backgroundImage: (isContractor || isSubContractor) &&
                                  companyLogoUrl.isNotEmpty
                              ? NetworkImage(companyLogoUrl)
                              : profilePhotoUrl.isNotEmpty
                                  ? NetworkImage(profilePhotoUrl)
                                  : null,
                          child: (isContractor || isSubContractor)
                              ? (companyLogoUrl.isEmpty
                                  ? const Icon(Icons.business_center_rounded,
                                      size: 28, color: Colors.white)
                                  : null)
                              : (profilePhotoUrl.isEmpty
                                  ? Text(initials,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white))
                                  : null),
                        ),
                        if ((isContractor || isSubContractor) &&
                            profilePhotoUrl.isNotEmpty &&
                            companyLogoUrl.isNotEmpty)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: CircleAvatar(
                                radius: 14,
                                backgroundImage: NetworkImage(profilePhotoUrl)),
                          ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: displayVerified
                                    ? const Color(0xFF059669)
                                    : const Color(0xFF9CA3AF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check,
                                  size: 12, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName.isEmpty ? 'User' : fullName,
                            style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF111827)),
                          ),
                          if ((isContractor || isSubContractor) &&
                              companyName.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(Icons.business_rounded,
                                    size: 13, color: avatarColor),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(companyName,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: avatarColor),
                                      overflow: TextOverflow.ellipsis),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              ProfileBadge(
                                  label: _roleLabel(userType).toUpperCase(),
                                  color: avatarColor),
                              if (shortId.isNotEmpty)
                                ProfileBadge(label: shortId),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: onSettings,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: avatarColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'UPDATE\nPROFILE',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.4,
                              letterSpacing: 0.3),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Status row
              Container(
                margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ProfileStatusItem(
                          label: 'STATUS',
                          value: '● ONLINE',
                          valueColor: const Color(0xFF059669)),
                    ),
                    Container(
                        width: 1,
                        height: 36,
                        color: const Color(0xFFE5E7EB)),
                    Expanded(
                      child: ProfileStatusItem(
                        label: 'VISIBLE',
                        value: displayVerified ? 'VISIBLE' : 'HIDDEN',
                        valueColor: displayVerified
                            ? const Color(0xFF059669)
                            : const Color(0xFFDC2626),
                      ),
                    ),
                    Container(
                        width: 1,
                        height: 36,
                        color: const Color(0xFFE5E7EB)),
                    Expanded(
                      child: ProfileStatusItem(
                        label: isContractor ? 'HIRING' : 'AVAILABILITY',
                        value: availability
                            ? (isContractor ? 'OPEN\nTO HIRE' : 'READY TO\nWORK')
                            : (isContractor ? 'NOT HIRING' : 'BUSY'),
                        valueColor: availability
                            ? const Color(0xFF059669)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Contact Information
        ProfileSectionCard(
          title: 'CONTACT INFORMATION',
          icon: Icons.contact_page_outlined,
          color: const Color(0xFF2563EB),
          child: ProfileInfoGrid(items: [
            ProfileInfoItem(
                label: 'FULL NAME',
                value: fullName.isEmpty ? 'Not specified' : fullName),
            if ((isContractor || isSubContractor) && companyName.isNotEmpty)
              ProfileInfoItem(label: 'COMPANY NAME', value: companyName),
            ProfileInfoItem(label: 'EMAIL', value: email.isEmpty ? 'Not specified' : email),
            ProfileInfoItem(label: 'PHONE', value: mobile.isEmpty ? 'Not specified' : mobile),
            if (!isContractor && !isSubContractor)
              ProfileInfoItem(label: 'AGE', value: age.isEmpty ? 'Not specified' : age),
          ]),
        ),
        const SizedBox(height: 10),

        // Work / Business
        ProfileSectionCard(
          title: (isContractor || isSubContractor)
              ? 'BUSINESS DETAILS'
              : 'WORK EXPERIENCE & SKILLS',
          icon: (isContractor || isSubContractor)
              ? Icons.business_center_rounded
              : Icons.work_outline_rounded,
          color: const Color(0xFF7C3AED),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileInfoGrid(items: [
                ProfileInfoItem(
                    label: (isContractor || isSubContractor)
                        ? 'YEARS IN BUSINESS'
                        : 'EXPERIENCE',
                    value: experience.isEmpty ? 'Not specified' : experience),
                if (!isContractor && !isSubContractor)
                  ProfileInfoItem(
                      label: 'WORKING HOURS',
                      value: workingHours.isEmpty ? 'Not specified' : workingHours),
                ProfileInfoItem(
                    label: (isContractor || isSubContractor)
                        ? 'WORK TYPES / TRADE'
                        : 'WORK TYPES',
                    value: workTypes.isEmpty ? 'Not specified' : workTypes.join(', ')),
                ProfileInfoItem(
                    label: (isContractor || isSubContractor)
                        ? 'SPECIALIZATION'
                        : 'SKILLS',
                    value: skills.isEmpty ? 'Not specified' : skills.join(', ')),
                ProfileInfoItem(
                    label: 'SERVICE CATEGORIES',
                    value: serviceCategories.isEmpty
                        ? 'Not specified'
                        : serviceCategories.join(', ')),
                ProfileInfoItem(
                    label: 'LANGUAGES',
                    value: languages.isEmpty ? 'Not specified' : languages.join(', ')),
              ]),
              if (about.isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9FAFB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (isContractor || isSubContractor)
                            ? 'ABOUT COMPANY'
                            : 'ABOUT',
                        style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6B7280),
                            letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 6),
                      Text(about,
                          style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF374151),
                              height: 1.5)),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Location
        ProfileSectionCard(
          title: 'LOCATION PRESENCE',
          icon: Icons.location_on_outlined,
          color: const Color(0xFF059669),
          child: ProfileInfoGrid(items: [
            ProfileInfoItem(label: 'CITY', value: city.isEmpty ? 'Not specified' : city),
            ProfileInfoItem(label: 'STATE', value: state.isEmpty ? 'Not specified' : state),
            ProfileInfoItem(
                label: 'ADDRESS',
                value: address.isEmpty ? 'Not specified' : address),
          ]),
        ),
        const SizedBox(height: 10),

        // Verification
        ProfileSectionCard(
          title: 'ACCOUNT TRUST & VERIFICATION',
          icon: Icons.verified_outlined,
          color: const Color(0xFF2563EB),
          child: ProfileInfoGrid(items: [
            ProfileInfoItem(
                label: 'EMAIL',
                value: emailVerified ? '✓ Verified' : '✗ Not Verified',
                valueColor:
                    emailVerified ? const Color(0xFF059669) : const Color(0xFFDC2626)),
            ProfileInfoItem(
                label: 'MOBILE',
                value: mobileVerified ? '✓ Verified' : '✗ Not Verified',
                valueColor:
                    mobileVerified ? const Color(0xFF059669) : const Color(0xFFDC2626)),
            ProfileInfoItem(
                label: 'AADHAR',
                value: aadharVerified ? '✓ Verified' : '✗ Not Verified',
                valueColor:
                    aadharVerified ? const Color(0xFF059669) : const Color(0xFFDC2626)),
            ProfileInfoItem(label: 'ACCOUNT CREATED', value: createdAt),
            ProfileInfoItem(label: 'LAST LOGIN', value: lastLogin),
          ]),
        ),
        const SizedBox(height: 10),

        // Subscription
        ProfileSectionCard(
          title: subscriptionActive ? 'SUBSCRIPTION ACTIVE' : 'SUBSCRIPTION REQUIRED',
          icon: subscriptionActive
              ? Icons.workspace_premium_rounded
              : Icons.lock_outline_rounded,
          color: subscriptionActive
              ? const Color(0xFF059669)
              : const Color(0xFFF59E0B),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (subscriptionPlan != null) ...[
                ProfileInfoGrid(items: [
                  ProfileInfoItem(
                      label: 'PLAN AMOUNT',
                      value: '₹${subscriptionPlan!['price']}'),
                  ProfileInfoItem(
                      label: 'DURATION',
                      value: '${subscriptionPlan!['durationDays']} days'),
                  if ((subscriptionPlan!['pricePerDay'] as num?) != null)
                    ProfileInfoItem(
                        label: 'PER DAY',
                        value:
                            '₹${(subscriptionPlan!['pricePerDay'] as num).toStringAsFixed(2)}'),
                ]),
                const SizedBox(height: 12),
              ] else ...[
                Text(
                  subscriptionActive
                      ? 'You are visible to contractors and can apply for jobs freely.'
                      : 'Get more interactions and find more job opportunities.',
                  style: const TextStyle(
                      fontSize: 13, color: Color(0xFF374151), height: 1.5),
                ),
                const SizedBox(height: 12),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => onShowSubscription(subscriptionPlan),
                  icon: Icon(
                      subscriptionActive
                          ? Icons.manage_accounts_rounded
                          : Icons.payment_rounded,
                      size: 18),
                  label: Text(subscriptionActive
                      ? 'Manage Subscription'
                      : 'Pay Now — Get Visible'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: subscriptionActive
                        ? const Color(0xFF059669)
                        : const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    textStyle: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Actions
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Column(
            children: [
              ProfileActionTile(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: onSettings,
              ),
              const Divider(height: 1, indent: 56),
              ProfileActionTile(
                icon: Icons.refresh_rounded,
                label: 'Refresh Profile',
                onTap: onRetry,
              ),
              const Divider(height: 1, indent: 56),
              ProfileActionTile(
                icon: Icons.logout_rounded,
                label: 'Logout',
                color: const Color(0xFFDC2626),
                onTap: onLogout,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
