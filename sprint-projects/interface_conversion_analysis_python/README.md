# Interface A/B Test — Conversion Rate Analysis

## Project Overview

BitMotion Kit is an e-commerce store selling gamified wellness products. The company developed a new, simplified interface to improve the shopping experience and potentially boost conversion rates. An A/B test was conducted to evaluate the effectiveness of the new interface.

This analysis focuses on:
- Validating the test design
- Estimating the conversion rate in both groups
- Assessing the statistical significance of the observed differences

---

## Data Sources

- **participants.csv** — User test group assignment
- **events.csv** — User activity logs on the platform

---

## Key Columns

### Participants
- `user_id` — Unique user identifier
- `group` — A/B test group (A = control, B = new interface)
- `ab_test` — Name of the test (we focus on `interface_eu_test`)
- `device` — Device used during registration

### Events
- `user_id` — Unique user identifier
- `event_dt` — Timestamp of the event
- `event_name` — Event type (e.g., purchase)
- `details` — Additional event metadata (may be missing)

---

## Test Design Validation

- The test groups are nearly evenly split:  
  - Group A: 5383 users  
  - Group B: 5351 users  
  - Difference: 0.59%

- Groups are independent and do not overlap.
- Sample size per group exceeds the minimum threshold (3762 users) required to detect a 3 percentage point (pp) change in conversion.

---

## Test Results

- **Conversion (Group A):** 27.49%
- **Conversion (Group B):** 29.51%
- **Absolute Lift:** +2.02 pp
- **Relative Lift:** +7.35%
- **p-value:** 0.01039

### Interpretation:
- The new interface has a statistically significant positive effect on user conversion (p < 0.05).
- However, the observed lift (+2.02 pp) falls short of the target increase (+3 pp).

---

## Recommendations

- Conduct additional iterations of the test focused on optimizing specific interface elements (e.g., purchase buttons, checkout flow).
- Use funnel analysis or path analysis to identify friction points in the new interface.
- Perform a cost-benefit analysis before a full rollout, considering the gap between expected and actual uplift.

---

## Conclusion

The A/B test confirms that the simplified interface improves conversion rates. Despite the smaller-than-expected lift, the results are statistically significant, supporting a potential implementation with further refinements.
