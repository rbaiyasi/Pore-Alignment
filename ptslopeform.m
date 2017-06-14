function [ b ] = ptslopeform( m , p0 )
%pointslopesolver Uses input slope and single point to calculate intercept
b = p0(2) - m*p0(1);