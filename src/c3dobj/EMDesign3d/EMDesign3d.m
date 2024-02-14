%--------------------------------------------------------------------------
% This code is written by: H-K. Bui, 2024
% as a contribution to champ3d code.
%--------------------------------------------------------------------------
% champ3d is copyright (c) 2023 H-K. Bui.
% See LICENSE and CREDITS files in champ3d root directory for more information.
% Huu-Kien.Bui@univ-nantes.fr
% IREENA Lab - UR 4642, Nantes Universite'
%--------------------------------------------------------------------------

classdef EMDesign3d < Xhandle

    % --- Properties
    properties
        info
        % ---
        fr
        jome
        % ---
        econductor
        mconductor
        airbox
        bc
        bsfield
        coil
        nomesh
        pmagnet
    end

    % --- Dependent Properties
    properties (Dependent = true)
        
    end

    % --- Constructors
    methods
        function obj = EMDesign3d(args)
            arguments
                % ---
                args.info = 'no_info'
                args.fr = []
                
            end
            % ---
            obj <= args;
            % ---
            obj.jome = 1j*2*pi*obj.fr;
        end
    end

    % --- Methods
    methods
        
    end

    % --- Methods
    methods (Access = protected, Hidden)
        % -----------------------------------------------------------------
        function add_econductor(obj)
        end
        % -----------------------------------------------------------------
        function add_airbox(obj) 
        end
        % -----------------------------------------------------------------
        function add_nomesh(obj) 
        end
        % -----------------------------------------------------------------
        function add_sibc(obj) 
        end
        % -----------------------------------------------------------------
        function add_bsfield(obj) 
        end
        % -----------------------------------------------------------------
        function add_embc(obj) 
        end
        % -----------------------------------------------------------------
        function add_open_iscoil(obj) 
        end
        % -----------------------------------------------------------------
        function add_close_iscoil(obj) 
        end
        % -----------------------------------------------------------------
        function add_open_jscoil(obj) 
        end
        % -----------------------------------------------------------------
        function add_close_jscoil(obj) 
        end
        % -----------------------------------------------------------------
        function add_open_vscoil(obj) 
        end
        % -----------------------------------------------------------------
        function add_close_vscoil(obj) 
        end
        % -----------------------------------------------------------------
        function add_mconductor(obj) 
        end
        % -----------------------------------------------------------------
        function add_pmagnet(obj) 
        end
        % -----------------------------------------------------------------
    end
end
