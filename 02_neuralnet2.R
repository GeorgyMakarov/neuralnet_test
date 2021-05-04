library(MASS)
library(dplyr)
library(caret)
library(neuralnet)

mydata = Boston


# Check that no data is missing
apply(X = mydata, MARGIN = 2, FUN =function(x){sum(is.na(x))})

# Sample the data
set.seed(500)
index    = sample(x = 1:nrow(mydata), size = round(0.75*nrow(mydata)))
training = mydata[index, ]
testing  = mydata[-index, ]


# Fit a simple linear regression model as a base for the reference
model_lm = glm(medv ~., data = training)
summary(model_lm)
pred_lm  = predict(model_lm, newdata = testing)
mse_lm   = sum((pred_lm - testing$medv)^2 / nrow(testing))


# Normalize the data before training a neural network. Missing this step
# can lead to useless results or to hard tuning process.
maxs   = apply(mydata, 2, max)
mins   = apply(mydata, 2, min)
scaled = as.data.frame(scale(mydata, center = mins, scale = maxs - mins))
train_scaled = scaled[index, ]
test_scaled  = scaled[-index, ]


# Choose the params
# One or two hidden layers is enough for many applications
# Number of neurons should be between the size of the input layer and the size
# of the output layer -- usually 2/3 of the input size
n  = names(train_scaled)
nn = neuralnet(medv ~., 
               data          = train_scaled, 
               hidden        = c(5, 3), 
               linear.output = T)


# Make predictions on the test set
# Convert scaled data to original format
pred = predict(nn, newdata = test_scaled)
pred = pred * (max(mydata$medv) - min(mydata$medv)) + min(mydata$medv)
test = 
    (test_scaled$medv) * (max(mydata$medv) - min(mydata$medv)) + 
    min(mydata$medv)
mse_nn = sum((pred - test)^2) / nrow(test_scaled)


# Make a plot to compare lm and nn performance
plot(x     = testing$medv,
     y     = pred,
     col   = 'red',
     frame = F,
     main  = 'Real vs prediction',
     pch   = 18,
     cex   = 0.7)
points(x   = testing$medv,
       y   = pred_lm,
       col = 'blue',
       pch = 18,
       cex = 0.7)
abline(0, 1, lwd = 1.5)


# Make cross validation of the model
set.seed(450)
cv_error = NULL
k        = 10

for (i in 1:k){
    index    = sample(1:nrow(mydata), round(0.75*nrow(mydata)))
    train_cv = scaled[index, ]
    test_cv  = scaled[-index, ]
    model_nn = neuralnet(medv ~., 
                         data          = train_cv, 
                         hidden        = c(5, 3),
                         linear.output = T)
    pred_nn = predict(model_nn, newdata = test_cv)
    pred_nn = pred_nn * (max(mydata$medv) - min(mydata$medv)) + min(mydata$medv)
    test    = 
        (test_cv$medv) * (max(mydata$medv) - min(mydata$medv)) + 
        min(mydata$medv)
    mse_cv  = sum((pred_nn - test)^2) / nrow(test_cv)
    cv_error[i] = mse_cv
}

mean(cv_error)
cv_error

