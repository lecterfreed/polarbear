
# The "Hannah model" -- in-person and anonymous interactions unfold together
# to change agents' hidden and expressed opinions.
# Relevant question: how much of a "hidden Trump vote" might there be, given a
# certain set of expressed opinions?

library(ggplot2)

source("opinionDynamics.R")


# Hidden vs. Expressed Opinions

hannahModel <- function(num=20, prob=0.25, num.enc=2000, update=0.5, internalize=0.5, peer=0.5){
    init <<- get.expressed.latent.graph(num.agents=num, prob.connected=prob, dir=FALSE)
    graphs <<- sim.opinion.dynamics(init, num.encounters=num.enc,
        encounter.func=list(
            get.mean.field.encounter.func(1),
            get.graph.neighbors.encounter.func(1)),
        victim.update.function=list(
            get.automatically.update.victim.function(A.is.victim=TRUE,prob.update=update, opinion.type="hidden"),
            get.peer.pressure.update.function(A.is.victim=TRUE,
                prob.knuckle.under.pressure=peer,
                prob.internalize.expressed.opinion=internalize)),
#        edge.update.function=get.no.edge.update.function(),
#        verbose=TRUE,
        generate.graph.per.encounter=TRUE,
        termination.function=get.unanimity.termination.function("expressed", "hidden"),
		choose.randomly.each.encounter=TRUE)

    #num.hidden.1s <<- sapply(1:length(graphs),function(i) { sum(get.vertex.attribute(graphs[[i]],"hidden"))})
    #num.expressed.1s <<- sapply(1:length(graphs),function(i) { sum(get.vertex.attribute(graphs[[i]],"expressed"))})

    #animated.graph <- plot.animation(graphs, attribute.name="expressed", second.attribute = "hidden",
    #    delay.between.frames=1)
    #plot(animated.graph)
    #plot.binary.opinions(graphs, attribute1="expressed", attribute2="hidden")

    #print.transcript(graphs)
#    plot.animation(graphs,attribute.name="hidden",
#        second.attribute="expressed", delay.between.frames=.5, 
#        interactive=FALSE, animation.filename="thing.gif",
#        subtitle=SUMMARY.STATS)
#    return(invisible(graphs))
    return(graphs)
}

compute.confusion.matrix <- function(graph) {
    confusion.matrix <- matrix(rep(0,4),nrow=2)
    rownames(confusion.matrix) <- c("E- blue", "E- red")
    colnames(confusion.matrix) <- c("H- blue", "H- red")
    hidden.results <- sapply(1:vcount(graph), function(x) 
        get.vertex.attribute(graph, "hidden", V(graph)[x]))
    expressed.results <- sapply(1:vcount(graph), function(x) 
        get.vertex.attribute(graph, "expressed", V(graph)[x]))
    for(j in 1:vcount(graph)){
        confusion.matrix[expressed.results[j]+1,hidden.results[j]+1] <- 
            confusion.matrix[expressed.results[j]+1,hidden.results[j]+1]+1
    }
    confusion.matrix
}
#hannahModel()
