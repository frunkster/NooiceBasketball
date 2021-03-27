library(ggplot2)
library(tidyverse)
library(dplyr)
library(pivottabler)
library(reshape)
library(ggforce)
library(concaveman)
library(plyr)
library(plotly)
library(nlme)
library(gridExtra)
library(grid)
library(ggpmisc)
df = read.csv('scores22021.csv')
df = within(df, meanWeek <- ave(X0, X, FUN = mean))
names(df)[names(df) == "index"] <- "Teams"
df$X1 = df$X0 - df$meanWeek
df = filter(df,X!=0)
x = filter(df,for.==1)
x = x %>% group_by(X) %>%
  mutate(special_mean = (sum(X0) - X0)/(n()-1))
x$X2 = x$X0 - x$special_mean
x = x%>%group_by(Teams) %>% mutate(cum_mean = (cumsum(X2)/X))
y = filter(df,for.==0)
x$win = x$X1-y$X1
count_wins=0
x$won = ifelse(x$win>0,1,0)
x = x%>%group_by(Teams) %>% mutate(cum_won = (cumsum(won)))
data = data.frame(x$X1,y$X1)
gg = ggplot(data=x,aes(x=win,y=X2,color=Teams))
#gg = gg+ geom_mark_ellipse(aes(x=x$win,y=x$X1,color=x$index),alpha=0.5)
gg = gg+geom_point(alpha=0.6,size=3)
#gg = gg+geom_point(shape = 1, size=3,color='black')
gg = gg + xlab("Points for - Points against")+ylab("Points for - avg")
gg = gg + geom_hline(yintercept=0) + geom_vline(xintercept=0) 
#gg = gg+ geom_smooth(method = lm,se=FALSE)
#geom_abline(slope=1,intercept=0,linetype="dashed")
#gg = gg + coord_fixed(xlim=c(-450,450),ylim=c(-450,450))
# gg = gg + annotate("rect", xmin = 0, xmax = Inf, ymin = 0, ymax = Inf, fill= "purple",alpha=0.1)
# gg = gg + annotate("rect", xmin = -Inf, xmax = 0, ymin = -Inf, ymax = 0, fill= "yellow",alpha=0.1)
# gg = gg + annotate("rect", xmin = 0, xmax = Inf, ymin = -Inf, ymax = 0, fill= "green",alpha=0.1)
# gg = gg + annotate("rect", xmin = -Inf, xmax = 0, ymin = 0, ymax = Inf, fill= "red",alpha=0.1)

gg = gg + geom_text(aes(x=300,y=300,label='Win + Good'))
gg = gg + geom_text(aes(x=300,y=-300,label='Win + Bad'))
gg = gg + geom_text(aes(x=-300,y=300,label='Loss + Good'))
gg = gg + geom_text(aes(x=-300,y=-300,label='Loss + Bad'))
gg = gg + theme(panel.border = element_rect(colour = "black", fill=NA, size=2),
                axis.text.y   = element_text(size=14),
                axis.text.x   = element_text(size=14),
                axis.title.y  = element_text(size=14),
                axis.title.x  = element_text(size=14))
print(gg)
#gg = gg + transition_reveal(X)
gf = ggplot(data=x,aes(x=X,y=X2,color=Teams))
gf = gf + geom_point(size=3,alpha=0.6) + geom_point(shape=1,size=3,color='black')

#gf = gf + geom_line(stat='smooth',method='lm',alpha=0.8)
my.formula = y ~ x
gf = gf + geom_smooth(method = "lm", se=FALSE, formula = my.formula)
gf = gf + stat_poly_eq(geom='text',formula = my.formula, 
                       aes(label = stat(eq.label)), 
                       parse = TRUE,label.x=c(10,1,9,10,1,10,1,1), label.y=c(0,130,-35,140,-65,200,-190,-20),size=3.5,hjust = "inward")
#gf = gf + geom_text(x = 25, y = 300, label = lm_eq(df), parse = TRUE)
gf = gf + xlab("Week")+ylab("Points for - avg")
gf = gf + scale_x_continuous(breaks = c(1,2,3,4,5,6,7,8,9,10))

#gf = gf + geom_line(stat='smooth',method='loess',alpha=0.5)
#gf = gf + annotation_custom(tableGrob(lmList(X1~X | index,data=x), rows=NULL), 
                            #xmin=1, xmax=2, ymin=200, ymax=300)
#gf = gf + annotate(geom='table',x=1,y=250,label=list(lmList(X1~X | index,data=x)))
#gf = ggplotly(gf)
#print(lmList(X1~X | index,data=x))
gf = gf + theme(panel.border = element_rect(colour = "black", fill=NA, size=2),
                axis.text.y   = element_text(size=14),
                axis.text.x   = element_text(size=14),
                axis.title.y  = element_text(size=14),
                axis.title.x  = element_text(size=14))
print(gf)
gh = ggplot(x, aes(x=Teams, y=X2,fill=Teams)) + 
  geom_boxplot()+scale_x_discrete(guide = guide_axis(angle = 45))
gh = gh + theme(panel.border = element_rect(colour = "black", fill=NA, size=2),
                axis.text.y   = element_text(size=14),
                axis.text.x   = element_text(size=14),
                axis.title.y  = element_text(size=14),
                axis.title.x  = element_text(size=14))

#print(gf)
gh = gh +ylab("Points for - avg")
print(gh)
library(tibble)
library(hrbrthemes)

pdf = read.csv('/Users/frankgentile/Documents/NBA/pdf.csv')
gi = ggplot(data = pdf, aes(x=team1, y=team2,fill=pvalue)) + 
  geom_tile()+
  scale_fill_gradientn("Custom Colours",
                       colours=c("forestgreen","ghostwhite"),
                       limits=c(0,1))+
  geom_text(aes(label=round(pvalue,2)))
gi = gi +xlab("Team1")+ylab("Team2")


gi = gi + theme(axis.text.y   = element_text(size=12),
                axis.text.x   = element_text(size=12),
                axis.title.y  = element_text(size=14),
                axis.title.x  = element_text(size=14)) 
gi=gi+scale_x_discrete(guide = guide_axis(angle = 45))
gi = gi+ggtitle("Corresponding p values for one-tailed two sample t test H0: team1 > team2")
print(gf)


library(gganimate)
library(gifski)
library(magick)
library(png)
# x %>% 
#   ggplot(aes(x=X,y=X2,color=Teams))+
# #gj = gj+geom_point(size=3,alpha=0.6)
#     geom_line() + xlab("Week")+ylab("Points for - avg")+
# #gj = gj + scale_x_continuous(breaks = c(1,2,3,4,5,6,7,8,9,10))
# #gj = gj + theme(axis.text.y   = element_text(size=14),
#  #               axis.text.x   = element_text(size=14),
#   #              axis.title.y  = element_text(size=14),
#    #             axis.title.x  = element_text(size=14))
# 
#   ## gganimate functionality starts here
#     theme_ipsum()+
#     transition_reveal(X)
#file_renderer(dir = ".", prefix = "gganim_plot", overwrite = FALSE)
#print(gj)
#anim_save("trends.gif")


library(plotly)
accumulate_by <- function(dat, var) {
  var <- lazyeval::f_eval(var, dat)
  lvls <- plotly:::getLevels(var)
  dats <- lapply(seq_along(lvls), function(x) {
    cbind(dat[var %in% lvls[seq(1, x)], ], frame = lvls[[x]])
  })
  dplyr::bind_rows(dats)
}
fig <- x %>% accumulate_by(~X)


fig <- fig %>%
  plot_ly(
    x = ~X,
    y = ~cum_mean,
    color = ~Teams,
    colors = c("coral1","darkgoldenrod","darkolivegreen4","forestgreen","darkturquoise","dodgerblue","darkorchid1","deeppink1"),
    frame = ~frame,
    type = 'scatter',
    mode = 'lines+markers',
    line = list(simplyfy = F)
  )
fig <- fig %>% layout(
  xaxis = list(
    title = "Week",
    zeroline = F
  ),
  yaxis = list(
    title = "MVAVG(Points for - avg)"
  )
)
fig <- fig %>% animation_opts(
  frame = 500, transition = 0,
  redraw = FALSE
)
print(fig) 
# fig <- x %>%
#   plot_ly(
#     x = ~win,
#     y = ~cum_mean,
#     color = ~Teams,
#     frame = ~X,
#     type = 'scatter',
#     mode = 'markers',
#     size = ~cum_won*10
#   )
# fig <- fig %>% layout(
#   xaxis = list(
#     title = "Week",
#     zeroline = F
#   ),
#   yaxis = list(
#     title = "Points for - avg"
#   )
# )
# fig <- fig %>% animation_opts(
#   frame = 500, transition = 0,
#   redraw = FALSE
# )
# fig