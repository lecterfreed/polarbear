source("opinionDynamics.R")

# Binary Opinions
# Graph does not change

pelryan <- function() {

    #download.file("http://cs.umw.edu/~stephen/pelosiRyan.RData", "pelosiRyan.RData")
    #load("pelosiRyan.RData")

    #first.g <<- U
    first.g <<- erdos.renyi.game(100,0.05)
    V(first.g)$opinion <<- sample(c(0,1),vcount(first.g),replace=TRUE)
    pel.graphs <<- sim.opinion.dynamics(first.g,
        num.encounters=40,
        encounter.func=get.graph.neighbors.encounter.func(1),
        victim.update.function=get.automatically.update.victim.function(A.is.victim=FALSE),
        edge.update=FALSE,
        majority=FALSE,
        choose.randomly.each.encounter=FALSE)
    plot.animation(pel.graphs,"opinion",delay.between.frames=.15, 
        interactive=FALSE, animation.filename="graphA.gif")
    plot.polarization(pel.graphs, "opinion")
    plot.binary.opinions(pel.graphs)
}