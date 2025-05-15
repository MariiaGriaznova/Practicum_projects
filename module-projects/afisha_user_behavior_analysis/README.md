# Capstone Project — User Behavior Analysis & Metrics Dashboard for Yandex Afisha

**Tools:** 
- SQL, 
- Python, 
- Jupyter Notebook, 
- Yandex DataLens (dashboard link 'https://datalens.yandex/htiniykfn1t63')

---

## Project Goal

To analyze user behavior and revenue dynamics for **Yandex Afisha**, identify seasonal patterns and performance across segments, and build an interactive business dashboard.

---

## Project Structure

### 1. SQL Analytics & Data Preparation
- Queried PostgreSQL database to extract data on orders, users, and events;
- Created aggregate tables and data marts for the dashboard:
  - Weekly metrics (revenue, orders, average check);
  - Revenue breakdown by device, region, and event type;
  - Top-performing events, venues, and partners.

### 2. Yandex DataLens Dashboard
- Built an interactive dashboard with key business metrics:
  - Weekly trends in revenue and number of orders;
  - Revenue structure by category;
  - Geographic revenue breakdown (RUB and KZT shown separately);
  - Filters by region, partner, and event type.
- Used for identifying revenue drivers and areas with potential for optimization (e.g., low mobile revenue in specific regions).

### 3. Exploratory Data Analysis (EDA) & Hypothesis Testing in Python
- Conducted EDA on user activity and revenue:
  - Seasonal trends and peak periods;
  - User activity distribution and average check;
  - Device type and regional segmentation.
- Performed statistical hypothesis testing:
  - Compared order activity between desktop and mobile users;
  - Used Mann–Whitney U test (p < 0.05 — significant difference found).

---

## Key Insights

- Strong seasonal dependency in user activity;
- Major revenue comes from large cities and a few key partners (especially in RUB segment);
- Mobile users place fewer orders than desktop users (statistically significant).