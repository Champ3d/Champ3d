function coeftype = f_coeftype(coef)
% F_COEFTYPE
% coeftype supported :
% + numeric_iso_value
% + numeric_iso_array
% + numeric_gtensor_value
% + numeric_gtensor_array
% + numeric_ltensor_value
% + function_ltensor_array
% + function_iso_array
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
coeftype = [];
%--------------------------------------------------------------------------
sizecoef = size(coef);
%--------------------------------------------------------------------------
if isa(coef,'numeric')
    if numel(coef) == 1
        coeftype = 'numeric_iso_value';
    elseif sizecoef(1) == 1 || sizecoef(2) == 1
        coeftype = 'numeric_iso_array';
    elseif sizecoef(1) == 3 && sizecoef(2) == 3 && length(sizecoef) == 2
        coeftype = 'numeric_gtensor_value';
    elseif sizecoef(1) == 3 && sizecoef(2) == 3 && length(sizecoef) > 2
        coeftype = 'numeric_gtensor_array';
    else
        fprintf('coef = \n');
        disp(coef);
        error([mfilename ' : cannot define the type of the coefficient !']);
    end
elseif isa(coef,'struct')
    % ---------------------------------------------------------------------
    if isfield(coef,'main_value') && isfield(coef,'main_dir')
        coeftype = 'numeric_ltensor_value';
        paramconfig = fieldnames(coef);
        for i = 1:length(paramconfig)
            if isa(coef.(paramconfig),'function_handle')
                coeftype = 'function_ltensor_array';
                break;
            end
        end
    % ---------------------------------------------------------------------
    elseif isfield(coef,'f') && ~isfield(coef,'main_value')
        if isa(coef.f,'function_handle')
            coeftype = 'function_iso_array';
        else
            error([mfilename ' : #coefficient.f must be a function_handle !']);
        end
    end
    % ---------------------------------------------------------------------
else
    fprintf('coef = \n');
    disp(coef);
    error([mfilename ' : cannot define the type of the coefficient !']);
end