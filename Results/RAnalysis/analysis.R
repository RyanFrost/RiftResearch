
if( !exists("gaitData") || !is.data.table(gaitData))
{
  source("readAndCleanData.R")
}

gaitData[,time:=time_vst_absolute-gaitData$time_vst_absolute[1]]

heelstrike <- c(0,diff(gaitData$movingForward))
heelstrike[heelstrike==1] <- 0

gaitData[,cycle:=cumsum(-heelstrike)]

gaitData[,perturb:= as.integer(median(perturb)),by=cycle]

gaitData[,time:=time-min(time),by=cycle] # make time start from beginning of cycle for each cyle


gaitData[hip_right   > 1000, hip_right    := NA]
gaitData[hip_left    > 1000, hip_left     := NA]
gaitData[ankle_right <  -50, ankle_right  := NA]
gaitData[ankle_left  <  -50, ankle_left   := NA]
gaitData[knee_right  > 1000, knee_right   := NA]
gaitData[knee_left   > 1000, knee_left    := NA]

## This function fits data to a spline with the desired number of points. It is
## used to upsample the kinematic data from each gait cycle to a uniform number 
## of equally spaced points so that cycles may be compared to one another

makeSpline <- function(x,y,sequence)
{
  y=spline(x=x,y=y,xout=sequence,method="natural")$y
  list(y=y,x=sequence)
}



nSpline <- 50  # Number of points to fit each spline to

upToSpeed <- gaitData[tspeed_desired==700,
                      list(cycle,
                           perturb,
                           time,
                           xf,
                           xfr,
                           hip_right,
                           knee_right,
                           ankle_right,
                           hip_left,
                           knee_left,
                           ankle_left)]


splines <- upToSpeed[cycle > 60 & cycle < 1003,
                     makeSpline(time,
                                xfr,
                                seq(0,max(time),length.out=nSpline)),
                     by=list(cycle,perturb)]


splines[,pgc:=seq(0,100,length.out=nSpline)]


# Separate post-perturbation cycles - cycles after perturbation are given 
# perturb value of 3 plus the perturb value of the previous cycle
postPertCycs <- unique(splines[perturb > 0,list(cyc=cycle+1,pert=perturb)])
splines[cycle %in% postPertCycs[,cyc],perturb := postPertCycs[cyc==cycle,pert] +3 ]
postPertCycs <- unique(splines[perturb > 0,list(cyc=cycle+1,pert=perturb)])
splines[cycle %in% postPertCycs[,cyc],perturb := postPertCycs[cyc==cycle,pert] +3 ]


avgs <- splines[,
                list(mn=mean(y),
                      std=sd(y),
                      sse=sum((y-mean(y))^2)),
                by=list(pgc,perturb)]


## Statistical Analysis




# Get number of cycles for each type of perturbation
nSamples <- table(splines$perturb)/nSpline
n0 <- unname(nSamples[names(nSamples)=='0'])
n1 <- unname(nSamples[names(nSamples)=='1'])
n2 <- unname(nSamples[names(nSamples)=='2'])
n3 <- unname(nSamples[names(nSamples)=='3'])



nh02 <- 2/(1/n0+1/n2)    # Harmonic mean of sample sizes for pert types 0 and 2
df02 <- (n0+n2)/2

diffStd_0_2 <- avgs[perturb %in% c(0,2),
            c("dm","s"):=list( diff(mn) , sqrt(2*sum(sse)/df02/nh02) ),
            by=pgc]



diffStd_0_2 <- diffStd_0_2[,list(pgc,dm,s)]
setkey(diffStd_0_2,s)
diffStd_0_2 <- unique(diffStd_0_2)

tcrit <- qt(0.975,df02)

diffStd_0_2[,upper:=dm+s*tcrit][,lower:=dm-s*tcrit]





probs <- pt(diffStd_0_2$dm/diffStd_0_2$s,df02)
probsCorrected <- p.adjust(sort(probs),method="bonferroni")


mins <- splines[,list(lowpt=min(y)),by=list(perturb,cycle)]
mins2 <- mins[,list(lowmn=mean(lowpt),lowsd=sd(lowpt)),by=list(perturb)]

maxs <- splines[,list(highpt=max(y)),by=list(perturb,cycle)]
maxs2 <- maxs[,list(highmn=mean(highpt),highsd=sd(highpt)),by=list(perturb)]

extrema <- splines[,list(time=max(x),low=min(y),high=max(y)),by=list(perturb,cycle)] %>%
  gather(extreme,value,high,low)
extremaMeans <- extrema[,list(mnTime=mean(time),sdTime=sd(time),mn=mean(value),std=sd(value)),by=list(perturb,extreme)]


strideLength <- splines[pgc %in% c(0,100),list(time=max(x),val=y),by=list(perturb,cycle,point=pgc/100)]
strideLength1 <- strideLength[,list(time=max(time),diffVal=diff(val)),by=list(perturb,cycle)]
strideLength1[,strideLen:=time*70+diffVal]

setkey(strideLength1,perturb)
strideLength2 <- strideLength1[,list(numSamples=.N,mnTime=mean(time),sdTime=sd(time),mnVal=mean(diffVal),sdVal=sd(diffVal)),by=list(perturb)]

strideLength2[,SL:=mnTime*70+mnVal]
strideLength2[,sdSL:=sqrt((70*sdTime)^2+sdVal^2)]

setkey(strideLength2,perturb)

print(strideLength2)

#strideLength3[,strideLength:=]
#fit <- lm(value~factor(extreme)+factor(perturb)+cycle,extrema[perturb%in%c(0,1,2)])
fit <- lm(lowpt~factor(perturb)+(cycle),mins[perturb%in%c(0,2)])




t <- t.test(strideLength1[perturb==0,diffVal],strideLength1[perturb==2,diffVal])


print(t)

p <- ggplot(avgs[perturb %in% c(0,1,2)],aes(x=pgc,y=mn,colour=factor(perturb))) +
    geom_line() +
    geom_ribbon(aes(ymin=mn-std,ymax=mn+std,fill=factor(perturb)),alpha=0.3,colour=NA)

p2 <- ggplot(diffStd_0_2,aes(x=pgc,y=dm)) +
  geom_line() +
  geom_ribbon(aes(ymin=lower,ymax=upper),fill="gray",alpha=0.4,colour=NA)

p3 <- ggplot(,aes(x=1:nSpline,y=probsCorrected)) +
  geom_point()

p4 <- ggplot(splines[perturb %in% c(0,2)],aes(x=pgc,y=y,colour=factor(perturb),group=cycle)) +
  geom_line()

p5 <- ggplot(mins,aes(lowpt,fill=as.factor(perturb))) +
    geom_density(alpha=0.5)

p6 <- ggplot(mins,aes(x=cycle,y=lowpt,colour=factor(perturb))) +
    geom_point(size=3) +
    stat_smooth(aes(x=cycle,fill=factor(perturb)),method="lm")

p7 <- ggplot(extrema,aes(x=cycle,y=value,colour=factor(perturb)))+
  geom_point() +
  stat_smooth(aes(fill=factor(perturb)),method="lm") +
  facet_grid(extreme~.,scales="free_y")

p8 <- ggplot(strideLength1,aes(x=diffVal)) +
  geom_density(aes(fill=factor(perturb)),alpha=0.3)

p9 <- ggplot(strideLength1[perturb < 4,],aes(x=cycle,y=strideLen,colour=factor(perturb))) +
  geom_point(size=3) +
  geom_smooth(aes(fill=factor(perturb)),method="lm")

print(p)
print(p3)
print(p5)
print(p6)
print(p7)
print(p8)
print(p9)