rm(list=ls())
library(data.table)
library(tidyr)
library(dplyr)
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

