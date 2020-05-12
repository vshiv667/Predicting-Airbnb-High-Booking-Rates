# Predicting-Airbnb-High-Booking-Rates
In this project, the aim was to predict the booking rates (high or not) of Airbnb listings.

# Introduction:

Over the past decade, Airbnb has become a widely popular company with many travelers using it for accommodation across many locations around the world. Recent statistics show that Airbnb has approximately over 150 million users in more than 65,000 cities. There are more than 5 million listings, and the platform has managed to tap into an inefficient market - rooms or entire homes that are unused and could earn the property-owner some extra income.
In this project, our aim was to predict the booking rates (high or not) of Airbnb listings in the test data set. Through exploring relationships within around 100,000 samples of Airbnb listing data, we tried to better understand the key variables that influence whether a property will be highly booked or not. The end goal is to then use that data and information to guide Airbnb hosts on how to maximize the profitability of their listings. Given that the aim of this project is to best predict whether a listing will have a high booking rate or not, the most important metric to assess the performance of our model is prediction accuracy.
The models we tried were Logistic Regression, Random Forest, and XGBoost. After running these models, we found that the XGBoost model gave us the best prediction accuracy at 84.59% using max_depth (depth of the trees) of 14, nrounds (number of iterations) of 3000 and learning rate of 3.9% on the variables. Although we can’t claim any direct interpretation of the data using XGBoost, it still provided us with a variable importance plot telling us the most influential variables in the model that contributed to the high prediction accuracy. These key variables included the listing’s longitude and latitude, price per guest, whether the property was available to book 30, 60, 90, and 365 days in advance, cleaning fee and minimum nights allowed to stay at the property, among others.

# Conclusion:

So, what is the business value of predicting high booking rate listings? 

Perhaps, from the perspective of a host, our model can help the host determine if their listing will have a high booking rate or not. If not, then the host can decide to sell the listing, rent out the listing to a potential tenant, remove the listing, switch to a competitor of Airbnb to list the same listing or reach out to airbnb to help promote the listing for a small fee. 
From the perspective of Airbnb, it helps them get an idea of how their listings are affected given the various features and what demand may look like for certain types of listings, which they can use to target the listings that are not popular by promotion.
