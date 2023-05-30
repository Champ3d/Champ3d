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
arglist = {'f','depend_on','from','b','h'};
% --- default input value
parameter.f = '';
parameter.depend_on = '';
parameter.from = '';
% --- check and update input
for i = 1:nargin/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        parameter.(lower(varargin{2*i-1})) = varargin{2*i};
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isa(parameter.f,'numeric')
    ptype = 'number';
elseif isa(parameter.f,'function_handle')
    ptype = 'function';
elseif isa(parameter.f,'char')
    ptype = 'data';
end
%--------------------------------------------------------------------------
switch ptype
    case 'number'
        parameter.f = str2func(['@()' num2str(parameter.f)]);
    case 'function'
        %------------------------------------------------------------------
        if ~iscell(parameter.depend_on)
            parameter.depend_on = {parameter.depend_on};
        end
        %------------------------------------------------------------------
        if nargin(parameter.f)
            if nargin(parameter.f) ~= length(parameter.depend_on)
                error([mfilename ': Check number of arguments !']);
            end
        end
    case 'data'
        %------------------------------------------------------------------
        dattype = {'bhdata','bhfunction'};
        if sum(any(strcmpi(dattype,parameter.f))) == 0
            error([mfilename ' : ' parameter.f ' is not support !']);
        end
        %------------------------------------------------------------------
        if strcmpi(parameter.f,'bhdata')
            parameter = f_calbhdata(parameter);
        end
        %------------------------------------------------------------------
end
%--------------------------------------------------------------------------




