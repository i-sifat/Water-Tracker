# Manual Fixes Still Needed

## Critical Compilation Errors (Remaining)

### 1. Test API Mismatches
The following test files call methods that don't exist in the actual implementations:

**NotificationService Tests:**
- `scheduleNotification()` method doesn't exist
- Should be: `scheduleReminder()` or similar

**StorageService Tests:**
- `saveData()`, `getData()` methods don't exist  
- Need to check actual StorageService API

**HydrationProvider Tests:**
- `todayIntake`, `addWater()` methods don't exist
- Need to check actual HydrationProvider API

### 2. Constructor Parameter Issues
Several widgets have missing required parameters:
- CustomRulerPicker needs `isKg` and `value` parameters
- Various Switch widgets need proper parameter names

### 3. Type Mismatches
- Animation types need to be consistent (double vs int vs num)
- Mock class overrides need to match parent signatures

## Recommended Approach:

1. **Check Actual APIs:** Look at the real implementation files to see what methods actually exist
2. **Update Test Expectations:** Align test method calls with actual APIs
3. **Fix Constructor Calls:** Add missing required parameters
4. **Update Mock Classes:** Make sure mock implementations match real interfaces

## Files Needing Manual Review:
- lib/core/services/notification_service.dart (check actual API)
- lib/core/services/storage_service.dart (check actual API)  
- lib/features/hydration/providers/hydration_provider.dart (check actual API)
- All corresponding test files

