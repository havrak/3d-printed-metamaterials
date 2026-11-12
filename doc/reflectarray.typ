#import "config.typ": *

#align(center)[
    #text(size: 18pt, weight: "bold")[Reflectarray with LP $->$ CP Polarization Conversion] \
    #text(size: 14pt)[Deepdive on potential thesis topic] \
    #link("https://typst.app/project/wBQGVX8CTMedKqXLVoBbtb")[Online Version]
]


#show: conf

#outline()

#pagebreak()
= Reflectarray with LP $->$ CP Polarization Conversion
This document focuses on a potential topics of reflectarrays with unit cells that exhibit form-birefringerence -- that is they exhibit anisotropic properties. It builds on the general reflectarray and material observations recorded in `reserach.typ` file.

#pagebreak()
= The Idea: Form-Birefringent Unit Cells

== Physical Mechanism
- Form birefringence creates an anisotropic medium using subwavelength features, so the incident wave does not resolve the individual physical boundaries and instead sees a homogenized anisotropic medium.
  - This can be achieved either with asymmetric voids/pillars, or by combining two or more isotropic materials into a subwavelength grating whose composite response is anisotropic @Isakov2018.
  - Effective refractive index differs for electric fields polarized parallel ($n_parallel$) versus perpendicular ($n_perp$) to the structural axis.
- *Design rule for LP-to-CP conversion:*
  - When a linearly polarized wave is incident at $45 degree$ to the structural axis, its parallel and perpendicular components travel at different phase velocities and emerge with a differential phase delays.
    $ Delta phi = (2 pi f d) / c_0 (n_parallel - n_perp) $
  - Setting $Delta phi = pi / 2$ (quarter-wave retardation) while keeping the two transmitted amplitudes roughly equal (This won't be possible to achieve.) converts the linear input into a circularly polarized output.
  - This was actually used by @Hao2020 where the unit cell had this anisotropy, however phase shifts was mainly a function of height

== Reflectarray Application
- Reflectarray can be designed with unit cell that exhibits such anisotropy to have additional function aside from beam focusing
  - *Polarization transformation* (CP generation or LP-to-CP conversion).
  - *Polarization purification:* since most real feeders exhibit some cross-polar reception, the array can be designed so that only the desired polarization is focused, thereby improving cross-polar discrimination (XPD) of the overall system.
- Basic ideal for the new cell design comes from @Massaccesi2023
  - @Massaccesi2023 achieved a flat reflectarray, comprised of unit cell with square footprint with variable square hole.
  - New cell design would have an elliptical (or rhombic) cutout in place of a symmetric void - with major axis of the body being oriented along the diagonal of the square.
  - the ellipse/rhombus presents a different effective permittivity along its major and minor axes, and thus a different reflection phase per polarization.
  - Conventional polarization-controlling reflectarrays rely on blocks of differing height to obtain the per-axis phase, like @Cheng2022
  - What hasn't really been tried is constructing an array of uniform height where the two degrees of freedom (necessary to tune $n_perp$ and $n_parallel$ independently) are achieved in geometry changes in $x$ and $y$ directions
  - Such design could enable easier addition of some covering to make the final reflectarray smooth at the surface futher enhancing it's mechanical properties
  - Or possibly in order to improve printability the unit cell could be inverted -- instead of elliptical cutouts printing elliptical pillars.
- Phase shifting mechanism of the cell will then rely on it operating near resonance
  - Single resonance can give up to 360 degrees of phase change.
  - Due to Form Form-Birefringence the resonance will be slightly shifted between two axis.

== Geometry

=== Array Size

Using basic gain formula
$
  G = eta (4 pi A)/(lambda_0^2),
$

a gain of the reflect array can be estimated. Assuming aperture efficiency of 40~%, closed to what was achieved by @Massaccesi2023 using $0.3 lambda_0$ size cells, @Beccaria2025 achieved 50~% with $0.4 lambda_0$ size. Table bellow shows rough gain estimation for a square aperture (Since the print bed is square there's no reason to consider any other geometry).

#align(center)[
  #table(
    columns: 7,
    align: center,
    [*Aperture Size* ($lambda$)],
    [*Gain* (dBi)],
    [*Size 10 GHz* (mm)],
    [*Size 15 GHz* (mm)],
    [*Size 20 GHz* (mm)],
    [*Size 25 GHz* (mm)],
    [*Size 30 GHz* (mm)],

    [6], [22.5], [180], [120], [90], [72], [60],
    [8], [25.07], [240], [160], [120], [96], [80],
    [10], [27.01], [300], [200], [150], [120], [100],
    [12], [28.60], [360], [240], [180], [144], [120],
    [14], [29.94], [420], [280], [210], [168], [140],
    [16], [31.10], [480], [320], [240], [192], [160],
    [18], [32.12], [540], [360], [270], [216], [180],
    [20], [33.03], [600], [400], [300], [240], [200],
  )
]

=== Unit Cell Size

All text bellow is taken from @Nayeri2018.
The standard rule for reflectarrays is that the unit cell periodicity should be $<= lambda_0/2$ at the design frequency to avoid grating lobes.
Dimension of $lambda_0/2$ seems to be the standard in other literature.

#align(center)[
  #table(
    columns: 3,
    align: center,
    [*Periodicity* ], [*Advantages*], [*Disadvantages*],
    [$lambda_0/2$], [Standard; sufficient phase range ($300 degree$); good for large apertures], [narrower bandwidth],
    [$lambda_0/3$],
    [Better aperture sampling; wider bandwidth; lower element losses],
    [Reduced phase range; steeper phase slope (more quantization error)],

    [$lambda_0/4$],
    [Even wider bandwidth; further loss reduction; better for small-to-moderate arrays],
    [Phase range severely restricted; would necessitate multi-layer design or high $epsilon_r$ material],
  )
]

Especially if the thesis will be focused on creating reflectarray with additional capabilities like polarization transformation it's not worth to consider other cell designs then with $lambda_0/2$ base dimension.

In terms the heigh, higher cell will mean A) larger losses in the dielectric and B) being more susceptible to incidence angle changes.

=== Conclusions for this topic.
Typical FDM printer print bed is in the range of 200 to 300~mm. For SLA most are between 120 to 150~mm.
As the thesis will be mainly research focused a aperture size could be on the lower end - between 8 to 12 $lambda_0$ giving size that should be printable on FDM even at 10 GHz and SLA till 25 GHz assuming 150~mm print bed.

As for unit cell size, bandwidth here isn't the primary consideration.
Usable range of frequencies will be already limited plenty by the range in which polarization conversion will work as intended.
Thus unit cell smaller than $lambda_0/2$ doesn't really make that much sense.



== Problems and Open Questions
- *Phase-range coupling is the central difficulty:*
  - The unit cell must supply $Delta phi_x = 360 degree$ while maintaining $Delta phi_y - Delta phi_x approx 90 degree$ across the entire phase range.
  - This effectively requires a single cell geometry that has to cover range of $0 degree$ to $450 degree$ while the orthogonal axis tracks it with a constant offset.
  - This is a substantially harder problem than a single-polarization element.
  - Block-based CP transformers side-step this by offsetting the $y$ component in height relative to $x$.
- *The phase range of the available reference designs is insufficient:*
  - Assuming a smaller, compact aperture fed by a reasonable illuminator, a reduced maximum phase of roughly $300 degree$ might be tolerable -- but even that demands coverage out to about $390 degree$ in the converted axis.
  - Existing dielectric reflectarray elements fall short of this.
    - @Zhang2017 reached only $270 degree$ with $epsilon_r = 2.75$ and needed a custom composite at $epsilon_r = 4.4$ to cover desired range.
    - @Beccaria2025 required $epsilon_r = 7.5$ to reach roughly $300 degree$.
    - The core reference @Massaccesi2023 covered only about $200 degree$ (The exact value is not stated in the thesis, I'm judging from the phase curves they've listed), though this is quite extreme case.
  - The gap between required and available phase range is therefore the primary feasibility risk, and it pushes the design toward utilizing materials with the highest workable permittivity.
- *Manufacturing feasibility is in tension with the required geometry:*
  - *SLA:* has the resolution and build area to realize a compact reflectarray at higher frequencies, but high-permittivity resins are prohibitively expensive.
  - *FDM:* the filament availability problem is largely solved, but print resolution is the limiting factor -- the unit cells are small and the anisotropic cutout geometry is not straightforward to print.
    - While precision of nozzle positioning on more advance printers is in the ranges of single, tens micrometers nozzle diameter is normally 0.4~mm.
    - While 0.2~mm nozzles are available and I think that Zetamix filaments should still be printable with them, even at 0.2~mm the resolutions is far behind what SLA can achieve.
    - The narrow gaps at the tips of an elliptical cutout may fall below the printer's reliable feature size, causing inconsistent extrusion or incomplete fill; a rhombic cutout fares somewhat better but is not a complete solution.
    - In addition the addition of material on walls -- print being slightly bigger then designed requires consideration during design of the print model - which will slightly differ from the optimized model.
  - Mitigations:
    - Lower the design frequency so that resolution is less critical, at the cost of build-area problems.
    - Invert the design so that the anisotropic features are pillars rather than voids, avoiding thin walls that must be dimensionally accurate.
- *Design challenges:*
  - Because the two polarizations are coupled through a single geometry, the per-axis reflection phases cannot be tuned independently.
    - Incidence angle stability is up to questions. I would assume that ellipse would fair better then rhombus, but how well will the phase delay properties be kept across the array is hard to estimate.
  - Computer optimization is required to converge on a cell that meets both the total range and the $90 degree$ offset simultaneously.
  - I don't think this will be that big of a problem - S parameters for many different configuration of major - minor axis combos can be computed, surrogate model with Gaussian Processes or Polynomial Response created and configurations for each phase delay discovered on that.

#pagebreak()
= Materials
- The unit cell is an all-dielectric, additively manufactured, so the material system sets both the achievable permittivity contrast (and therefore the attainable phase range) and the loss.
- *FDM with Zetamix* $"TiO"_2$ (up to $epsilon_r = 10$) is the leading candidate: uniform filler distribution, a reproducible permittivity ladder, and no sedimentation issue.
- *SLA with a manually loaded resin* offers resolution and build-area headroom but carries the sedimentation risk and an unverified printability assumption.


== The Baseline-Polymer Permittivity Ceiling
- Unloaded SLA and FDM polymers usually exhibit low relative permittivity, roughly $epsilon_r$ between 2.0 and 3.0.
  - This ceiling limits the phase range obtainable from geometry alone, which is exactly the constraint identified above.
  - A polarization-converting cell needs independent control of two orthogonal reflection phases, so the phase-range limitation is even more restrictive than for a single-polarization reflector.
- Micro-voids from high feedstock viscosity and the natural result of FDM layering process depress the bulk dielectric constant.
- Hygroscopic polymers take up moisture, which further raises $"tan" delta$ and lowers $epsilon_r$.

== High-Permittivity FDM Filaments
- High-permittivity filaments are made by blending the polymer matrix with ceramic nanoparticles such as barium titanate, titanium dioxide, or alumina.
  - For FDM systems the ceramic filler does not sediment as it does in liquid photopolymer systems, so the filler distribution remains uniform across the print.
- @ZetamixEpsilon offers a family of $"TiO"_2$-loaded materials with $epsilon_r$ of 2.2, 4.5, 7.5, and 10 at 100~% infill.
  - At 35~% infill the nominal $epsilon_r = 7.5$ material drops to around $epsilon_r = 2$.
- @Zhang2017 obtained comparable material by manually adding submicron additives to a base PREPERM filament.
- Practical conclusion for this thesis:
  - The Zetamix $"TiO"_2$ family is the most reproducible FDM option.
  - It's also easiest to get filament with high permittivity for any plausible 3D printer type.
  - The $epsilon_r = 10$ grade provides headroom to test whether the required phase shifts are even realizable before committing to a lower-permittivity material.

== Photopolymer and Ceramic-Loaded Resins (SLA)
- In SLA and other liquid-resin processes, dense ceramic fillers undergo gravity-driven sedimentation before UV curing.
  - This induces an unintended anisotropic permittivity gradient along the vertical build axis.
  - Non-uniform particulate distribution also inhibits the maximum achievable effective permittivity.
- Most ceramic-loaded photocurable resins do not reach high permittivity because the additive concentration is kept small
  - @Whittaker2023 indicates values around $epsilon_r approx 4$.
  - This is below what the phase-range analysis demands.
- Higher permittivity resins are created by loading base resin with $"BaTiO"_3$ nanoparticles.
  - Manufacturer data for 3Dresyn HP1 BTO70 lists $epsilon_r$ between 8 and 9 with loss tangent below 0.04 across 10-20~GHz range @3DresynHP1BTO70.
  - However, they are prohibitively expansive.
  - Loss factor of these resins is usually rather high -- base resin is already fairly lossy, and barium titanate suffers from additional dipole relaxation losses on higher frequencies.

#pagebreak()
= Characterization of the Unit Cell

== Simulation of Unit cell

== Measurement of the Unit Cell #TODO
- I need to measure phase delay in two principal axis at 90 degree incident angle illuminated by a lineary polarized source.
  - Waveguide out of question -- incidence angle changes with frequency.
  - Dielectric waveguide esque structure could maybe be used.
  - Free space to complicated.
  - Parallel plate?

#pagebreak()
= Feasibility Study
- Aim's to verify if such unit cell can be realized with reasonable parameters using FDM printer with filament permittivities bellow $epsilon_r < 10$
  - The pillared variant is preferred because it improves printability: it avoids the thin, dimensionally-critical walls of an elliptical cutout.
- The study must answer two questions:
  - *A) Phase range on a single axis:* can the geometry produce a sufficient range of phase delays (target $>= 300 degree$) along one polarization?
  - *B) Cross-axis offset:* can a stable $90 degree$ phase difference be maintained between the two axes across that range?

== Test Geometry
- An all-dielectric unit cell with:
  - A square footprint of $lambda_0 / 2 times lambda_0 / 2$ where $P = c_0 / (2 f_0)$.
  - An elliptical pillar whose major axis is aligned with the *diagonal* of the square, i.e. rotated $45 degree$ relative to the array axes.
  - A base substrate layer below the pillar.
  - $epsilon_r in [7, 10]$; the headroom value used in the study is $epsilon_r = 9$.
- Because the ellipse presents a different projected cross-section to the x- and y-polarized waves, the two polarizations see different effective permittivities. This is the form-birefringence mechanism.

== CST Setup

=== Create the project
- `File -> New -> Microwave & RF / Optical -> Unit Cell`.
- Set the frequency range (e.g. 25-35 GHz for Ka-band) and units (mm, GHz, ns).

=== Define parameters
- Open `Home -> Parameter List` (`Ctrl + P`) and add:

#align(center)[
  #table(
    columns: 3,
    align: center,
    [*Name*], [*Value*], [*Description*],
    [`f0`], [30], [Design frequency (GHz)],
    [`P`], [5.0], [Unit cell period, $lambda_0 / 2$ at 30 GHz],
    [`epsilon_r`], [9], [Material permittivity],
    [`a`], [1.5], [Ellipse semi-major axis (mm)],
    [`ratio`], [2], [Aspect ratio $a / b$, always $> 1$],
    [`b`], [`a / ratio`], [Ellipse semi-minor axis (mm)],
    [`H_pillar`], [3.8], [Pillar height (mm)],
    [`H_base`], [0.6], [Base substrate thickness (mm)],
  )
]

- Defining `b = a / ratio` with `ratio > 1` enforces $a > b$ automatically, so the sweep only searches half of the parameter space.

=== Build the geometry
- *Ground plane:* `Modeling -> Brick` (`Ctrl + B`), name `ground`, X and Y from `-P/2` to `P/2`, Z from `-H_base` to `0`, material `PEC`.
- *Base dielectric:* `Ctrl + B`, name `base_dielectric`, X and Y from `-P/2` to `P/2`, Z from `0` to `H_base`, new material `Zetamix_eps9` with Epsilon set to `epsilon_r`.
- *Elliptical pillar:* CST has no native elliptical-cylinder primitive, so extrude a 2-D ellipse:
  - `Curves -> Ellipse`: centre `(0, 0, 0)`, radius X `= a`, radius Y `= b`.
  - `Curves -> Transform -> Rotate`: select the curve, axis z, angle `45`.
  - `Modeling -> Extrude Curves`: select the rotated ellipse, height `H_pillar`, name `pillar`.
  - `Modeling -> Transform -> Translate`: `pillar`, Z `= H_base`.
- *Boolean union:* `Modeling -> Boolean -> Add`, first `base_dielectric`, then `pillar`.

=== Boundaries and ports
- The Unit Cell template pre-configures these; verify them:
  - `Simulation -> Boundaries`: X and Y set to `unit cell`, Zmin set to `electric (Et = 0)`, Zmax set to `open (add space)`.
  - `Simulation -> Waveguide Ports`: the Floquet port exists. Open its properties and ensure Mode 1 (TE00) and Mode 2 (TM00) are enabled.
  - In the port's *Polarization* tab, set Mode 1 polarization angle to $0 degree$ and Mode 2 to $90 degree$, so `S1,1` is the x-pol reflection and `S2,2` the y-pol reflection.
- #text(fill: orange)[*Caveat:*] because the pillar sits at $45 degree$, the structural eigenmodes are rotated relative to the global axes. Cross-terms `S1,2` and `S2,1` will therefore be non-zero. This is an expected consequence of the birefringence, not an error.

=== Solver
- `Simulation -> Frequency Domain Solver`.
- Accuracy `-40 dB` (coarse), frequency sampling set to *Fixed frequency list* at `30`, since single-frequency solves are much faster for sweeps.
- Mesh: adaptive refinement on, max passes `2`.
- Run and confirm `|S11|` is near 0 dB.

== Sweep 1: Phase range on one axis (Question A)
- `Simulation -> Parameter Sweep`.
- Sweep `a` from `0.3` to `2.0` mm in steps of `0.3` (about 6 samples); keep `ratio` fixed (e.g. `2.5`).
- Result template: `S1,1` and `S2,2`, complex.
- Enable *Combine all sequences in one run*, then Start.
- Processing the results:
  - In the *Navigation Tree*, expand `1D Results -> S-Parameters`, right-click `S1,1` and choose *Plot Properties*.
  - Right-click the plot, choose *Export Data to File*, ASCII, *Export all curves in one file*, and save as `sweep_phase_x.txt`; repeat for `S2,2`.
  - Alternatively create result templates `phi_x = phase(S1,1)` and `phi_y = phase(S2,2)` via `Post-Processing -> Result Templates -> New -> 1D Result from 1D Results`, then export those directly in degrees.
- Build the assessment table:

#align(center)[
  #table(
    columns: 4,
    align: center,
    [`a` (mm)], [$phi_x$ ($degree$)], [$phi_y$ ($degree$)], [$Delta phi = phi_y - phi_x$ ($degree$)],
    [0.3], [..], [..], [..],
    [0.6], [..], [..], [..],
    [..], [..], [..], [..],
  )
]

- Go/no-go metrics:
  - $phi_x$ range, $max(phi_x) - min(phi_x)$, target $>= 300 degree$.
  - $phi_y$ range, target $>= 390 degree$, i.e. $300 degree + 90 degree$.
  - $Delta phi$ stability, target within $90 degree plus.minus 15 degree$ over most of the sweep.
- #text(fill: orange)[*Note:*] CST returns phases in $(-180 degree, 180 degree]$. Always unwrap before computing ranges, otherwise a wrap past $plus.minus 180 degree$ will corrupt the result.

== Sweep 2: Cross-axis offset (Question B)
- `Simulation -> Parameter Sweep` with two parameters:
  - `a` from `0.5` to `2.0` mm in steps of `0.3`.
  - `ratio` from `1.5` to `4.0` in steps of `0.5`.
- This is about 36 simulations. Use *Sequential* mode so all combinations are covered.
- Because `b = a / ratio`, the constraint $a > b$ is preserved with no extra work.
- Processing:
  - Create 2-D scalar templates via `Post-Processing -> Result Templates -> New -> 2D Scalar Result from 1D Results`:
    - `phase_range_x`: `max(phase(S1,1)) - min(phase(S1,1))`, parameters `a` and `ratio`.
    - `phase_range_y`: `max(phase(S2,2)) - min(phase(S2,2))`.
    - `phase_diff_mean`: `mean(phase(S2,2) - phase(S1,1))`.
  - Plot each from `Results -> 2D Results -> ...` as a heatmap: bright regions where the phase range exceeds the targets, and a region near $90 degree$ for `phase_diff_mean`.
  - The overlap of the feasible regions in the range map and the $90 degree$ map defines the usable $(a, ratio)$ design space.
  - Right-click a 2-D plot, choose *Export -> Export to File* (ASCII matrix) for the design map.

== Unwrap check (external script)
- After exporting the raw phase curves, verify the numbers outside CST:

```python
import numpy as np
data_x = np.loadtxt('sweep_phase_x.txt', skiprows=1)
data_y = np.loadtxt('sweep_phase_y.txt', skiprows=1)
phases_x = np.unwrap(data_x[:, 1:], axis=0)
phases_y = np.unwrap(data_y[:, 1:], axis=0)
for i in range(phases_x.shape[1]):
    phi_x, phi_y = phases_x[:, i], phases_y[:, i]
    delta = phi_y - phi_x
    print(f"cfg {i}: phi_x range={np.ptp(phi_x):.1f}, "
          f"phi_y range={np.ptp(phi_y):.1f}, "
          f"delta mean={np.mean(delta):.1f} +/- {np.std(delta):.1f}")
```

== Interpretation and next steps
- *If all three criteria pass:* the concept is feasible. Proceed to a finer sweep around the best $(a, ratio)$ region and then to the surrogate-model optimization described in the design-challenges note (Gaussian Process / polynomial response surface).
- *If the phase range falls short:* the levers are a taller pillar, a higher $epsilon_r$ (up to 10), and a smaller-than-$lambda_0 / 2$ footprint, which improves range at the cost of grating-lobe margin (@Nayeri2018).
- *If the $90 degree$ offset drifts:* the diagonal orientation alone may couple the axes. Consider adding a second geometric degree of freedom, as @Cheng2022 added independent heights, to decouple the per-axis phases.



#pagebreak()
= Surrogate Model

== Why a Surrogate Is Needed
- The feasibility study establishes that the phase behaviour of the elliptical pillar cannot be predicted analytically. There is no closed-form solution for a truncated elliptical dielectric resonator on a grounded substrate, and the elliptic-cylinder harmonics that exist do not survive truncation in height plus the ground plane.
- At the same time the design problem is not a single evaluation but a search. Each element of the final reflectarray needs a geometry that realises its own required phase, and the array contains hundreds of elements. On top of that the geometry has to be chosen such that the $90 degree$ inter-axis offset is preserved across the whole phase range.
- Evaluating that by full-wave simulation is not viable: a single CST solve costs minutes, the design space spans five parameters, and the search would have to be repeated for every element of every candidate array.
- A surrogate model replaces the full-wave solve with a cheap regression that maps geometry to response, so that the search runs on the model and only the final candidates are verified in CST. This is the standard role of surrogate modelling in simulation-driven design @Forrester2008.

== Requirements on the Model
- The model must predict two quantities per configuration: the phase delay along each principal axis, and the phase difference between them.
- Phase must not be regressed directly. It wraps at $360 degree$, so identical geometries would map to both $0 degree$ and $360 degree$ and any regressor would average them toward $180 degree$ at every wrap boundary. Adding more data does not fix this; it makes the model more confidently wrong.
- The model therefore predicts the four components of the two complex principal reflection coefficients:
  $ bold(R)_"major" = a + j b, quad bold(R)_"minor" = c + j d $
  from which every quantity of interest is derived:
  $ phi_"major" = angle(R_"major"), quad Delta phi = angle(R_"minor" dot R_"major"^* ) $
  This is continuous through resonance, bounded by $|R| <= 1$ for a passive structure, and makes $Delta phi$ a derived quantity rather than a second independent target.

== Why Polynomial Response Surfaces Were Discarded
- A polynomial response surface is a global low-order fit $y = bold(X) beta$, attractive because it has no hyperparameters and is fitted by a single linear solve.
- It is inappropriate here because the response is dominated by a resonance. Near resonance the phase slope reaches several hundred degrees per millimetre of geometry, so a low-order polynomial cannot represent the curve at all.
- Raising the order to capture the resonance makes the number of basis terms grow combinatorially in five dimensions. The data requirement then becomes larger than the full-factorial sweep the surrogate was meant to avoid, which defeats the purpose.
- The polynomial is therefore kept only as a baseline check, not as the production model.

== Why Gaussian Processes Were Discarded
- A Gaussian process was the natural alternative: it gives a posterior variance for free, which is the correct confidence interval, and it is designed for small sample sizes.
- Two reasons ruled it out.
  - *Multiple independent models.* A GP regresses one scalar output at a time, so four complex components require four independent GPs. Each fits its own length scales, the four can disagree with each other, and each can independently violate $|R| <= 1$. There is no shared representation, even though the major and minor axes are the same physics seen from two directions.
  - *Sample efficiency is not the binding constraint.* The main advantage of a GP is that it works with a few dozen samples. Here the CST sweep can be run repeatedly overnight and produces on the order of $10^4$ configurations, so that advantage is not needed. At that sample count a neural network matches or exceeds a GP while training faster per sample.
- The Gaussian process is therefore not used.

== Multi-Layer Perceptron
- The chosen model is a single multi-layer perceptron with one shared latent representation and four outputs, which resolves the multi-model objection directly: one training run, one set of hyperparameters, and a network that learns the coupling between the two axes.
- *Inputs* are physically derived features rather than raw geometry. The raw parameters $(a, "ratio", P_"ratio", epsilon_r, H_"pillar")$ are a poor coordinate system because they do not scale with frequency and do not expose the physics. The features are normalised so that the $30$ to $15$~GHz frequency scaling leaves them invariant:
  - Fill fraction $f = pi a b \/ P^2$, which sets the effective permittivity of the cell.
  - Electrical pillar height $(H_"pillar" \/ lambda_0) sqrt(epsilon_r)$ and the same for the base layer.
  - Anisotropy strength $ln(a \/ b)$.
  - Ellipsoidal effective-medium permittivities along the major and minor axes, obtained from the depolarisation factors of a prolate spheroid combined with a Maxwell-Garnett mixing rule. This yields the two separated resonances analytically.
  - Distance to resonance $f_0 \/ f_"res"$ for each axis, and the resonance separation, since proximity to resonance is the dominant driver of phase slope.
- *Outputs* are the real and imaginary parts of both principal reflection coefficients, as above.
- *Loss* combines a mean-squared error on the four components with a passivity penalty $ "mean"( "relu"(|R| - 1)^2 )$, which guarantees the surrogate never predicts gain, a failure mode a plain regression can exhibit near resonance.
- *Hyperparameters* (depth, width, activation, learning rate, regularisation) are tuned with Optuna @Akiba2019, which uses a define-by-run search space and pruning of unpromising trials.
- *Sampling* for additional training points uses a Sobol sequence rather than a full grid. In five dimensions a grid of five values per axis already needs $5^5 = 3125$ runs and leaves the space between lattice lines unsampled, which is exactly where the resonance sits. A Sobol sequence is nested, so successive overnight batches accumulate into a well-spread design rather than wasting earlier runs.
- Every candidate the surrogate proposes is verified by a full CST simulation before it is accepted. The surrogate therefore only needs to rank candidates correctly, not to be accurate in absolute terms.

== Uncertainty Quantification
- Two different uncertainties are needed, and they are not interchangeable.
  - *Generalisation error* answers how accurate the model is overall. It is estimated by $k$-fold cross-validation: the data are split into $k = 5$ folds, the model is trained $k$ times with one fold held out each time, and the spread of the held-out error across folds gives the variance of the performance estimate.
  - *Per-prediction uncertainty* answers how far a single prediction can be trusted. Cross-validation cannot supply this, because it says nothing about any individual input.
- For design work the second is the one that matters: the surrogate has to indicate which regions of the parameter space it has not learned, so that unverified proposals are not trusted and new simulations are directed where they are most informative.
- The method used is a *deep ensemble*: $M = 5$ networks trained from independent random initialisations with independently shuffled data ordering, so that the ensemble members differ only in their starting point and the order in which they see the same data.
  $ mu(bold(x)) = 1/M sum_(m=1)^M f_m (bold(x)), quad sigma^2 (bold(x)) = 1/M sum_(m=1)^M (f_m (bold(x)) - mu (bold(x)))^2 $
  This gives an epistemic uncertainty: it is small where the training data are dense and large where the model is extrapolating, which is exactly the behaviour required for active learning. It is preferred over Monte-Carlo dropout, which is cheaper but tends to produce overconfident intervals, and over a variational Bayesian network, whose tuning cost is not justified at this scale.
- The uncertainty is propagated through the nonlinearity rather than approximated. Since the design quantity is $Delta phi$, which is a function of all four predicted components, the ensemble spread is taken over $Delta phi$ computed from each member:
  $ sigma_(Delta phi) (bold(x)) = "std"_m [ angle(R_"minor"^((m)) dot R_"major"^((m))^* ) ] $
  rather than by linear propagation of the per-component variances.
- The intervals are validated by a *calibration* check: predictions are binned by predicted $sigma$, and for each bin the fraction of true values falling within $plus.minus 1.96 sigma$ is compared with the nominal $95 thin %$. Systematic under-coverage would indicate overconfident intervals and require recalibration before the uncertainty is used to guide sampling.

== Physics-Informed Neural Networks
- A physics-informed neural network (PINN) embeds the residual of a governing differential equation in the training loss @Raissi2019:
  $ cal(L) = cal(L)_"data" + lambda cal(L)_"PDE" $
  where $cal(L)_"PDE"$ penalises violation of the PDE at collocation points, evaluated by differentiating the network output with respect to its spatial or temporal coordinates.
- *This formulation does not apply to the present problem.* The network here maps design parameters to a response, $ (a, "ratio", epsilon_r, H) |-> bold(R) $. There are no spatial coordinates in the input, so there is no differential operator to apply and $cal(L)_"PDE"$ is undefined. Writing Maxwell's equations in terms of $diff bold(R) \/ diff a$ is not a physics residual.
- The distinction is definitional rather than a matter of degree: a model trained purely by supervised learning is not a PINN, regardless of how much physics enters its inputs. The loose reading of the original framework has blurred this.
- Two further properties of PINNs work against their use here. They are formulated for a single instance of a PDE, that is one set of boundary conditions and material parameters, whereas the requirement is a map over a five-dimensional parameter space. And their training is expensive and sensitive to architecture, sampling and optimisation settings, which would be paid for no benefit.
- *What is adopted instead* is the approach used in electromagnetic surrogate modelling, where physical consistency comes from the prediction basis rather than from a PDE term. Physics-constrained networks for antenna work predict spherical wave expansion coefficients and scattering parameters with an ordinary network @Jensen2026, and for lossless periodic structures the constraint is imposed by projecting the output onto a manifold that enforces energy conservation @Prehn2026. The analogue here is the pair of measures already described: predicting complex reflection coefficients instead of wrapped phase, and penalising $|R| > 1$ in the loss.
- A neural operator, which does map between function spaces and generalises across parameters where a PINN does not, would become relevant only if the model were extended from a single frequency to a full frequency sweep. It is not used at present.

#pagebreak()

#v(2em)
#bibliography("bibliography.bib", style: "ieee")

