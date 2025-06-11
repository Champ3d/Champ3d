# **Champ3d**
_Matlab Platform for Computational Physics in Electrical Engineering_
### Applications
- [x] Induction Welding/Heating
- [x] Rotational/Linear Electrical Machines
- [x] Inductive Power Transfer
- [x] Eddy Current Testing
### Supported models
**Champ3d** supports, when it's possible, all combinations of the models listed below:
- [x] Electromagnetic
  - [x] Magneto-dynamic
  - [x] Magneto-static
  - [x] Electro-static
  - [x] Electro-kinetic
  - [ ] Wave
- [x] Thermic
  - [x] Diffusion
  - [x] Convection
  - [x] Radiation
- [x] Electric circuit
  - [x] Weak coupling
  - [x] Strong coupling
### Numerical methods
+ [x] FEM
  - [x] 2D on quadrilateral and triangle mesh
  - [x] 3D on hexahedral, prismatic and tetrahedral mesh
- [x] FEM/DDM
- [x] FEM/BEM
### Dependency
+ Standard MATLAB without needs of additional toolboxes.
+ **Champ3d** provides several ways to create meshes programmatically.
+ You can also import extern mesh files to **Champ3d**.
### Optional dependency
* **FEMM**
  If you want to build 2D mesh with FEMM. On Windows, you should have FEMM installed with matlab/octave interface (*femm42\mfiles*).
  **Champ3d** provides also an interface to FEMM tools to build mesh much more conveniently.
* **OpenSCAD**
  Work on Windows/Mac.
* **PDE Tool (Matlab)**
  To build 3D mesh from SLT files and create tetrahedral mesh of simple objects.
* **LTSpice**
  To run programmatically electronic/electric circuit simulations. **Champ3d** provides an interface to LTSpice.
----

**Champ3d** is copyright (C) 2023-2025 H-K. Bui and distributed under the terms of the GNU GENERAL PUBLIC LICENSE Version 3. See LICENSE and CREDITS files for more information.
