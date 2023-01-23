function design3d = f_add_tconductor(design3d,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'design3d','id_tconductor','id_dom3d','id_elem','flambda','frho','fcp'};

% --- default input value
if isempty(design3d)
    design3d.tconductor = [];
end
id_dom3d = [];
id_elem  = [];
flambda  = [];
frho     = [];
fcp      = [];

%--------------------------------------------------------------------------
if ~isfield(design3d,'tconductor')
    iec = 0;
else
    iec = length(design3d.tconductor);
end

id_tconductor = ['tcon' num2str(iec+1)];

%--------------------------------------------------------------------------
if nargin <= 1
    error([mfilename ': No conductor to add!']);
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

if ~isfield(design3d,'dom3d')
    error([mfilename ': dom3d is not defined !']);
end

if isempty(id_dom3d)
    error([mfilename ': id_dom3d must be defined !'])
end

if ~isfield(design3d.dom3d,id_dom3d)
    error([mfilename ': ' id_dom3d ' is not defined !']);
end

%--------------------------------------------------------------------------
design3d.tconductor(iec+1).id_tconductor  = id_tconductor;
design3d.tconductor(iec+1).id_dom3d = id_dom3d;
if isempty(id_elem)
    design3d.tconductor(iec+1).id_elem  = design3d.dom3d.(id_dom3d).id_elem;
else
    design3d.tconductor(iec+1).id_elem  = id_elem;
end
design3d.tconductor(iec+1).flambda   = flambda;

%--------------------------------------------------------------------------
design3d.tconductor(iec+1).frho = frho;
design3d.tconductor(iec+1).fcp  = fcp;

end



