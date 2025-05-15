# Startup Acquisition Analysis

This project focuses on preparing and preprocessing data about startups, evaluating their acquisitions, and analyzing key factors that could influence the success of deals. The project is part of a course where you learn the basics of Python, work with the pandas library, and create visualizations using matplotlib. Additionally, the project allows you to apply data analysis skills in Jupyter Notebook.

## Project Overview

A financial company that provides subsidized loans to startups plans to enter the investment market by acquiring, developing, and reselling promising startups. To develop a business model, the company needs historical data to understand which data points are most useful.

The goal of the project is to prepare the dataset, preprocess it, answer the client's questions, and verify the data for business purposes. The analysis should include:
- Data merging and validation from different tables.
- Assessing the accuracy of information about employees and their education.
- Analyzing deals involving purchases for $0 or $1.
- Investigating the relationship between acquisition prices, startup categories, and the number of funding rounds.

## Datasets

The following datasets are used in the project:

1. **company_and_rounds.csv** — Information about startups and their funding rounds.
2. **acquisition.csv** — Data about startup acquisition deals.
3. **people.csv** — Information about employees in startups.
4. **education.csv** — Data about employees' education.
5. **degrees.csv** — Information about employees' degree types.

### Dataset Descriptions

- **acquisition.csv**: Contains information about startup acquisition deals, including the deal price, acquisition date, and company identifiers.
- **company_and_rounds.csv**: Contains information about startups, including their name, category, number of funding rounds, and total funding amount.
- **people.csv**: Contains information about employees in startups, including names and company affiliations.
- **education.csv**: Contains data on employees' higher education.
- **degrees.csv**: Contains data on employees' degree types.

## Project Structure

The project consists of several stages, which are detailed in the notebook:

1. Data loading and initial exploration.
2. Data preprocessing, including handling missing values and duplicates.
3. Exploratory data analysis (EDA) and answering the client's key questions.
4. Final insights and recommendations based on the analysis.
