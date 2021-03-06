c  *********************************************************************
c  *                                                                   *
c  *                          function chdst                           *
c  *                                                                   *
c  *********************************************************************
c  Single Precision Version 1.0
c  Written by Gordon A. Fenton, DalTech, Dec 9, 1998
c  Latest Update: Dec 9, 1998
c
c  PURPOSE  returns the Chi-square distribution function for a
c           given x and dof n
c
c  This function employs the gamma distribution dgmdst, specialized
c  to produce the Chi-Square distribution results, to compute the
c  Chi-Square distribution function, that is the probability p such that
c  p = P[ X <= x], where X follows a Chi-square distribution with n
c  degrees of freedom. Arguments to the function are as follows;
c
c     x    real value giving the position at which the cumulative distribution
c          is desired. (input)
c
c     n    the number of degrees of freedom associated with the Chi-square
c          distribution. (input)
c
c  REVISION HISTORY:
c---------------------------------------------------------------------------
      real*4 function chdst( x, n )
      data two/2.0/

      pa = float(n)/two
      chdst = gmdst(x,pa,two)

      return
      end
