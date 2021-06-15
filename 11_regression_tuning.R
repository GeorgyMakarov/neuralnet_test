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

rm(temp_vect)
rm(temp_fact)




# Data preprocessing includes: identifying near-zero variance variables,
# identifying correlated predictors, 
# Split the data into training and testing sets as 80/20.
set.seed(5627)
index <- createDataPartition(y = cars$price, p = 0.8, list = F)

