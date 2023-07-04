function p_value = f_calparam(design3d,parameter,varargin)
% F_CALPARAM calculates and returns parameter value according to its dependency.
% p_value : array of values of the parameter computed for each element
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'design3d','parameter','id_elem'};
% --- default input value
id_elem = 1:design3d.mesh.nbElem;
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
% ---
nbElem = length(id_elem);

if isstruct(parameter)
    if isa(parameter.f,'function_handle')
        %----------------------------------------------------------------------
        alist = {};
        for ial = 1:nargin(parameter.f)
            alist{ial} = ['design3d.' parameter.from '.' parameter.depend_on{ial}];
        end
        %----------------------------------------------------------------------
        if nargin(parameter.f) == 0
            p_value = ones(1,nbElem) .* parameter.f();
        else
            %-----------------------------
            if isrow(eval(alist{ial}))
                argu = [alist{ial} '(:,id_elem)'];
            elseif iscolumn(eval(alist{ial}))
                argu = [alist{ial} '(id_elem,:)'];
            else
                argu = [alist{ial} '(:,id_elem)'];
            end
            %-----------------------------
            fform = 'feval(parameter.f';
            for ial = 1:nargin(parameter.f)
                fform = [fform ',' argu];
            end
            fform = [fform ');'];
            %-----------------------------
            p_value = eval(fform);
        end
        %----------------------------------------------------------------------
        if iscolumn(p_value)
            p_value = p_value.';
        end
        %----------------------------------------------------------------------
    elseif isa(parameter.f,'char')
        if strcmpi(parameter.f,'bhdata')      % -> to compute the inital solution
            p_value = max(parameter.mur) .* ones(1,nbElem);
        end
        if strcmpi(parameter.f,'bhfunction')  % -> to compute the inital solution
            % TODO
        end
    end
elseif isrow(parameter)    % for main_dir, ort1_dir, ort2_dir
    p_value = repmat(parameter,nbElem,1);
elseif iscolumn(parameter) % for main_dir, ort1_dir, ort2_dir
    p_value = repmat(parameter.',nbElem,1);
else
    error([mfilename ': Parameter error !']);
end

