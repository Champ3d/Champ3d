function integ = f_0o_integral(node,elem,varargin)
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
arglist = {'defined_on','coefficient','vector_field'};

% --- default input value
defined_on = [];
coefficient = [];
vector_field = [];

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if isempty(defined_on)
    error([mfilename ': #defined_on must be given !']);
end
%--------------------------------------------------------------------------
chavec = f_chavec(node,elem,'defined_on',defined_on);
elmeas = f_measure(node,elem,'defined_on',defined_on);
%--------------------------------------------------------------------------
chavecx = chavec(1,:);
chavecy = chavec(2,:);
chavecz = chavec(3,:);
%--------------------------------------------------------------------------
if isempty(coefficient)
    coef_array = 1;
    coef_array_type = 'iso_array';
else
    [coef_array, coef_array_type] = f_tensor_array(coefficient);
end
%--------------------------------------------------------------------------
if isempty(vector_field)
    vfx = 1;
    vfy = 1;
    vfz = 1;
else
    vfx = vector_field(:,1);
    vfy = vector_field(:,2);
    vfz = vector_field(:,3);
end
%--------------------------------------------------------------------------
if any(strcmpi(coef_array_type,{'iso_array'}))
    %----------------------------------------------------------------------
    integ = coef_array .* elmeas .* ...
            (chavecx .* vfx + chavecy .* vfy + chavecz .* vfz);
    %----------------------------------------------------------------------
elseif any(strcmpi(coef_array_type,{'tensor_array'}))
    %----------------------------------------------------------------------
    integ = elmeas .* ...
              ( coef_array(:,1,1) .* chavecx .* vfx +...
                coef_array(:,1,2) .* chavecy .* vfx +...
                coef_array(:,1,3) .* chavecz .* vfx +...
                coef_array(:,2,1) .* chavecx .* vfy +...
                coef_array(:,2,2) .* chavecy .* vfy +...
                coef_array(:,2,3) .* chavecz .* vfy +...
                coef_array(:,3,1) .* chavecx .* vfz +...
                coef_array(:,3,2) .* chavecy .* vfz +...
                coef_array(:,3,3) .* chavecz .* vfz );
    %----------------------------------------------------------------------
end


