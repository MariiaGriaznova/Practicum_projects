# Restaurant Market Analysis in Moscow (2022)

## Project Description

Investors fund are venturing into the restaurant business in Moscow. They are unsure about the type of establishment to open (cafe, restaurant, or bar), the location, menu, and pricing. Your task as an analyst is to conduct an exploratory analysis of the restaurant market in Moscow to help guide their decision.

The analysis is based on a dataset containing information about public food establishments in Moscow, collected from Yandex Maps and Yandex Business in the summer of 2022.

## Dataset Description

The project uses two datasets:

1. **`rest_info.csv`** - Information about food establishments:
   - `name`: Name of the establishment
   - `address`: Address of the establishment
   - `district`: Administrative district of the establishment (e.g., Central Administrative District)
   - `category`: Category of the establishment (e.g., "cafe", "pizzeria", "coffee shop")
   - `hours`: Operating hours
   - `rating`: Rating of the establishment on Yandex Maps (scale from 0 to 5)
   - `chain`: Indicates if the establishment is part of a chain (0 = no, 1 = yes)
   - `seats`: Number of seating places

2. **`rest_price.csv`** - Information about average check prices in the establishments:
   - `price`: Price category of the establishment (e.g., "average", "below average", "above average")
   - `avg_bill`: Range of the average bill (e.g., "Average bill: 1000–1500 ₽")
   - `middle_avg_bill`: Median value of the average bill
   - `middle_coffee_cup`: Price for a cup of cappuccino in the establishment

## Steps for the Project

### Step 1: Data Loading and Exploration

- Load the datasets `rest_info.csv` and `rest_price.csv`.
- Explore the data by checking the data types, missing values, and general statistics.
- Merge the two datasets into one combined dataframe for further analysis.

### Step 2: Data Preprocessing

- Clean the data by correcting data types and handling missing values.
- Normalize text data (e.g., names of establishments and addresses).
- Create a new column `is_24_7` indicating whether the establishment operates 24/7 (True/False).

### Step 3: Exploratory Data Analysis

- Investigate the distribution of different types of establishments (e.g., cafes, restaurants, bars) and their ratings.
- Analyze the distribution of establishments across different administrative districts of Moscow, particularly the Central Administrative District.
- Compare the proportion of chain vs non-chain establishments and explore which categories tend to be chains.
- Analyze the seating capacity and identify any outliers or anomalies.
- Investigate the average ratings for different types of establishments.
- Study the correlation between different features (e.g., ratings, category, district, chain status, seating capacity, price category).
- Identify the top 15 most popular restaurant chains in Moscow and analyze their average ratings.
- Study the variation in average check prices across different districts, focusing on how proximity to the city center impacts pricing.

### Step 4: Final Recommendations

- Provide a summary of the key findings from the exploratory analysis.
- Offer recommendations to the investors based on the analysis, such as the best type of establishment to open, ideal location, and expected pricing strategies.

## Requirements

- Python 3.x
- Libraries: pandas, numpy, matplotlib, seaborn, etc.

## How to Run

1. Install the required Python libraries using `pip install -r requirements.txt`.
2. Run the Jupyter Notebook `restaurant_market_analysis.ipynb` to reproduce the analysis.

## Conclusion

This project provides a comprehensive exploratory analysis of the Moscow restaurant market, offering insights into categories of establishments, distribution across districts, and price variations. The findings will guide investors in making an informed decision on the type of restaurant to open in Moscow.
