# This shows how to predict cereals rating using neuralnet
# Link: https://www.analyticsvidhya.com/blog/2017/09/creating-visualizing-neural-network-in-r/

library(dplyr)
library(neuralnet)

mydata <- read.csv("00_datasets/cereals.csv", stringsAsFactors = F, header = T)


# Pre-process the data
maxs <- apply(mydata, 2, max)
mins <- apply(mydata, 2, min)
mydata_scaled <- as.data.frame(scale(mydata, 
                                     center = mins, 
                                     scale  = maxs - mins))

# Make training and testing datasets
set.seed(5627)
index  <- sample(seq_len(nrow(mydata)), size = 0.8 * nrow(mydata))  
training <- mydata_scaled[index, ]
testing  <- mydata_scaled[-index, ]


# Train basic neural network ----------------------------------------------

# Fit neuralnet and predict rating for the testing dataset. Note that prediction
# has to be transformed to original values using max-min values.
set.seed(5627)
nn_fit <- neuralnet(formula       = rating ~.,
                    data          = training,
                    hidden        = 3,
                    linear.output = T)

nn_pred  <- as.vector(predict(nn_fit, newdata = testing))
nn_trans <- 
  nn_pred * (max(mydata$rating) - min(mydata$rating)) +
  min(mydata$rating)


# Plot the results and compute RMSE
obs_test <- mydata[-index,]
obs_test <- obs_test$rating
plot(x     = obs_test,
     y     = nn_trans,
     col   = "dodgerblue",
     pch   = 19,
     ylab  = "predicted",
     xlab  = "observed",
     xlim  = c(20, 70),
     ylim  = c(20, 70),
     frame = F)

rmse_res <- (sum((obs_test - nn_trans) ^ 2) / length(nn_trans)) ^ 0.5
rmse_res