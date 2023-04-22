function design3d = f_add_econductor(design3d,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'design3d','id_econductor','id_dom3d','id_elem','sigma'};

% --- default input value
id_dom3d = [];
id_elem  = [];
sigma    = 0;
id_econductor = [];

%--------------------------------------------------------------------------
if ~isfield(design3d,'econductor')
    design3d.econductor = [];
end
%--------------------------------------------------------------------------
if nargin <= 1
    error([mfilename ': No econductor to add!']);
end
%--------------------------------------------------------------------------
% --- check and update input
for i = 1:(nargin-1)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------

if isempty(id_econductor)
    error([mfilename ': id_econductor must be defined !'])
end

if ~isfield(design3d,'dom3d')
    error([mfilename ': dom3d is not defined !']);
end

if isempty(id_dom3d) && isempty(id_elem)
    error([mfilename ': id_dom3d or id_elem must be defined !'])
end

%--------------------------------------------------------------------------
if isempty(id_elem)
    design3d.econductor.(id_econductor).id_elem  = design3d.dom3d.(id_dom3d).id_elem;
else
    design3d.econductor.(id_econductor).id_elem  = id_elem;
end
% ---
design3d.econductor.(id_econductor).id_dom3d = id_dom3d;
design3d.econductor.(id_econductor).sigma = sigma;

% --- info message
fprintf(['Add econ ' id_econductor ' - done \n']);



%
% if isstruct(sigma)
%     design3d.econductor.(id_econductor).sigma = sigma;
% elseif isnumeric(sigma)
%     if numel(sigma) == 1 % scalar
%     design3d.econductor.(id_econductor).sigma = ...
%         f_make_gtensor('type','gtensor','main_value',sigma,'ort1_value',sigma,'ort2_value',sigma,...
%                        'main_dir',[1 0 0],'ort1_dir',[0 1 0],'ort2_dir',[0 0 1]);
%     end
%     if numel(sigma) == 9 % tensor
%         design3d.econductor.(id_econductor).sigma = sigma;
%     end
% end

