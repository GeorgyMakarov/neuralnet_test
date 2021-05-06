# Predict digits using NN and H2O package
# Link:  https://koalaverse.github.io/machine-learning-in-R/deep-neural-networks.html
# Train: https://h2o-public-test-data.s3.amazonaws.com/bigdata/laptop/mnist/train.csv.gz
# Test:  https://h2o-public-test-data.s3.amazonaws.com/bigdata/laptop/mnist/test.csv.gz

suppressPackageStartupMessages(library(dplyr))
suppressPackageStartupMessages(library(h2o))

h2o.init(nthreads = -1)
train = h2o.importFile("datasets/train.csv.gz")



