%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function check_discrete(obj)

% ---
elem_type_ = obj.elem_type;
%--------------------------------------------------------------
if any(f_strcmpi(elem_type_,{'tri', 'triangle', 'quad'}))
    if ~isempty(obj.discrete.div) && ~isempty(obj.discrete.rot) 
        if any(any(obj.discrete.div - obj.discrete.rot))
            if any(any(obj.discrete.div - (- obj.discrete.rot)))
                error([mfilename ': error on mesh entry, Div and Rot are not equal!']);
            end
        end
    end
    % ---
    if ~isempty(obj.discrete.rot) && ~isempty(obj.discrete.grad) 
        if any(any(obj.discrete.rot * obj.discrete.grad))
            error([mfilename ': error on mesh entry, RotGrad is not null !']);
        end
    end
    %----------------------------------------------------------
    %--- Log message
    f_fprintf(0,'--- check',1,'ok',0,'\n');
else
    if ~isempty(obj.discrete.div) && ~isempty(obj.discrete.rot) 
        if any(any(obj.discrete.div * obj.discrete.rot))
            error([mfilename ': error on mesh entry, DivRot is not null !']);
        end
    end
    % ---
    if ~isempty(obj.discrete.rot) && ~isempty(obj.discrete.grad) 
        if any(any(obj.discrete.rot * obj.discrete.grad))
            error([mfilename ': error on mesh entry, RotGrad is not null !']);
        end
    end
    %----------------------------------------------------------
    %--- Log message
    f_fprintf(0,'--- check',1,'ok',0,'\n');
end

end