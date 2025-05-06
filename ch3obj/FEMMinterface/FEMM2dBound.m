%--------------------------------------------------------------------------
% Interface to FEMM
% FEMM (c) David Meeker 1998-2015
%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2025
% as a contribution to Champ3d code.
%--------------------------------------------------------------------------
% Champ3d is copyright (c) 2023-2025 H-K. Bui.
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
% See LICENSE and CREDITS files for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef FEMM2dBound < Xhandle
    properties
        id_bc
        id_box
        choosed_by
        max_segment_len = 0
        max_segment_arclen = 0
        auto_mesh = 1
        % ---
        parent_model
    end
    % --- Constructor
    methods
        function obj = FEMM2dBound()
            obj@Xhandle
        end
    end
    % --- Methods/public
    methods (Access = public)
        function setup(obj)
            if f_strcmpi(obj.choosed_by,{'all'})
                choosed_by_ = {'bottom','top','left','right'};
            else
                choosed_by_ = {obj.choosed_by};
            end
            % ---
            for i = 1:length(choosed_by_)
                boline = obj.parent_model.box.(obj.id_box).bound.(choosed_by_{i});
                mi_selectgroup(boline.id);
                if any(f_strcmpi(boline.type,{'segment','line'}))
                    mi_setsegmentprop(obj.id_bc,obj.max_segment_len,obj.auto_mesh,0,boline.id);
                elseif any(f_strcmpi(boline.type,{'arc_segment','arc'}))
                    mi_setarcsegmentprop(obj.max_segment_arclen,obj.id_bc,0,boline.id);
                end
            end
        end
    end
    % --- Methods/protected
    methods (Access = protected)
    end
    % --- Methods/private
    methods (Access = private)
    end
end