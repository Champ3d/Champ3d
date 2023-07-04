function scellargin = f_to_scellargin(argin,varargin)
%F_TO_SCELLARGIN : returns a single cell argin from double cell or string
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = {'forced'};

% --- default input value
forced = 0;
% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': Check function arguments : ' strjoin(arglist,', ') ' !']);
    end
end
%--------------------------------------------------------------------------
if ~iscell(argin)
    argin = {argin};
end
%--------------------------------------------------------------------------
k = 0;
scellargin = {};
for i = 1:length(argin)
    if iscell(argin{i})
        for j = 1:length(argin{i})
            if iscell(argin{i}{j})
                for m = 1:length(argin{i}{j})
                    if iscell(argin{i}{j}{m})
                        error([mfilename() ' : cell structure too profond !'])
                    else
                        k = k + 1;
                        scellargin{k} = argin{i}{j}{m};
                    end
                end
            else
                k = k + 1;
                scellargin{k} = argin{i}{j};
            end
        end
    else
        k = k + 1;
        scellargin{k} = argin{i};
    end
end





