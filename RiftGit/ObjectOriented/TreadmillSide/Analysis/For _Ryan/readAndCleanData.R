setwd(dirname(parent.frame(2)$ofile))
rm(list=ls())
library(data.table)
library(tidyr)
library(dplyr)
library(ggplot2)

gaitData <- fread("erinData3_22_15.txt")
gaitData[,V54:=NULL]
setnames(gaitData, c(
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


# Remove unneeded columns

gaitData[,motorv_int:=NULL]
gaitData[,numEMG := NULL]
gaitData[,xd_raw := NULL]
gaitData[,angle_enc:=NULL]
gaitData[,Fb_raw:=NULL]
gaitData[,xact:=NULL]
gaitData[,Kd:=NULL]
gaitData[,Kact:=NULL]
gaitData[,elapsed:=NULL]
gaitData[,distance:=NULL]

# Add column for right foot position
gaitData[,xfr:=(marker_x_r_5+marker_x_r_6)/2]

