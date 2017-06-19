function [ mu , sigma , final_iteration ] = extractBGstats( trace1 , std_fact )
%extractBGstats For an input time trace with bright spikes, determine the 
%background values such that they do not include bright spikes
%   Detailed explanation goes here

if numel(size(trace1)) == 3
    trace1 = mean(squeeze(mean(trace1)));
end
maxiter = 100;
keepids = true(size(trace1));
oldmean = NaN;
oldstd = NaN;
for k = 1:maxiter
    newmean = mean(trace1(keepids));
    newstd = std(trace1(keepids));
    if isequal(newmean,oldmean) && isequal(newstd,oldstd)
        final_iteration = k-1;
        mu = newmean;
        sigma = newstd;
        return
    else
        oldmean = newmean;
        oldstd = newstd;
        keepids = trace1 <= oldmean + std_fact*oldstd;
    end
end
error(['Did not converge in ',num2str(maxiter),' iterations'])

