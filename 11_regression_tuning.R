# This shows how to use neuralnet package to predict car prices
# Link to data: https://topepo.github.io/caret/data-sets.html#kelly-blue-book

library(dplyr)
library(caret)
library(neuralnet)


# Prepare the data prior to model training. I want all the column names to be
# consistent across the dataset, so I don't have to remember which columns start
# from capital letters and which don't. 
data(cars)
colnames(cars) <- tolower(colnames(cars))


# Identifying near-zero variables and excluding them from the data helps us to
# prevent model crash and makes the fit more stable.
near_zero_vars <- nearZeroVar(cars, saveMetrics = T)


# A model can benefit from removing correlated predictors. Our dataset has
# 16 factor variables. This is why we can't use the standard cor function to
# identify correlation. Instead we can use the Uncertainty coefficient for 
# finding correlation between factors variables. The lower the U coefficient
# the higher is the correlation between the variables -- low entropy means
# strong correlation.
temp_fact <- as.data.frame(t(combn(colnames(cars)[3:18], 2)))
colnames(temp_fact) <- c("f1", "f2")
temp_vect <- c()

for (i in 1:nrow(temp_fact)) {
  tbl <- table(cars[, temp_fact$f1[i]], cars[, temp_fact$f2[i]])
  out <- DescTools::UncertCoef(tbl, direction = "column")
  temp_vect <- c(temp_vect, out)
  rm(i, tbl, out)
}

temp_vect       <- round(temp_vect, 2)
temp_fact$ucoef <- temp_vect
temp_fact       <- temp_fact %>% filter(ucoef == 0.00)
temp_fact       <- unique(c(unique(temp_fact$f1), unique(temp_fact$f2)))
del_columns     <- c('cruise', 'coupe', 'wagon', 'sound', 'buick', 
                     'convertible', 'sedan', 'leather', 'pontiac', 
                     'saturn', 'saab')
cars <- cars %>% select(-del_columns)
rm(temp_vect, temp_fact, del_columns)


# Split the data into training and testing sets as 80/20.
set.seed(5627)
index    <- createDataPartition(y = cars$price, p = 0.8, list = F)
training <- cars[index, ]
testing  <- cars[-index,]


# Neuralnet requires data preprocessing -- center & scale. We use built in
# caret function to preprocess the data.
pre_proc_vals <- preProcess(training, method = c("center", "scale"))
train_transf  <- predict(pre_proc_vals, training)
test_trsanf   <- predict(pre_proc_vals, testing)

train_x <- train_transf[, 2:7]
train_y <- train_transf$price
test_x  <- test_trsanf[, 2:7]
test_y  <- test_trsanf$price


# Setup a base model -- the simplest model possible is linear regression
# model. I want to compare it to tuned neuralnet regression with different
# tuning parameters.
base_model <- lm(formula = price ~ ., data = train_transf)
summary(base_model)$r.squared


# Train a model using adaptive resampling. Start with adjusting the learning
# rate. Try to use softplus activation function instead of ReLU -- neuralnet
# does not recognize ReLU, and will not work with max(k, 0). Softplus is a
# smooth approximation of ReLU.
softplus   <- function(x){log(1 + exp(x))}
adapt_ctrl <- trainControl(method   = "adaptive_cv",
                           number   = 10,
                           repeats  = 10,
                           adaptive = list(min = 5,
                                           alpha = 0.05,
                                           method = "gls",
                                           complete = F),
                           search   = "random")
set.seed(5627)
cars_fit <- train(train_x, train_y,
                  method    = "neuralnet",
                  trControl = adapt_ctrl,
                  tuneGrid  = data.frame(layer1 = 2:3, layer2 = 0, layer3 = 0),
                  learningrate = 0.20,
                  act.fct      = softplus,
                  threshold    = 0.1,
                  stepmax      = 1e+05)
cars_fit$bestTune
cars_fit$finalModel$param
cars_fit


# `Neuralnet` by default uses `rprop+` algorithm for backpropagation. This
# algorithm's tuning parameters are learning rate limit and learning rate
# factor. We perform full grid search to setup learning rate parameters. Here
# the recommendation is to not use too high min learning rate limit, as this
# might stop model training.
# learning rate limit  [1e-10; 0.1] -> [1e-08; 0.3]
# learning rate factor [0.5; 1.2]   -> [0.5; 1.2]  
# This allows the R squared to go up from 0.76 to 0.78
lr_tuning <- expand.grid(lrr_min = c(1e-10, 1e-09, 1e-08, 1e-07, 1e-06, 1e-05),
                         lrr_max = c(0.1, 0.2, 0.3, 0.4))
rsq_vect <- data.frame()

for (i in seq(nrow(lr_tuning))){
  
  lr_min <- lr_tuning$lrr_min[i]
  lr_max <- lr_tuning$lrr_max[i]
  
  set.seed(5627)
  temp_fit <- neuralnet(formula      = price ~ .,
                        data         = train_transf,
                        rep          = 1,
                        hidden       = 6,
                        threshold    = 0.1,
                        algorithm    = "rprop+",
                        learningrate.limit  = list(min   = lr_min, 
                                                   max   = lr_max),
                        learningrate.factor = list(minus = 0.5,   
                                                   plus  = 1.2),
                        act.fct      = softplus,
                        err.fct      = "sse",
                        stepmax      = 1e+06)
  
  temp_pred <- as.vector(temp_fit$net.result[[1]])
  temp_obs  <- train_transf$price
  rsq       <- cor(temp_pred, temp_obs) ^ 2
  out_df    <- data.frame(lr_min, lr_max, rsq)
  
  rsq_vect  <- rbind(rsq_vect, out_df)
  rm(i, lr_min, lr_max, temp_fit, temp_pred, temp_obs, rsq, out_df)
}

rsq_vect


# Train a model with modified learning rate and search through the grid of
# different layers combinations. Use adaptive resampling technique to find
# the best model. To ensure that the model will converge -- increase the step
# to 1e+07.
tune_grd  <- expand.grid(.layer1 = c(3:6), .layer2 = c(0:3), .layer3 = c(0:3))
set.seed(5627)

cars_fit <- train(train_x, train_y,
                  method              = "neuralnet",
                  trControl           = adapt_ctrl,
                  tuneGrid            = tune_grd,
                  learningrate.limit  = list(min   = 1e-08, max  = 0.3),
                  learningrate.factor = list(minus = 0.5,   plus = 1.2),
                  act.fct             = softplus,
                  rep                 = 1,
                  algorithm           = "rprop+",
                  err.fct             = "sse",
                  threshold           = 0.1,
                  stepmax             = 1e+06)