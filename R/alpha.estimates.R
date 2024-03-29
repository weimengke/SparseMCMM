#require(nloptr)

####### parameter estimation for the log contrast model regrssion
##penalty tuning parameter settings

alpha.estimates=function(Treatment,otu.com,outcome,covariates=NULL,
                         penalty.lambda1=seq(0,1,0.1),penalty.lambda2=seq(0,2,0.2),
                         low.bound=NULL,up.bound=NULL,
                         max.iter=3000)
{
  sample.num=nrow(otu.com);p=ncol(otu.com)

  if(is.null(covariates)) q=0 else q=ncol(covariates)


  alpha.initial=rep(0,(2+q+2*p))


  BIC=estimates=NULL

  for(lambda1 in penalty.lambda1)
  {

    for(lambda2 in penalty.lambda2)
    {
      qq=nloptr( x0=alpha.initial,
                 toOpt,
                 lb=low.bound,
                 ub=up.bound,
                 eval_g_eq=eqCon,
                 opts =list( "algorithm" = "NLOPT_LD_SLSQP",
                             "xtol_rel" = 1.0e-4,
                             "maxeval"= max.iter),
                 Treatment=Treatment,Z=log(otu.com),outcome=outcome,
                 covariates=covariates,lambda=c(lambda1,lambda2))

      if(qq$status %in% c(1,3,4)){

        estimates1=round(qq$solution,3)
        estimates=rbind(estimates,estimates1)

        BIC=c(BIC,
              log(SSR(estimates1,Treatment=Treatment,covariates=covariates,Z=log(otu.com),outcome=outcome)/(sample.num-1))+
                sum(estimates1!=0)*log(sample.num)/sample.num)
      }}}

  if(length(BIC)==0) alpha.estimates=alpha.initial else alpha.estimates=estimates[which.min(BIC),]

  return(alpha.estimates)

}





