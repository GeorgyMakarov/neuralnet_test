# This shows how subsampling helps in solving class imbalance issue
# Link: https://topepo.github.io/caret/subsampling-for-class-imbalances.html

library(caret)

# Simulate training and test datasets, where minority class is of about 5.9%
set.seed(2969)
imb_train <- twoClassSim(1e4, intercept = -20, linearVars = 20)
imb_test  <- twoClassSim(1e4, intercept = -20, linearVars = 20)
table(imb_train$Class)


# Apply three methods of class imbalance subsampling. We obtain all three ways
# in order to compare how each method works.
set.seed(9560)
down_train <- downSample(x = imb_train[, -ncol(imb_train)],
                         y = imb_train$Class)
table(down_train$Class)

set.seed(9560)
up_train <- upSample(x = imb_train[, -ncol(imb_train)],
                     y = imb_train$Class)
table(up_train$Class)

set.seed(9560)
rose_train <- ROSE::ROSE(Class ~., data = imb_train)$data
table(rose_train$Class)


# Make classification models which compare different results
all_control <- trainControl(method          = "repeatedcv",
                            repeats         = 5,
                            classProbs      = T,
                            summaryFunction = twoClassSummary,
                            sampling        = "down")
