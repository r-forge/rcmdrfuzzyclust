#' Fuzzy C-Means
#'
#' @description This function used to perform Fuzzy C-Means of X dataset.
#'
#' @param X data frame n x p
#' @param K specific number of cluster (must be >1)
#' @param m fuzzifier / degree of fuzziness
#' @param max.iteration maximum iteration to convergence
#' @param threshold threshold of convergence
#' @param RandomNumber specific seed
#'
#' @return func.obj objective function that calculated.
#' @return U matrix n x K consist fuzzy membership matrix
#' @return V matrix K x p consist fuzzy centroid
#' @return D matrix n x K consist distance of data to centroid that calculated
#' @return Clust.desc cluster description (dataset with additional column of cluster label)
#'
#' @details This function perform Fuzzy C-Means algorithm by Bezdek (1981).
#' Fuzzy C-Means is one of fuzzy clustering methods to clustering dataset
#' become K cluster. Number of cluster (K) must be greater than 1. To control the overlaping
#' or fuzziness of clustering, parameter m must be specified.
#' Maximum iteration and threshold is specific number for convergencing the cluster.
#' Random Number is number that will be used for seeding to firstly generate fuzzy membership matrix.
#' @details Clustering will produce fuzzy membership matrix (U) and fuzzy cluster centroid (V).
#' The greatest value of membership on data point will determine cluster label.
#' Centroid or cluster center can be use to interpret the cluster. Both membership and centroid produced by
#' calculating mathematical distance. Fuzzy C-Means calculate distance with Euclideans norm. So it can be said that cluster
#' will have sperichal shape of geometry.
#'
#' @export

fuzzy.CM<-function(X,...) UseMethod("fuzzy.CM")
fuzzy.CM.default <- function(X,K=2,m=2,max.iteration=1000,threshold=10^-9,
                     RandomNumber=0) {
  ## Set data
  library(MASS)
  data.X <- as.matrix(X)
  n <- nrow(data.X)
  p <- ncol(data.X)
  ##Initiation Parameter##
  if (
    (K <= 1) || !(is.numeric(K)) || (K %% ceiling(K) > 0))
    K = 2
  if ( (m <= 1) || !(is.numeric(m)))
    m = 2
  if (RandomNumber > 0)
    set.seed(RandomNumber)
  if(length(rho)!=K)
    rho = rep(1,K)

  ## Membership Matrix U (n x K)
  U <- matrix(runif(n * K,0,1),n,K)

  ## Prerequirement of U:
  ## Sum of membership on datum is 1
  U <- U / rowSums(U)

  ## Centroid Matrix V (K x p)
  V <- matrix(0,K,p)


  ## Distance Matrix
  D <- matrix(0,n,K)

  U.old <- U + 1
  iteration = 0
  while ((max(abs(U.old - U)) > threshold) &&
         (iteration < max.iteration))
  {
    U.old <- U
    ## Calculate Centroid
    V <- t(U ^ m) %*% data.X / colSums(U ^ m)
    for (k in 1:K)
    {
      #Distance calculation
      for (i in 1:n)
      {
        D[i,k] = t(data.X[i,] - V[k,]) %*%
          (data.X[i,] -V[k,])
      }
    }
    D<-(D+10^-10)
    ##FUZZY PARTITION MATRIX
    for (i in 1:n)
    {
      U[i,] <- 1 /
        (((D[i,]+10^-10) ^ (1 / (m - 1))) *
           sum((1 / (D[i,]+10^-10)) ^ (1 /(m - 1))))
    }
    for (i in 1:n)
      for (k in 1:K) {
        if (U[i,k] < 0)
          U[i,k] = 0
        else if (U[i,k] > 1)
          U[i,k] = 1
      }
    func.obj = 0
    func.obj = sum(U ^ m * D)
    iteration = iteration + 1
  }
  func.obj -> func.Obj.opt
  U -> U.opt
  V -> V.opt
  D -> D.opt
  ###Labelling###
  colnames(U.opt) = paste("Clust",1:K,sep = " ")
  Clust.desc <- matrix(0,n,p + 1)
  rownames(Clust.desc) <- rownames(X)
  colnames(Clust.desc) <- c(colnames(X),"cluster")
  Clust.desc[,1:p] <- data.X
  for (i in 1:n)
    Clust.desc[i,p + 1] <- which.max(U.opt[i,])
  result <- list()
  result$func.obj <- func.Obj.opt
  result$U <- U.opt
  result$V <- V.opt
  result$D <- D.opt
  result$m <- m
  result$call<-match.call()
  result$Clust.desc <- Clust.desc
  class(result)<-"fuzzy.cm"
  return(result)
}
print.fuzzy.cm<-function(x,..){
  cat("Call:\n")
  print(x$call)
  cat("\nObjective Function:",x$func.obj)
  cat("\nfuzzifier:",x$m)
  cat("\nCentroid:\n")
  print(x$V)
  cat("\nCluster Label:\n")
  print(x$Clust.desc[,ncol(x$Clust.desc)])
  cat("\nOther result available: U V D")
}