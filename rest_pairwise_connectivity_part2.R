## Run pairwise connectivity analyses on clusters from background connectivity age effect 

library(tidyr)
library(dplyr)
library(reshape2)
library(ggplot2)
library(purrr)
library(lubridate)
library(RColorBrewer)

subjs <- read.table("/Volumes/Zeus/MMY1_EmoSnd/analysis_rest/cond_cor_pairwise/dir_list.txt", header=F)
names(subjs) <- "Subj"

getd <- function(id_vdate) {
  idsplit <- strsplit(as.character(id_vdate), '_')[[1]]
  id <- idsplit[1]
  vdate <- idsplit[2]
  f <- sprintf("/Volumes/Zeus/MMY1_EmoSnd/analysis_fm/%s/cond_cor_rest/%s_adj_pearson.txt",id,id)
  if( ! file.exists(f) ) {
    cat(f, "doesn't exist?\n")
    return(NULL)
  }
  d <- read.table(f)
  if(is.null(d)) return(NULL)
  names(d) <- as.numeric(gsub('V','',names(d)))
  d$roi2 <- names(d)
  d.m <- melt(d, variable.name='roi1', id.var='roi2')
  d.m$Subj <- id_vdate

  keeprowidx <-  as.numeric(d.m$roi1) < as.numeric(d.m$roi2)
  d.diag <- d.m[keeprowidx, ]
  return(d.diag)
}

l <- lapply(subjs$Subj, getd)
d <- bind_rows(l)
#d <- Reduce(rbind,l)

d.date <- tidyr::separate(d,Subj,sep='_',c("ID","vdate")) %>% mutate(vdate=ymd(vdate))

#d.age <- merge(d,subjs,by='Subj')
#d.age

allsex <- LNCDR::db_query("select id,sex,dob from person natural join enroll where etype like 'LunaID'")
d.age.sex <-
   merge(d.date,allsex,by.x='ID',by.y='id',all.x=T,all.y=F) %>%
   mutate(age=as.numeric(vdate-dob)/365.25)
write.table(d.age.sex, "/Volumes/Zeus/MMY1_EmoSnd/analysis_rest/cond_cor_pairwise/corr_table.txt", quote = FALSE, sep="\t", row.names = FALSE)


n <- 19
outm <- matrix(NA,nrow=n,ncol=n)
outitr <- matrix(NA,nrow=n,ncol=n)
for(i in 1:(n-1)) {
  for (j in (i+1):n){
   m <- lm(value ~ age * sex,data =  d.age.sex %>% filter(roi1 == i, roi2== j) )
   val <- summary(m)$coefficients[2,4]
   outm[i,j] <- val
   outitr[i,j] <- summary(m)$coefficients[4,4]
  }
}

# outm: p-value for age
# outitr: p-value for age x sex interaction

corrplot::corrplot(outm, method = "number", col = brewer.pal(n = 8, name = "Accent"), is.corr=F)
corrplot::corrplot(outitr, method = "number", col = brewer.pal(n = 8, name = "Accent"), is.corr=F)

dev.off()
