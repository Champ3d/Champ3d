function parameter = f_make_parameter(varargin)
% Allow separated declaration of parameters with different dependency.
% 'f' : dependency function
%     + if a constant -> chose 'f' = value, ex. 'f' = 5
%     + give function handle for 'f'
%          * ex: 'f',@(a,b,c) a+b+c
% 'depend_on' :
%     + 'elem_temp' : (average) element temperature
%     + 'node_temp' : nodal temperature
%     + 'b' : induction (flux density)
%     + 'h' : magnetic field strength
% 'from' : physical problem
%     + 'heat'
%     + 'aphi_jw'
%     + 'aphi_t'
%     + 'tome_jw'
%     + 'tome_t'
%
% murPlate   = f_make_parameter('type','bh_nonlinear_curve','f',@(B) B,'depend_on','b','from','aphi_jw');
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'f','depend_on','from','id_design3d'};

% --- default input value
f = [];
depend_on = [];
from = [];
id_design3d = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(f)
    error([mfilename ' : #f must be given, numeric or function_handle !']);
else
    if isa(f,'numeric')
        ptype = 'number';
    elseif isa(f,'function_handle')
        ptype = 'function';
    end
end
%--------------------------------------------------------------------------
switch ptype
    case 'number'
        f = str2func(['@()' num2str(f)]);
    case 'function'
        %--------------------------------------------------------------------------
        if isempty(from)
            error([mfilename ': #from what ?!']);
        end
        %------------------------------------------------------------------
        depend_on = f_to_scellargin(depend_on);
        %------------------------------------------------------------------
        if nargin(f)
            if nargin(f) ~= length(depend_on)
                error([mfilename ': Check number of f arguments !']);
            end
        end
        %------------------------------------------------------------------
        from = f_to_scellargin(from);
        %------------------------------------------------------------------
        %if isempty(id_design3d)
        %    for i = 1:length(from)
        %        if any(strcmpi(from{i},{'emdesign3d','thdesign3d'}))
        %            iddes3d = fieldnames(c3dobj.(from{i}));
        %            id_design3d{i} = iddes3d{1};
        %        end
        %    end
        %else
        %    id_design3d = f_to_scellargin(id_design3d);
        %end
        %------------------------------------------------------------------
        id_design3d = f_to_scellargin(id_design3d);
        %------------------------------------------------------------------
        while ((length(depend_on) ~= length(from)) || ...
               (length(depend_on) ~= length(id_design3d)) || ...
               (length(from) ~= length(id_design3d)))
            [depend_on,from] = f_pairing_scellargin(depend_on,from);
            [id_design3d,from] = f_pairing_scellargin(id_design3d,from);
            [id_design3d,depend_on] = f_pairing_scellargin(id_design3d,depend_on);
        end
end
%--------------------------------------------------------------------------
% --- Output
parameter.f = f;
parameter.design3d = from;
parameter.id_design3d = id_design3d;
parameter.field = depend_on;


