# Real-World Data Analysis Scenario: Predicting Flight Delays with Data Analytics

## Introduction

A recent example of the importance of data analysis can be found in the aviation industry. In March 2026, a study published in *Case Studies on Transport Policy* examined how flight and weather data could be used to predict delays at Hazrat Shahjalal International Airport in Dhaka, Bangladesh.

Flight delays represent a major operational problem for airlines and airports. They can increase costs, disrupt schedules, create difficulties in resource management and reduce passenger satisfaction. Instead of only reacting to delays once they occur, the researchers investigated whether historical data and predictive analytics could help identify delays in advance and better understand their causes.

## Data Used in the Analysis

The analysis combined two main types of data: historical flight information and weather data.

The flight dataset contained information such as flight dates, flight numbers, destinations, scheduled departure times, actual departure times, arrival times and flight duration. Weather information was then matched with the flight data according to date and time.

In total, the researchers worked with **31,578 flight records** from 2022. After combining the different sources, the dataset contained 41 features. The data then went through a typical data-analysis preprocessing process, including cleaning missing or incorrect values, transforming date and time information, encoding categorical variables and selecting the most useful features. Around 30 features were finally used for the predictive models.

This step is important because the quality of a predictive model strongly depends on the quality and relevance of the data used to train it.

## Methods Used

After preparing the dataset, the researchers compared several machine-learning models to determine which ones were the most effective at predicting flight delays.

The models included K-Nearest Neighbors, Support Vector Machine, Decision Tree, Random Forest, AdaBoost, XGBoost and CatBoost.

The best results came from the ensemble-learning models, particularly **XGBoost and CatBoost, which achieved approximately 95% prediction accuracy**.

However, predicting whether a flight will be delayed was only one part of the analysis. Decision-makers also need to understand *why* a prediction is being made.

For this reason, the researchers also used **LIME (Local Interpretable Model-Agnostic Explanations)**. This explainability technique identifies which variables contribute most strongly to individual predictions. The analysis showed that **weather conditions and scheduling factors were among the most important drivers of flight delays**.

## Impact on Decision-Making

The value of this analysis is not simply that it produces an accurate prediction. The predictions can support real operational decisions.

If airport and airline teams can identify flights that have a high probability of being delayed, they can react earlier. For example, they may adjust schedules, allocate resources differently or prepare operational teams before congestion becomes more serious.

The explainability component is particularly useful because it transforms a prediction into actionable information. Instead of only receiving a result such as “this flight is likely to be delayed,” decision-makers can also understand whether the risk is mainly connected to weather, scheduling or another operational factor.

The researchers concluded that this type of analysis could support better scheduling, improve resource allocation and help airports manage delays more effectively.

## What Would Happen Without Data Analysis?

Without data analysis, airport management would rely much more heavily on reactive decision-making. Teams would recognize problems when delays were already occurring and would have less information available to anticipate them.

Historical flight and weather data would exist, but without cleaning, combining and analyzing it, it would not automatically provide useful insights.

Data analysis therefore changes the approach from:

**“A delay has happened. How should we respond?”**

to:

**“The data indicates that a delay is likely. What can we do before it happens?”**

This illustrates the difference between descriptive and predictive analytics. Descriptive analysis helps explain what has already happened, while predictive analysis uses historical patterns to estimate what is likely to happen in the future.

## Conclusion

This case demonstrates how data analysis can directly support real-world decision-making. By combining more than 31,000 flight records with weather information, preparing the data and applying machine-learning models, researchers were able to predict flight delays with high accuracy.

More importantly, explainable analytics helped identify the factors behind those predictions, making the results more useful for airport and airline decision-makers.

The case shows that the value of data analysis is not simply in collecting large amounts of information. Its real value comes from transforming raw data into insights that can help organizations **anticipate problems, understand their causes and make better decisions**.

### Reference

Chowdhury, F. T., Mahmud, S. Z., Mashruk, S., Basunia, A. T., Hasib, K. M., & Alam, M. S. (2026). *Flight delay prediction using machine learning and explainable AI: A case study on Hazrat Shahjalal International Airport, Dhaka*. Case Studies on Transport Policy, 23, 101663.
