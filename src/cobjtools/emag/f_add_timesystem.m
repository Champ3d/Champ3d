function c3dobj = f_add_timesystem(c3dobj,varargin)
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2023
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'id_timesystem','time_array'};

% --- default input value
id_timesystem = [];
time_array = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(id_timesystem)
    id_timesystem = 'timesystem_01';
    %error([mfilename ' : #id_timesystem must be given !']);
end
%--------------------------------------------------------------------------
c3dobj.timesystem.(id_timesystem).time_array   = time_array;

% --- Log message
f_fprintf(0,'Add #timesystem',1,id_timesystem,0,'\n');





