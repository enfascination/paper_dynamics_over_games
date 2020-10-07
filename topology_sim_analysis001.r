library(ggplot2)
library(cowplot)
library(sqldf)
library(data.table)
e <- exp(1)
data.analysis.path <- "data/"
image.analysis.path <- "images/"
data.analysis.path2 <- "data/"

toposquat <- read.csv(paste(data.analysis.path, "data_phase1.csv", sep=""))
topo <- data.frame(exp_num = numeric(0), pop = numeric(0), count = numeric(0), percent = numeric(0), percentattr = numeric(0),  n_eq = numeric(0), concentration = numeric(0), is_attractor = numeric(0), n_runs = numeric(0), n_exp = numeric(0), n_attr = numeric(0) )
topo[1:(12*nrow(toposquat)),1:11] <- 0
for (i in 1:nrow(toposquat)) {
  ne <- toposquat[i, "exp_num"]
  p <- toposquat[i, "population"]
  #n <- toposquat[i, "nruns"]
  nr <- sum(toposquat[i, c( "unstable0eq",  "unstable1eq",  "unstableneq",  "stable1boss",  "stable2boss",  "stable3boss",  "stable4boss",  "stable5boss",  "stable6boss",  "stable7boss", "stable8boss", "stable9boss") ] , na.rm=TRUE) 
  nattr <- sum(toposquat[i, c( "stable1boss",  "stable2boss",  "stable3boss",  "stable4boss",  "stable5boss",  "stable6boss",  "stable7boss", "stable8boss", "stable9boss") ] , na.rm=TRUE) 
  nexp <-  nrow(unique(subset(toposquat, population==p, select=exp_num))) 
  topo[(12*(i-1)+1),] <- c(exp_num=ne, pop=p, count=toposquat[i, "unstable0eq"], 
                percent=toposquat[i,"unstable0eq"]/nr/nexp, percentattr=NA, 0, NA, FALSE, nr, nexp, nattr)
  topo[(12*(i-1)+2),] <- c(exp_num=ne, pop=p, count=toposquat[i, "unstable1eq"], 
                percent=toposquat[i,"unstable1eq"]/nr/nexp, percentattr=NA, 1, NA, FALSE, nr, nexp, nattr)
  topo[(12*(i-1)+3),] <- c(exp_num=ne, pop=p, count=toposquat[i, "unstableneq"], 
                percent=toposquat[i,"unstableneq"]/nr/nexp, percentattr=NA, 2, NA, FALSE, nr, nexp, nattr)
  topo[(12*(i-1)+4),] <- c(exp_num=ne, pop=p, count=toposquat[i, "stable1boss"], 
                percent=toposquat[i,"stable1boss"]/nr/nexp, percentattr=toposquat[i,"stable1boss"]/nattr, 1, 1, TRUE, nr, nexp, nattr)
  topo[(12*(i-1)+5),] <- c(exp_num=ne, pop=p, count=toposquat[i, "stable2boss"], 
                percent=toposquat[i,"stable2boss"]/nr/nexp, percentattr=toposquat[i,"stable2boss"]/nattr, 1, 2, TRUE, nr, nexp, nattr)
  topo[(12*(i-1)+6),] <- c(exp_num=ne, pop=p, count=toposquat[i, "stable3boss"], 
                percent=toposquat[i,"stable3boss"]/nr/nexp, percentattr=toposquat[i,"stable3boss"]/nattr, 1, 3, TRUE, nr, nexp, nattr)
  topo[(12*(i-1)+7),] <- c(exp_num=ne, pop=p, count=toposquat[i, "stable4boss"], 
                percent=toposquat[i,"stable4boss"]/nr/nexp, percentattr=toposquat[i,"stable4boss"]/nattr, 1, 4, TRUE, nr, nexp, nattr)
  topo[(12*(i-1)+8),] <- c(exp_num=ne, pop=p, count=toposquat[i, "stable5boss"], 
                percent=toposquat[i,"stable5boss"]/nr/nexp, percentattr=toposquat[i,"stable5boss"]/nattr, 1, 5, TRUE, nr, nexp, nattr)
  topo[(12*(i-1)+9),] <- c(exp_num=ne, pop=p, count=toposquat[i, "stable6boss"], 
                percent=toposquat[i,"stable6boss"]/nr/nexp, percentattr=toposquat[i,"stable6boss"]/nattr, 1, 6, TRUE, nr, nexp, nattr)
  topo[(12*(i-1)+10),] <- c(exp_num=ne, pop=p, count=toposquat[i, "stable7boss"], 
                percent=toposquat[i,"stable7boss"]/nr/nexp, percentattr=toposquat[i,"stable7boss"]/nattr, 1, 7, TRUE, nr, nexp, nattr)
  topo[(12*(i-1)+11),] <- c(exp_num=ne, pop=p, count=toposquat[i, "stable8boss"], 
                percent=toposquat[i,"stable8boss"]/nr/nexp, percentattr=toposquat[i,"stable8boss"]/nattr, 1, 8, TRUE, nr, nexp, nattr)
  topo[(12*(i-1)+12),] <- c(exp_num=ne, pop=p, count=toposquat[i, "stable9boss"], 
                percent=toposquat[i,"stable9boss"]/nr/nexp, percentattr=toposquat[i,"stable9boss"]/nattr, 1, 9, TRUE, nr, nexp, nattr)
}

sizes <- 2:9

n = seq(from=2, to=9, length.out=100)
pp = list()
### plots 
### this calculatled counts and percentages of attractors wrong.  it got he symmettry off: to be an attractor, a game has to be an attractor for *me*, not just *someone*.  For three players, that means dividing the number of concentration=1 attractors by 3, concentration=2 attractors by 2/3, and adding the concentration=3 attracotrs (for whcih being ana ttractor implies being one for me)
topo_attr_depr <- sqldf("SELECT pop, SUM(count) AS count, SUM(percent) AS percent, is_attractor, COUNT(exp_num) FROM topo GROUP BY pop, is_attractor")
topo_attr <- sqldf("SELECT pop, SUM(count / pop * (concentration OR 0)) AS count, SUM(percent / pop * concentration) AS percent, is_attractor, COUNT(exp_num) FROM topo GROUP BY pop, is_attractor")
oneneq <- sqldf("SELECT pop, SUM(count) AS count, SUM(percent) AS percent, is_attractor, COUNT(exp_num) FROM topo WHERE n_eq = 1 GROUP BY pop")$percent
attractor_bounds <- data.frame(x=n, ymin=0.5^(n-1), ymax=approx(oneneq, n=100)$y)
attractor_bounds_short <- data.frame(x=sizes, ymin=0.5^((sizes)-1), ymax=oneneq)
pp$attractorplot <- 
ggplot() + geom_point(data=attractor_bounds_short , aes(x=x, y=ymin), color="blue", alpha=0.7) + geom_point(data=attractor_bounds_short , aes(x=x, y=ymax), color="blue", alpha=0.7) + geom_abline(slope =0,intercept=1/e, linetype=2, color="gray")  + geom_ribbon(data=attractor_bounds, aes(x=x, ymin=ymin,ymax=ymax), fill="blue", alpha="0.2") + geom_line(data=subset(topo_attr, is_attractor==1), aes(y=percent, x=pop), alpha=1, color="black") + geom_point(data=subset(topo_attr, is_attractor==1), aes(y=percent, x=pop),  stat="identity", alpha=0.9, color="black") + xlab("# players") + ylab("% attractors") + scale_x_continuous(labels=sizes, breaks=sizes) + scale_y_continuous(limits=c(0,0.75))
pp$attractorplot_simple <- 
ggplot() + geom_line(data=subset(topo_attr, is_attractor==1), aes(y=percent, x=pop), alpha=1, color="black") + geom_point(data=subset(topo_attr, is_attractor==1), aes(y=percent, x=pop),  stat="identity", alpha=0.9, color="black") + xlab("# players") + ylab("% attractors") + scale_x_continuous(labels=sizes, breaks=sizes) + scale_y_continuous(limits=c(0,0.75))
ggsave(file.path(image.analysis.path,"plot_attractors.pdf"), pp$attractorplot, width=12, units="cm")
##ggplot(topo_attr, aes(fill=factor(is_attractor), y=percent, x=factor(pop))) + geom_bar(position="dodge", stat="identity")
ggsave(file.path(image.analysis.path,"plot_attractors_simple.pdf"), pp$attractorplot_simple, width=12, units="cm")

### try again
tmp$attractorplot <- 
ggplot() + geom_line(data=subset(topo_attr, is_attractor==1), aes(y=percent, x=pop), alpha=1, color="black") + geom_point(data=subset(topo_attr, is_attractor==1), aes(y=percent, x=pop),  stat="identity", alpha=0.9, color="black") + xlab("# players") + ylab("% attractors") + scale_x_continuous(labels=sizes, breaks=sizes) + scale_y_continuous(limits=c(0,0.75))
##ggplot(topo_attr, aes(fill=factor(is_attractor), y=percent, x=factor(pop))) + geom_bar(position="dodge", stat="identity")
tmp$logattractorplot <- ggplot() + geom_line(data=subset(topo_attr, is_attractor==1), aes(y=percent, x=pop), alpha=1, color="black") + geom_point(data=subset(topo_attr, is_attractor==1), aes(y=percent, x=pop),  stat="identity", alpha=0.9, color="black", size=0.5) + xlab("# players") + scale_x_continuous(labels=sizes, breaks=sizes)  + ylab("log(%)") + scale_y_log10() 
pp$attractorplot2  <- 
ggdraw() + draw_plot(tmp$attractorplot, 0, 0, 1, 1) + draw_plot(tmp$logattractorplot + theme( axis.text=element_blank(), axis.title=element_text(size=10)) , 0.5, 0.52, 0.45, 0.4)
ggsave(file.path(image.analysis.path,"plot_attractors2.pdf"), pp$attractorplot2, width=12, units="cm")

tmp <- list()
c <- 2
pwinwin = data.frame(x=seq(from=2, to=9, length.out=100), y=(1/(c^n))^(n-1))
tmp$winwinplot <- ggplot() + geom_line(data=attractor_bounds , aes(x=x, y=ymin), color="black", position=position_nudge(-1,0), linetype=2) + geom_line(data=pwinwin , aes(x=x, y=y), color="black", position=position_nudge(-1,0)) + xlab("# players") + ylab("% win-win") + scale_y_continuous(limits=c(0,0.75)) + scale_x_continuous(breaks=1:8, labels=sizes)# + geom_line(data=subset(topo_attr, is_attractor==1), aes(y=percent, x=pop-1), alpha=1, color="grey", linetype=2) 
tmp$logwinwinplot <- ggplot() + geom_line(data=attractor_bounds , aes(x=x, y=ymin), color="black", position=position_nudge(-1,0), linetype=2) + geom_line(data=pwinwin , aes(x=x, y=y), color="black", position=position_nudge(-1,0)) + xlab("# players") + ylab("log(% win-win)") + scale_y_log10(limits=c(1e-30, 0.75)) + scale_x_continuous(breaks=1:8, labels=sizes)# + geom_line(data=subset(topo_attr, is_attractor==1), aes(y=percent, x=pop-1), alpha=1, color="grey", linetype=2) 
pp$winwinplot <- 
ggdraw() + draw_plot(tmp$winwinplot, 0, 0, 1, 1) + draw_plot(tmp$logwinwinplot + theme( axis.text=element_blank(), axis.title=element_text(size=10)) , 0.5, 0.52, 0.45, 0.4)

ggsave(file.path(image.analysis.path,"plot_winwin.pdf"), pp$winwinplot, width=12, units="cm")


#unfairAttractorGame <- c(0.11549823633156965, 0.2043476318026391 , 0.24915603960198865, 
                 #0.27397074170401914, 0.28808446224417095, 0.29693421118742458, 0.30269643433195914, 0.3067281221615708 )
#unfairAttractorNashOutcome <- c( 0.051587301587301571 , 0.10640309885233581 , 0.13704308541023494 , 
                 #0.15771847461723548 , 0.16837088043409834 , 0.17528690842329989 , 0.17948750254140727 , 0.17910942249101042)
#unfairFullSpaceNashOutcome <- c( 0.062698412698412961, 0.11445051674449237, 0.14323647641233506, 0.15999782361488674, 0.1694677978030682, 0.17562524154933712, 0.17959874558870362, 0.18139282927147482 )

unfairAttractorGame <- c( 0.11549823633156965, (5*0.204731931636944 + 5*0.20455970299628096)/10, (5* 0.249660598640060 + 5*0.24966229188843225)/10, (5*0.273834251199148 + 5*0.27392983507673757)/10, (5*0.288152269931237 + 5*0.2881981294997625)/10,  (5*0.296849229637602 + 5*0.2968904431893335)/10, (5*0.30269175743650073 + 2*0.3026242916738846 +5*0.302586161038056)/12, (5*0.306802108418872 + 0.3067350867202556 + 5*0.30682172035159083)/11)#, (5*0.30978725053329836 + 0.30980776215428646)/6)
unfairAttractorNashOutcome <- c( 0.05158730158730158, (5*0.106940440484962 + 5*0.1066127263460903)/10, (5*0.139570031039507 + 5*0.13892533726642076)/10, (5*0.158266510934601 + 5*0.15912480894855538)/10, (5*0.168829369637625 + 5*0.16805470757225668)/10,  (5*0.176404610414267 + 5*0.17634741822795602)/10, (5*0.1794884135727717 + 2*0.1807548630387084 + 5*0.179978025496799)/12, (5*0.1833052652230143 + 0.18667685747911766 + 5*0.18190650437549213)/11)#, (5*0.1858826523904319 + 0.17723872045607683)/6)
unfairFullSpaceNashOutcome <- c( .0626984126984127, (5*0.114024843408603 + 5*0.11406535333134733)/10, (5*0.143361814606283 + 5*0.14334085902587787)/10, (5*0.159633690151397 + 5*0.15984717448413036)/10, (5*0.169643950514247 + 5*0.16957184176395512)/10, (5*0.175429506724289 + 5* 0.17572206409861169)/10, (5*0.1794423972651385 + 2*0.1795381584606132 + 5*0.179563645914994)/12, (5*0.1822910370036324 + 0.1820381066972486 + 5*0.18232069841787552)/11)#, (5*0.1842950648301108 + 0.18452844625132134)/6)

unf <- data.frame(systemSize=c(sizes,sizes,sizes), 
                  space=c(rep("attractors", length(sizes)), c(rep("attractors", length(sizes)) ), c(rep("fullspace", length(sizes)) ) ), 
                  outcomes=c(rep("all", length(sizes)), c(rep("nash", length(sizes)) ), c(rep("nash", length(sizes)) ) ), 
                  gini=c(unfairAttractorGame, unfairAttractorNashOutcome, unfairFullSpaceNashOutcome))
pp$giniplot <- ggplot( unf[unf$outcomes == "nash" & unf$space == "attractors",], aes(x=systemSize, y=gini, group=outcomes) ) + 
                         geom_line() + scale_y_continuous( limits=c(0,0.25) )  + 
                         scale_x_discrete( limits=sizes )+ xlab("# players") + ylab("GINI") 
ggsave(file.path(image.analysis.path,"plot_gini.pdf"), pp$giniplot, width=12, units="cm")

unf2 <- data.frame(systemSize=c(sizes), 
                   ginidiff=c( unfairFullSpaceNashOutcome - unfairAttractorNashOutcome ))
pp$giniplotdiff <- ggplot( unf2, aes(x=systemSize, y=ginidiff) ) + 
                         geom_line() + #scale_y_continuous( limits=c(0,0.25) )  + 
                         geom_point( stat="identity", alpha=0.9, color="black") + 
                         geom_abline(slope =0,intercept=0, linetype=2, color="gray") +
                         scale_x_discrete( limits=sizes )+ xlab("# players") + ylab("diff. in GINI") 

ggsave(file.path(image.analysis.path,"plot_ginidiff.pdf"), pp$giniplotdiff, width=12, units="cm")

bootreps = 1000
nrows = bootreps*length(sizes)
unf3 <- data.frame(space=rep("",nrows), outcomes =rep("",nrows, population =rep(0,nrows)), reps =rep(0,nrows), bootrep =rep(0,nrows),
                   ginidiff =rep(0,nrows),ginidiffmin =rep(0,nrows),ginidiffmax =rep(0,nrows))
for (rin in 1:length(sizes)) {
    print("")
    print(rin+1)
    #gini_raw1 <- read.csv(paste(data.analysis.path2, "sim_inequality_full_dataout.txt", sep=""), header=FALSE, nrows=1, skip=(rin-1)*4)
    #gini_raw2 <- read.csv(paste(data.analysis.path2, "sim_inequality_full_dataout.txt", sep=""), header=FALSE, nrows=1, skip=(rin-1)*4+1)
    gini_raw2 <- as.data.table(fread(paste(data.analysis.path2, "sim_inequality_full_dataout.txt", sep=""), header=FALSE, nrows=1, skip=(rin-1)*4+1))
    print(dim(gini_raw2))
    #gini_raw3 <- read.csv(paste(data.analysis.path2, "sim_inequality_full_dataout.txt", sep=""), header=FALSE, nrows=1, skip=(rin-1)*4+2)
    gini_raw4 <- as.data.table(fread(paste(data.analysis.path2, "sim_inequality_full_dataout.txt", sep=""), header=FALSE, nrows=1, skip=(rin-1)*4+3))
    print(dim(gini_raw4))
    unf3[(1+(rin-1)*bootreps):(rin*bootreps), "space"] <- gini_raw2[1,1]
    unf3[(1+(rin-1)*bootreps):(rin*bootreps), "outcomes"] <- gini_raw2[1,2]
    unf3[(1+(rin-1)*bootreps):(rin*bootreps), "population"] <- gini_raw2[1,3]
    unf3[(1+(rin-1)*bootreps):(rin*bootreps), "reps"] <- gini_raw2[1,4]
    vals2 <- as.numeric( gini_raw2[1,5:ncol(gini_raw2)] )
    vals4 <- as.numeric( gini_raw4[1,5:ncol(gini_raw4)] )
    nvals2 <- length( vals2 )
    nvals4 <- length( vals4 )
    #for (rout in (1+(rin-1)*bootreps):(rin*bootreps)) {
    rout = (1+(rin-1)*bootreps):(rin*bootreps)
    print("start bootstrap")
    for (b in 1:bootreps)  {
        vals2.boot <- sample(vals2, nvals2, replace=TRUE)
        vals4.boot <- sample(vals4, nvals4, replace=TRUE)
        unf3[rout[b], "bootrep"] <- b
        unf3[rout[b], "ginidiff"] <- mean(vals4.boot)  - mean(vals2.boot) 
    }
}

nrows4 <- 8
unf4 <- data.frame(space=rep("",nrows4), outcomes =rep("",nrows4), population =rep(0,nrows4), reps =rep(0,nrows4),ginidiff =rep(0,nrows4), ginidiff2 = c( unfairFullSpaceNashOutcome - unfairAttractorNashOutcome ),ginidiffmin =rep(0,nrows4),ginidiffmax =rep(0,nrows4))
for (i in 1:8) {
   unf4[i, c("space", "outcomes", "population", "reps")] <- unf3[1+(i-1)*bootreps, c("space", "outcomes", "population", "reps")]
   unf4[i, "ginidiff"] <- mean( unf3[ (1+(i-1)*bootreps):(i*bootreps), "ginidiff"] )
   unf4[i, "ginidiffmin"] <- quantile( unf3[ (1+(i-1)*bootreps):(i*bootreps), "ginidiff"], 0.05 )
   unf4[i, "ginidiffmax"] <- quantile( unf3[ (1+(i-1)*bootreps):(i*bootreps), "ginidiff"], 0.95 )
}
unf4$ginidiffmin <- with(unf4, ifelse(population == 2, ginidiff, ginidiffmin))
unf4$ginidiffmax <- with(unf4, ifelse(population == 2, ginidiff, ginidiffmax))
pp$giniplotdiff2 <- ggplot(unf4, aes(x=population, y=ginidiff2, ymin=ginidiffmin, ymax=ginidiffmax)) + 
                         geom_line(alpha=0.5) + geom_point() +
                         geom_ribbon( alpha=0.3, fill="blue") +
                         geom_abline(slope =0,intercept=0, linetype=2, color="gray") +
                         scale_x_discrete( limits=sizes )+ xlab("# players") + ylab("diff. in GINI") 
pp$giniplotdiff2 

ggsave(file.path(image.analysis.path,"plot_ginidiff2.pdf"), pp$giniplotdiff2, width=12, units="cm")

#ggsave(file.path(image.analysis.path,"plot_multiplot.pdf"), plot_grid(plotlist=pp, labels=c("a.", "b.", "c."), nrow=1), width=20, height=6, units="cm")
ggsave(file.path(image.analysis.path,"plot_multiplot1.pdf"), plot_grid(plotlist=list(pp$attractorplot_simple, pp$giniplotdiff2 ), labels=c("a.", "b."), nrow=1), width=16, height=6, units="cm")

ggsave(file.path(image.analysis.path,"plot_multiplot2.pdf"), plot_grid(plotlist=list(pp$winwinplot, pp$giniplot ), labels=c("a.", "b."), nrow=1), width=16, height=6, units="cm")
ggsave(file.path(image.analysis.path,"plot_multiplot3.pdf"), plot_grid(plotlist=list(pp$attractorplot2, pp$giniplotdiff2 ), labels=c("a.", "b."), nrow=1), width=16, height=6, units="cm")
ggsave(file.path(image.analysis.path,"plot_multiplot3.tiff"), plot_grid(plotlist=list(pp$attractorplot2, pp$giniplotdiff2 ), labels=c("a.", "b."), nrow=1), width=16, height=6, units="cm")

topo_concentration <- sqldf("SELECT concentration, pop, SUM(count) AS count, AVG(percentattr) AS percent, COUNT(exp_num) FROM topo WHERE is_attractor=1 GROUP BY pop, concentration")
ggplot(topo_concentration, aes(x=factor(concentration), y=percent, group=factor(pop), colour=factor(pop))) + geom_line() 
ggplot(topo_concentration, aes(x=factor(concentration), y=percent, group=factor(pop), colour=factor(pop))) + geom_line() + scale_y_log10()


p <- ggplot(topo, aes(factor(is_attractor, count),  fill=factor(pop))) + geom_bar(aes(y=..density..), position="dodge") 
p <- ggplot(topo, aes(factor(is_attractor))) + geom_bar( y=count ) 
p
p <- ggplot(topo, aes(x=factor(is_attractor), y=count)) + geom_freqpoly(aes(y=..density..), position="dodge") 
p
p <- ggplot(topo, aes(factor(is_attractor), group=factor(pop), colour=factor(pop))) + geom_freqpoly(aes(y=..density..), position="dodge") 
p
p <- ggplot(topo, aes(factor(pop), percent))+ geom_boxplot(aes(fill = factor(is_attractor))) 
p
qplot(levels(factor(topo_attr$is_attractor)), tapply(topo_attr$count, topo_attr$is_attractor, function(x) sum(x, na.rm=TRUE)), geom="bar", stat="identity") 

p <- ggplot(topo_attr, aes(factor(is_attractor))) + geom_bar( y=percent ) 
p

ggplot(topo, aes(factor(concentration), percent)) + geom_point()
