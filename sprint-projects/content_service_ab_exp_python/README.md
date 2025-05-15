# A/B Test Analysis for Content Recommendation Service

## Project Overview

This project focuses on the development and analysis of an A/B test for a content recommendation algorithm in an entertainment app featuring an infinite content feed (similar to short video apps). The app uses two monetization models:
- A **monthly subscription** with no ads.
- A **free version** with advertisements.

The recommendation system team developed a new content algorithm, which is hypothesized to increase user engagement. As a product analyst, your goal is to plan the A/B test, validate its setup, and analyze the results.

---

## Tools & Libraries

- Python (pandas, numpy, scipy, matplotlib, seaborn)
- Jupyter Notebook
- A/B testing methodology (Z-test for proportions)

## Data Description

The analysis is based on three datasets:

- `sessions_project_history.csv` — historical session data from **2025-08-15** to **2025-09-23**
- `sessions_project_test_part.csv` — session data from the **first day** of the experiment (2025-10-14)
- `sessions_project_test.csv` — session data from the **entire experiment period** (2025-10-14 to 2025-11-02)

Each dataset includes the following fields:

- `user_id`: User identifier  
- `session_id`: Session identifier  
- `session_date`: Date of the session  
- `session_start_ts`: Session start timestamp  
- `install_date`: App install date  
- `session_number`: Session number per user  
- `registration_flag`: Whether the user is registered  
- `page_counter`: Number of pages viewed in the session  
- `region`: User's region  
- `device`: Device type  
- `test_group`: A/B test group identifier  

---

## Key Insights

### Historical Trends

- **User growth** peaked in late August (e.g., ~18K users and 1.2K registrations on August 22).
- **Decline** in traffic began in September, reaching ~300 active users and only 32 registrations by September 23.
- **Registration conversion** increased over time: from 4–7% early on to 12%+ by September 21–22.
- Majority of sessions involved **viewing just 3 pages**, with few users engaging beyond that.
- The share of **"successful sessions"** (4+ pages viewed) remained stable around **30%**.

---

## A/B Test Setup

- **Experiment Period:** 2025-10-14 to 2025-11-02 (19 days)  
- **Participants:**  
  - Group A (control): 1,477 users  
  - Group B (test): 1,466 users  
- **Key Metric:** Share of "successful sessions" (≥ 4 pages viewed)

---

## Hypotheses

1. **Daily Unique Sessions**  
   - H₀: No difference in the number of daily unique sessions between groups  
   - H₁: There is a difference  
   - **p-value = 0.938** → Not statistically significant

2. **Successful Session Rate**  
   - H₀: Success rates (4+ pages viewed) are equal in groups A and B  
   - H₁: Success rates differ between the groups  
   - **p-value = 0.00031** → Statistically significant difference

---

## Conclusions

- **Group A (control):** 30.77% success rate  
- **Group B (test):** 31.83% success rate  
- **Uplift:** +1.1% in the test group  
- **Statistical significance:** Confirmed (p < 0.05)

➡️ The new recommendation algorithm positively impacts user engagement. Given the statistical significance and measurable improvement, the algorithm is a candidate for rollout.

