function cmatrix = f_cmatrix(coef,varargin)
% F_CMATRIX builds the coef matrix ready to pass to integral computation.
%--------------------------------------------------------------------------
% FIXED INPUT
% coef : coefficient
%   o scalar
%   o vector : dim x nbElem
%   o tensor : dim x dim
%   o matrix : dim x dim x nbElem
%--------------------------------------------------------------------------
% OPTIONAL INPUT
% 'id_elem' : array of indices of elements in the mesh
% 'dim' : dimension
% 'nbElem' : total number of element in the computation mesh
%--------------------------------------------------------------------------
% OUTPUT
% cmatrix : coefficient matrix
%   o 2D : 2 x 2 x nbElem
%   o 3D : 3 x 3 x nbElem
%--------------------------------------------------------------------------
% EXAMPLE
% cmatrix = F_CMATRIX(coef,'dim',3);
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
arglist = {'coef','dim','id_elem','nb_elem'};

% --- default input value
dim  = 3;
id_elem = [];
nb_elem  = 1;

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end
% --- no specified id_elem
if isempty(id_elem)
    id_elem = 1:nb_elem;
end
% --- default cmatrix
if dim == 2
    cmatrix = zeros(2,2,nb_elem);
elseif dim == 3
    cmatrix = zeros(3,3,nb_elem);
end

%--------------------------------------------------------------------------
scoef = size(coef);
if scoef(1) == 1 && scoef(2) == 1
    lenscoef = 1;
else
    lenscoef = length(scoef);
end

switch lenscoef
    case 1
        % -- scalar applied to all elem specified by id_elem
        for idim = 1:dim
            cmatrix(idim,idim,id_elem) = coef;
        end
    case 2
        if scoef(1) == 1
            % -- scalar applied to elem specified by id_elem
            if scoef(2) == nb_elem  % len coef = len all elem, coef constructed for all elem
                for idim = 1:dim
                    cmatrix(idim,idim,id_elem) = coef(1,id_elem);
                end
            elseif scoef(2) == length(id_elem) % coef constructed for elem specified by id_elem
                for idim = 1:dim
                    cmatrix(idim,idim,id_elem) = coef(1,:);
                end
            end
        elseif scoef(1) == 2 || scoef(1) == 3
            % -- tensor 2D or 3D applied to all elem specified by id_elem
            for idim = 1:dim
                for jdim = 1:dim
                    cmatrix(idim,jdim,id_elem) = coef(idim,jdim);
                end
            end
        end
    case 3
        % -- tensor 2D or 3D applied to elem specified by id_elem
        if scoef(3) == nb_elem  % len coef = len all elem, coef constructed for all elem
            for idim = 1:dim
                for jdim = 1:dim
                    cmatrix(idim,jdim,id_elem) = coef(idim,jdim,id_elem);
                end
            end
        elseif scoef(3) == length(id_elem) % coef constructed for elem specified by id_elem
            for idim = 1:dim
                for jdim = 1:dim
                    cmatrix(idim,jdim,id_elem) = coef(idim,jdim,:);
                end
            end
        end
end
