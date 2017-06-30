function [ finalPs , tfParams , MSEs , theta_hats ] = alignGrids( p0s , p1s )
%alignGrids Aligns a set of correlated points using rotation, scaling, and
%translation
%   INPUT:  p0s(p1s) - matrix of [x,y] row vectors where the points are
%               correlated with each other. p0s are the locked points,
%               while p1s are the points that are fit to p0s.
%   OUTPUT: tfParams - structure containing the various transformations p1s
%               must undergo to best fit p0s

%% Error Codes
numPtsError.identifier = 'FUNCTION:unmatchInputs';
numPtsError.message = 'Same number of input points required for p0s and p1s';
%% Minimization setup
% Convert position matrices to complex vectors
p0s = p0s(:,1) + 1i*p0s(:,2);
p1s = p1s(:,1) + 1i*p1s(:,2);

N = numel(p0s);
msefact = 1/N;
if ~isequal(numel(p1s),N)
    error(numPtsError)
end
onev = ones(N,1);
%% Anonymous functions
% error vector is p0s - exp(1i*phi_hat) - a*ones(N,1)
errVect = @(xtheta1)  p0s - exp(1i*xtheta1(1))*p1s - xtheta1(2)*onev;
calcGrad = @(xtheta2) [1i*exp(1i*xtheta2(1)')*p1s';-onev']*errVect(xtheta2);
calcPs = @(xtheta3) exp(1i*xtheta3(1))*p1s + xtheta3(2)*onev;

%% Minimization parameters
maxiter = 1000;
% step sizes are arbitrarily set at this point, by what works
stepsize = [1e-7;2e-2]*1e-1; %different step size for each parameter
theta_init = [0;0];
err_thresh = 0.005;

%% Minimization procedure
theta_hats = zeros(2,maxiter);
theta_hats(:,1) = theta_init;
MSEs = zeros(1,maxiter);
conv_flag = false;
for k = 1:maxiter
    % first check if it converged after the last loop
    err = errVect(theta_hats(:,k));
    MSE = msefact * (err' * err);
    MSEs(k) = MSE;
    if MSE < err_thresh
        disp(['Minimization converged in ',num2str(k),' iterations'])
        conv_flag = true;
        break
    end
    % calculate gradient and step forward
    grad = calcGrad(theta_hats(:,k));
    theta_hats(:,k+1) = theta_hats(:,k) - stepsize.*grad;
end
MSEs = MSEs(1:k);
theta_hats = theta_hats(:,1:k);
if ~conv_flag
    disp('Failed to converge')
end

final_theta = theta_hats(:,k);
finalPs = calcPs(final_theta);
finalPs = [real(finalPs),imag(finalPs)];
tfParams.phi = real(final_theta(1));
tfParams.c = exp(-imag(final_theta(1)));
tfParams.x0 = real(final_theta(2));
tfParams.y0 = imag(final_theta(2));