function [vout, ivout] = f_intersectvec(vin1,vin2,varargin)
% F_FINDVEC returns the idx of vectors in a array of reference vectors
%--------------------------------------------------------------------------
% FIXED INPUT
% vin : nD x nb_vectors
% vref : nD x nb_vectors
%--------------------------------------------------------------------------
% OPTIONAL INPUT
% 'urow','row','r','ucol','col','c'
%--------------------------------------------------------------------------
% OUTPUT
% ivec : indices of found vectors.
%--------------------------------------------------------------------------
% EXAMPLE
% ivec = F_FINDVEC(vin,vref);
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'position'};

% --- default input value
position = 1; % index of the dimension

%--------------------------------------------------------------------------
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
size1 = size(vin1);
dim1  = size1(position);
size2 = size(vin2);
dim2  = size2(position);
%--------------------------------------------------------------------------
if dim1 ~= dim2
    error([mfilename ': #vin1 and #vin2 do not have the same dimension !']);
end
%--------------------------------------------------------------------------
if position > 2 || position < 1
    error([mfilename ': #vin1 and #vin2 must have dimension-2 !']);
end
%--------------------------------------------------------------------------
svin1 = f_magicsum(vin1,'position',position);
svin2 = f_magicsum(vin2,'position',position);
%--------------------------------------------------------------------------
[~,ivout] = intersect(svin1,svin2);
%--------------------------------------------------------------------------
vout = vin1(:,ivout);
%--------------------------------------------------------------------------

end