# Learning NN basics
# Link: https://rdrr.io/cran/neuralnet/man/neuralnet-package.html

library(dplyr)
library(caret)
library(neuralnet)

# Predict infert case from parity, induced, spontaneous
data("infert")


# Scale the data
# Try different scaling and centering data
mydata = infert %>% select(case, parity, induced, spontaneous)
resval = mydata$case
mydata = as.data.frame(scale(mydata, center = F))
maxs   = apply(mydata, 2, max)
mins   = apply(mydata, 2, min)
mydata = as.data.frame(scale(mydata, center = mins, scale = maxs - mins))
mydata$case = resval


# Split the data into training and testing
set.seed(123)
in_train = createDataPartition(y = mydata$case, p = 0.8, list = F, times = 1)
training = mydata[in_train, ]
testing  = mydata[-in_train, ]

nn = neuralnet(formula       = case ~ parity + induced + spontaneous,
               data          = training,
               linear.output = F,
               threshold     = 0.01)
nn$result.matrix
plot(nn)

pred = round(predict(nn, newdata = testing), 0)
outs = data.frame(obs = testing$case, pred = pred)
outs$obs  = factor(ifelse(outs$obs == 1, "yes", "no"), levels = c("yes", "no"))
outs$pred = factor(ifelse(outs$pred == 1, "yes", "no"), levels = c("yes", "no"))
confusionMatrix(data = outs$pred, reference = outs$obs)
