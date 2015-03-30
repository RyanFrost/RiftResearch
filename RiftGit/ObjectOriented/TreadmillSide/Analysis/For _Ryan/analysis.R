rm(list=ls())
library(data.table)
library(ggplot2)

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
"joint_angles1",
"joint_angles2",
"joint_angles3",
"joint_angles4",
"joint_angles5",
"joint_angles6",
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

dat[,time:=time_vst_absolute-dat$time_vst_absolute[1]]

heelstrike <- c(0,diff(dat$movingForward))
heelstrike[heelstrike==1] <- 0

dat[,cycle:=cumsum(-heelstrike)]

dat[,perturb:=as.integer(median(perturb)),by=cycle]


splines <- dat[,spline(x=time,y=xf,xmin=0,xmax=100,n=1000),by=list(cycle)]

avgs <- splines[,list(mean(y),sd(y)),by=list(x)]

xfmax <- dat[,max(xf),by=perturb]
dat <- dat[xf>(-10000)][tspeed_desired==700]
p <-ggplot(dat[cycle%in%c(630)],aes(x=time,y=xf)) +
    geom_point(aes(colour=factor(perturb)))

p2 <- ggplot(splines) +
    geom_boxplot(aes(x=x,y=y,colour=perturb))

print(p2)