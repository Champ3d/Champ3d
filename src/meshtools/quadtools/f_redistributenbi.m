function line2d = f_redistributenbi(line2d,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------
cr = copyright();
if ~strcmpi(cr(1:49), 'Champ3d Project - Copyright (c) 2022 Huu-Kien Bui')
    error(' must add copyright file :( ');
end
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'ilfix','ilfree','nbi'};

% --- default input value
ilfix = [];
ilfree = [];
nbi = 1;

% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
nbifix = sum([line2d(ilfix).nbi]);
nbirem = nbi - nbifix;
nlfree = length(ilfree);
%--------------------------------------------------------------------------
if isempty(ilfree) && (nbirem ~= 0)
    error([mfilename ': No free lines to redistribute !']);
elseif nbirem < 0
    error([mfilename ': nbi < nbi fixed, too low to be redistributed !']);
elseif isempty(ilfree) && (nbirem == 0)
    % everything was fine
    return
end
%--------------------------------------------------------------------------
% try to distribute equally
% but may be random in unsolvable
nbidis = floor(nbirem/nlfree);
distributed = 0;
for il = 1:nlfree-1
    line2d(ilfree(il)).nbi = nbidis;
    distributed = distributed + line2d(ilfree(il)).nbi;
end
line2d(ilfree(end)).nbi = nbirem - distributed;
%--------------------------------------------------------------------------
% lz = [line2d(ilfree(end)).linezone];
% for iz = 1:length(lz)
%     zone2d(lz(iz)).divisible = 0; % change zone status
% end


