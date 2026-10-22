# Olist E-Commerce Analysis: Uncovering the Root Causes of Negative Customer Reviews

## 📌 Project Overview

The aim of this project was to understand the most significant contributors to low-score reviews left by customers. The dataset used in this work was the public Olist Brazilian E-Commerce dataset (extracted from Kaggle – see reference segment).

In order to identify the quantitative and qualitative drivers behind low customer satisfaction (1-star and 2-star reviews), I utilized parsing of unstructured review text and joined multiple tables containing geographic, customer opinions, and logistical data to identify the leading causes of these negative reviews.

The first step of the project was to identify the split between review scores 1 and 2. The data showed that reviews with a score of 1 accounted for 80.31% of the low-score reviews, with a score of 2 being responsible for the remaining 19.69%.

The next step was to identify which words appeared the most frequently. Looking at the top 10 words that can be classed as keywords (excluding prepositions or conjunctions), most of them point directly towards delivery (“*recebi*”, “*veio*”, “*entrega*”, “*entregue*”, “*chegou*”, “*prazo*”, etc.).

With that in mind, I decided to categorise the reviews based on keywords that serve as strong indicators of the main issue. I created categories to class the reviews into operational groups, including *Delivery*, *Quality*, *Mistake in Reviews*, *Costs*, and *Dispatching/Advertising* (see bar chart visual on the Tableau dashboard). Although a number of reviews could not be cleanly grouped, a very clear picture emerged showing that **delivery is, in fact, the main driver** of the low reviews.

I also observed that many of the reviews grouped under *Delivery* were submitted before the expected delivery date (over 2,600 reviews). I then created a visual (see line chart on the Tableau dashboard) demonstrating how the increase in days an order is delayed affects the review score. The data shows a sharp increase in score 1 reviews and a sharp decline in scores 3-5 immediately after the expected delivery date has passed.

As a final step prior to data visualization, I analyzed whether there was a geographic correlation within the delivery-related reviews. The logistics system in Brazil is historically impacted by geography, with deliveries to the northern regions usually taking longer since the main hubs are located in the south. The data confirmed that the Northeast region was the most impacted by delays and failures to deliver, with only 79.05% of orders being delivered on time (see map visualization on the Tableau dashboard). When looking at delivery success by state, Alagoas (AL) and Roraima (RR) were the most impacted, with only 65-66% of deliveries arriving on time. 

The final output is a dynamic Tableau dashboard designed for operations managers to monitor these delivery bottlenecks and product quality issues by region.


## 🌐 Live Dashboard
You can interact with the final visualization here: **[Olist E-Commerce: Delivery Bottlenecks & Customer Satisfaction](https://public.tableau.com/views/OlistE-Commerce-DeliveryPerformancewithinBrazilianMarket/OlistE-CommerceDeliveryBottlenecksCustomerSatisfaction?:language=en-GB&publish=yes&:sid=&:redirect=auth&:display_count=n&:origin=viz_share_link)**


## 🛠️ Tech Stack & Techniques

* **PostgreSQL:** Data cleaning, text mining, complex joins, subqueries, and database architecture.

  * Used `unaccent` and Regular Expressions (`~*`) to parse unstructured Portuguese text comments.

  * Utilized complex `CASE WHEN` logic to categorize thousands of distinct review messages into clean operational buckets (e.g., Delivery vs. Quality).

  * Built an optimized reporting layer using `CREATE VIEW` to feed live reporting tools.

* **Tableau:** Data visualization and dashboarding.

  * Implemented parameter-driven dynamic filters (using True/False logic evaluation) to seamlessly slice aggregate metrics without breaking the underlying visualizations.

* **Git/GitHub:** Version control and professional repository structuring.


## 🗂️ Repository Structure

This repository is organized to reflect a professional data engineering and analysis pipeline.

```
├── datasets.zip                         # Compressed raw CSV data files (Olist public dataset)
├── schema.sql                           # DDL script: Table architecture, Extensions, and final Reporting Views
├── seed.sql                             # DML script: Inserts and static mapping data
├── tasks/                               # Modular analytical queries
│   ├── 01-review-text-analysis.sql      # NLP/Text mining for most frequent complaint keywords
│   ├── 02-issue-categorisation.sql      # Master query grouping issues via Regex & Date Math
│   ├── 03-delivery-geography.sql        # Exploratory Data Analysis (EDA) on geographic bottlenecks
│   └── 04-final-tableau-export.sql      # Final validation of the Tableau data source
└── README.md                            # Project documentation

```


## 📊 Key Insights & Business Value

* **Delivery is the Primary Bottleneck:** Text analysis revealed that words associated with shipping deadlines (*prazo*, *atrasado*, *não chegou*) drastically outweighed pure product quality complaints in 1-star and 2-star reviews (which make up \~20% and \~80% of negative reviews, respectively).

* **Geographical Disparities:** Exploratory data analysis highlighted specific regional codes with vastly higher percentages of delayed or undelivered orders compared to the national average.

* **Expectation Misalignment:** Date math calculations comparing estimated vs. actual delivery dates against the review creation date showed that customers frequently leave negative reviews when they misunderstand the estimated delivery window.


## 🚀 How to Run This Project

1. Clone the repository to your local machine.

2. **Note on Data:** Due to GitHub file size limits, the raw CSV data is compressed in `datasets.zip`. Please extract this folder before proceeding.

3. Ensure you have PostgreSQL installed and run `schema.sql` to build the database architecture. *(Note: This project utilizes the `unaccent` extension).*

4. Import the extracted CSV files into your tables, and run `seed.sql` for the geographic mapping data.

5. Connect Tableau directly to the `cat_issue_delivery` view to explore the dashboard.


## 🔗 References
* **Data Source:** [Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) via Kaggle.
