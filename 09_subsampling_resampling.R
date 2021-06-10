# This shows how to do subsampling inside usual resampliing
# Link: https://topepo.github.io/caret/subsampling-for-class-imbalances.html#resampling

library(dplyr)
library(caret)

set.seed(2969)
imb_train <- twoClassSim(1e4, intercept = -20, linearVars = 20)
imb_test  <- twoClassSim(1e4, intercept = -20, linearVars = 20)

all_ctrl <- trainControl(method          = "repeatedcv",
                         repeats         = 5,
                         classProbs      = T,
                         summaryFunction = twoClassSummary,
                         sampling        = "down")
set.seed(5627)
down_inside <- train(Class ~.,
                     data      = imb_train,
                     method    = "treebag",
                     nbagg     = 50,
                     metric    = "ROC",
                     trControl = all_ctrl)

down_inside$results
