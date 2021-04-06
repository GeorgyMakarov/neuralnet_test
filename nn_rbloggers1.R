# This follows R-bloggers tutorial that shows the basics of NN
# Link: https://www.r-bloggers.com/2018/10/neuralnet-train-and-test-neural-networks-using-r/
library(dplyr)
library(caret)
library(neuralnet)
setwd("/home/georgy/Документы/GitHub/neuralnet_test/")


# Solve classification problem
# Question: will a stock pay dividends?
mydata = read.csv(file = "dividends.csv")


# Exploratory data analysis
summary(mydata)
apply(X = mydata[, 2:6], 
      MARGIN = 2, 
      FUN = function(x){hist(x)})
apply(X = mydata[, 2:6], 
      MARGIN = 2, 
      FUN = function(x){shapiro.test(x)})
mydata %>% 
    group_by(dividend) %>% 
    summarise(fcfps           = mean(fcfps),
              earnings_growth = mean(earnings_growth),
              de              = mean(de),
              mcap            = mean(mcap),
              current_ratio   = mean(current_ratio))


# Normalize data
# Data normalization is required for NN
# Use two types of normalization: scale function, min-max custom formula
scaled_data = as.data.frame(scale(mydata, center = F))
scaled_data = as.data.frame(lapply(mydata,
                                   FUN = function(x){(x - min(x)) / (max(x) - min(x))}))


# Split the data into training and testing sets
training = scaled_data[1:160,]
testing  = scaled_data[161:200,]


# Build neural net
nn = neuralnet(dividend ~ ., 
               data          = training, 
               hidden        = c(2, 1),
               linear.output = F,
               threshold     = 0.01)
nn$result.matrix
plot(nn)


# Predict results
# Make confusion matrix
pred      = round(predict(nn, newdata = testing), 0)
outs      = data.frame(obs = testing$dividend, pred = pred)
outs$obs  = factor(ifelse(outs$obs == 1, "yes", "no"), levels = c("yes", "no"))
outs$pred = factor(ifelse(outs$pred == 1, "yes", "no"), levels = c("yes", "no"))
confusionMatrix(data = outs$pred, reference = outs$obs)