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

set.seed(5627)
orig_fit <- train(Class ~.,
                  data      = imb_train,
                  method    = "treebag",
                  nbagg     = 50,
                  metric    = "ROC",
                  trControl = all_control)

set.seed(5627)
down_outside <- train(Class ~ ., 
                      data      = down_train, 
                      method    = "treebag",
                      nbagg     = 50,
                      metric    = "ROC",
                      trControl = all_control)

set.seed(5627)
up_outside <- train(Class ~ ., 
                    data      = up_train, 
                    method    = "treebag",
                    nbagg     = 50,
                    metric    = "ROC",
                    trControl = all_control)

set.seed(5627)
rose_outside <- train(Class ~ ., 
                      data      = rose_train, 
                      method    = "treebag",
                      nbagg     = 50,
                      metric    = "ROC",
                      trControl = all_control)


# Create a wrapper that compares the model results
list_of_models <- list(orig = orig_fit,
                       down = down_outside,
                       up   = up_outside,
                       rose = rose_outside)

mods_resampling <- resamples(list_of_models)
test_roc        <- function(model, data){
  library(pROC)
  roc_obj <- roc(data$Class,
                 predict(model, data, type = "prob")[, "Class1"], 
                 levels = c("Class2", "Class1"))
  ci(roc_obj)
}


# Check models performance using the wrapper and test set
outside_test <- lapply(list_of_models, test_roc, data = imb_test)
outside_test <- lapply(outside_test, as.vector)
outside_test <- do.call("rbind", outside_test)
colnames(outside_test) <- c("lower", "ROC", "upper")
outside_test <- as.data.frame(outside_test)


# Comparison of models' performance in training and testing sets shows that
# up-sampling leads to overfitting the model. ROSE sampling has the lowest
# performance on the training set, but that means that all possible combinations
# of variables were sampled -- this is proved by the best performance on the
# test set.
summary(mods_resampling, metric = "ROC")
outside_test
