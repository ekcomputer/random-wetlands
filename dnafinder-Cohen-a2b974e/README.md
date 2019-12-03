# Cohen
This function computes the Cohen's kappa coefficient<br/>
Cohen's kappa coefficient is a statistical measure of inter-rater
reliability. It is generally thought to be a more robust measure than
simple percent agreement calculation since k takes into account the
agreement occurring by chance.
Kappa provides a measure of the degree to which two judges, A and B,
concur in their respective sortings of N items into k mutually exclusive
categories. A 'judge' in this context can be an individual human being, a
set of individuals who sort the N items collectively, or some non-human
agency, such as a computer program or diagnostic test, that performs a
sorting on the basis of specified criteria.
The original and simplest version of kappa is the unweighted kappa
coefficient introduced by J. Cohen in 1960. When the categories are
merely nominal, Cohen's simple unweighted coefficient is the only form of
kappa that can meaningfully be used. If the categories are ordinal and if
it is the case that category 2 represents more of something than category
1, that category 3 represents more of that same something than category
2, and so on, then it is potentially meaningful to take this into
account, weighting each cell of the matrix in accordance with how near it
is to the cell in that row that includes the absolutely concordant items.
This function can compute a linear weights or a quadratic weights.

Syntax: 	kappa(X,W,ALPHA)
     
    Inputs:
          X - square data matrix
          W - Weight (0 = unweighted; 1 = linear weighted; 2 = quadratic
          weighted; -1 = display all. Default=0)
          ALPHA - default=0.05.

    Outputs:
          - Observed agreement percentage
          - Random agreement percentage
          - Agreement percentage due to true concordance
          - Residual not random agreement percentage
          - Cohen's kappa 
          - kappa error
          - kappa confidence interval
          - Maximum possible kappa
          - k observed as proportion of maximum possible
          - k benchmarks by Landis and Koch 
          - z test results

     Example: 

          x=[88 14 18; 10 40 10; 2 6 12];

          Calling on Matlab the function: kappa(x)

          Answer is:

UNWEIGHTED COHEN'S KAPPA
--------------------------------------------------------------------------------
Observed agreement (po) = 0.7000<br/>
Random agreement (pe) = 0.4100<br/>
Agreement due to true concordance (po-pe) = 0.2900<br/>
Residual not random agreement (1-pe) = 0.5900<br/>
Cohen's kappa = 0.4915<br/>
kappa error = 0.0549<br/>
kappa C.I. (alpha = 0.0500) = 0.3839     0.5992<br/>
Maximum possible kappa, given the observed marginal frequencies = 0.8305<br/>
k observed as proportion of maximum possible = 0.5918<br/>
Moderate agreement<br/>
Variance = 0.0031     z (k/sqrt(var)) = 8.8347    p = 0.0000<br/>
Reject null hypotesis: observed agreement is not accidental<br/>

          Created by Giuseppe Cardillo
          giuseppe.cardillo-edta@poste.it

To cite this file, this would be an appropriate format:
Cardillo G. (2007) Cohen's kappa: compute the Cohen's kappa ratio on a square matrix.   
http://www.mathworks.com/matlabcentral/fileexchange/15365
