# Predict height from gender exercise
# Link: https://rafalab.github.io/dsbook/introduction-to-machine-learning.html

suppressPackageStartupMessages(library(dslabs))
suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(caret))

data("heights")
y = heights$sex
x = heights$height

set.seed(123)
in_train = createDataPartition(y, times = 1, p = 0.8, list = F)
training = heights[in_train, ]
testing  = heights[-in_train,]


# Check the no information rate. Training set contains 77% males -- if we use
# this as a baseline then we get the 77% correct result. This is the baseline
# for our algorithm.
prop.table(table(training$sex))
prop.table(table(testing$sex))


# Exploration data analysis shows that on average males are slightly higher than
# females. This allows us to think that we can predict gender with height better
# than the baseline.
heights %>% group_by(sex) %>% summarise(h = mean(height), sd = sd(height))


# Simple approach: predict male if height is within two standard deviations from
# the average male's height. This simple models is performing 2% better than the
# NIR baseline.
y_hat = 
    ifelse(x > 62, "Male", "Female") %>% 
    factor(levels = levels(testing$sex))
round(mean(y == y_hat), 2)


# Simple approach: we can specify different cutoff rates to find the best
# performing height value. For this particular example the best cutoff value is
# 65. Note that you have to use training set only to find cutoff value. The new
# cutoff value add another 4% of accuracy improvement to the simple approach.
# Here we measure an accuracy on all `y` values since the proportion of males
# is the same for training and testing sets.
y_hat =
    ifelse(x > 65, "Male", "Female") %>% 
    factor(levels = levels(testing$sex))
round(mean(y == y_hat), 2)


# Create confusion matrix and investigate the number of correctly predicted
# females. This shows that despite overall accuracy being better than the `NIR`
# and the `p-value` showing that this was not acheived by chance but it was a
# result of our model, the model performs poorly in predicting females -- low
# sensitivity value.
y_hat =
    ifelse(testing$height > 65, "Male", "Female") %>% 
    factor(levels = levels(testing$sex))
confusionMatrix(data = y_hat, reference = testing$sex)


# Rebuild the simple model with optimizing the `F-score` instead of overall
# accuracy. This allows to make better predictions on females.



