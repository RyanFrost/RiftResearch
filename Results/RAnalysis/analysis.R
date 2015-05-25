
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



nSpline <- 200  # Number of points to fit each spline to

upToSpeed <- gaitData[tspeed_desired==700 & cycle > 60 & cycle < 1003,
                      list(cycle,
                           perturb,
                           time,
                           relTime = time/max(time),
                           xf,
                           xfr,
                           yf,
                           yfr,
                           hip_right,
                           knee_right,
                           ankle_right,
                           hip_left,
                           knee_left,
                           ankle_left),
                      by=cycle]


splines <- upToSpeed[,
                     makeSpline(time,
                                yfr,
                                seq(0,max(time),length.out=nSpline)),
                     by=list(cycle,perturb)]


splines[,pgc:=seq(0,100,length.out=nSpline)]




# Separate post-perturbation cycles - cycles after perturbation are given 
# perturb value of 3 plus the perturb value of the previous cycle

postPertCycs <- unique(splines[perturb > 0,list(cyc=cycle+1,pert=perturb)])
splines[cycle %in% postPertCycs[,cyc],
        perturb := postPertCycs[cyc==cycle,pert] + as.integer(3) ]

postPertCycs <- unique(splines[perturb > 0,list(cyc=cycle+1,pert=perturb)])
splines[cycle %in% postPertCycs[,cyc],
        perturb := postPertCycs[cyc==cycle,pert] + as.integer(3) ]


avgs <- splines[,
                list(mn=mean(y),
                      std=sd(y),
                      sse=sum((y-mean(y))^2)),
                by=list(pgc,perturb)]


set.seed(1234)

splinesOrdered <- splines[order(perturb)]

nSamp <- splinesOrdered[, list(count = .N/nSpline), by = list(perturb)]

trainingSet <- splinesOrdered[,.SD[cycle %in% sample(.N,as.integer(.N*0.6))],by=perturb]
trainingCycs <- sort(unique(trainingSet$cycle))
testSet <- splinesOrdered[,.SD[!cycle %in% trainingCycs]]
testCycs <- sort(unique(testSet$cycle))

trainingIndices <- as.vector(sapply(trainingCycs, function(x) 1:nSpline + x*nSpline))
testIndices <- as.vector(sapply(testCycs, function(x) 1:nSpline + x*nSpline))


samp <- c()

#nn <- nnet(perturb~.,data=splinesOrdered,subset=trainingIndices,size=10)


#pred <- predict(nn,testSet,type="class")


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




extrema <- splines[,list(time=max(x),low=min(y),high=max(y)),by=list(perturb,cycle)] %>%
  gather(extreme,value,high,low)
extremaMeans <- extrema[,list(mnTime=mean(time),sdTime=sd(time),mn=mean(value),std=sd(value)),by=list(perturb,extreme)]

ex <- unique(extrema[,list(time,rng=-diff(value)),by=list(perturb,cycle)])

ex2 <- spread(extrema,extreme,value)



unc <- (ex[,list(mn = mean(rng), unc = sd(rng)/sqrt(.N)),by=perturb])

dif <- unc[perturb %in% c(0,2), list(D=diff(mn),uncD=sqrt(sum(unc^2)))]

prop <- lapply(0:3,
               function(x) propagate(expression(high-low),
                                     ex2[perturb==x,list(high,low)],
                                     type="raw",
                                     dist.sim="t",
                                     nsim=10000))


prop0 <- prop[[1]]
prop2 <- prop[[3]]

dtprop <- data.table("0"=prop0$datPROP,"1"=prop2$datPROP) %>%
  gather(perturb,rng,1,2)

#list(pk2 = max(y),
 #    pgc=pgc[head(which(y==max(y)),1)]



peak2 <- splines[pgc > 37.5 & pgc < 60,
                 list(pk2 = y[head(which(diff(sign(diff(y)))==-2)+1,1)],
                      pgc=pgc[head(which(diff(sign(diff(y)))==-2)+1,1)]),
                 by=list(cycle,perturb)]



strideLength <- splines[pgc %in% c(0,100),list(time=max(x),val=y),by=list(perturb,cycle,point=pgc/100)]
strideLength1 <- strideLength[,list(time=max(time),diffVal=diff(val)),by=list(perturb,cycle)]
strideLength1[,strideLen:=time*70+diffVal]

setkey(strideLength1,perturb)
strideLength2 <- strideLength1[,list(numSamples=.N,mnTime=mean(time),sdTime=sd(time),mnVal=mean(diffVal),sdVal=sd(diffVal)),by=list(perturb)]

strideLength2[,SL:=mnTime*70+mnVal]
strideLength2[,sdSL:=sqrt((70*sdTime)^2+sdVal^2)]

setkey(strideLength2,perturb)



fit <- lm(rng~factor(perturb)+time,data=ex[perturb %in% c(0,2)])

print(summary(fit))
print(anova(fit))


t <- t.test(diffVal~perturb,data=strideLength1[perturb %in% c(0,2)])

t2 <- t.test(rng~perturb,data=ex[perturb %in% c(0,2)])

t3 <- t.test(pgc~perturb,data=peak2[perturb %in% c(2,0)])

print(t3)





## Plots


p <- ggplot(avgs[perturb %in% c(0,1,2,3) ],aes(x=pgc,y=mn,colour=factor(perturb))) +
    geom_line() +
    geom_ribbon(aes(ymin=mn-std,ymax=mn+std,fill=factor(perturb)),alpha=0.3,colour=NA)

p2 <- ggplot(diffStd_0_2,aes(x=pgc,y=dm)) +
  geom_line() +
  geom_ribbon(aes(ymin=lower,ymax=upper),fill="gray",alpha=0.4,colour=NA)

p3 <- ggplot(,aes(x=1:nSpline,y=probsCorrected)) +
  geom_point()

p4 <- ggplot(splines[perturb %in% c(0,2)],aes(x=pgc,y=y,colour=factor(perturb),group=cycle)) +
  geom_line()

p5 <- ggplot(extrema,aes(x=cycle,y=value,colour=factor(perturb)))+
  geom_point() +
  stat_smooth(aes(fill=factor(perturb)),method="lm") +
  facet_grid(extreme~.,scales="free_y")

p6 <- ggplot(strideLength1,aes(x=diffVal)) +
  geom_density(aes(fill=factor(perturb)),alpha=0.3)

p7 <- ggplot(strideLength1[perturb < 4,],aes(x=cycle,y=strideLen,colour=factor(perturb))) +
  geom_point(size=3) +
  geom_smooth(aes(fill=factor(perturb)),method="lm")

p8 <- ggplot(ex[perturb < 4],aes(x=time,y=rng,colour=factor(perturb))) +
  geom_point(size=4) +
  geom_smooth(aes(fill=factor(perturb)),method=lm)

p9 <- ggplot(ex[perturb < 4],aes(x=rng,fill=as.factor(perturb))) +
  geom_density(alpha=0.5)

p10 <- ggplot(ex[perturb < 4],aes(x=factor(perturb),y=rng)) +
  geom_violin(aes(fill=factor(perturb)),alpha=0.4) +
  geom_jitter(size=2,
              position= position_jitter(width= 0.3),
              aes(colour=factor(perturb)))

p11 <- ggplot(upToSpeed[perturb %in% c(0,2)],aes(x=relTime,y=yfr,colour=factor(perturb))) +
  geom_line(aes(group=cycle))

p12 <- ggplot(peak2[perturb < 4],aes(x=pgc)) +
  geom_density(aes(fill=factor(perturb)),alpha=0.3)

p13 <- ggplot(peak2[perturb < 4],aes(x=pk2)) +
  geom_density(aes(fill=factor(perturb)),alpha=0.3)


print(p)
print(p4)
print(p12)
print(p13)