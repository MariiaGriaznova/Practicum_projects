# Comparing User Engagement in Moscow and Saint Petersburg

## 📌 Project Goal

To statistically test whether users from Saint Petersburg spend more time reading and listening to books in the app than users from Moscow.

**Hypothesis:**
> Users from Saint Petersburg spend more time on average in the app than users from Moscow.

## 📊 Dataset Description

Source file: `yandex_knigi_data.csv`  
Each row contains a user's total time spent in the app (in hours) along with their city.

- `user_id` — unique user identifier  
- `city` — user’s city (`Moscow` or `Saint Petersburg`)  
- `total_hours` — total hours of app activity

## 🔍 Analysis Steps

1. **Data validation:**
   - Checked for duplicate `user_id`s — none found.
   - Sample sizes: the Moscow group was significantly larger than the Saint Petersburg group.

2. **Hypothesis formulation:**
   - **Null hypothesis (H₀):** The average activity time in Saint Petersburg is **less than or equal to** that in Moscow.
   - **Alternative hypothesis (H₁):** The average activity time in Saint Petersburg is **greater than** in Moscow.

3. **Statistical testing:**
   - Used the **Mann–Whitney U test** — a non-parametric test suitable for data that may not be normally distributed.
   - Significance level: `α = 0.05`.

## 🧪 Test Results

- **p-value:** `0.62`
- **Conclusion:** We fail to reject the null hypothesis.
- **Interpretation:** The difference in user activity time between the two cities is **not statistically significant**.

## 📌 Insights

- User behavior in terms of time spent in the app is similar between Moscow and Saint Petersburg.
- Possible explanations:
  - Similar digital habits across cities.
  - Comparable socio-economic or demographic profiles.

## 💡 Recommendations

- Increase the sample size for Saint Petersburg to improve test sensitivity.
- Incorporate additional features (e.g., age, profession, content preferences).
- If assumptions are met, consider parametric tests (e.g., t-test) for future analysis.

