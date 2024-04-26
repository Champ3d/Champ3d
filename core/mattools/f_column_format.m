%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

function [colx,array_type] = f_column_format(x)

arguments
    x {mustBeNumeric}
end

% ---
x = squeeze(x);
% ---
sx = size(x);
lensx = length(sx);
% ---
if lensx > 3
    colx = x;
    array_type = '4+dimensional';
    return
end
% ---
if lensx == 2
    s1 = sx(1);
    s2 = sx(2);
    if s1 == s2
        if s1 == 1
            colx = x;
            array_type = 'scalar';
        else
            colx(1,:,:) = x;
            array_type = 'tensor';
        end
    elseif s1 < s2
        colx = x.';
        if s1 == 1
            if s2 > 3
                array_type = 'scalar';
            else
                array_type = {'scalar','vector'};
            end
        else
            array_type = 'vector';
        end
    else
        colx = x;
        if s2 == 1
            if s1 > 3
                array_type = 'scalar';
            else
                array_type = {'scalar','vector'};
            end
        else
            array_type = 'vector';
        end
    end
    % ---
    return
end
% ---
if lensx == 3
    s1 = sx(1);
    s2 = sx(2);
    s3 = sx(3);
    % ---
    if s1 == s2 && s2 == s3
        colx = x;
        if s1 <= 3
            array_type = 'tensor';
        else
            array_type = '4+dimensional';
        end
    else
        if s1 == s2
            ielem = 3;
            % ---
            if s1 <= 3
                array_type = 'tensor';
            else
                array_type = '4+dimensional';
            end
        elseif s1 == s3
            ielem = 2;
            % ---
            if s1 <= 3
                array_type = 'tensor';
            else
                array_type = '4+dimensional';
            end
        elseif s2 == s3
            ielem = 1;
            % ---
            if s2 <= 3
                array_type = 'tensor';
            else
                array_type = '4+dimensional';
            end
        else
            [~,ielem] = max(sx);
            array_type = '4+dimensional';
        end
        % ---
        ix = [1 2 3];
        ix(ielem) = [];
        ix = [ielem ix];
        colx = permute(x,ix);
    end
    % ---
    return
end
% --
if lensx > 3
    colx = x;
    array_type = '4+dimensional';
end


