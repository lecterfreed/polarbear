#!/usr/bin/env Rscript

# Run as:
# plotSweep.R --args csv_filename

require(ggplot2)
require(dplyr)

ITER.CUTOFF <- 0   # Iteration at which to start counting assortativity

if (length(commandArgs(TRUE)) == 0) {
    filename <- '/tmp/final_output.csv'
} else {
    filename <- commandArgs(TRUE)[2]
}
results <- tbl_df(read.csv(filename,header=TRUE,stringsAsFactors=FALSE))

# Compute the number of sims per parameter value tuple, for display.
first.env_openness <- as.numeric(results[1,'env_openness'])
first.homophily <- as.numeric(results[1,'homophily'])
n <- nrow(results %>% dplyr::filter(env_openness==first.env_openness,
                               homophily==first.homophily)) / 
    (max(results$iteration) + 1)

results %>% 
    dplyr::filter(iteration >= ITER.CUTOFF) %>%
    group_by(seed) %>%
    # hack -- "min" for homophily and env_openness is just "the one value they
    # all share" since these are all the same value for a given seed
    summarize(homophily=min(homophily), env_openness=min(env_openness),
        min.a=min(assortativity),
        mean.a=mean(assortativity),
        max.a=max(assortativity)) -> sum.each.run.results

g <- ggplot(sum.each.run.results, 
    aes(x=env_openness, group=env_openness, fill=env_openness, y=mean.a)) + 
    facet_wrap(~homophily, labeller="label_both") +
    ggtitle(paste0('(n=',n,' sims for each param value)')) +
    xlab('Environmental openness') +
    ylab(paste('Mean assortativity',
            ifelse(ITER.CUTOFF > 0,paste('\n(past',ITER.CUTOFF,'iterations)'),
                ''))) +
    ylim(c(-.2,1)) +
    geom_boxplot(show.legend=FALSE) +
    scale_x_continuous(breaks=unique(results$env_openness)) +
    theme(axis.text.x=element_text(size=9))
image_name <- str_replace(filename, '.csv', '.png')
ggsave(image_name, g)
system(paste("eog",image_name))