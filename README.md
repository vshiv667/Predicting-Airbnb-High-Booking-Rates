[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)

## Predicting-Airbnb-High-Booking-Rates
In this project, the aim was to predict the booking rates (high or not) of Airbnb listings.

## Introduction:

Over the past decade, Airbnb has become a widely popular company with many travelers using it for accommodation across many locations around the world. Recent statistics show that Airbnb has approximately over 150 million users in more than 65,000 cities. There are more than 5 million listings, and the platform has managed to tap into an inefficient market - rooms or entire homes that are unused and could earn the property-owner some extra income.

In this project, our aim was to predict the booking rates (high or not) of Airbnb listings in the test data set. Through exploring relationships within around 100,000 samples of Airbnb listing data, we tried to better understand the key variables that influence whether a property will be highly booked or not. The end goal is to then use that data and information to guide Airbnb hosts on how to maximize the profitability of their listings. Given that the aim of this project is to best predict whether a listing will have a high booking rate or not, the most important metric to assess the performance of our model is prediction accuracy.

The models we tried were Logistic Regression, Random Forest, and XGBoost. After running these models, we found that the XGBoost model gave us the best prediction accuracy at 84.59% using max_depth (depth of the trees) of 14, nrounds (number of iterations) of 3000 and learning rate of 3.9% on the variables. Although we can’t claim any direct interpretation of the data using XGBoost, it still provided us with a variable importance plot telling us the most influential variables in the model that contributed to the high prediction accuracy. These key variables included the listing’s longitude and latitude, price per guest, whether the property was available to book 30, 60, 90, and 365 days in advance, cleaning fee and minimum nights allowed to stay at the property, among others.

## Modeling, Results and Evaluation:

Once the data was cleaned and imputed and the features were engineered, we moved on to modeling. We started off with a simple Logistic Regression model that included 43 predictors. We split the dataset into a 75 percent train and 25 percent validation. This Logistic Regression model produced a validation accuracy of 78.84%, which was a good baseline for us to improve upon.  

Given the large number of instances in the training data, our next approach was building a classification based Decision Tree. These are flexible, robust to outliers and require very little data preparation. However, these are prone to overfitting. To reduce this, we converged to ensemble methods. We wanted to explore bagging methods. If a feature is considered very important, then this feature may be present in all the trees of our bagging model and result in high variance. To counter this, we chose to implement a Random Forest model. Here, each split is done with a randomly selected subset of features denoted with the hyperparameter ‘mtry’. This value was chosen as ‘7’ as this approximated to the square root of the total number of features we had in our cleaned dataset - ‘43’. Several numbers of trees were fit on the training data and were evaluated on the validation data. The optimal tree count was found to be ‘1000’. This high number of trees also ensured that we had a low bias, low variance model. This model resulted in an accuracy of 83.70%, which was a major improvement over the Logistic Regression model.

Looking at the resulting accuracy of the Random Forest model, we wanted to increase the accuracy further without overfitting. This was possible by using a boosting algorithm. However, as there were many tree boosting algorithms available, we wanted to select the right one for our dataset. XGBoost uses Newton tree boosting which has Hessian matrix, a higher-order approximation, which plays a crucial role to determine a better tree structure compared to other tree boosting algorithms. Hence, we used the XGBoost model on our dataset and obtained very good accuracy values. After performing grid search for determining the best hyperparameter values we used max_depth (depth of the trees) as 14, nrounds (number of iterations) as 3000 and learning rate as 3.9% which are the main hyperparameters for XGBoost to obtain the best accuracy from the model. In addition, we used a cutoff of .43 for this model as it increased the accuracy on the validation dataset. This XGBoost model resulted in an accuracy of 84.59%.

Given that our goal was to predict the listings with high booking rates, the evaluation metric we focused on was accuracy, which is the ratio of total correctly predicted to the total actual values. As we can see in the table below, XGBoost model produced the highest accuracy, followed by Random Forest.

<p align="center">
  <img  height="200" src="/Table.PNG">
</p>
  
We chose XGBoost to be our final model primarily because it gave us the best accuracy out of all the models we tested. Additionally, the XGBoost model provides feature importance of all the features which is very useful to answer feature importance questions. It also provides a better tree structure compared to all other tree based ensemble methods. XGBoost also includes an extra randomization parameter, i.e. column subsampling, which helps to reduce the correlation of each tree even further. The XGBoost model also performs automatic feature selection and captures high-order interactions without breaking down. After understanding all the advantages of using the XGBoost model, we finally chose it to be our final model.

As seen from the relative feature importance plot , longitude and latitude are the most important features which we too had assumed during the exploratory data analysis because the geographical location of the rental is very important to predict whether it will have a high booking rate or not. Surprisingly, the number of bedrooms, bathrooms and type of room do not appear to be very important contrary to what we had assumed earlier.

**Feature Importance**
<p align="center">
  <img  height="500" src="/FeatureImp.PNG">
</p>


## Conclusion:

**So, what is the business value of predicting high booking rate listings?**

Our XGBoost model helps determine whether the host’s listings are predicted to have a high booking rate, as well as suggest which features the host can improve to reach a high booking rate. For example, we can advise the host that responding to potential clients in an hour instead of a few hours will boost the likelihood of having a high booking rate. Overall, we would also advise to increase the days prior to the booking date that the property is available to rent, to respond to as many potential customers as quickly as possible, and have positive interactions with potential clients. Based on the results and findings, the host can decide to sell the listing, rent out the listing to a potential tenant, remove the listing, switch to a competitor of Airbnb to list the same listing or reach out to Airbnb to help promote the listing for a small fee. 

From the perspective of Airbnb, it helps them get an idea of how their listings are affected given the various features and what demand may look like for certain types of listings, which they can use to target the listings that are not popular by promotion.

## Libraries:
R: dplyr, tidyr, ggplot2

## License:
```
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
