# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Champ3d is a pure-MATLAB framework for computational physics in electrical engineering (electromagnetics, thermal, electric circuits) using FEM/DDM/BEM on 2D and 3D meshes. It requires only standard MATLAB — no toolboxes. GPL v3, copyright H-K. Bui.

## Running code

There is no build step or linter (the GitHub workflow is a no-op). Unit tests are `matlab.unittest` classes under `utest/`, one folder per feature — e.g. `addpath('utest/testParameter'); runtests('TestParameter')`. Their `.mat` fixtures are gitignored and regenerated on first run by each folder's `run_create_*` function. Development happens inside MATLAB:

- Add the repo folders (`ch3obj` and its subfolders, `utils` subfolders, root) to the MATLAB path, then run `set_up.m` (sets figure defaults and the FEMM path on Windows).
- `Ch3Config.m` holds machine-specific paths to optional external tools (LTSpice, OpenSCAD, Gmsh, FEMM). It is user-edited per machine — avoid committing changes to it.
- The scripts in `tutorial/` are runnable end-to-end examples and the best reference for correct API usage (e.g. `tuto_IH_03.m` shows the full mesh → physics → coupling → solve → plot workflow).

## Architecture

All framework classes live in `ch3obj/` (flat on the path, not packages) and derive from `Xhandle < matlab.mixin.Copyable` ([ch3obj/Xhandle.m](ch3obj/Xhandle.m)) — handle objects identified by a string `id`, with `dependent_obj`/`defining_obj` links used for dependency tracking between objects.

**Conventions used everywhere:**
- Constructors and `add_*` methods take name–value pair arguments: `Mesh1d(); m.add_line1d('id','xcoil','len',5e-3,'dnum',4,'dtype','lin')`. Argument parsing helpers are in `utils/argin/` (`f_getvalue`, `f_validvarargin`, …).
- Objects are wired together by string ids, not references: domains, coils, conductors are created with an `'id'` and referenced later via `'id_dom3d'`, `'id_meshdom'`, etc. Id patterns support `'...'` wildcards (`'x...'` = all ids starting with `x`, in creation order).
- `Xhandle` overloads `<=` (`obj <= args`) to bulk-assign a struct of parsed arguments onto object properties; constructors use this idiom.
- Utility functions in `utils/` are prefixed `f_` (e.g. `f_color`, `f_getvalue`).

**Mesh layer** (dimensional extrusion pipeline): `Mesh1d` (named `Line1d` segments with distribution types `lin`, `log-`, `log+`, `log=`) → `QuadMeshFrom1d`/`TriMesh` → `HexaMeshFromQuadMesh`/`PrismMesh`/`TetraMesh`. Named volume/surface domains are declared on meshes with `add_vdom`/`add_sdom` and are the handles by which physics attaches to geometry. Meshes support `centering`, `lock_origin`, and `plot`. Alternative mesh sources: `ch3obj/Shape/` (CSG shapes written to Gmsh `.geo` via `GMSHWriter`, meshed with `TetraMeshFromGMSH`), `FEMMinterface/`, `PDEToolInterface/`.

**Physics layer**: `PhysicalModel` → `EmModel`/`ThModel` → concrete formulations named by formulation and regime, e.g. `FEM3dAphi` (magnetostatics), `FEM3dAphijw` (magnetodynamics, frequency domain), `FEM3dAphits` (time stepping), `FEM3dTherm`, `FEM3dV*`. A model is built on a mesh (`'parent_mesh'`), populated with physical-domain objects from `ch3obj/PhysicalDomAphi/` (coil variants, `Econductor`, `PMagnet`, `Airbox`, `Sibcjw` surface impedance, `Nomesh`, …) or `ch3obj/PhysicalDomTherm/` via `add_coil`, `add_econductor`, `add_sibc`, `add_convection`, `add_thconductor`, `add_pv`, etc., then run with `.solve`. Results are `Field` objects (see below) accessed as `model.field{it}.J.elem`, `.P.face`, etc., each plottable per mesh domain (`plot('id_meshdom',...)`).

**Numeric data layers** (`ch3obj/Array/`, `ch3obj/Dof/`, `ch3obj/Field/`):
- `Array` (abstract, in `ch3obj/Array/`) wraps per-entity numeric data in `TensorArray`/`VectorArray` (a `.value` matrix plus optional `parent_dom`) and overloads arithmetic operators (`mtimes`, …) to perform element-wise tensor/vector algebra — this is how material tensors are applied to field vectors. `Array.create(array, ...)` is a factory that picks the subclass from the array shape; plain numeric operands are auto-wrapped in operator overloads. `LTensor` builds on this layer.
- `ch3obj/Dof/` holds the solution unknowns: `NodeDof`, `EdgeDof`, `FaceDof` are vectors sized to the parent model's mesh entity counts (`nb_node`/`nb_edge`/`nb_face`), with size-checked assignment and scalar broadcast via `set.value`. Formulations map onto them naturally (nodal scalar potentials → `NodeDof`, edge vector potential → `EdgeDof`, face fluxes → `FaceDof`).
- `Field` (`ch3obj/Field/`) derives from `Array` and represents post-processed quantities along two orthogonal axes: support (`NodeField`/`ElemField`/`FaceField` — where values live on the mesh) × rank (scalar/`VectorField`), combined by multiple inheritance (e.g. `VectorElemField < ElemField & VectorField`). `*DofBased*` subclasses (e.g. `EdgeDofBasedVectorElemField`) evaluate a `Dof` through the mesh shape functions; formulation-specific classes (`JAphi*`, `HAphi*`, `PAphi*`, `WmAphi*`) compute J, H, losses, and magnetic energy for the A-phi formulation. Fields use a custom `subsref` evaluation-point convention: `field([idx])` evaluates at element centers (`cvalue`), `field({[idx]})` at interpolation points (`ivalue`), `field({{[idx]}})` at Gauss points (`gvalue`); empty brackets mean all entities.

**Coupling and parameters**: `ch3obj/XParameter/` (`ScalarParameter`, `VectorParameter`, `TensorParameter`) express dependencies between models — e.g. a thermal source depending on EM losses: `ScalarParameter('f',@(x)(x),'depend_on','P','from',em_02)`. This is the weak-coupling mechanism between multiphysics models. `LTensor` builds anisotropic material tensors from directional values. `LTime` provides time stepping (`add_ltime`), and `MovingFrame` subclasses (`LinearMovingFrame`, `RotationalMovingFrame`) provide motion, with steps that can themselves be parameters depending on `ltime`. Strong coupling and domain decomposition live in `ch3obj/CouplingModel/`.

## Repository layout notes

- `workspace/` is a collaboration scratch area: one folder per git branch (branches are named after GitHub issues, e.g. `49-core-dev-reorg-07-26`), with subfolders per contributor. Files prefixed `x__`/`X__` are private and gitignored. See [workspace/README.md](workspace/README.md).
- `outsource/` is third-party code (elfun18, LTspice2Matlab) — do not modify.
- Work-in-progress classes may sit at the repo root (e.g. `OxyCoil6.m`) before being moved into `ch3obj/`.
- Every source file carries the GPL header block naming H-K. Bui; new framework files should keep this convention.
