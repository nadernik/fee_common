function d = divisors(n)
%DIVISORS All possible divisors.
%
%   DIVISORS(N) returns a vector with all possible divisors of N.
%
%   The algorithm is not very efficient.
%
%   See also FACTOR.

%   Author:      Peter J. Acklam
%   Time-stamp:  2004-04-11 23:02:04 +0200
%   E-mail:      pjacklam@online.no
%   URL:         http://home.online.no/~pjacklam

   error(nargchk(1, 1, nargin));

   d = 1 : (n / 2);
   q = n ./ d;
   d = d(q == round(q));
   d(end + 1) = n;
