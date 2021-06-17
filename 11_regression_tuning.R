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


# Seq along the vector of learning rates and try a combination of different
# layers setups in order to achieve the optimal parameters. Compare results by
# R squared. I only choose the to tune the learning rate first.
lrn_rates <- c(0.25, 0.20, 0.15, 0.10, 0.05, 0.01)
tune_grd  <- expand.grid(.layer1 = c(1:4), .layer2 = c(0:4), .layer3 = c(0:4))
rsq_fit   <- data.frame()

for (i in seq_along(lrn_rates)){
  lr <- lrn_rates[i]
  
  set.seed(5627)
  
  cars_fit <- train(train_x, train_y,
                    method       = "neuralnet",
                    trControl    = adapt_ctrl,
                    tuneGrid     = tune_grd,
                    learningrate = lr,
                    act.fct      = softplus,
                    threshold    = 0.1,
                    stepmax      = 1e+05)
  
  tune_value <- cars_fit$finalModel$tuneValue
  lr_out     <- cars_fit$finalModel$param$learningrate
  rsq_out    <- max(cars_fit$results$Rsquared)
  out_df     <- data.frame(tune_value)
  out_df$lr  <- round(lr_out, 2)
  out_df$rsq <- rsq_out
  rsq_fit    <- rbind(rsq_fit, out_df)
  
  rm(i, lr, cars_fit, tune_value, lr_out, rsq_out, out_df)
}

rsq_fit
