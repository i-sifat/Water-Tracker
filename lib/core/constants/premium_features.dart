enum PremiumFeature {
  advancedAnalytics,
  customReminders,
  dataExport,
  healthSync,
  unlimitedHistory,
  customGoals,
  weeklyReports,
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
  };

  static const Map<PremiumFeature, String> featureDescriptions = {
    PremiumFeature.advancedAnalytics: 'Detailed charts and progress tracking',
    PremiumFeature.customReminders: 'Set personalized reminder schedules',
    PremiumFeature.dataExport: 'Export your data to CSV or PDF',
    PremiumFeature.healthSync: 'Sync with Google Fit or Apple Health',
    PremiumFeature.unlimitedHistory: 'Access unlimited historical data',
    PremiumFeature.customGoals: 'Set advanced personalized goals',
    PremiumFeature.weeklyReports: 'Receive detailed weekly reports',
  };
}