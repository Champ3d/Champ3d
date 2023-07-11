function f_save_c3dobj(c3dobj,varargin)
%--------------------------------------------------------------------------
% CHAMP3D PROJECT
% Author : Huu-Kien Bui, IREENA Lab - UR 4642, Nantes Universite'
% Huu-Kien.Bui@univ-nantes.fr
% Copyright (c) 2022 H-K. Bui, All Rights Reserved.
%--------------------------------------------------------------------------

% --- valid argument list (to be updated each time modifying function)
arglist = f_arglist('save_c3dobj');

% --- default input value
options = 'minimum';

% --- check and update input
for i = 1:length(varargin)/2
    if any(strcmpi(arglist,varargin{2*i-1}))
        eval([lower(varargin{2*i-1}) '= varargin{2*i};']);
    else
        error([mfilename ': #' varargin{2*i-1} ' argument is not valid. Function arguments list : ' strjoin(arglist,', ') ' !']);
    end
end

%--------------------------------------------------------------------------
fname = [c3dobj.config.project_path '/c3dobj.mat'];
%--------------------------------------------------------------------------
if any(strcmpi(options,{'minimum'}))
    save(fname,'c3dobj','-v7.3');
elseif any(strcmpi(options,{'full'}))
    save(fname,'c3dobj','-v7.3');
end

end