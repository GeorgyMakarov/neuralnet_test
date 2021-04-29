# Predict if a client subscribes a term deposit 
# Link: http://www.learnbymarketing.com/tutorials/neural-networks-in-r-tutorial/
# Data: http://archive.ics.uci.edu/ml/datasets/Bank+Marketing

suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(caret))
suppressPackageStartupMessages(library(neuralnet))

mydata = data.table::fread("bank.csv", stringsAsFactors = T)
mydata = as.data.frame(mydata)


# Dataset explanation prescribes to not use duration as a variable as this
# is going to ruin the idea of the modeling, becuase we know the outcome of
# a call from its duration.
mydata = mydata %>% select(-duration)


# Split numeric and factor variables. This approach helps to scale the numeric
# variables and convert factors to dummy variables.
data_num = 
    mydata %>% 
    select(age, campaign, pdays, previous, emp.var.rate, cons.price.idx,
           cons.conf.idx, euribor3m, nr.employed)

f_cols  = setdiff(colnames(mydata), colnames(data_num))
data_fc = mydata %>% select(f_cols)
rm(f_cols)


# Scale numeric variables. Use max - min method because it is easy to go back
# to original data if you need it.
maxs   = apply(data_num, 2, max)
mins   = apply(data_num, 2, min)
data_num = as.data.frame(scale(x      = data_num, 
                               center = mins, 
                               scale  = maxs - mins))
data_num$resp = data_fc$y
rm(maxs, mins)

# Select numeric variables that correspond to classification problem. Select
# variables that have significant differencies by class.
data_num %>% 
    group_by(resp) %>% 
    summarise(age = mean(age),
              camp = mean(campaign),
              pdays = mean(pdays),
              prev = mean(previous),
              empv = mean(emp.var.rate),
              cpi  = mean(cons.price.idx),
              cci  = mean(cons.conf.idx),
              eur  = mean(euribor3m),
              empl = mean(nr.employed))

data_num = 
    data_num %>% 
    select(pdays, emp.var.rate, cons.price.idx, euribor3m, nr.employed)


# Select factors that help split the classes



# Convert factor variables to one hot encoding variables using `caret` package.
# Do not convert the response variable -- keep it separately.
resp_y  = data_fc$y
data_fc = data_fc %>% select(-y)
dummies = dummyVars(formula = ~., data = data_fc)
dummies = as.data.frame(predict(dummies, newdata = data_fc))


# Make new dataset with from response, numeric and dummy variables
mydata = cbind(resp_y, data_num, dummies)
rm(data_fc, data_num, dummies, resp_y)


# Check if column names contain signs not appropriate for use in `R` -- such
# may be '-' sign. It is better to stick with traditional conventions and also
# change the '.' for the empty space in the name of the columns.
names(mydata) = gsub(x = names(mydata), pattern = "-", replacement = "_")
names(mydata) = gsub(x = names(mydata), pattern = "\\.", replacement = "")


# Convert 'yes' to 1 and 'no' to 0 in order to have numeric response variable
mydata$resp_y = as.numeric(mydata$resp_y)
mydata$resp_y[mydata$resp_y == 1] = 0
mydata$resp_y[mydata$resp_y == 2] = 1


# Split the data to training and testing
set.seed(123)
in_train = createDataPartition(y = mydata$resp_y, p = 0.8, times = 1, list = F)
training = mydata[in_train, ]
testing  = mydata[-in_train, ]
rm(in_train)


# Make a neuralnet with default parameters
# Check the quality of the model on testing set using confusion matrix. We are
# interested in predicting positive cases -- use sensitivity to evaluate the
# result of the model
set.seed(123)
basic_model = neuralnet(formula       = resp_y ~.,
                        data          = training,
                        linear.output = F)

basic_pred = round(predict(basic_model, newdata = testing), 0)
basic_res  = data.frame(obs = testing$resp_y, pred = basic_pred)
basic_res$obs  = factor(ifelse(basic_res$obs == 0, "no", "yes"), 
                        levels = c("yes", "no"))
basic_res$pred = factor(ifelse(basic_res$pred == 0, "no", "yes"), 
                        levels = c("yes", "no"))


# Confusion matrix shows that this basic model is not better than the NIR base
# line in predicting the positive class 'yes'. This is confirmed by p-value
# 0.139 > 0.05 -- the accuracy is by pure chance higher than the NIR. The
# sensitivity of the model is very low 0.49 -- we are correct about our positive
# case less than 50% times.
confusionMatrix(data = basic_res$pred, reference = basic_res$obs)
rm(basic_pred, basic_model)


# Model tuning: basically you can add layers and change number of neurons in
# the model.
set.seed(123)
tuned_model = neuralnet(formula       = resp_y ~.,
                        data          = training,
                        hidden        = c(10, 3),
                        linear.output = FALSE,
                        threshold     = 0.1,
                        stepmax       = 1e6)
tuned_pred = round(predict(tuned_model, newdata = testing))
tuned_res  = data.frame(obs = testing$resp_y, pred = tuned_pred)
tuned_res$obs  = factor(ifelse(tuned_res$obs == 0, "no", "yes"), 
                        levels = c("yes", "no"))
tuned_res$pred = factor(ifelse(tuned_res$pred == 0, "no", "yes"), 
                        levels = c("yes", "no"))


# The matrix shows that the tuned model 
confusionMatrix(data = tuned_res$pred, reference = tuned_res$obs)