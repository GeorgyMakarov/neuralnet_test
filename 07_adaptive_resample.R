# This illustrates how adaptive resampling helps to find the best set of
# tuning parameters.
# Link: https://topepo.github.io/caret/adaptive-resampling.html

library(mlbench)
library(caret)

data("Sonar")
set.seed(998)
index    <- createDataPartition(Sonar$Class, p = 0.75, list = FALSE)
training <- Sonar[index,]
testing  <- Sonar[-index,]


# Random search -----------------------------------------------------------

# Tune an SVM model using random search
svm_control <- trainControl(method          = "repeatedcv",
                            number          = 10,
                            repeats         = 10,
                            classProbs      = T,
                            summaryFunction = twoClassSummary,
                            search          = "random")

set.seed(825)
svm_fit <- train(Class ~.,
                 data       = training,
                 method     = "svmRadial",
                 trControl  = svm_control,
                 preProc    = c("center", "scale"),
                 metric     = "ROC",
                 tuneLength = 15)

# Using this method the best tuning parameters are sigma 0.03 and cost 9.09
svm_fit$bestTune


# Adaptive resampling -----------------------------------------------------

# Tune parameters for adaptive resampling
adapt_control <- trainControl(method   = "adaptive_cv",
                              number   = 10,
                              repeats  = 10,
                              adaptive = list(min = 5,
                                              alpha = 0.05,
                                              method = "gls",
                                              complete = T),
                              classProbs      = T,
                              summaryFunction = twoClassSummary,
                              search          = "random")
set.seed(825)
svm_adapt <- train(Class ~.,
                   data       = training,
                   method     = "svmRadial",
                   trControl  = adapt_control,
                   preProc    = c("center", "scale"),
                   metric     = "ROC",
                   tuneLength = 15)


# Adaptive resampling acheived sigma of 0.03 and cost of 9.09. It used less time
# than the random search.
svm_adapt$bestTune