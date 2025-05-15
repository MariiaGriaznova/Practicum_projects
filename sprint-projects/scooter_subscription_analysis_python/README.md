# Scooter Subscription Effectiveness Analysis

This project analyzes the effectiveness of the subscription model in a scooter-sharing service. The goal is to understand user behavior with and without a subscription and evaluate how it affects trip duration and revenue.

## Project Structure

- `gofast_scooters_hypothesis_testing.ipynb`: Main Jupyter Notebook containing data preprocessing, exploratory analysis, statistical testing, and results.

## Objectives

- Compare users with and without a subscription.
- Test hypotheses about trip duration, distance, and monthly revenue.
- Estimate the probabilities of long trips and identify key patterns in usage.

## Key Findings

- 54% of users do not have a subscription; 46% are subscribers.
- 5% of all users are underage.
- The average trip duration is 18 minutes (standard deviation: 6 minutes).
- Most trips last between 14 and 22 minutes.
- Subscribers ride longer on average: 19 minutes vs. 17 minutes for non-subscribers.
- A hypothesis test confirmed this difference is statistically significant (p-value ≈ 3e-35).
- The average trip distance for subscribers does not significantly exceed 3130 meters (p-value ≈ 0.92).
- Monthly revenue from subscribers is significantly higher than from non-subscribers (359 RUB vs. 322 RUB, p-value ≈ 1.7e-37).
- The probability of a trip longer than 30 minutes is about 2%.
- The probability of a trip lasting 20–30 minutes is about 37.7%.
- 90% of trips are shorter than 4502 meters — useful for estimating scooter wear and maintenance needs.

## Conclusion

The subscription model is associated with longer trips and higher revenue, confirming its business value. These insights can support decisions on pricing, promotions, and operational planning.

---

*Author: [Mariia Griaznova]*  

