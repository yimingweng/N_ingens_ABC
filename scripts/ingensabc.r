install.packages("abc")
library(abc)
require(abc.data)

setwd("E:/YiMing/ingens_ABC")

indep.sum <- read.table("indep_sum.out", header=F, sep=" ")
indep.prior <- read.table("indep_prior.out", header=F, sep=" ")
admix.sum <- read.table("admix_sum.out", header=F, sep=" ")
admix.prior <- read.table("admix_prior.out", header=F, sep=" ")

f3.obs <- read.table("f3_obs.txt", header=T, sep=" ")
dxy.obs <- read.table("dxy_obs.txt", header=T, sep='\t')

indep
indep.sum['model'] = 'indep'
admix.sum['model'] = 'admix'
all.sum <- rbind(indep.sum, admix.sum)
colnames(all.sum) <- c("f3", "dcs", "dca", "das", "model")

# draw out the distribution of the summary statistics
x11()
boxplot(all.sum$f3 ~ all.sum$model, main="f3")
abline(h=f3.obs[1,1], col="red")

x11()
boxplot(all.sum$dcs ~ all.sum$model, main="f3")
abline(h=dxy.obs[1,1], col="red")

x11()
boxplot(all.sum$dca ~ all.sum$model, main="f3")
abline(h=dxy.obs[1,2], col="red")

x11()
boxplot(all.sum$das ~ all.sum$model, main="f3")
abline(h=dxy.obs[1,3], col="red")

############################## Moldel selection ##########################
# cross validation
cv.modsel <- cv4postpr(all.sum$model, all.sum[,1:4], nval=10, tol=0.01, method="mnlogistic")
s <- summary(cv.modsel)
x11()
plot(cv.modsel, names.arg=c("independent", "admixture"))
# based on the confusion matrix, ABC can disinguish the two model

# posterior of models
target <- data.frame(f3.obs[1,1], dxy.obs[1,1:3])
colnames(target) <- c("f3", "dcs", "dca", "das")
modsel.indep <- postpr(target, all.sum$model, all.sum[,1:4], tol=.05, method="mnlogistic")
summary(modsel.indep)
# the result shows that the admixture is better supported

# Cross-validation to test the accuracy of prediction of summary statistics by the parameters
stat.admix.sim <- subset(all.sum, subset=model=="admix")
colnames(admix.prior) <- c("seed", "Nc", "Ns", "Na", "NE", "t1", "cs", "as", "t2")

# rejection
cv.res.rej <- cv4abc(admix.prior$t2, stat.admix.sim[,1:4], nval=10, tols=c(.005,.01, 0.05), method="rejection")
summary(cv.res.rej)
# Local linear regression
cv.res.reg <- cv4abc(admix.prior$t2, stat.admix.sim[,1:4], nval=10, tols=c(.005,.01, 0.05), method="loclinear")
summary(cv.res.rej)
x11()
par(mfrow=c(1,2), mar=c(5,3,4,2), cex=.8)
plot(cv.res.rej, caption="Rejection")
plot(cv.res.reg, caption="Local linear regression")


############################## goodness of fit ###########################
x11()
gfitpca(target=target, sumstat=all.sum[,1:4], index=all.sum$model, cprob=.1)

########################### Parameter inference ##########################
# t2
res <- abc(target=target, param=admix.prior$t2, stat.admix.sim[,1:4], tol=0.05, transf=c("log"), method="neuralnet")
res
summary(res)
# t1
res <- abc(target=target, param=admix.prior$t1, stat.admix.sim[,1:4], tol=0.05, transf=c("log"), method="neuralnet")
res
summary(res)

# cs
res <- abc(target=target, param=admix.prior$cs, stat.admix.sim[,1:4], tol=0.05, transf=c("log"), method="neuralnet")
res
summary(res)

# NE
res <- abc(target=target, param=admix.prior$NE, stat.admix.sim[,1:4], tol=0.05, transf=c("log"), method="neuralnet")
res
summary(res)

# Nc, Ns, and Na
res <- abc(target=target, param=admix.prior$Na, stat.admix.sim[,1:4], tol=0.05, transf=c("log"), method="neuralnet")
res
summary(res)
