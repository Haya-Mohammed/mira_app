# Mira Beauty Salon — Mobile Design System

> Version 1.0 · October 2026 · Design source of truth for the Flutter customer application

## 1. Product vision

**Mira (ميرا)** is an Arabic-first women's beauty salon booking application for customers to discover services, review specialists, select available appointments, and manage reservations. The visual identity is **crimson elegance + warm white minimalism**: refined, welcoming, feminine, accessible, and uncluttered.

**Primary audience:** women, young women, and brides. **Platforms:** Android and iOS. **Primary locale:** `ar` (RTL); English (`en`, LTR) is optional but should be structurally supported. **Currency:** ILS (`₪`) in sample UI; currency and actual prices must be supplied by the business/backend.

### Product principles
1. **Booking first:** every service detail page should lead clearly to a reservation.
2. **Trust and clarity:** show actual service price, duration, specialist, date, and cancellation terms before confirmation.
3. **Elegant restraint:** generous whitespace, one primary CTA per screen, minimal decorative graphics.
4. **Arabic-native:** layout mirroring, natural Arabic microcopy, and accessible typography—not translated LTR mockups.
5. **Real states:** design loading, empty, failure, offline, and success states alongside ideal screens.
6. **No false availability:** only present time slots and discounts confirmed by the data source.

## 2. Brand foundations

### Brand voice
Warm, professional, reassuring, concise. Avoid exaggerated beauty claims and overly promotional copy. Use feminine Arabic address consistently where appropriate. Examples: **«احجزي موعدك»**, **«اختاري الوقت المناسب»**, **«حجوزاتي»**.

### Color tokens

| Token | Hex | Usage |
|---|---|---|
| `primary` | `#B50922` | Main CTAs, active controls, selected navigation |
| `primaryDark` | `#800719` | Pressed states, premium accents |
| `accentRose` | `#D93B50` | Limited highlights and decorative accents |
| `blush` | `#FCE8EB` | Subtle chip and section backgrounds |
| `warmWhite` | `#FFFAFA` | Main page background |
| `white` | `#FFFFFF` | Surfaces, cards |
| `textPrimary` | `#24191C` | Headings and body |
| `textSecondary` | `#827579` | Supporting copy (verify contrast for small text) |
| `border` | `#F0DFE2` | Dividers and card outlines |
| `success` | `#217A55` | Confirmed bookings and success |
| `warning` | `#9A6300` | Pending actions |
| `error` | `#B42318` | Validation and failed actions |
| `disabledSurface` | `#F4F0F1` | Disabled controls |

**Distribution:** ~75% white/warm white, ~15% blush/neutral, ~10% crimson accents. Never use red for every card or paragraph. Use status colors semantically, not as brand decoration. Verify text/background pairs against WCAG contrast targets (4.5:1 normal text; 3:1 large text and UI boundaries).

### Typography
- **Arabic:** `Cairo` (preferred), fallback `IBM Plex Sans Arabic` / system sans.
- **Latin body:** system sans or `Inter`.
- **Brand wordmark:** use an approved *Mira* logo asset. The previous Lumé artwork must not be reused with its old wordmark; create or supply an updated Mira logo before release.
- Use Flutter `TextTheme` with text scaling and no fixed-height text boxes.

| Style | Size / line height | Weight | Typical use |
|---|---|---|---|
| Display | 30 / 40 | 700 | Large welcome / hero |
| H1 | 26 / 36 | 700 | Page heading |
| H2 | 22 / 32 | 700 | Section heading |
| H3 | 18 / 28 | 600 | Card title |
| Body | 16 / 26 | 400 | Main content |
| Body small | 14 / 23 | 400 | Secondary content |
| Label | 14 / 22 | 600 | Buttons / controls |
| Caption | 12 / 20 | 500 | Metadata only |

Respect dynamic text sizing; truncation should be intentional, not the default for critical booking information.

### Spacing, geometry and elevation
- Base spacing: **4px**. Tokens: `xs=4`, `sm=8`, `md=12`, `base=16`, `lg=20`, `xl=24`, `2xl=32`, `3xl=40`, `4xl=48`.
- Screen horizontal padding: **20px** default, **16px** on narrow layouts.
- Card inner padding: **16–20px**; section vertical gap: **24–32px**.
- Radii: `small=8`, `medium=12`, `large=16`, `xl=24`, `pill=999`.
- Hairline border: 1px in `border`. Use light elevation only for overlays/floating elements; favor border and tonal surfaces for cards.
- Minimum interactive target: **48×48 logical px**; avoid icons that are visually crowded.
- Primary button: **52–56px** high, radius **14–16px**.
- Inputs: **52–56px** high, labels outside or reliably floating above content.

### Imagery and icons
- Photography: realistic, professional beauty imagery with soft daylight/studio light, authentic skin texture, neutral backdrops, and restrained crimson/blush accents.
- Category imagery: one consistent visual treatment across makeup, hair, nails, skincare, lashes/brows, bridal.
- Avoid overly retouched faces, watermarks, stock-photo inconsistencies, text baked into category photos, and image-only communication of essential facts.
- Use consistent rounded outline icons (e.g., Material Symbols Rounded / Lucide-equivalent), 20–24px, stroke weight consistent throughout.
- Brand assets: supplied logo, banner and category images are **references**. Keep logo proportions and clear space; do not recolor or redraw without approval.
- Export assets as WebP/PNG where appropriate, supply 2x/3x resolutions, and use placeholders/error fallbacks.

## 3. Navigation and information architecture

### Bottom navigation (five destinations)
1. **الرئيسية** — home
2. **الخدمات** — service catalog
3. **حجوزاتي** — upcoming/history
4. **المفضلة** — saved services/specialists
5. **حسابي** — account and settings

Show bottom navigation only on root destinations. Detail and booking screens use a back action and clear progress/context. Preserve tab state when switching. Follow RTL ordering visually and use directional icons that mirror correctly.

### Primary journey
`Home / Services → Category → Service details → Specialist → Date → Time → Review → Confirm → Booking details`

Allow the user to return to a prior step without losing valid selections. Refresh availability before final confirmation and handle a slot that becomes unavailable.

### Screen inventory

| Screen | Key content and actions |
|---|---|
| Splash | Centered logo, minimal loading treatment |
| Onboarding (3) | Explore services, book easily, personalized care; skip/next/start |
| Login / Register | Phone/email, password, validation, recovery; guest access if supported |
| Home | Greeting, search, branded hero, categories, featured services, offers, specialists, upcoming appointment |
| Categories | Six categories with imagery and short labels |
| Service list | Search, category filters, image, price, duration, favorite, detail action |
| Service details | Hero, inclusions, price, duration, specialist options, policies, sticky book CTA |
| Specialists | Portrait, specialty, experience, genuine ratings if available |
| Specialist details | Bio, portfolio, supported services, availability |
| Booking steps | Specialist, calendar, time slot, review; step progress and editable summary |
| Confirmation | Status, reference, exact appointment details, view booking |
| My bookings | Upcoming / past tabs, status, details, reschedule/cancel when allowed |
| Booking details | Full reservation, policies, status, contact and actions |
| Favorites | Saved services/specialists; empty state |
| Offers | Validity, eligibility, original/current price where verified |
| Notifications | Reminders, confirmations, changes, read/unread |
| Profile | Personal details, settings, appointments, sign out |
| Salon information | About, location, hours, contact, social links |
| Global states | Loading, no results, offline, error, permission, session expired |

## 4. Detailed screen specifications

### 4.1 Home
**Hierarchy:** safe-area header → greeting + notifications → search → promotional banner → categories → popular services → specialists → offers/upcoming booking (only if applicable).

- Greeting example: **«صباح الجمال، سارة 🌸»** (use time-aware greeting only when available).
- Search placeholder: **«عن أي خدمة بتدوري؟»**.
- Banner: white/blush canvas, branded red curves, premium beauty photograph, a concise line and **«احجزي الآن»**. Never place text on a busy image without a scrim.
- Categories: 2-row grid or horizontal list; visible text labels; consistent category images.
- Service cards: name, price, duration, photo, favorite, booking/detail action.
- Do not overload the first viewport: prioritize banner and categories.

### 4.2 Service catalog and details
- Categories: **المكياج، الشعر، الأظافر، العناية بالبشرة، الرموش والحواجب، باقات العرائس**.
- Filters: category, price range, duration, available specialists; show selected filter chips and clear-all.
- Service card example: **«ميك أب محترف للمناسبات»** · **«60 دقيقة»** · **«150 ₪»** (illustrative, replace with real data).
- Detail screen: large media, service name, description, inclusions, estimated duration, total starting/fixed price clearly differentiated, policies, reviews only when real, and bottom sticky CTA.
- If prices vary, say **«يبدأ من …»** and clarify final pricing before booking.

### 4.3 Specialists
- Cards include name, role/specialty, portrait and experience. Only show ratings and work samples when actual data is available and permission to display has been obtained.
- Selection screen should support **«أي خبيرة متاحة»** if business rules permit.

### 4.4 Booking flow
- Step indicator: **1. الخبيرة → 2. التاريخ → 3. الوقت → 4. التأكيد** (omit specialist step when predetermined).
- Calendar: week/month picker with localized Arabic weekdays; disable unavailable and past dates; display selected date in crimson.
- Slots: 2–3-column wrapping grid, 48px min height, distinct selected/disabled states. Show timezone/local salon time where relevant.
- Review: service, specialist, date, time, duration, price breakdown, policy acknowledgment if required.
- Confirm: disabled while submitting; guard against double submission. Recheck availability and show actionable conflict message.
- Success: **«تم تأكيد حجزك بنجاح!»** only after server confirms; otherwise show pending status honestly.
- Cancellation/rescheduling: display only when policy and booking state permit.

### 4.5 My bookings
- Tabs: **«القادمة»**, **«السابقة»**.
- Statuses: **مؤكد، بانتظار التأكيد، مكتمل، ملغي، تمت إعادة الجدولة**.
- Cards show service, specialist, date/time, price, status; action to view details.
- Empty state: **«ما عندك حجوزات حالياً»** + **«استعرضي الخدمات»**.

### 4.6 Authentication and account
- Prefer simple forms and clearly labeled fields. Support password visibility, inline error messages, recovery, and autofill.
- Do not invent social-login/payment methods not supported by the product.
- Account settings include personal info, notification preferences, language (if supported), privacy, contact, and logout.

## 5. Component library

| Component | Variants / rules |
|---|---|
| `MiraButton` | Primary filled crimson; secondary outlined; tertiary text; disabled/loading |
| `MiraTextField` | Default, focused, error, disabled; label, helper and error text |
| `ServiceCard` | Compact horizontal and image-forward vertical; no fixed-length title assumption |
| `CategoryTile` | Consistent image size and label placement |
| `SpecialistCard` | Portrait, name, specialty, verified metadata |
| `OfferBanner` | Image + contrast-safe overlay + short CTA |
| `BookingSummary` | Structured rows; editable until final confirmation |
| `DateSelector` | Localized date, disabled dates, focus and selected states |
| `TimeSlotChip` | Available, selected, unavailable, loading |
| `StatusChip` | Semantic color plus readable text, never color alone |
| `EmptyState` | Illustration/icon, heading, helpful next action |
| `ErrorState` | Short explanation + retry or alternative |
| `BottomSheet` | Drag handle, title, close action, safe-area support |
| `AppNavigationBar` | Five labeled destinations; persistent selection |

### Interaction states
Every interactive element must have **default, pressed, focused, disabled**, and when relevant **selected, loading, error** states. Do not rely on animation alone to signal selection.

## 6. Motion and interaction
- Short transitions: **150–250ms**; complex page transitions up to **300ms**.
- Curves: ease-out for entrances, ease-in-out for selection changes.
- Animate subtle card/CTA feedback, tab indicators and confirmation states.
- Respect reduced-motion preferences. No autoplaying distracting banner carousel by default.
- Haptics should be restrained and optional; do not require them for feedback.

## 7. RTL, localization and accessibility

- Use Flutter `Directionality` and directional paddings (`EdgeInsetsDirectional`, `AlignmentDirectional`) instead of manual reversing.
- Back arrows, chevrons, page transitions and row ordering must mirror appropriately. Brand logo and photos must **not** mirror.
- Dates, numbers, currency and phone numbers should be formatted deliberately; test mixed Arabic/Latin strings and bidirectional text.
- Store copy in `app_ar.arb` and optionally `app_en.arb`; avoid hardcoded screen strings.
- Support at least 200% text scaling for essential flows where feasible, screen readers, logical focus order, accessible labels, and clear validation messages.
- Maintain visible focus/selection states, 48px tap targets, and semantic text alternatives for informative images.
- Distinguish booking status using text + shape/icon, not color alone.

## 8. Responsive behavior

- Reference artboard: **390×844 logical px**.
- Support compact devices around **320px width**, standard phones, larger phones and tablets.
- Respect safe areas, gesture insets, keyboard overlap, landscape constraints, and large text.
- On tablets, constrain content to a comfortable max width (~600–720px for forms; wider catalog grids as appropriate).
- Prefer adaptive grids based on available width rather than fixed column counts.

## 9. Flutter implementation guidance

### Recommended theme structure
```text
lib/
  core/
    design_system/
      tokens/
        app_colors.dart
        app_spacing.dart
        app_radii.dart
        app_typography.dart
      theme/
        app_theme.dart
      widgets/
        mira_button.dart
        mira_text_field.dart
        service_card.dart
        category_tile.dart
        booking_summary.dart
        state_views.dart
  l10n/
    app_ar.arb
    app_en.arb
  features/
    home/
    services/
    specialists/
    booking/
    favorites/
    notifications/
    profile/
```

- Use Material 3 with **explicit** `ColorScheme`, text styles, button styles, input decoration, card themes and navigation bar themes; do not rely on default seed-color output to match the brand.
- Centralize design tokens and avoid inline magic numbers/colors in feature widgets.
- Separate API-driven domain data from UI formatting; dates and money must be localized in presentation code.
- Model asynchronous states explicitly: initial/loading/data/empty/error. Preserve content on refresh when sensible.
- Keep image loading, missing images and offline behavior consistent.
- Use real availability/booking APIs for confirmed slots; mock data is acceptable only for design previews and must be labeled as such.

## 10. Sample Arabic content

| Context | Copy |
|---|---|
| Home greeting | صباح الجمال 🌸 |
| Search | عن أي خدمة بتدوري؟ |
| Categories heading | اكتشفي خدماتنا |
| Popular section | الخدمات الأكثر طلباً |
| Service CTA | احجزي موعدك |
| Choose specialist | اختاري خبيرة التجميل |
| Choose date | اختاري التاريخ المناسب |
| Choose time | اختاري الوقت المناسب |
| Review | مراجعة تفاصيل الحجز |
| Confirm | تأكيد الحجز |
| Success | تم تأكيد حجزك بنجاح! |
| No slots | ما في مواعيد متاحة بهذا اليوم، جرّبي تاريخ ثاني |
| No results | ما لقينا خدمات مطابقة لبحثك |
| Offline | تعذّر الاتصال بالإنترنت. تحققي من الاتصال وحاولي مرة ثانية |
| Retry | إعادة المحاولة |
| Favorites empty | لسه ما أضفتِ خدمات للمفضلة |

**Content policy:** never fabricate customer testimonials, specialist ratings, offers, salon addresses, opening hours, or available appointments.

## 11. Asset requirements

| Asset | Intended use | Recommendation |
|---|---|---|
| Mira master logo (new artwork required) | Splash, headers, brand presence | Transparent PNG + editable vector master |
| Square app icon | Launcher | Simplified emblem, high contrast, no tiny tagline |
| Salon banner | Home hero | Wide landscape crop with safe text area |
| Category images | Six categories | Matching 1:1 crops, cohesive lighting/background |
| Service images | Catalog/detail | 4:3 cards and larger detail crop |
| Specialist portraits | Directory | Consistent 1:1 portraits with consent |
| Empty-state illustrations | Bookings, favorites, errors | Minimal line illustrations in blush/crimson |

Do not assume existing generated image assets are transparent or vector; verify their file properties before production use.

## 12. QA and acceptance checklist

- [ ] All screens use shared colors, type, spacing and components.
- [ ] Arabic RTL navigation, icon directions and mixed-script strings are correct.
- [ ] Every core journey works without inaccessible or hidden CTAs.
- [ ] Booking selection persists across back/forward navigation.
- [ ] Unavailable slots cannot be selected; final booking conflict is handled.
- [ ] Prices, durations and policies are accurate and visible before confirmation.
- [ ] Loading, empty, error, offline and success states are designed.
- [ ] Contrast, touch targets, screen-reader labels and text scaling are tested.
- [ ] Keyboard, safe areas, small devices and tablet layouts are tested.
- [ ] All photos have valid rights and user/specialist consent where applicable.
- [ ] Real logo and banner render without stretching or clipping important details.
- [ ] No fabricated reviews, offers, availability or booking confirmations.

## 13. Design handoff deliverables

1. Token sheet with colors, typography, spacing, radii, elevation and icons.
2. High-fidelity RTL screens for all primary journeys and major states.
3. Reusable component library with variants and interaction states.
4. Navigation flow and booking prototype.
5. Asset inventory with dimensions, crop rules and export formats.
6. Flutter theme/token mapping and localized copy keys.

---

**Design north star:** *Mira should feel like stepping into a beautiful, calm salon: effortlessly welcoming, visually polished, and focused on making every booking simple.*
