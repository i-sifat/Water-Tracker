enum PremiumFeature {
  advancedAnalytics,
  customReminders,
  dataExport,
  healthSync,
  unlimitedHistory,
  customGoals,
  weeklyReports,
  themeCustomization,
  backupRestore,
  prioritySupport,
}

class PremiumFeatures {
  static const Map<PremiumFeature, String> featureNames = {
    PremiumFeature.advancedAnalytics: 'Advanced Analytics',
    PremiumFeature.customReminders: 'Custom Reminders',
    PremiumFeature.dataExport: 'Data Export',
    PremiumFeature.healthSync: 'Health App Sync',
    PremiumFeature.unlimitedHistory: 'Unlimited History',
    PremiumFeature.customGoals: 'Custom Goals',
    PremiumFeature.weeklyReports: 'Weekly Reports',
    PremiumFeature.themeCustomization: 'Theme Customization',
    PremiumFeature.backupRestore: 'Backup & Restore',
    PremiumFeature.prioritySupport: 'Priority Support',
  };

  static const Map<PremiumFeature, String> featureDescriptions = {
    PremiumFeature.advancedAnalytics: 'Detailed charts and progress tracking',
    PremiumFeature.customReminders: 'Set personalized reminder schedules',
    PremiumFeature.dataExport: 'Export your data to CSV or PDF',
    PremiumFeature.healthSync: 'Sync with Google Fit or Apple Health',
    PremiumFeature.unlimitedHistory: 'Access unlimited historical data',
    PremiumFeature.customGoals: 'Set advanced personalized goals',
    PremiumFeature.weeklyReports: 'Receive detailed weekly reports',
    PremiumFeature.themeCustomization: 'Customize app themes and colors',
    PremiumFeature.backupRestore: 'Backup and restore your data across devices',
    PremiumFeature.prioritySupport: 'Get priority customer support',
  };
}
