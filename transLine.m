function [ beta1 ] = transLine( beta0 )
%transLine for an input [slope;intercept], return the transposed
%[slope;intercept] (column vectors)
beta1 = zeros(size(beta0));
for k = 1:size(beta0,2)
    m0 = beta0(1,k);
    b0 = beta0(2,k);

    m1 = 1/m0;
    b1 = -b0/m0;

    beta1(:,k) = [ m1 ; b1 ];
end