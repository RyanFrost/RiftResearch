rm(list=ls())
library(data.table)
library(tidyr)
library(dplyr)
library(ggplot2)
library(pspline)

dat <- fread("erinData3_22_15.txt")
dat[,V54:=NULL]
setnames(dat, c(
"motorv_int",
"lcR_lbs",
"lcL_lbs",
"time",
"tspeed_desired",
"xd_raw",
"xact",
"perturb",
"angle_enc",
"Kd",
"Kact",
"Fb_raw",
"elapsed",
"numEMG",
"cycle",
"time_vst_absolute",
"zero_time_absolute",
"hip_left",
"knee_left",
"ankle_left",
"hip_right",
"knee_right",
"ankle_right",
"xf",
"movingBackward",
"movingForward",
"distance",
"currentPatch",
"patchType",
"marker_x_l_1",
"marker_x_l_2",
"marker_x_l_3",
"marker_x_l_4",
"marker_x_l_5",
"marker_x_l_6",
"marker_y_l_1",
"marker_y_l_2",
"marker_y_l_3",
"marker_y_l_4",
"marker_y_l_5",
"marker_y_l_6",
"marker_x_r_1",
"marker_x_r_2",
"marker_x_r_3",
"marker_x_r_4",
"marker_x_r_5",
"marker_x_r_6",
"marker_y_r_1",
"marker_y_r_2",
"marker_y_r_3",
"marker_y_r_4",
"marker_y_r_5",
"marker_y_r_6"))

dat[,motorv_int:=NULL]
dat[,numEMG := NULL]
dat[,xd_raw := NULL]
dat[,angle_enc:=NULL]
dat[,Fb_raw:=NULL]
dat[,xact:=NULL]
dat[,Kd:=NULL]
dat[,Kact:=NULL]
dat[,elapsed:=NULL]
dat[,distance:=NULL]

dat3 <- dat %>% gather(jointleg,angle,c(hip_left,
                                   knee_left,
                                   ankle_left,
                                   hip_right,
                                   knee_right,
                                   ankle_right)) %>%
    separate(jointleg,c("joint","leg"),sep="_")

dat[,xfr:=(marker_y_r_6+marker_y_r_5)/2]


dat[,time:=time_vst_absolute-dat$time_vst_absolute[1]]

heelstrike <- c(0,diff(dat$movingForward))
heelstrike[heelstrike==1] <- 0

dat[,cycle:=cumsum(-heelstrike)]

dat[,perturb:= as.integer(median(perturb)),by=cycle]
dat2<-dat
dat2[,time:=time-min(time),by=cycle]

myfunc <- function(x,y,sequence)
{
    
    y=spline(x=x,y=y,xout=sequence,method="natural")$y
    list(y=y,x=sequence)#,y2=predict(sm.spline(sequence,y), sequence, 1))
}



splines <- dat2[tspeed_desired==700,
                list(cycle,
                     perturb,
                     time,
                     xf,xfr)][,myfunc(time,
                                  xfr,
                                  seq(0,max(time),length.out=1000)),by=list(cycle,perturb)]
splines[,pgc:=seq(0,100,length.out=1000)]


avgs <- splines[,list(mn=mean(y),std=sd(y)),by=list(pgc,perturb)]
#tts <- t.test()
xfmax <- dat[,max(xf),by=perturb]
#dat <- dat[xf>(-10000)][tspeed_desired==700]

#avgs[,stdDiff:=]

print(summary(avgs))



p <- ggplot(avgs,aes(x=pgc,y=mn,colour=factor(perturb))) +
    geom_line() +
    geom_ribbon(data=avgs[perturb==1],aes(ymin=mn-std,ymax=mn+std,fill=factor(perturb)),alpha=0.3,colour=NA)




print(p)