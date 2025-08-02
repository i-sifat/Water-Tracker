# Manual Accessibility Testing Guide

This guide provides step-by-step instructions for manually testing the accessibility features of the swipeable hydration interface.

## Prerequisites

### iOS Testing
- Enable VoiceOver: Settings > Accessibility > VoiceOver > On
- Enable Accessibility Inspector: Settings > Accessibility > Accessibility Inspector > On

### Android Testing
- Enable TalkBack: Settings > Accessibility > TalkBack > On
- Enable Accessibility Scanner: Install from Google Play Store

## Test Scenarios

### 1. Screen Reader Navigation

#### Test: VoiceOver/TalkBack Navigation
**Objective**: Ensure all interactive elements are properly announced by screen readers.

**Steps**:
1. Enable VoiceOver (iOS) or TalkBack (Android)
2. Open the hydration tracking screen
3. Navigate through all elements using swipe gestures
4. Verify each element is announced with meaningful labels

**Expected Results**:
- Circular progress indicator announces current progress percentage and intake amounts
- Quick add buttons announce "Add [amount]ml of [drink type] to hydration log"
- Drink type selector announces current selection and water content percentage
- Navigation buttons announce their purpose (menu, profile)
- Page indicators announce current page and navigation hints

#### Test: Progress Change Announcements
**Objective**: Verify screen reader announces progress updates.

**Steps**:
1. With screen reader enabled, tap a quick add button
2. Listen for automatic announcement
3. Verify progress change is announced

**Expected Results**:
- Screen reader announces: "Added [amount]ml of [drink type] to your hydration log"
- Progress update is announced: "Hydration progress updated. You have consumed [amount] out of [goal]. That is [percentage]% complete."

### 2. Touch Target Size Testing

#### Test: Minimum Touch Target Size
**Objective**: Ensure all interactive elements meet 44x44 point minimum size.

**Steps**:
1. Navigate to each interactive element
2. Attempt to tap elements with different finger sizes
3. Test edge cases (corners, small elements)

**Expected Results**:
- All buttons and interactive elements should be easily tappable
- No accidental taps on adjacent elements
- Comfortable interaction for users with motor impairments

**Elements to Test**:
- Quick add buttons (500ml, 250ml, 400ml, 100ml)
- Drink type selector
- Navigation menu button
- Profile button
- Period selector tabs (Weekly, Monthly, Yearly)
- Drink type options in modal

### 3. Font Scaling Support

#### Test: Dynamic Type Support
**Objective**: Verify interface adapts to system font size changes.

**Steps**:
1. Go to device Settings > Display & Brightness > Text Size (iOS) or Settings > Display > Font Size (Android)
2. Set font size to largest setting
3. Return to app and check all text elements
4. Test with smallest font size setting

**Expected Results**:
- All text remains readable at all font sizes
- UI elements don't overlap or get cut off
- Layout adapts appropriately to larger text
- No text truncation in critical areas

### 4. Color Contrast Testing

#### Test: Visual Accessibility
**Objective**: Ensure sufficient color contrast for users with visual impairments.

**Steps**:
1. Test interface under different lighting conditions
2. Use color blindness simulation tools if available
3. Check contrast ratios using accessibility tools

**Expected Results**:
- Text has sufficient contrast against backgrounds (minimum 4.5:1 ratio)
- Interactive elements are distinguishable from non-interactive elements
- Progress indicators are visible to users with color vision deficiencies
- Selected states are clearly indicated beyond color alone

**Elements to Test**:
- White text on gradient background
- Progress indicator colors
- Button text on colored backgrounds
- Selected vs unselected states in period selector
- Streak indicator dots (completed vs incomplete)

### 5. Gesture Navigation Testing

#### Test: Swipe Gesture Accessibility
**Objective**: Verify swipe gestures work with accessibility features enabled.

**Steps**:
1. Enable screen reader
2. Navigate to main hydration page
3. Attempt vertical swipe gestures
4. Test with accessibility gestures enabled

**Expected Results**:
- Swipe up/down gestures still function with screen reader enabled
- Page changes are announced to screen reader
- Alternative navigation methods are available if gestures conflict

### 6. Keyboard Navigation (if applicable)

#### Test: External Keyboard Support
**Objective**: Ensure interface works with external keyboards.

**Steps**:
1. Connect external keyboard to device
2. Navigate through interface using Tab key
3. Activate elements using Enter/Space keys

**Expected Results**:
- All interactive elements are reachable via keyboard
- Focus indicators are visible
- Logical tab order is maintained

### 7. Reduced Motion Testing

#### Test: Motion Sensitivity
**Objective**: Verify interface respects reduced motion preferences.

**Steps**:
1. Enable "Reduce Motion" in device accessibility settings
2. Navigate through the interface
3. Trigger animations (progress updates, page transitions)

**Expected Results**:
- Animations are reduced or eliminated when reduce motion is enabled
- Essential functionality remains intact
- No motion-induced discomfort

## Accessibility Checklist

### Screen Reader Support
- [ ] All interactive elements have semantic labels
- [ ] Progress changes are announced
- [ ] Page navigation is announced
- [ ] Decorative elements are excluded from screen reader
- [ ] Meaningful content is included in screen reader

### Touch Targets
- [ ] All interactive elements meet 44x44 point minimum
- [ ] Adequate spacing between touch targets
- [ ] No accidental activation of adjacent elements

### Visual Accessibility
- [ ] Sufficient color contrast (4.5:1 minimum)
- [ ] Information not conveyed by color alone
- [ ] Text remains readable at all system font sizes
- [ ] Focus indicators are visible

### Motor Accessibility
- [ ] Large enough touch targets
- [ ] Alternative input methods supported
- [ ] No time-sensitive interactions
- [ ] Gesture alternatives available

### Cognitive Accessibility
- [ ] Clear and consistent navigation
- [ ] Meaningful labels and instructions
- [ ] Error messages are clear and helpful
- [ ] Interface is predictable and consistent

## Common Issues and Solutions

### Issue: Screen Reader Not Announcing Elements
**Solution**: Check that elements have proper semantic labels and are not excluded from accessibility tree.

### Issue: Touch Targets Too Small
**Solution**: Ensure minimum 44x44 point size using AccessibilityUtils.ensureMinTouchTarget().

### Issue: Poor Color Contrast
**Solution**: Use high contrast colors and test with accessibility tools.

### Issue: Text Truncation at Large Font Sizes
**Solution**: Use flexible layouts and test with maximum system font sizes.

### Issue: Gestures Not Working with Screen Reader
**Solution**: Provide alternative navigation methods and ensure gestures don't conflict with accessibility gestures.

## Testing Tools

### iOS
- VoiceOver
- Accessibility Inspector
- Voice Control
- Switch Control

### Android
- TalkBack
- Accessibility Scanner
- Select to Speak
- Voice Access

### Third-Party Tools
- Color Oracle (color blindness simulation)
- Stark (contrast checking)
- axe DevTools (web-based testing)

## Reporting Issues

When reporting accessibility issues, include:
1. Device and OS version
2. Accessibility feature being used
3. Steps to reproduce
4. Expected vs actual behavior
5. Screenshots or screen recordings if helpful

## Continuous Testing

Accessibility testing should be performed:
- During development of new features
- Before each release
- When making UI/UX changes
- After OS updates
- Based on user feedback

Remember: Accessibility is not a one-time check but an ongoing commitment to inclusive design.