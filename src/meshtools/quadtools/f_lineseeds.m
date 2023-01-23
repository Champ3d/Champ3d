function  line2d = f_lineseeds(line2d,varargin)

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
arglist = {'id','bline','tline','lline','rline','zonetype'};

% --- default input value
id = [];
bline = [];
tline = [];
lline = []; 
rline = [];
zonetype = 'rect';
% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end