
# Common plotting functions.
# Stephen and Hannah

library(igraph)

# Given a list of graphs, plot them, ensuring that vertices are plotted in the
# same location from graph to graph.
#
# graphs -- a list of igraph objects as produced by run.polar.
#
# attribute.name -- the name of a vertex attribute whose values should be
# mapped to vertex color.
#
# try.to.keep.vertex.positions -- if TRUE, try to plot each vertex in a
# similar x,y position from frame to frame. If FALSE, layout each frame of the
# animation anew, with new relation to the old.
#
# interactive -- if TRUE, display the animation within R. If FALSE, create an
# animation file in the current directory with the name specified.
#
# delay.between.frames -- the delay, in seconds, between graph displays.
#
# animation.filename -- only relevant if interactive is FALSE.
#
# overwrite.animation.file -- controls whether to overwrite or error out if
# file already exists. Only relevant if interactive is FALSE.
#
plot.animation <- function(graphs, attribute.name="ideology", 
    try.to.keep.vertex.positions=TRUE, delay.between.frames=.5, 
    interactive=TRUE, animation.filename="polar.gif",
    overwrite.animation.file=FALSE) {

    if (!interactive && !overwrite.animation.file) {
        if (file.exists(animation.filename)) {
            stop(paste0("File ",animation.filename, " already exists!"))
        }
    }

    # Detect binary graphs so we can plot colors differently.
    if (all(get.vertex.attribute(graphs[[1]],attribute.name) %in% c(0,1))) {
        binary <- TRUE
    } else {
        binary <- FALSE
    }

    vertex.coords <- layout_with_fr(graphs[[1]])
    for (i in 1:length(graphs)) {
        if (try.to.keep.vertex.positions) {
            vertex.coords <- layout_with_fr(graphs[[i]],coords=vertex.coords)
        } else {
            vertex.coords <- layout_with_fr(graphs[[i]],coords=NULL)
        }
        if (binary) {
            V(graphs[[i]])$color <- ifelse(
                get.vertex.attribute(graphs[[i]],attribute.name) == 0,
                "blue","red")
        } else {
            V(graphs[[i]])$color <- 
                colorRampPalette(c("blue","white","red"))(100)[ceiling(
                    get.vertex.attribute(graphs[[i]],attribute.name) * 100)]
        }
        if (!interactive) {
            png(paste0("plot",paste0(rep(0,3-floor(log10(i)+1)),collapse=""),
                i,".png"))
            cat("Building frame",i,"of",length(graphs),"...\n")
        }
        plot(graphs[[i]],
            layout=vertex.coords,
            main=paste("Iteration",i,"of",length(graphs)))
        legend("bottomright",legend=c("Liberal","Moderate","Conservative"),
            fill=c("blue","white","red"))
        if (interactive) {
            Sys.sleep(delay.between.frames)
        } else {
            dev.off()
        }
    }
    if (!interactive) {
        cat("Assembling animation...\n")
          system(paste0("convert -delay ",delay.between.frames*100,
              " plot*.png ", animation.filename))
          system("rm plot*.png")
          cat("Animation in file ",animation.filename,".\n",sep="")
    }
}


# Plot the polarization vs. time for the list of graphs passed.
#
# graphs -- a list of igraph objects, presumably created from run.polar().
#
# attribute.name -- the name of a vertex attribute whose assortativity is to
# be computed and plotted.
#
plot.polarization <- function(graphs, attribute.name="ideology") {
    assortativities <- sapply(graphs, function(graph) {
        assortativity(graph,
            types1=get.vertex.attribute(graph,attribute.name))
    })
    plot(1:length(graphs),assortativities, type="l",ylim=c(-1,1),
        main="Polarization over time", xlab="time (iteration)",
        ylab=paste("Assortativity of",attribute.name))
}



# Given a list of igraph objects representing an evolving graph, plot the 
# fraction of vertices with opinion 1 over time.
plot.binary.opinions <- function(graphs) {

    frac.opinion <- function(graph, opinion=0) {
        sum(V(graph)$opinion == opinion) / gorder(graph)
    }

    frac.1s <- sapply(graphs, frac.opinion)

    plot(1:length(graphs),frac.1s,ylim=c(0,1),type="l",col="blue",
        xlab="time (iteration)",ylab="Fraction of agents with opinion 1")
    abline(h=.5, lty="dashed", col="grey")
}
