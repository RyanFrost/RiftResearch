rm(list=ls())
library(data.table)
library(ggplot2)

dat <- fread("jeffTestNew_fail2.txt")

setnames(dat,c("V8","V15","V27","V24","V29","V28","V25","V26"),c("perturb","cycle","distance","xf","type","pnum","back","forward"))

dat[,direction := 4*forward+3*back]

dat[,ind := 1:.N]
perted <- dat[perturb != 0,]

region <- dat[24000:26000,]

p <- ggplot(region) +
  geom_line(aes(x=ind,y=distance,group=1,colour=factor(pnum)),size=1.5) +
  geom_line(aes(x=ind,y=(xf+10)/50,group=1,colour=factor(perturb)),size=1.5) 

print(p)