
df = read.csv("data.csv")

#interpolation of highschool education data for 2020
for (state in unique(df$State)){
  mean_highschool_state <- mean(df$'High.school.education'[df$State == state & (df$Year == 2019 | df$Year == 2021)], na.rm = TRUE)
  
  # Impute missing values for the current state in the year 2021 with the calculated mean
  df$'High.school.education'[df$State == state & df$Year == 2020] <- mean_highschool_state
}


#boxplots for exploratory data analysis
df2= subset(df, select = -c(Deaths, Population))
df1= subset(df, select = -c(Death_Rate..per.100.000.))
boxplot(df2$Death_Rate..per.100.000.~df2$Year, main="Death Rate vs Year", xlab="Year", ylab="Death Rate")
boxplot(df2$Death_Rate..per.100.000.~df2$Registered_Firearms, main="Deaths per 100k vs Registered Firearms", xlab="Registered Firearms", ylab="Death Rate")
boxplot(df2$Death_Rate..per.100.000.~df2$Median_Income, main="Deaths per 100k vs Median Income", xlab="Median Income", ylab="Death Rate")
boxplot(df2$Death_Rate..per.100.000.~df2$Type, main="Title", xlab="Red/Blue state", ylab="Death Rate")

df2$Year <- df2$Year - min(df2$Year)

#scatterplot
plot(subset(df2, select = -c(Year, State, Type)))
df2

#Full model for comparision
model = lm(df2$Death_Rate..per.100.000. ~ df2$Year+factor(df2$Type)+df2$Registered_Firearms+df2$Median_Income+df2$Mental_Health_Issues+df2$Unemployment_Rates+df2$Median.Age+df2$Literacy_Rate+df2$Conviction.Rates+df2$High.school.education)
summary(model)
anova(model)

#goodness of fit (full model)
fit = model$fitted
library('car')
residuals = rstandard(model)
cook = cooks.distance(model)
par(mfrow=c(2,2))
plot(fit, residuals, xlab="Residuals", ylab = "Fitted Values")
abline(0,0,col='red')
qqPlot(residuals, ylab="Residuals", main="")
hist(residuals, xlab="Residuals", nclass=10, col='navy')
plot(cook, type='h', lwd=3, col='red', ylab="Cook's distance")

#Base model
model = lm(df2$Death_Rate..per.100.000. ~ df2$Year+factor(df2$Type)+df2$Registered_Firearms+df2$Median_Income)
summary(model)
anova(model)

fit = model$fitted
library('car')
residuals = rstandard(model)
cook = cooks.distance(model)
par(mfrow=c(2,2))
plot(fit, residuals, xlab="Residuals", ylab = "Fitted Values")
abline(0,0,col='red')
qqPlot(residuals, ylab="Residuals", main="")
hist(residuals, xlab="Residuals", nclass=10, col='navy')
plot(cook, type='h', lwd=3, col='red', ylab="Cook's distance")

##Forward Stepwise Regression
scope = list(lower=df2$Death_Rate..per.100.000. ~ 1, upper = df2$Death_Rate..per.100.000. ~ df2$Year+factor(df2$Type)+df2$Registered_Firearms+df2$Median_Income+df2$Mental_Health_Issues+df2$Unemployment_Rates+df2$Median.Age+df2$Literacy_Rate+df2$Conviction.Rates+df2$High.school.education+I(df2$Unemployment_Rates^2)+I(df2$Literacy_Rate^2)+I(df2$Median_Income^2))
step(lm(df2$Death_Rate..per.100.000. ~ 1), scope=scope,direction='forward')

#Optimal model according to forward step
model= lm(df2$Death_Rate..per.100.000. ~ factor(df2$Type) + 
            df2$Median_Income + df2$Year + df2$Registered_Firearms + 
            df2$Unemployment_Rates + df2$Mental_Health_Issues + df2$Median.Age + 
            df2$High.school.education+I(df2$Median_Income^2)+I(df2$Unemployment_Rates^2)+I(df2$Literacy_Rate^2))
summary(model)
anova(model)

fit = model$fitted
library('car')
residuals = rstandard(model)
cook = cooks.distance(model)
par(mfrow=c(2,2))
plot(fit, residuals, xlab="Residuals", ylab = "Fitted Values")
abline(0,0,col='red')
qqPlot(residuals, ylab="Residuals", main="")
hist(residuals, xlab="Residuals", nclass=10, col='navy')
plot(cook, type='h', lwd=3, col='red', ylab="Cook's distance")

#Removal of outliers based on cook's distance
df2 = df2[which(cook <= 4/350 & abs(residuals) <= 2),]

model= lm(df2$Death_Rate..per.100.000. ~ factor(df2$Type) + 
            df2$Median_Income + df2$Year + df2$Registered_Firearms + 
            df2$Unemployment_Rates + df2$Mental_Health_Issues + df2$Median.Age + 
            df2$High.school.education+I(df2$Median_Income^2)+I(df2$Unemployment_Rates^2)+I(df2$Literacy_Rate^2))
summary(model)
anova(model)

#Goodness of fit(Final Optimal Model)
fit = model$fitted
library('car')
residuals = rstandard(model)
cook = cooks.distance(model)
par(mfrow=c(2,2))
plot(fit, residuals, xlab="Residuals", ylab = "Fitted Values")
abline(0,0,col='red')
qqPlot(residuals, ylab="Residuals", main="")
hist(residuals, xlab="Residuals", nclass=10, col='navy')
plot(cook, type='h', lwd=3, col='red', ylab="Cook's distance")






#Analysis of mental health variable (testing if the estimator is significant on a yearly basis)
new_model_2016 <- lm(Death_Rate..per.100.000. ~ factor(Type) + Median_Income + 
                       Registered_Firearms + Unemployment_Rates + 
                       Mental_Health_Issues + Median.Age + High.school.education, 
                     data = subset(df2_no_outliers, Year == 2019)) #chage year parameter here to check for each year

summary(new_model_2016)


# Diagnostic plots for the new model
fit_new_model_2016 <- new_model_2016$fitted
residuals_new_model_2016 <- rstandard(new_model_2016)
cook_new_model_2016 <- cooks.distance(new_model_2016)

par(mfrow=c(2,2))
plot(fit_new_model_2016, residuals_new_model_2016, xlab="Residuals", ylab="Fitted Values")
abline(0, 0, col='red')
qqPlot(residuals_new_model_2016, ylab="Residuals", main="")
hist(residuals_new_model_2016, xlab="Residuals", nclass=10, col='navy')
plot(cook_new_model_2016, type='h', lwd=3, col='red', ylab="Cook's distance")






