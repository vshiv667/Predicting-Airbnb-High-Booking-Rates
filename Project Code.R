
#Predicting Airbnb High Booking Rates 
#==========================================================================================
#load necessary libraries

library(ggplot2)
library(dplyr)
library(tidyr)
library(data.table)
library(stringr)
library(randomForest)
library(xgboost)

#read in the data
df <- fread('airbnb_train_x.csv', na.strings="NA")
test <- fread('airbnb_test_x.csv', na.strings = "NA")

df_train_interaction <- fread('Cleaned_train_additional.csv')
df_test_interaction <- fread('Cleaned_test_additional.csv')

# add in the sentiment analysis from separate df
df$Interaction_Sentiment <- df_train_interaction$Interaction_Sentiment
test_Interaction_Sentiment <- df_test_interaction$Interaction_Sentiment

# fn to convert to numeric
ConvertNumeric = function(dfCol, NAValue){
  val <- (gsub("\\$", "", dfCol))
  val <- (gsub("\\%", "", val))
  val <- suppressWarnings(as.numeric(gsub("\\,", "", val)))
  val[is.na(val)] = NAValue
  return(val)
}

# fn to convert to factor
ConvertFactor = function(dfCol, GoodVector, NAValue){
  dfCol = trimws(dfCol)
  dfCol = tolower(dfCol)
  dfCol[!(dfCol %in% GoodVector)] = NAValue
  dfCol = as.factor(dfCol)
  return(dfCol)
}

# fn to clean df
cleanDF = function(df){
  # remove unwanted column, these columns are either not important, redundant, or have more than 40% NA
  df <- select(df,-c('access','description','host_about', 'city_name', 'is_business_travel_ready', 'market', 'weekly_price',
                     'host_name','interaction','country','country_code', 'neighbourhood', 'smart_location', 'host_neighbourhood',
                     'license','name','notes','space','summary', 'host_total_listings_count', 'jurisdiction_names', 'street',
                     'experiences_offered','square_feet','host_acceptance_rate','zipcode','host_location'))
  # accomodates, set na to be the median of train data
  df$accommodates <- ConvertNumeric(df$accommodates, 3)
  # amenities, change to count of amenities
  df$amenities <- str_count(df$amenities, ",")
  # avail_30
  df$availability_30 <- ConvertNumeric(df$availability_30, 8)
  # avail_365
  df$availability_365 <- ConvertNumeric(df$availability_365, 148)
  # avail_60
  df$availability_60 <- ConvertNumeric(df$availability_60, 22)
  # avail_90
  df$availability_90 <- ConvertNumeric(df$availability_60, 41)
  # bathrooms
  df$bathrooms <- ConvertNumeric(df$bathrooms, 1)
  # bed type
  df$bed_type <- ConvertFactor(df$bed_type,c("airbed", 'couch', 'futon', 'pull-out sofa', "real bed"), 'real bed')
  # bedrooms
  df$bedrooms <- ConvertNumeric(df$bedrooms, 1)
  # beds
  df$beds <- ConvertNumeric(df$beds, 1)
  # cancellation policy
  df$cancellation_policy <- ConvertFactor(df$cancellation_policy,c('flexible', 'moderate',
                                                                   'strict', 'super_strict_30', 'super_strict_60'),'flexible')
  # city
  df$city <- ConvertFactor(df$city, c('new york', 'los angeles', 'brooklyn', 'austin', 'washington','new orleans',
                                      'nashville','chicago','san francisco', 'san diego', 'portland','boston','denver','seattle',
                                      'queens'), 'other')
  # cleaning fee
  df$cleaning_fee <- (ConvertNumeric(df$cleaning_fee, 50))
  # extra people
  df$extra_people <- ConvertNumeric(df$extra_people, 9)
  # first review
  df$first_review <- as.numeric(substring(df$first_review, 1,4))
  df$first_review[is.na(df$first_review)] = 2016
  # guest included
  df$guests_included <- ConvertNumeric(df$guests_included, 1)
  df$guests_included[df$guests_included < 0] = 0
  # host has profile pic 
  df$host_has_profile_pic <- ConvertFactor(df$host_has_profile_pic, c('t','f'), 't')
  # host identity verified
  df$host_identity_verified <- ConvertFactor(df$host_identity_verified, c('t','f'), 't')
  # host is super host
  df$host_is_superhost <- ConvertFactor(df$host_is_superhost, c('t','f'), 'f')
  # host listing count
  df$host_listings_count <- ConvertNumeric(df$host_listings_count, 1)
  # host response rate
  df$host_response_rate <- ConvertNumeric(df$host_response_rate, 100)
  # host response time
  df$host_response_time <- ConvertFactor(df$host_response_time, c('a few days or more', 'within a day', 'within a few hours', 'within an hour'), 'within an hour')
  # host since
  df$host_since <- as.numeric(substring(df$host_since, 1, 4))
  df$host_since[is.na(df$host_since)] = 2014
  # count of host verifications
  df$host_verifications <- str_count(df$host_verifications, ",")
  # instant bookable
  df$instant_bookable <- ConvertFactor(df$instant_bookable, c('t','f'), 'f')
  # is location exact
  df$is_location_exact <- ConvertFactor(df$is_location_exact, c('t','f'), 't')
  # latitude
  df$latitude <- ConvertNumeric(df$latitude, 37.96)
  # longitude
  df$longitude <- ConvertNumeric(df$longitude, -87.72)
  # maxmimum nights ( confine between 1 day to 1 year)
  df$maximum_nights <- as.numeric(df$maximum_nights)
  df$maximum_nights[df$maximum_nights < 1] = 1
  df$maximum_nights[df$maximum_nights > 365] = 365
  df$maximum_nights[is.na(df$maximum_nights)] = 365
  # minimum nights (confine between 1 day to half a year)
  df$minimum_nights <- as.numeric(df$minimum_nights)
  df$minimum_nights[df$minimum_nights < 0] = 0
  df$minimum_nights[df$minimum_nights > 180] = 180
  df$minimum_nights[is.na(df$minimum_nights)] = 2
  # monthly price
  df$monthly_price <- ConvertNumeric(df$monthly_price, 2400)
  # true if has a neighborhood overview
  df$neighborhood_overview <- !((df$neighborhood_overview) == "")
  # price
  df$price <- ConvertNumeric(df$price, 110)
  # property Type
  df$property_type <- ConvertFactor(df$property_type, c("apartment", 'house'), 'other')
  # require guest phone verif
  df$require_guest_phone_verification <- ConvertFactor(df$require_guest_phone_verification, c('t','f'), 'f')
  # require guest profile pic
  df$require_guest_profile_picture <- ConvertFactor(df$require_guest_profile_picture, c('t','f'), 'f')
  # requires liscence
  df$requires_license <- ConvertFactor(df$requires_license, c('t','f'), 'f')
  # room type
  df$room_type <- ConvertFactor(df$room_type, c('entire home/apt', 'private room', 'shared room'), 'entire home/apt')
  #smart location
  # dont think this is needed since it is extremely specific
  # state
  df$state <- ConvertFactor(df$state, c('ca','co','dc','il','la','ma','ny','or','tn','tx','wa'), 'other')
  # transit true if something written
  df$transit <- !((df$transit) == "")
  df$transit <- ConvertFactor(df$transit, c('true','false'),'true')
  # house rules true if something written
  df$house_rules <- !((df$house_rules) == "")
  df$house_rules <- ConvertFactor(df$house_rules, c('true','false'),'true')
  # security deposit
  df$security_deposit <- ConvertNumeric(df$security_deposit, 0)
  #Interaction Sentiment (from akshay)
  df$Interaction_Sentiment <- ConvertFactor(df$Interaction_Sentiment, c('negative', 'neutral', 'positive'), 'positive')
  return(df)
}

theCleanDF = cleanDF(df) #cleaned train df
theCleanDF_test = cleanDF(test) #cleaned test df

#==========================================================================================

# save the index columns
trainIndex <- theCleanDF$V1
theCleanDF <- select(theCleanDF, -('V1'))

testIndex <- theCleanDF_test$V1
theCleanDF_test <- select(theCleanDF_test, -('V1'))

#==========================================================================================
# simple Logistic Regression Model (as a baseline)

simpleLog <- glm(clean_train_labels ~., data = clean_train, family = binomial)
probabilities <- simpleLog %>% predict(clean_valid, type = "response")
predicted.classes <- ifelse(probabilities > 0.5, 1, 0)
lr_acc <- sum(ifelse(predicted.classes==clean_valid_labels,1,0))/valid_len
lr_acc #0.7884


#==========================================================================================
# Random Forest model

#Get train labels
train_labels <- fread("airbnb_train_y.csv")
train_labels_hbr = ConvertFactor(train_labels$high_booking_rate, c('0','1'), '0')

#set seed
set.seed(12345) 

#split train : valid - 75 : 25
valid_inst = sample(nrow(theCleanDF),0.25*nrow(theCleanDF))
clean_valid = theCleanDF[valid_inst,]
clean_train = theCleanDF[-valid_inst,]

clean_train_labels = train_labels_hbr[-valid_inst]
clean_valid_labels = train_labels_hbr[valid_inst]

#base model without grid search
rf_model=randomForest(clean_train_labels~.,data = clean_train, ntree=1000, mtry=7,importance=TRUE)

#predict on valid
pred1 = predict(rf_model, newdata = clean_valid)
pred1

#compute valid accuracy
valid_len = nrow(clean_valid) #get len of valid 
rf_acc <- sum(ifelse(pred1==clean_valid_labels,1,0))/valid_len
rf_acc #0.837

#==========================================================================================
# XGBoost Model

# covert to matrix
dttrain = data.matrix(clean_train)
dtvalid = data.matrix(clean_valid)
dttest = data.matrix(theCleanDF_test)

# change to xgb matrix, note labels need to be numeric so we convert back to numeric then subtract 1
dtrain <- xgb.DMatrix(data = dttrain, label = as.numeric(clean_train_labels)-1)
dvalid <- xgb.DMatrix(data = dtvalid, label = as.numeric(clean_valid_labels)-1)
dtest <- xgb.DMatrix(data = dttest)

# make model with hyperparameters
bstair<- xgboost(data=dtrain, max.depth = 14, eta =0.0390,min_child_weight = 2,nthread =8,nrounds = 3000, max_delta_step = 2,
                 colsample_bytree = 0.44, early_stopping_rounds = 400, objective = "binary:logistic",evalmetric = "auc")
pred1_XGB <- predict(bstair, dvalid)


# fn to compute metrics

class_performance <- function(confusion_matrix){
  
  TP <- confusion_matrix[2,2]
  TN <- confusion_matrix[1,1]
  FP <- confusion_matrix[1,2]
  FN <- confusion_matrix[2,1]
  acc <- (TP+TN)/(TP+TN+FP+FN)
  tpr <- TP/(TP+FN)
  tnr <- TN/(TN+FP)
  return(c(acc,tpr,tnr))
}

# fn to compute confusion matrix

confusion_matrix <- function(preds, actuals, cutoff){
  
  classifications <- ifelse(preds>cutoff,1,0)
  
  
  confusion_matrix <- table(actuals,classifications)
}

# after playing around with various cutoff points, it seems that cutoff around .40 maximizes the accuracy on valid
cm1=confusion_matrix(pred1_XGB,as.numeric(clean_valid_labels)-1,.43)
cm1
metrics1=class_performance(cm1)
metrics1 # .8466

predTest_XGB <- predict(bstair, dtest)
classTest_XGB <- ifelse(predTest_XGB > .43, 1, 0)
summary(predTest_XGB > .43)

#==========================================================================================
# save the best models predictions

final_df = data.frame(testIndex, classTest_XGB)
colnames(final_df) <- c('','high_booking_rate')
fwrite(final_df, file = 'submission_bookingrate_Group_5.csv')
