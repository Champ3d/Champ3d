function f_comparestruct(str1, str2, varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'field_name'};

% --- default input value
field_name = 'all';

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
if any(strcmpi({'all','all_fields','all_field'},field_name))
    field_name = fieldnames(str1);
end
%--------------------------------------------------------------------------
if ~isempty(field_name)
    lenfn = length(field_name);
    fprintf('Comparison_______________________________________________\n');
    for i = 1:lenfn
        fn = field_name{i};
        if isfield(str1,fn) && isfield(str2,fn)
            if isnumeric(str1.(fn)) && isnumeric(str2.(fn))
                if all(size(str1.(fn)) == size(str2.(fn)))
                    eq = all(find(str1.(fn) - str2.(fn)));
                else
                    eq = 0;
                end
            end
            if ischar(str1.(fn)) && ischar(str2.(fn))
                eq = strcmp(str1.(fn), str2.(fn));
            end
            if eq == 1
                mess = 'equal';
            else
                mess = 'not-equal';
            end
            str_out = ['/' fn '/'];
            f_print({str_out,'is',mess},'pad_len',30);
        end
    end
    fprintf('_________________________________________________________\n');
end
%--------------------------------------------------------------------------
end