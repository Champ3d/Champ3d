function ivec = f_findvecnd(vin,vref,varargin)
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
sizeref = size(vref);
sizein  = size(vin);
dimref  = sizeref(1);
lenref  = sizeref(2);
dimin   = sizein(position);
%--------------------------------------------------------------------------
if dimref ~= dimin
    error([mfilename ': #vref and #vin do not have the same dimension !']);
end
if length(sizeref) > 2
    error([mfilename ': size of #vref must be [dim x nb_vec] !']);
end
%--------------------------------------------------------------------------
[vin, rp, rl] = f_flatvec(vin,'position',position);
%--------------------------------------------------------------------------
svin  = f_magicsum(vin,'position',1);
svref = f_magicsum(vref,'position',1);
%--------------------------------------------------------------------------
iref = 1:lenref;
%-----
ivec = interp1(svref,iref,svin,'nearest');
%--------------------------------------------------------------------------
ivec = f_iflatvec(ivec, 'return_position_list', rp, 'return_len_list', rl, ...
                        'for_index',1);


end