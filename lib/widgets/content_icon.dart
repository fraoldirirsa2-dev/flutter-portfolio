import 'package:flutter/material.dart';

class ContentIcon {
  const ContentIcon._();

  static IconData fromName(String name) {
    switch (name.trim()) {
      case 'search':
      case 'search_rounded':
        return Icons.search_rounded;
      case 'auto_awesome':
      case 'auto_awesome_rounded':
        return Icons.auto_awesome_rounded;
      case 'code':
      case 'code_rounded':
        return Icons.code_rounded;
      case 'check':
      case 'check_circle_outline':
      case 'check_circle_outline_rounded':
        return Icons.check_circle_outline_rounded;
      case 'rocket':
      case 'rocket_launch':
      case 'rocket_launch_rounded':
        return Icons.rocket_launch_rounded;
      case 'support':
      case 'support_agent':
      case 'support_agent_rounded':
        return Icons.support_agent_rounded;
      case 'visibility':
      case 'visibility_outlined':
        return Icons.visibility_outlined;
      case 'devices':
      case 'devices_outlined':
        return Icons.devices_outlined;
      case 'speed':
      case 'speed_outlined':
        return Icons.speed_outlined;
      case 'flutter':
      case 'flutter_dash':
      case 'flutter_dash_rounded':
        return Icons.flutter_dash_rounded;
      case 'firebase':
      case 'cloud':
      case 'cloud_outlined':
        return Icons.cloud_outlined;
      case 'api':
      case 'api_rounded':
        return Icons.api_rounded;
      case 'responsive':
        return Icons.devices_outlined;
      case 'riverpod':
        return Icons.account_tree_outlined;
      case 'testing':
        return Icons.bug_report_outlined;
      case 'git':
        return Icons.merge_type_rounded;
      case 'ci_cd':
        return Icons.rocket_outlined;
      case 'design':
      case 'design_services':
        return Icons.design_services_rounded;
      case 'web':
      case 'web_rounded':
        return Icons.language_rounded;
      case 'mobile':
      case 'phone_android':
        return Icons.phone_android_rounded;
      default:
        return Icons.check_circle_outline_rounded;
    }
  }

  static IconData forTechnology(String label) {
    switch (label.trim().toLowerCase()) {
      case 'flutter':
        return Icons.flutter_dash_rounded;
      case 'dart':
        return Icons.code_rounded;
      case 'firebase':
        return Icons.cloud_outlined;
      case 'rest api':
      case 'rest apis':
      case 'api':
        return Icons.api_rounded;
      case 'responsive ui':
      case 'responsive':
        return Icons.devices_outlined;
      case 'riverpod':
        return Icons.account_tree_outlined;
      case 'testing':
        return Icons.bug_report_outlined;
      case 'git':
        return Icons.merge_type_rounded;
      case 'github':
        return Icons.code_rounded;
      case 'ci/cd':
      case 'ci_cd':
        return Icons.rocket_outlined;
      default:
        return Icons.code_rounded;
    }
  }
}
