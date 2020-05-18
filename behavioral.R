
###### Behavioral analyses for CogEmo paper

library(lme4)
library(nlme)
library(dplyr)
library(ggplot2)
library(scales)
library(lsmeans)
library(emmeans)

# import trial-by-trila behavioral data: correct/incorrect, latency, arousal rating, valence rating
d.import <- read.csv("~/Documents/00 Pitt/LNCD/trial_lat_valence.csv")

# important age & sex info
subj <- read.table("~/Documents/00 Pitt/LNCD/bilatamy_mvm_table_n50.txt", header = TRUE)

# merge behavioral data with age/sex info
d.include <- merge(d.import, subj, by.x="id", by.y="Subj")

# remove all dropped trials from dataframe
d <- d.include[d.include$score!="drop",]

d$val <- as.factor(d$val)

#Function to reverse scores so that arousal ratings actually make sense
# after reversal, higher numbers = greater arousal
revscore <- function(x) -1*(x -10)
d <- d %>% mutate_at(vars(arousal),funs(revscore))

#Remove extra sex and age columns
d$age.y <- NULL
d$sex.y <- NULL

#recode accuracy in d from "correct" and "incorrect" to 1 and 0 respectively
d$acc <- 0
d$acc[d$score=="correct"] <- 1

# Create a dataframe with no silent trials
# This dataframe only includes trials that have sounds --> only includes trials with corresponding arousal/valence ratings
d.emo <- d[d$val!="SilAS", ]

# Create a dataframe that only includes correct trials - for latency analyses
d.cor <- d[d$acc!="0", ]

####

## d : all trials except drops - use for accuracy only analyses
## d.emo : all non-silent trials - use for arousal/valence analyses
## d.cor : all correct trials - use for latency analyses


### Latency analyses

m1 <- lme(lat ~ age.x * sex.x * val, data = d.cor, random = ~1|id, method="ML", na.action="na.omit")
car::Anova(m1)

t1<-lstrends(m1,~val, var="age.x", at = list(Match=c("PosAS","NegAS","NeuAS","SilAS")))
summary(t1, infer=TRUE)

ggplot(d.cor, aes(x=age.x, y=lat, color=val)) + 
  geom_point() + 
  geom_smooth(method=lm, se=TRUE, fill="#d0d0d0") + 
  labs(x = "Age (years)", y = "Latency (ms)", color = "Condition") + 
  theme(axis.line = element_line(colour = "black"),
        axis.text = element_text(size=16),
        axis.title = element_text(size=24),
        legend.title=element_text(size=24),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        legend.text = element_text(size=16)) + 
  scale_color_manual(values=c("#e70808", "#08e722", "#0408FF", "#ad00ea"), 
                     labels = c("Positive", "Negative", "Neutral", "Silent"))

### % correct analyses

m2 <- glmer(acc ~ age.x * sex.x * val + (1|id), data = d, family="binomial", na.action="na.omit")
car::Anova(m2)

t2<-lstrends(m2,~val, var="age.x", at = list(Match= c("PosAS","NegAS","NeuAS","SilAS")))
summary(t2, infer=TRUE)

ggplot(d, aes(x=age.x, y=acc, color=val)) + 
  geom_point() + 
  geom_smooth(method=lm, se=TRUE, size=1.75, fill=c("#d0d0d0")) + 
  labs(x = "Age (years)", y = "% Correct Responses", color = "Condition") + 
  theme(axis.line = element_line(colour = "black"),
        axis.text = element_text(size=20),
        axis.title = element_text(size=24),
        legend.title=element_text(size=24),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        legend.text = element_text(size=16)) + 
  scale_color_manual(values=c("#e70808", "#08e722", "#0408FF", "#ad00ea"), 
                     labels = c("Positive", "Negative", "Neutral", "Silent"))

### Arousal analyses

m3 <- lmer(as.formula(arousal ~ age.x * sex.x * val + (1|id)), data = d.emo)
car::Anova(m3)

t3<-lstrends(m3,~val, var="age.x", at = list(Match= c("PosAS","NegAS","NeuAS")))
summary(t3, infer=TRUE)

ggplot(d.emo, aes(x=age.x, y=arousal, color=val)) + 
  geom_smooth(method=lm, se=TRUE, fill=c("#bdbdbd")) + 
  labs(x = "Age (years)", y = "Arousal Rating", color = "Condition") + 
  scale_y_continuous(breaks=seq(1,9,1), limits=c(1,9)) +
  theme(axis.line = element_line(colour = "black"),
        axis.text = element_text(size=16),
        axis.title = element_text(size=20),
        legend.title=element_text(size=20),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        legend.text = element_text(size=12)) + 
  scale_color_manual(values=c("#e70808", "#08e722", "#0408FF"), 
                     labels = c("Positive", "Negative", "Neutral"))

### Valence analyses

m4 <- lmer(as.formula(valence ~ age.x * sex.x * val + (1|id)), data = d.emo)
car::Anova(m4)

t4<-lstrends(m4,~val, var="age.x", at = list(Match= c("PosAS","NegAS","NeuAS")))
summary(t4, infer=TRUE)

ggplot(d.emo, aes(x=age.x, y=valence, color=val)) + 
  geom_smooth(method=lm, se=TRUE, fill="#bdbdbd") + 
  labs(x = "Age (years)", y = "Valence", color = "Condition") + 
  scale_y_continuous(breaks=seq(1,9,1), limits=c(1,9)) +
  theme(axis.line = element_line(colour = "black"),
        axis.text = element_text(size=16),
        axis.title = element_text(size=20),
        legend.title=element_text(size=20),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        panel.background = element_blank(),
        legend.text = element_text(size=12)) + 
  scale_color_manual(values=c("#e70808", "#08e722", "#0408FF"), 
                     labels = c("Positive", "Negative", "Neutral"))

