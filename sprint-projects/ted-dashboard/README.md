# TED Conferences Dashboard Project

## Project Overview
An analytics agency was approached by a company that purchased a license to organize TED conferences. To successfully organize the first event, the company needs a dashboard that provides insights based on the experience of past TED events.

The dashboard will help answer key business questions about popular topics, optimal event organization, and speaker engagement.

## Business Objectives
- Which topics are the most popular? How do audiences react to them?
- What is the average number of speakers per conference?
- What is the average talk duration? How to plan the event schedule properly?
- Which speakers are most engaging for the audience?
- How are applause and laughter distributed across topics and speakers?

## Data Description
The data comes from a PostgreSQL database and includes three tables:

- **events** — conference information:
  - `conf_id`, `event_name`, `country`
- **speakers** — speaker information:
  - `author_id`, `speaker_name`, `speaker_occupation`, `speaker_description`
- **talks** — talk details:
  - `talk_id`, `url`, `title`, `description`, `duration`, `views_count`, `main_tag`, `laughter_count`, `applause_count`, `speaker_id`, `event_id`, `film_date`, `language_sp`

## Tools and Technologies
- **SQL** — data extraction
- **Yandex DataLens** — dashboard development

**Link to the dashboard in DataLens**: [Go to Dashboard](https://datalens.yandex/gug5ply1prty3)

## Dashboard Features
- **Top-level metrics**:
  - Number of conferences, talks, topics, and unique speakers
- **Country-level drill-down**:
  - Average talk duration
  - Maximum views per talk
  - Total applause per conference
  - Number of speakers
- **Talks analysis**:
  - Top-10 funniest talks (based on laughter count)
  - Top-20 most popular tags
- **Speakers analysis**:
  - Most applauded speaker occupations
- **Detailed view**:
  - Filters by country, conference name, talk tag, and talk date
  
  ## Author

- **Author Name**: [Maria Gryaznova]

