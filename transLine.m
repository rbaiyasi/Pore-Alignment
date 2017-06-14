function [ beta1 ] = transLine( beta0 )
%transLine for an input [slope,intercept], return the transposed
%[slope,intercept]
m0 = beta0(1);
b0 = beta0(2);

m1 = 1/m0;
b1 = -b0/m0;

beta1 = [ m1 , b1 ];
