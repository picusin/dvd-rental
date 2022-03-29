# DVD Rental database analysis
## by Miguel Orellana

This was the first project from Udacity's Programming for Data Science Nanodegree covering the block on SQL.

The goal of this project is to query the Sakila DVD Rental database, provided by Udacity. This database holds information about a fictional company that rents movie DVDs.

The goal of the project is to query the database to answer four questions chosen by the student and this way gain an understanding of the customer base, such as what the patterns in movie watching are across different customer groups, how they compare on payment earnings, and how the stores compare in their performance. The schema for the DVD Rental database is also provided:

![DVD Rental ER Diagram](/images/erd.JPG)

All the questions are answered using SQL queries. To create the visualizations in the report, the tables resulting from the queries are imported into Excel.

### Question 1

**What would be the cost of a campaign aiming to increase the number of rentals. The campaign consists in a fidelity card that keeps track of every customer rentals and offers a free rental after 10 rentals.**

The result is US$ 4822, calculated as the value of all the free rentals offered over four weeks using an average value equal to the average value of all the rentals in the database.

![Average Rental Cost per Customer](/images/Q01_graph.PNG)

![Rental Count per Day](/images/Q01_table.JPG)

### Question 2

**When would be the best time of the year to launch this campaign?**

I look at the time of the year when rentals tend to go down, as the best time to launch the campaign to motivate the customers. Given the limited database not providing data for a full year, I'm aware it's not possible to get a clear picture. The query is written so that it would be applicable to a more extended database.

By Week 5 the generated amount starts decreasing, breaking the previous positive trend, so it'd be a good time to launch the campaign.

![Weekly Income and Variation per Week](/images/Q02_chart.JPG)

### Question 3



### Question 4
