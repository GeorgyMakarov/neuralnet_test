library(mlbench)
library(deepnet)
data("BreastCancer")
bc <- BreastCancer[which(complete.cases(BreastCancer) == TRUE), ]
head(bc)


# Create a set of independent variables and a dependent variable. Conversion
# to matrix is a requirement from `deepnet` package
y <- as.matrix(bc[, 11])
y[which(y == "benign")]    <- 0
y[which(y == "malignant")] <- 1
y <- as.numeric(y)

x <- as.numeric(as.matrix(bc[, 2:10]))
x <- matrix(as.numeric(x), ncol = 9)


# Train a neural net. Set number of nodes in a hidden layer to 5. There is no
# any specific requirement to choose 5, so you can try with any number of nodes.
nn    <- nn.train(x, y, hidden = c(5))
y_hat <- nn.predict(nn, x)
print(head(y_hat))


# Convert class 1 probabilities into classes. For the purpose of this script
# we decide on positive class if the probability is greater than the mean.
yhat <- matrix(0, length(y_hat), 1)
yhat[which(y_hat > mean(y_hat))]  <- 1
yhat[which(y_hat < mean(y_hat))]  <- 0
cm <- table(y, yhat)


# Compute accuracy of a NN
print(sum(diag(cm)) / sum(cm))



# Neuralnet package -------------------------------------------------------

library(neuralnet)
df = data.frame(cbind(x,y))
nn = neuralnet(y~V1+V2+V3+V4+V5+V6+V7+V8+V9,data=df,hidden = 5)
yy = nn$net.result[[1]]
yhat = matrix(0,length(y),1)
yhat[which(yy > mean(yy))] = 1
yhat[which(yy <= mean(yy))] = 0
print(table(y,yhat))
