#import "config.typ": *
#show: conf

#outline()

#pagebreak()
= Manufacturing and Design Observations
- The effective relative permittivity ($epsilon_r$) depends on the material density in a systematic and predictable way, provided the structural resolution is significantly higher than the operating wavelength.
- Printing often fails to reach 100% density, shifting measured $epsilon_r$ lower than theoretical substrate values.
- Varying density or permittivity can be achieved using a number of design approaches.

- *Lattice Grid:*
  - The structure is made up of a uniform lattice with cubes placed at intersection points.
  - Depending on the cube dimensions, the space is differently filled and thus density changes.
  - It can be printed using 100% infill, making it friendly towards standard slicers.
  - It is also welcoming towards EM field simulators, as multiple papers show simplified models where the lattice grid support is neglected or simplified into floating cubes.

- *Varying Infill:*
  - A varying infill level is used in different spatial locations throughout the structure, as shown on a GRIN lens in FFI 2017 @Kristoffersen2017.
  - Simulating these arbitrary infill architectures is highly problematic because the complex internal mesh easily becomes uncomputable.
  - The entire structure must typically be remodeled as a collection of solid domains with discrete, homogeneous effective materials - moving to 3D printed model cannot be easily offloaded to slicer.
  - Material properties (such as loss) will be a property of the infill pattern orientation relative to E field direction.

- *Multiple Materials:*
  - The basic approach resembles a lattice grid, but instead of air gaps, a second material forms the surrounding support structure or alternating cells.
  - The exact behavior within high-frequency simulation suites remains highly dependent on boundary mesh approximations.
  - Designing these alternating spatial allocations is straightforward using programmatic CAD environments like CadQuery.
  - Requires multi-head printers.

- *Design Automation Tools:*
  - Most geometries are easily described by mathematical equations, but manual modeling in classic parametric CAD engines is highly inefficient due to geometric complexity.
  - *CadQuery:* A Python-based programmatic CAD environment that describes models via explicit code loops rather than interactive 2D sketching. This simplifies lattice synthesis and mathematical infill variation, handling high component counts effectively for academic prototype scales.
  - *OpenSCAD:* faster real time preview than CadQuery, much slower final output, cannot output to STL I think.

== Print Technologies Comparison
- Three manufacturing techniques are prominently utilized: SLA, SLS, and standard FDM.
- SLA and SLS are widely adopted due to their high spatial resolution and superior management of complex geometric overhangs without extensive support arrays.

=== FDM (Fused Deposition Modeling)
- Unable to reliably handle overhangs, applicable only to methods relying on varying infill.
- Extrusion nozzle diameters ($>= 0.4 "mm"$) impose lower bounds on minimum spatial feature size, limiting metamaterials to lower frequencies.
- Setups with multiple print heads enable innovative construction techniques -- use of conductive filaments supported by non conductive one, on instead of controlling ratio of air to filament one can use two filaments with widely different permittivities (However there are problems with different print temperature, how well do the materials combine and such).
- FDM will probably produce more anisotropic materials then other techniques with much higher resolution -- between layers there will be microscopic inter-track air gaps
  - NOTE: it would be interesting to exploit this, however, I would assume that this anisotropy isn't particularly constant and cannot be relied upon.
- Monolithic Multi-Filament FDM Metamaterials
  - Traditional way of constructing left handed metamaterials (not just materials with varying permittivity) relies on stacking PCBs .
    - Their alignment needs to be precisely controlled to ensure proper function.
    - Two possible solutions that utilize 3D printing
      - Printing support structure from plastic and inserting copper wires, or CNCed copper inserts, seen it done, but looks incredibly laborious.
      - Using combination of support filament with conductive one.
  - Multi-filament printing introduces severe nozzle cross-contamination and micro-stringing, where minute conductive polymer droplets drag across dielectric boundary zones to create unwanted electrical shorts.
  - Differential thermal expansion coefficients between carbon-filled conductive filaments and pristine dielectric substrates cause severe inter-layer delamination and Z-axis warping during cooling - though  I probably could get some guidance on this.
- Infill in Small Cross-Sections and Confined Spaces:
  - Generating sparse internal infill within small features (e.g., $10 - 12 "mm"$ pillars) forces the print head into rapid start-stop cycles over minimal travel distances, preventing steady-state extrusion.
  - Abrupt direction reversals under standard acceleration and jerk thresholds transfer high-frequency mechanical shock to the frame and gantry, which manifests as ringing or ghosting on adjacent outer walls @All3DPGhosting.
  - Nozzle pressure compensation (pressure advance) fluctuates during rapid consecutive retractions and unretractions across sub-centimeter gaps, triggering local under-extrusion or surface blobbing.
  - Confined toolhead paths continuously pool localized heat, requiring strict minimum layer cooling thresholds to prevent thermal softening and perimeter corner curling.
  - Standard mitigation entails replacing interior infill entirely with concentric perimeters/walls, as continuous loop paths optimize exterior dimensional tolerance and structural rigidity @PrusaInfillPatterns.

=== SLA (Stereolithography)
- high resolutions, able to do overhangs with some consideration
- fairly frequently used, though some paper struggle with it for some reasons (even though their geometry doesn't seem to be that complicated)
- in case of composites there is a risk of sedimentation and loss of uniformity of the material
- Infill, Hollowing, and Internal Voids in Small Features:
  - SLA is physically unsuited for internal lattice infill or hollowing inside small cross-sections ($<= 15 "mm"$), and such geometries must be printed 100% solid.
  - Enclosed internal voids generate suction cup forces against the release film during the Z-axis peel cycle, resulting in layer separation, horizontal suction banding, or support failure @Dreaming3DSuction.
  - Mitigating suction requires dual vent and drainage apertures (minimum diameter $2 - 3 "mm"$), which are impractical to integrate into sub-centimeter cavities without degrading wall integrity @FormlabsHollowing.
  - High surface tension and capillary action trap viscous uncured monomer within narrow internal voids, impeding solvent flow during isopropyl alcohol (IPA) washing stages.
  - Trapped liquid resin generates hydraulic overpressure during downward build-plate repositioning, causing thin perimeter blowouts; unreacted monomer left sealed inside eventually outgases and causes delayed osmotic cracking.

=== SLS (Selective Laser Sintering):
- essential for the high-quality nylon grids in the FFI study, providing single-step execution of dense internal cavities
- however, clearing unsintered powder from the inner chambers remains a difficult post-processing logistical hurdle
- enables used of ceramic based filaments (although in a limited matter, usually metal/ceramic require binder-jetting based 3D printing)



#pagebreak()
= Materials

== Weird Materials
- Foaming PLA
  - Increasing volumetric expansion with higher printing temperatures.
  - On the one hand interesting, on the other hand it's probably faster to have slicer that does variable infill and print at one temperature then constantly adjusting nozzle temperature.
    - Not to mention expansion needs to be considered in the slicing.
    - Also printers usually aren't created with modulating print temperature constantly -- even though theoretically it would be possible to get some nice gradual transitions with this material.
  - Bambulab Aero PLA @BambulabAero
    - Created primarily for RC plane models where it enables more versatility then styrofoam.
    - GRIN lense printed using this material demonstrated in @Moschner2025.
    - At $190 degree"C"$ the volumetric expansion is 100~\% at $260 degree"C"$ 280~\% (higher temperature will start decreasing the ratio)
    - This results in a shift of permittivity from 2.66 to 1.31

== High Permittivity Filaments
- Unfilled baseline polymers uniformly demonstrate low relative permittivity ($epsilon_r$) between 2.0 and 3.0.
  - Micro-voids caused by high feedstock viscosity and volatile outgassing systematically degrade the bulk dielectric constant.
  - Similarly some materials are for examples hygroscopic -- absorption of water/humidity increases $"tan" delta$ and deceases $epsilon_r$
- High permittivity filaments are created by blending standard polymer matrices with ceramic nanoparticles like barium titanate, titanium dioxide, or alumina.
- In SLA or other technologies relying on liquid materials can dense ceramic fillers undergo gravity-driven sedimentation before localized UV curing occurs.
  - This precipitation induces unintended anisotropic permittivity gradients along the vertical build axis.
  - Non-uniform particulate distribution minimizes interfacial polarization and inhibits maximum effective permittivity.
  - With powder based filament this effect is lessen - not to mention often the if the mixture is composite the materials are already premixed in tiny granules so that uniform distribution is ensured.
  - For FDM systems this is not an issue at all.

=== FDM Filaments
- Zetamix Epsilon series - for FDM printing #FAV
  - permittivities with 100% infill - 2.2, 4.5, 7.5, 10 (Different percentage of $"TiO"_2$ in the material) @ZetamixEpsilon
  - rather hot extrusion temperature 270-300 degrees
  - 137.5 Euro per 500g 1.75 mm spool
  - for $epsilon_r=7.5$ at 35\% infill the permittivity drops to around Er=2 - can cover wide range of permittivities while still being structurally sound
  - loss tangent of around $10^(-3)$ - order of magnitude better then ABS, or PETG
- PREPERM ABS filaments
  - wide range of permittivities from 2.55 to 23, while being low loss
  - @Valdes2023 managed to get filament from Avient no idea what the price is or what are it's properties, Avient only does B2B and no information is publicly available.
  - @Zhang2017 also mentions them, however they've added submicron additives manually to the base PREPERM filament
- TPU
  - Unfilled, pure TPU exhibits a relative permittivity ($epsilon_r$) ranging from 3.6 to 8.0, heavily dependent on the Shore hardness and specific chemical backbone (polyether versus polyester) @CovestroTPU.
  - TPU is hydroscopic material - permittivity will futher shift down after manufacturing.
  - Permittivity drops dramatically under strain (Which is to be expected) @Wang2024, this shouldn't be a problem however.
  - Polyether-based TPU grades possess intrinsically higher dielectric constants than polyester-based equivalents.
  - The dielectric loss factor ($"tan"delta$) for standard commercial TPU varies broadly between 0.03 and 0.10 @CovestroTPU.
  - This loss factor is inversely proportional to the material's mechanical hardness; softer, more flexible grades exhibit higher dielectric loss - the native $"tan"delta approx 0.03 - 0.10$ renders pure TPU highly dissipative for high-Q RF transmission components, acting effectively as an electromagnetic absorber at microwave frequencies. #COOL
    - Absorbing mechanism is based onDielectric Relaxation - the polymer is polar and molecules will attempt to reorient with electrical field, with friction they dissipate electrical energy  energy as heat.
    - Also there is high impedance mismatch so reflection for just a TPU based absorber would be high (unless one used a pyramidal structure).
  - TPU would be very interesting in dual-extrusion systems
    - Exceptional-Point (EP) Metasurfaces - both the $"tan"delta$ and high $epsilon_r$ would be a benefit in these, but manufacturing tolerances of these metasurfaces must be fairly small - unsuitable for FDM manufacturing.
    - Strain-Tunable LWAs - high loss makes TPU basically unusable, but mechanically reconfigurable antennas are interesting.
    - Tapered loads - in traveling wave/leaky wave antennas one needs to eliminate the traveling wave at the end of the antenna to prevent reflection which would raise sidelobes, decrease gain.
      - One could transition to TPU based load to dissipate the wave more efficiently.
      - Due to impedance mismatch the transition would need to be done gradually - lossy filament would need to be introduced to the material on a sub wavelength scale.


=== SLA, DLP, and LCD Resins
- Photopolymerization ensures optimal spatial resolution for fine subwavelength metamaterial geometries.
- Experimental customized resins leverage high mass fractions of titanium dioxide or barium titanate - this substantially attenuates incident light and restricts UV curing depth per layer.
  - In case of $"TiO"_2$ with contraction at max around 20~\% high print resolution ($<= 100 mu"m"$) can still be maintained @Malas2019.
  - $"BaTiO"_3$ loaded resins achieves up to $epsilon_r = 9$ and are commercially available.
  - There aren't any commercially available resins with $"TiO"_2$ for high permittivity the market is dominated by $"BaTiO"_3$ from 3Dresyns.
- Rogers Radix Printable Dielectric operates at a relatively low 2.8 $epsilon_r$ with a specialized dissipation factor of 0.0043 at 10 GHz @RogersRadix2026.
  - Wouldn't say it enables something more than conventional SLA filaments, just that Rogers is relatively trustworthy so complicated measurement process could be skipped.
  - Not really interesting for the thesis.
  - Also the permivitivity is roughly comperable to that of other resints @Vargas2022.
- 3Dresyns HP1 BTO70 employs suspended ferroelectric barium titanate to provide high dielectric response.
  - Manufacturer data for HP1 BTO70 details an $epsilon_r$ range of 8 to 9 with a loss tangent below 0.04 across 10 to 20 GHz range @3DresynHP1BTO70.
  - Additive used is Barium Titanate $"BaTiO"_3$.
  - Exhibit's also ferroelectric, pyroelectric and piezoelectric properties.
  - Very expensive at 18,700 NTD per 500~g.
- 3Dresyns HP1 Clear functions as an optically transparent high-permittivity photopolymer alternative.
  - HP1 Clear maintains an $epsilon_r$ between 8 and 12 at lower frequency spectra @3DresynHP1Clear.
  - Slightly cheaper at 11,200 NTD per 500~g.
- Most ceramic loaded photocurable resins don't exhibit that high of a dielectric permittivity as the additive concentration is usually fairly small.
  - According to @Whittaker2023 the permittivity should be around 4.
  - R-CF3000 and HS-R2000 are listed as examples of ceramic loaded resins  @Neway3DPCeramic.
  - R-CF3000 - dielectric constant rather low at $epsilon_r = 2.65$ in 1-20~GHz range. @BenchchemCyclotene.
  - HS-R2000 - unable to find dielectric properties, but they shouldn't be anything special.

=== SLS and Powder-Bed Ceramic Composites
- Selective laser sintering permits the creation of complex internal cavities without required support arrays.
- Base SLS polyamides retain low native permittivity and demand substantial filler volume for high-dielectric operation.
- Direct thermal sintering of pure ceramics remains limited by excessive melting points and resulting thermal shock fractures.
- Advanced high-permittivity RF models utilizing powder-bed systems typically employ indirect binder-assisted manufacturing (a powder bed is selectively exposed to binding agent which binds together material pellets to for a green form model -- that model is later sintered in a oven).
  - The printed green parts require extensive thermal debinding and subsequent high-temperature furnace sintering to achieve solid ceramic states.
  - Significant geometric shrinkage occurs during the final thermal phase.
  - This volumetric reduction requires exact pre-calculation and scaling within the initiating CAD geometry.
- Alumina lattice structures produced via lithography-based ceramic manufacturing demonstrate fully sintered permittivity values approaching 9.8 with minimal dielectric loss @Cillessen2026.
  - Interesting technology but given the complex geometry of the structure and need to maintain the exact geometry after sintering probably too complex for the thesis.

== Electrically Conductive filaments
- Interesting field of research
- Only applicable to FDM and multiple print heads, no other configuration makes sense.
- Proto-pasta @ProtoPastaConductive
  - PLA with carbon black, prints with standard PLA settings.
  - 1 cm of 1.75 mmm wire has resistance of about 200 to 350 Ohm
  - Seems more useful for EMC shielding than making anything that needs to be really conductive.
  - \$90 per 1.75 mm 1 kg spool
- Electrifi Conductive Filament @Electrifi
  - Copper-polymer composite, prints at low temperatures around 130-160 degrees - well bellow what's needed for PLA.
  - Conductivity of 10 000 S/m
  - Super expensive at \$215 per 1.75 mm 100 g spool (17 meters), offered in 200 g or 500 g spools.
  - Actually used for antennas or in replacing stacked PCBs to create metamaterials.
- Spectrum Electrically Conductive
  - Enhanced with carbon nano tubes.
  - PLA based @SpectrumPLA
    - Print temperature at the higher end of PLA 210 - 230 degrees.
    - 4x4x120 mm test print (Idk the orientation so this value is useless) had resistance of 97 to 120 Ohm depending on the print temperature (lower resistance with higher print temperature).
    - \$70 per 1.75 mm of 750 g spool
    - Seems price comparable to Proto-pasta, with roughly 4 times lower resistance.
  - ASA based @SpectrumASA
    - High print temperatures of 270 to 290 degrees.
    - 4x4x120 mm test print had resistance of 41 to 51 Ohm depending on the print temperature.
    - \$70 per 1.75 mm of 750 g spool
    - Again price comparable to Proto-pasta, but with 8 times lower resistance.

=== Electrodynamics of Low-Conductivity Filaments vs Electrifi
- Standard commercial conductive filaments rely on microscopic carbon black, carbon nanotube, or graphite filler networks dispersed in thermoplastics.
- These carbon-loaded composite filaments exhibit low electrical conductivity, typically ranging from $sigma approx 0.01 "S/m"$ to hundreds $"S/m"$, with linear resistance measuring in tens to hundreds of $Omega / "cm"$.
  - At frequency of 1 GHz, a low conductivity of $sigma < 100 "S/m"$ prevents complete boundary reflection, causing incoming waves to penetrate deep into the material where energy is absorbed via ohmic losses. @Xie2017
  - #WARN I'm not totally sure, to what degree what they've numerically calculated is applicable to composite materials, they blabber about skin depth, but simple skin depth calculation isn't applicable to this case. So I would say 100 S/m is quite generous and real conductivity needs to be much higher.
- Low-conductivity filaments fail as high-Q resonant radiators or highly reflective phase-screen elements, but excel as single-step monolithic electromagnetic absorbers and radar cross-section dampeners.
- Conversely, copper-loaded filaments such as Electrifi achieve significantly higher bulk conductivities ($sigma approx 1.67 times 10^4 "S/m"$), placing them in a distinct performance tier - allowing them to act like a true metallic conductor at microwave bands @Xie2017, @Yurduseven2019. However even at $sigma approx 1.67 times 10^4 "S/m"$ performance of the final structure isn't that great.

=== Microwave Metamaterials Made by Fused Deposition
- *Source:* _Applied Physics Letters_, vol. 110, no. 18, 2017. @Xie2017
- *Research Context:* Direct evaluation of high-conductivity metal-polymer composite filament (Electrifi) versus standard carbon-loaded conductive filaments for 3D metamaterials.
- Methodology & Construction
  - Utilized dual-material FDM to print three-dimensional conductive unit cell topologies directly into a dielectric matrix, bypassing multi-layer PCB etching and manual stacking.
  - Analyzed the transition of effective medium parameters across a wide conductivity spectrum from $0.01 "S/m"$ to $10^6 "S/m"$ using EM field simulations.
- Experimental Findings
  - Demonstrated that carbon-loaded filaments ($sigma approx 0.01 - 100 "S/m"$) behave primarily as lossy dielectrics with minimal capacitive charge accumulation.
  - Proved that conductivities exceeding $10^2 "S/m"$ are required to elicit strong artificial permittivity responses reaching up to 14.4 at 1 GHz.
  - Validated that Electrifi ($sigma approx 1.67 times 10^4 "S/m"$) effectively mimics a perfect conductor at microwave frequencies without PCB stacking alignment errors



#pagebreak()
= Permittivity Measurement
- Accurate measurement of material properties is necessary for structure design and simulation.
  - Full-scale metamaterial structures are computationally prohibitive, necessitating the extraction of accurate localized surrogate models.
- *3D-printed metamaterials exhibit two superimposed layers of electromagnetic anisotropy.*
  - Geometric Anisotropy: The macroscopic unit cell structure (e.g., a rectangular block with a cylindrical void) responds differently to electric fields applied parallel versus perpendicular to its void axis.
  - Manufacturing Anisotropy: The microscopic layer-by-layer Fused Deposition Modeling (FDM) process introduces inter-track air voids. The bulk material fundamentally exhibits higher permittivity along the continuous filament extrusion paths than across the stacked layer boundaries.
  - Full-wave simulation is probably required prior to measurement to identify dominant operational modes, ensuring the characterization setup accurately replicates the final boundary conditions.


== Free-Space Measurement Techniques
- Free-space characterization involves illuminating a planar slab of the printed metamaterial using high-directivity antennas.
  - Adding dielectric lenses enhances directivity by collimating the beam into a highly planar wavefront, minimizing edge diffraction.
  - Lens effects are mathematically removed during the calibration step.
  - In a macroscopic free-space setup utilizing horn antennas, the transverse in-plane tensor components ($epsilon_(x x)$ and $epsilon_(y y)$) can be measured without reprinting the structure. The planar slab is physically rotated 90 degrees around the propagation axis to align with the linear polarization of the incident wave.
  - Evaluating the component $epsilon_(z z)$ (parallel to the propagation vector) requires complete reprint of the slab to align the unit cell's Z-axis transversely.
- *The Infinity Assumption Problem:*
  - Free-space quasi-TEM incidence attempts to evaluate the structure using Bloch-Floquet theory, which relies on the spatial harmonic expansion: $beta_n = beta_0 + (2 pi n) / p$.
  - Floquet modal analysis strictly assumes an infinite periodic lattice.
  - For a finite 3D-printed sample, translational symmetry is broken.
    - Truncation at the edges introduces macroscopic scattering and lateral energy leakage.
- *DUT Placement Constraints:*
  - Near-Field Placement:
    - Sandwiching the DUT directly between horn antennas induces reactive near-field coupling.
    - Standard Vector Network Analyzer (VNA) calibration performed without the DUT present becomes immediately invalid.
    - The source impedance of the antennas shifts when the DUT is inserted.
  - Far-Field Placement:
    - Placing the DUT in the far-field satisfies the plane-wave incidence assumption but introduces spillover (diffraction).
    - The interrogating beam width can exceeds the dimensions of a small 3D-printed sample.
    - The receiving antenna measures a composite signal encompassing the wave passing through the dense sample and the unperturbed wave passing through the surrounding air, diluting the extracted permittivity.
- *Dielectric Waveguide Calibration Methodology:*
  - To solve the free-space placement paradox, the measurement environment can be constrained using dielectric waveguides @Kato2019.
  - The VNA setup is calibrated using a homogeneous dielectric waveguide (serving as the Thru and Line standards).
  - The baseline waveguide cat then substituted with a segmented waveguide containing the metamaterial DUT embedded within it.
  - This technique prevents air-spillover and eliminates near-field probe coupling.
  - In addition, the reference plane is extended directly into the dielectric cross-section, isolating the intrinsic guided Bloch-mode.
  - However there arise problems with measuring anisotropy of the material
    - Physical rotation of the sample within the fixture is geometrically impossible. To extract orthogonal tensor components, the sample must be entirely reprinted with the unit cell geometry oriented to align the desired measurement axis with the fixture's electric field.
    - The Extrusion Bias Conundrum: Reprinting the metamaterial to rotate the unit cell geometry inherently alters the orientation of the FDM layer lines relative to the applied electric field, unless multi-axis non-planar printing is utilized.
      - The resulting measurement captures a convoluted response, mixing the intended geometric anisotropy of the metamaterial with the unintended anisotropic bias of the FDM printing process.
      - Isolating the geometric response from the manufacturing bias requires a prerequisite cross-calibration step: unperforated solid blocks of the base polymer must be printed in all three orthogonal orientations and measured to establish a baseline 3D permittivity tensor for the raw printing process before evaluating the perforated supercells.

=== Analytical Parameter Extraction
- Effective medium parameters are extracted from measured scattering parameters ($S_11$ and $S_21$) using the Nicolson-Ross-Weir (NRW) analytical formulation @Nicolson1970.
- The method first combines the scattering coefficients into composite variables:
  $ V_1 = S_21 + S_11 $
  $ V_2 = S_21 - S_11 $
  $ X = (1 - V_1 V_2) / (V_1 - V_2) $
- The intermediate reflection coefficient ($Gamma$) and transmission factor ($z$) of the material slab are derived as:
  $ Gamma = X plus.minus sqrt(X^2 - 1) $
  $ z = (V_1 - Gamma) / (1 - V_1 Gamma) $
  (Note: The sign for $Gamma$ is chosen such that $|Gamma| <= 1$)
- To determine the complex parameters, two intermediate variables ($c_1$ and $c_2$) are defined, incorporating the speed of light ($c$), angular frequency ($omega$), and sample thickness ($d$):
  $ c_1 = ((1 + Gamma) / (1 - Gamma))^2 $
  $ c_2 = - ( c / (omega d) ln(1/z) )^2 $
- The complex permeability ($mu_R$) and permittivity ($epsilon_R$) are subsequently calculated as:
  $ mu_R = sqrt(c_1 c_2) $
  $ epsilon_R = sqrt(c_2 / c_1) $
- *System Correction and Plane-Wave Limitations:*
  - NRW is mathematically formulated for closed, single-mode environments which enforce uniform phase fronts.
  - Original Nicolson's paper utilized a coaxial transmission line where dielectric DUT was realized as a disc placed into it @Nicolson1970.
  - In free space, a true uniform plane wave is impossible to achieve due to Gaussian beam divergence. The curved phase front violates the NRW assumption that the wave impacts the entire sample cross-section with identical phase and normal incidence.
- *Phase Ambiguity Resolution:*
  - The NRW equations suffer from phase wrapping when the physical sample thickness ($d$) exceeds a half-wavelength, causing the complex logarithm $ln(1/z)$ to yield multiple valid mathematical roots.
  - For 3D-printed continuous polymers, this phase ambiguity is deterministic.
  - As demonstrated by Chang & Lin (2026), the missing integer phase cycles ($M_"wrap"$) can be explicitly resolved by estimating an expected phase delay ($phi_"pred"$) based on the physical geometry of the central unit cell and comparing it to the measured VNA phase ($phi_"meas"$):
    $ M_"wrap" = "round"( (phi_"pred" - phi_"meas") / (2 pi) ) $
- *It's worthy to enable Time-Domain Gating:*
  - The VNA sweeps normally in the frequency domain. An internal Inverse Fast Fourier Transform (IFFT) converts the broadband S-parameter data into a synthetic time-domain impulse response.
  - A mathematical window (e.g., Hann or Chebyshev) is applied to this time-domain signal to isolate the primary transmitted pulse and zero-out late-arriving multipath reflections (e.g., signals bouncing off room fixtures or sample edges).
  - A subsequent Fast Fourier Transform (FFT) transforms the isolated pulse back into a smoothed, reflection-free frequency-domain response.

=== Advanced Extraction Algorithms - Kramers-Kronig (K-K) Relations:
- *Robust Branch Determination and Sign Selection:*  @Chen2004
  - NRW extraction frequently fails because small numerical or measurement errors can flip the sign of the real impedance ($z'$), and the real part of the refractive index ($n'$) is ambiguous due to the multiple branches of the complex logarithm.
  - The branch ambiguity of $n'$ is resolved iteratively by exploiting the mathematical continuity of the parameters across frequencies. By expanding the function $e^(i n k_0 d)$ in a Taylor series, the refractive index at a subsequent frequency is predicted from the previous one.
  - The initial branch index at the starting frequency is determined by enforcing strict physical causality: both the imaginary permittivity ($epsilon''$) and imaginary permeability ($mu''$) must be non-negative.
- *Effective Boundary Optimization:* @Chen2004
  - Standard retrieval methods assume the effective homogeneous boundaries of a metamaterial slab coincide perfectly with its physical geometry (e.g., $d / 2$). This often yields discontinuities in the extracted parameters .
  - Advanced robust methods determine the true effective boundaries and thickness of the slab dynamically by optimizing the physical distance parameters ($x_1$, $x_2$) to minimize the impedance mismatch between slabs of different cell counts across all frequencies.

== Measuring Permittivity using Ring Resonators
- *Mechanism:*
  - Resonant methods characterize the effective permittivity and dielectric loss of a material based on the perturbation of an electromagnetic field @Hehenberger2022.
  - When a printed material is introduced into the near-field of the resonator, it causes a measurable shift in the resonant frequency ($Delta f$) and a change in the resonance bandwidth ($Delta B$).
  - Complex to characterize the structure analytically; parameter extraction typically relies on mapping the measured $Delta f$ and $Delta B$ shifts against polynomial curves pre-computed from full-wave EM simulations (e.g., CST Studio Suite) rather than using direct analytical inversions.
- *Suspended Microstrip Ring Resonator Setup:*
  - A highly effective configuration for characterizing 3D-printed structures utilizes a suspended two-board system.
  - This system consists of a feeder printed circuit board (PCB) containing a microstrip transmission line, and a separate resonator PCB containing the microstrip ring.
  - The 3D-printed sample under test (e.g., an FCC or SC dielectric lattice) is sandwiched directly between the feeder and resonator boards.
  - Because the setup is suspended, mechanical pressure from the inserted sample can bend the boards, altering the baseline capacitance -- resonator PCB must be fairly rigid or have a support structure.
- *Split-Ring Resonators (SRR) for In-Line Process Monitoring:*
  - Moving beyond static post-print measurements, split-ring resonators can be integrated directly into the additive manufacturing process to measure the local relative permittivity of a 3D-printed part in-situ, layer-by-layer @Fieber2020.
  - The SRR is formed by placing two magnetic loops equidistant from a split ring to produce an electric field, causing the ring to resonate at a baseline frequency $f_0$. As the printer deposits material over the SRR's near-field, the shift in capacitance allows real-time mapping of the dielectric constant @Lekas2022.
  - The control system uses the SRR readings to apply closed-loop control, dynamically updating the infill density of subsequent layers to correct permittivity errors and variations in porosity as they happen @Lekas2022.
- *Advantages:*
  - Accommodates flat, solid materials and complex porous 3D-printed lattices without requiring the samples to be perfectly machined to fit inside a closed metallic waveguide @Hehenberger2022.
- *Critical Limitations:*
  - Multiple different cuts/models need to be created in order to map the anisotropy of the material - measurement is only in one axis.
  - Because the system relies entirely on resonance, the extracted permittivity and loss tangent are valid only at that single resonant frequency point -- different ring resonators would need to be used to map out permittivity in discrete steps over larger interval.
  - Zero Dispersion Insight: The method provides no data regarding the broadband behavior, spatial dispersion, or frequency-dependent loss profile of the printed material.
  - Cutoff Frequency Obfuscation: For periodic 3D-printed structures, the effective medium approximation breaks down at higher frequencies when the internal lattice constant approaches the operating wavelength. The resonant method is inherently incapable of detecting or characterizing this upper cutoff frequency.

== Closed Waveguide Measurements
- *Mechanism:*
  - Inserting the 3D-printed metamaterial directly into a metallic rectangular waveguide provides a rigidly bounded measurement environment that eliminates free-space diffraction and spillover.
  - This methodology operates in the dominant $"TE"_10$ mode, necessitating exact mechanical alignment to minimize parasitic air gaps.
- *Analytical Extraction & The Transmission/Reflection (TR) Method:*
  - Standard Nicolson-Ross-Weir (NRW) equations cannot be applied directly to waveguides because the guided wave exhibits spatial dispersion governed by the cutoff wavelength ($lambda_c$).
  - The waveguide propagation constant must be explicitly accounted for as $gamma = j sqrt(omega^2 mu_R^* epsilon_R^* / c^2 - (2 pi / lambda_c)^2)$ @Baker1990.
  - Traditional analytical algorithms inherently diverge for low-loss materials at frequencies where the sample length constitutes an integer multiple of a half-wavelength.
  - To eliminate this instability, Baker introduced a robust iterative Newton-Raphson procedure using combined sets of scattering parameters @Baker1990.
  - Alternatively, Boughriet proved that this half-wavelength divergence originates entirely from the $ (1-Gamma)/(1+Gamma) $ term. They formulated a completely non-iterative stable method that extracts effective electromagnetic parameters first, bypassing the instability without requiring the initial numerical guesses demanded by iterative methods @Boughriet1997.
- *The Air Gap Depolarization Effect (Critical Limitation):*
  - 3D printing (FDM/SLA) inherently suffers from dimensional shrinkage, layer-line roughness, and thermal warping, making a perfectly flush physical fit inside a machined metallic waveguide practically impossible.
  - Microscopic air gaps between the printed dielectric and the waveguide broad walls act as parasitic series capacitors. The electric field concentrates heavily in the low-permittivity air void rather than the material under test, drastically depressing the measured effective permittivity.
  - This uncorrected air gap error becomes catastrophic as frequencies scale into the millimeter-wave bands, reaching error rates exceeding 68% in standard setups @Wang2025.
  - Classical gap-correction models (e.g., $epsilon_(r,"meas") approx epsilon_r / (1 + ((Delta d) / b) (epsilon_r - 1))$) attempt to analytically reverse this depolarization. However, literature confirms these formulas systematically under-correct the real part of the permittivity ($epsilon'$) and over-correct the imaginary part ($epsilon''$) @Baker1990.
- *Modern Measurement Strategies (2025-2026):*
  - *Overmoded Waveguides:*  @Wang2025
    - To mitigate extreme air gap sensitivity at high frequencies, recent research utilizes overmoded waveguides.
    - By structurally expanding the broad and narrow dimensions of the measurement fixture relative to standard single-mode waveguides, the relative volumetric impact of the air gap is vastly reduced.
    - Errors were reduced from $>68%$ down to $<8%$ across the W-band.
  - *Open-Waveguide Flange Clamping:* @Isik2026
    - For sub-THz characterization (70-110 GHz) of 3D-printed slabs, modern workflows employ an open-waveguide junction where the sample is simply clamped directly between two flanges.
    - This models the sample as an equivalent shunt impedance, rendering the entire extraction mathematically insensitive to the sample's precise transverse shape or the presence of lateral wall gaps.
  - *Full-Wave Inverse Parameter Fitting:*
    - When characterizing complex 3D-printed unit cells, truncation against the metallic waveguide wall fundamentally disrupts the periodic lattice structure, rendering analytical TR extraction methods invalid.
    - The state-of-the-art solution physically recreates the exact sample—including internal voids, measured mechanical gaps, and truncated boundary edges—inside a full-wave 3D EM simulator (e.g., HFSS, CST) @Wang2025.
    - The intrinsic bulk permittivity of the 3D-printing filament is then tuned via nonlinear optimization algorithms until the simulated S-parameters converge precisely with the empirical VNA measurements.

#pagebreak()
= Metamaterial-Based Antennas

== Metantennas and Resonant Surfaces
- *Mechanism:* Incorporation of artificial subwavelength inclusions like split-ring resonators and electromagnetic bandgap grids into or around radiators.
- Multi-layer printed circuit board constraints limit conventional layouts to rigid, two-dimensional surfaces.
- Multi-material 3D printing circumvents PCB limits, facilitating the fabrication of spatial meta-atoms directly onto curved structural hulls.
  - Losses in the dielectric and limited conductivity degrade the performance significantly.
  - Printing layer variations and infill density fluctuations alter the local effective permittivity, shifting the antenna's tuned resonant frequency.

=== Low-Profile 3-D Printable Metastructure for Aperture Antennas #COOL
- *Source:* _Scientific Reports_, vol. 14, 2024 @Ali2024.
- *Research Context:* Enhancement of broadside directivity and radiation efficiency using a low-profile 3D-printed meta-superstrate.
- Methodology & Construction
  - Configured a periodic metamaterial array as an unexcited superstrate suspended directly above an active patch radiator.
  - To improve perforamce a hybrid cells combining dielectric and conductive material were used.
- Experimental Findings
  - Transformed expanding spherical wave distributions into highly directive broadside plane waves.
  - Achieved notable gain improvements while maintaining a compact, lightweight antenna profile.
- Personal notes
  - quite interesting, requires copper inserts into the structure, but looks reasonably manufacturable.

=== 3D Conductive Polymer Printed Metasurface Antenna for Fresnel Focusing
- *Source:*  _Designs_, vol. 3, no. 3,2017  @Yurduseven2019
- *Research Context:* holographic metasurface antenna for beam-focusing applications at 10 GHz using Electrifi filament
- Methodology & Construction
  - A PLA substrate was sandwiched between two surfaces from Electrifi - one ground plane second a Metasurface
  - Metasurface layer is patterned into an array of subwavelength slot-shaped metamaterial elements (or meta-elements). These meta-elements couple to the guided mode (or the reference wave) launched into the PLA substrate by a coaxial feed placed in the center of the antenna
- Experimental Findings
  - It was also observed that improving the material conductivity could significantly enhance the radiation characteristics of the proposed antenna.
  - Antenna exhibited relatively low gain, both lower conductivity and losses in substrate significantly degraded performance of the antenna.

== Leaky-Wave Antennas
- *Mechanism:* Propagation of fast-wave spatial harmonics along open boundary structures characterized by a complex longitudinal wavenumber $k_z = beta - j alpha$ @Monticone2015.
- *Design Rule:* The main beam radiation angle $theta_0$ (measured from broadside) is governed by the phase constant:
  $ sin(theta_0) approx beta / k_0 $
  while the elevation beamwidth is dictated by the normalized attenuation constant:
  $ Delta theta approx (2 alpha / k_0) / cos(theta_0) $
- Periodic leaky-wave structures introduce subwavelength geometric modulations of period $p$ to generate infinite space harmonics:
  $ beta_n = beta_0 + (2 pi n) / p $
  where radiation occurs when a specific Floquet harmonic (typically $n = -1$) enters the fast-wave region $|beta_n| < k_0$ @Monticone2015.
- *The Open Stopband (OSB) Problem:* At broadside radiation ($beta_n = 0$), reflections from individual periodic unit cells add constructively in-phase back to the input port, creating an open stopband characterized by severe impedance mismatch and radiation nulls @Monticone2015, @Liu2026.
  - Suppressing the OSB requires balancing series and shunt radiating elements or introducing asymmetric perturbations that establish destructive interference of reflections at the broadside frequency @Monticone2015, @Liu2026.

=== Existing Research

==== 3D Printed Spiral Leaky-Wave Antenna with Circular Polarization #COOL
- *Source:* _IEEE Open Journal of Antennas and Propagation_, vol. 4, 2023 @Valdes2023.
- *Research Context:* Design, manufacturing, and RF validation of an additively manufactured, fully dielectric leaky-wave antenna operating at 18 GHz that synthesizes high-gain broadside circular polarization using an Archimedean spiral corrugation.
- Methodology & Construction
  - The geometry consists of a grounded dielectric substrate ($h = 2 "mm"$, outer diameter $d = 180 "mm"$) with relative permittivity $epsilon_(r 1) = 3$ (PREPERM ABS300), fed by a central SMA coaxial probe (Pasternack PE4111) exciting a fundamental $"TM"_0$ cylindrical surface wave.
  - The periodic leaky perturbation comprises a raised Archimedean spiral corrugation with elevated permittivity $epsilon_(r 2) = 10$ (PREPERM ABS1000).
  - Fabrication utilized a single-extruder Creality CP-01 3D printer with a programmed pause at to swap filaments, eliminating interlayer adhesive boundaries and ensuring concentric alignment between substrate and spiral.
  - Parametric sweeps were performed across corrugation thicknesses and spiral permittivities ($epsilon_(r 2) = 3, 10, 15, 30$) to map their electromagnetic transfer functions.
- Experimental Findings
  - Measured reflection coefficient maintained $|S_11| < -10 "dB"$ across 16 GHz to 20 GHz (fractional bandwidth $> 22\%$).
  - Achieved a measured peak broadside gain of 25 dBi at 18 GHz with a narrow half-power beamwidth ($"HPBW" approx 6 degree$) and sidelobe suppression below $-20 "dB"$.
  - Maintained an axial ratio below the 3 dB threshold between 17.4 GHz and 19.18 GHz, validating that spiral winding orientation dictates circular polarization handedness (RHCP for counterclockwise, LHCP for clockwise).
  - Confirmed that altering the corrugation permittivity $epsilon_(r 2)$ tunes the guided propagation constant $beta_g$, shifting the circular-polarization broadside operating band without requiring physical re-scaling of the antenna footprint.
- Personal notes
  - Surprisingly good parameters while being relatively cheap to manufacture
  - They also use the PREPERM materials so it appears it's possible to get them shipped in a filament spool form.

==== LW ADS on Perforated Dielectric Spacer for Wide-Angle Beam Tilt
- *Source:* _IEEE Transactions on Antennas and Propagation_, vol. 71, no. 6, 2023 @Kaji2023.
- *Research Context:* A leaky-wave antenna with dielectric superstrate (LW ADS) using a periodically perforated dielectric spacer to achieve wide-angle tilted-beam radiation at X-band with a single feed.
- Methodology & Construction
  - The antenna consists of a ground plane, a half-filled perforated dielectric spacer (HDPE, $epsilon_r = 2.34$), and a dielectric superstrate (soda-lime glass, $epsilon_r = 6.8$). A standard WR-90 waveguide feed is placed at the center of the ground plane.
  - The dielectric spacer is perforated with a square lattice of cylindrical air holes ($p = 10 "mm"$). The effective permittivity $epsilon_("reff")$ is controlled by the hole radius $r$ via the volume-averaging relation:
    $ epsilon_("reff") = epsilon_("rsub") + (1 - epsilon_("rsub")) (pi r^2) / p^2 $
    yielding a tuning range $1.29 <= epsilon_("reff") <= 2.34$ for HDPE.
  - Only one half of the dielectric spacer is filled with perforated dielectric ($x < 0$), while the other half is left as air ($x > 0$). This asymmetric structure creates a *quasi-cutoff region* on the air side where leaky-wave modes cannot propagate — confining radiation to a single direction.
  - By adjusting the hole radius alone ($r = 4.3$, 3.4, 1.9 mm), three different beam angles were realized with the *same antenna height*, which is critical for multibeam arrays on uniform-height mounting surfaces.
- Experimental Findings
  - Measured tilted beams at $theta = 21 degree$, $40 degree$, and $52 degree$ with peak gains exceeding 14 dBi across all three configurations at 10 GHz.
  - The quasi-cutoff region successfully suppressed the unwanted broadside radiation mode that typically appears at large tilt angles — a problem that plagued previous LW ADS designs.
  - The directivity gain $G_d$ of LW ADS is proportional to $epsilon_(r 2) / epsilon_(r 1)$ — using perforated dielectric to achieve $epsilon_("reff")$ close to 1 while maintaining the structural integrity of a solid spacer maximizes the gain-to-height ratio.
  - Frequency range of 8-11 GHz for stable single-beam operation; at higher frequencies a secondary beam appears from the air-side region.
  - By controlling effective permittivity purely through hole geometry (not through changes in spacer height), an array of LW ADS elements with different beam directions can share a uniform mechanical profile — enabling a switched-feed multibeam antenna system with a flush mounting surface.
- *Personal notes*
  - This is a good example of a*relatively simple, well-executed leaky-wave antenna design. The physics is not novel (perforated dielectrics for permittivity control, asymmetric spacer for unidirectional radiation), but the integration of both concepts to achieve wide-angle beam steering at uniform height is clean and practical.
  - #INFO The quasi-cutoff concept is a cool — rather than using an absorber or complex termination, the air-half of the spacer simply does not support a guided mode. This is essentially a *modal* approach to suppressing the backward wave, distinct from the impedance-tapering approach discussed in the Monolithic Matched Termination research proposal. However in the forward direction there should still be unwanted radiation
  - While not 3D printed the dielectric spacer design is compatible with 3D printing technology

=== Possible Research Areas for Leaky-Wave Antennas

==== Monolithic Multi-Material Matched Terminations for LWAs
- #INFO: Ruled out for the thesis — requires dual-extruder FDM with conductive/lossy filament, which is not available. However, it would be an interesting research topic
- *Underlying Electrodynamic Problem:*
  - Traveling-wave and leaky-wave antennas inherently retain residual guided power at the distal end of the aperture ($approx 10 - 20\%$) to maintain reasonable aperture efficiency @Monticone2015.
  - Unradiated residual power reflecting off an open termination launches a backward-traveling wave that creates high sidelobes, distorts main-beam directivity, and degrades the axial ratio in circularly polarized apertures.
  - Conventional external terminations introduce parasitic inductance, connector losses, and complex manual assembly - and since matching the traveling wave impedance isn't straightforward terminators are often emitted in the first place.
- *Additively Manufactured Monolithic Reflectionless Load Architecture:*
  - Multi-head FDM systems permit co-printing a low-loss structural dielectric (antenna body) and an electrically lossy composite polymer (absorber) in a single uninterrupted fabrication cycle.
  - The termination is integrated directly into the guiding substrate as a physical continuation of the antenna line.
- *Impedance Tapering and Reflection Suppression:*
  - An abrupt material interface between low-loss dielectric ($Z_0$) and lossy composite ($Z_L$) causes severe back-reflection.
  - Reflectionless energy transfer requires continuous spatial impedance tapering over an axial length $L >= lambda_g / 2$:
  $ Z(z) = Z_0 exp(1/2 ln(Z_L / Z_0) (z / L)) $
  - This continuous function is discretized into interlocking subwavelength geometric wedges where lossy filament volume fraction increases monotonically along the propagation axis.
  - Alternatively, variable-density infill or dual-tool spatial dithering smoothly shifts the complex effective permittivity:
  $ epsilon_("eff")(z) = epsilon'_("eff")(z) - j epsilon''_("eff")(z) $
  maintaining $epsilon'_("eff")$ matching while gradually ramping $epsilon''_("eff")$ to attenuate the forward traveling wave.
- *Research Value:*
  - I haven't found even a single study doing this.
  - However many designs of LWAs are done in such a way that the guided mode cannot really exist past end of the antenna, which also solves the problem somewhat (e.g. it transitions into structure acting as subcritical waveguide)

==== Continuous Sinusoidal Reactance Surfaces via Different Methods
- #INFO either it would take essentially  the same approach as @Araghi2024 only twist it 90 degrees (which would probably degrade the perforamce given the orientation of electric field) or it would be pain dealing with Foaming PLA, not to mention achievable spread of permittivities with just expansion isn't that high
- *Concept:* There needs to be a sinusoidal change in permittivity in order to work as a leaky-wave and not excite higher-order spatial harmonics @Araghi2024.
  - Basic designs will just interchange blocks of dielectric and air - producing higher-order spatial harmonics.
  - More advance ones use complex unit cells or realize the sinusoidal pattern in $z$ axis
- *Mechanism 1:* Utilizing active temperature modulation of the FDM hotend during the print, the volumetric expansion of Foaming PLA (PolyLite LW-PLA or ColorFabb LW-PLA) can be continuously varied.
- *Mechanism 2:* Utilizing differing infill level to modulate the permittivity (the infill will still have sinusoidal pattern so it's not tha different from modulating height in $z$)
- *Research Value:*
  - Don't think anybody has done it - be it modulating infill or using foaming PLA
  - Instead of a square-wave permittivity profile, the LWA is printed with a mathematically somewhat continuous, sinusoidal spatial permittivity gradient.
  - A pure sinusoidal modulation theoretically couples energy *only* into the $n = -1$ radiating harmonic, suppressing all other parasitic modes and grating lobes, maximizing directivity and radiation efficiency.
- *Challenges:* \
  - For Foaming PLA:
    - It's necessary to establish a highly accurate, calibrated mapping between the G-code extrusion temperature, the resulting physical void fraction, and the extracted RF permittivity.
    - Print times would be long with need to constantly adjust nozzle temperature and wait for it to settle.
    - Change in volume of foaming filaments is roughly 3 times between highest and lowest - so the change in permittivity probably wont be that large.
  - Both necessitate development of completely new slicer, or more likely a program that would generate the gcode directly.

==== Chirped Conformal LWAs with Pre-Distorted Geometries
- *Concept:*
  - Mounting a standard periodic leaky-wave antenna onto a curved aerodynamic surface fundamentally bends the electromagnetic propagation axis.
  - This conformal curvature introduces a severe non-linear phase error ($Delta phi$) across the radiating aperture.
  - Uncompensated phase errors cause the main beam to defocus, directly collapsing the directivity and elevating parasitic side-lobe levels.
  - Standard planar printed circuit board manufacturing cannot easily pre-distort the substrate thickness or internal dielectric density to match the required phase gradient on a highly curved surface.
- *Mechanism:*
  - An inverse-design methodology is deployed where the unit-cell periodicity ($p$) and the effective dielectric constant ($epsilon_("eff")$) are progressively altered along the curved propagation axis @Bartley2025.
  - Additive manufacturing would enables this phase correction by continuously modifying the internal geometric fill fraction to tune the effective dielectric constant at every discrete spatial coordinate.
- *Research Value:*
  - Very little research has been done on these.
  - Utilizes unique capability of 3D printing to fabricate non-uniform, spatially varying structures that are geometrically impossible/hard to manufacture using traditional subtractive milling.
  - Recent studies employing effective dielectric constant modeling demonstrate that 3D-printable pre-distorted unit cells can scan coherent phase fronts over $plus.minus 28 degree$ directly from cylindrical surfaces @Bartley2025.
- *Challenges:*
  - CAD workload is more complex, highly accurate surrogate model of the unit cell needs to be created and validated.
  - Beamforming is already complicated, this is doing beamforming on a more complex geometry. (But one other students under Ding Bing Lin is alterad working on beamforming using basic structure from @Kaji2023)
  - There will be problems with anisotropy.
    - If unit cells aren't always in parallel with the local surface normal there will be some error.
    - Even if unit cell is rotated correctly the raster lines of 3D printer lead inherently to anisotropic environment -- 3D print parameters must be rigorously characterized.


==== Open Stopband Suppression in All-Dielectric 3D-Printed Periodic LWAs
- *Underlying Electromagnetic Problem:*
  - At broadside radiation ($beta_n = 0$), reflections from individual periodic unit cells in a grating-type LWA add constructively in-phase back to the input port, creating an open stopband (OSB) characterized by  impedance mismatch and a radiation null @Monticone2015.
  - In metallic LWAs, OSB suppression is well-studied: asymmetric unit cells, matching stubs, quarter-wave transformers, and transversal asymmetry have all been demonstrated @Monticone2015 and @Liu2018.
  - In *dielectric-only* 3D-printed LWAs, OSB suppression is barely studied
    - The spiral LWA of @Valdes2023 inherently suppresses the OSB through continuous rotational asymmetry, but this is tied to the spiral geometry and does not generalize to linear grating-type LWAs
    - The dual-grating shifted structure of @Francois2026 closes the bandgap through longitudinal offset of two grating layers — a fundamentally different mechanism tied to their ground-plane-free ceramic design.
    - There is no systematic study of OSB suppression techniques for simple, single-material, FDM-printable dielectric grating LWAs utilizing conventional construction with ground plane.
- *Research Value:*
  - Directly addresses a known fundamental problem (OSB) in an under-explored domain.
  - Simulation-heavy but fabrication-light: unit cell dispersion analysis in HFSS/CST for each candidate geometry, followed by printing and measuring 1-2 promising prototypes.
  - Single filament, simple rectangular geometries, standard FDM — no exotic requirements.
- *Challenges:*
  - Dispersion analysis (Bloch-wave extraction from unit cell S-parameters) is computationally intensive — requires careful simulation setup.
  - The OSB suppression mechanism must be validated not just in simulation ($|S_{11}|$ and $beta$ vs. frequency) but also in far-field pattern measurements — broadside gain collapse is the definitive signature of an unsuppressed OSB.
  - Simulations would likely need to be run on true geometry not surrogate model - which is usually sufficient to capture the desired leaky wave behavior.

==== Tapered Aperture Illumination for 3D-Printed Dielectric LWAs
- *Underlying Electromagnetic Problem:*
  - Most 3D-printed dielectric LWAs use *uniform* grating geometries — same tooth height, same fill factor, same period throughout the entire aperture @Valdes2023, @Kaji2023, @Francois2026.
  - A uniform grating produces an *exponentially decaying* aperture field distribution.
  - This non-uniform illumination reduces aperture efficiency (the aperture is under-utilized near the distal end) and produces asymmetric sidelobes that cannot be independently controlled.
  - In metallic LWAs, aperture tapering is standard practice: the leakage rate $alpha(z)$ is controlled along the aperture by varying slot width, stub length, or element coupling to achieve a desired amplitude distribution.
- *Additively Manufactured Tapered Aperture Architecture:*
  - The leakage rate $alpha$ of a dielectric grating LWA is a function of the grating geometry — primarily the tooth height $h_t$ and the fill factor $l/p$ (tooth width to period ratio).
  - By *gradually increasing* the tooth height or fill factor along the propagation direction, the leakage rate increases to compensate for the decaying guided-wave power, producing a more uniform aperture illumination.
  - The entire tapered grating structure is printed as a single dielectric piece — no geometry is repeated, but all elements are variations of the same simple rectangular-tooth motif.
- *Research Value:*
  - Directly improves antenna performance (higher aperture efficiency, lower sidelobes, symmetric patterns) without changing materials, feed, or adding components.
  - Once the $alpha(h_t)$ or $alpha(l/p)$ relationship is characterized for a given dielectric material and substrate geometry, the taper profile can be synthesized analytically.
  - Single filament, simple geometry, standard FDM — the only complexity is in the CAD (each grating tooth is slightly different).
- *Challenges:*
  - The $alpha(h_t)$ relationship must be extracted numerically (dispersion analysis of unit cells with varying $h_t$).
  - When looking soly at the leakage creates near the feed the grating would need to be very shallow - potentially limited by the FDM limits, however, in practice there would be more limits at minimal height - dictated by material properties to achieved needed permittivities and such.

==== All-Dielectric Ground-Plane-Free LWA Translated to Commodity FDM
- *Underlying Concept:*
  - François et al. (2026) demonstrated an all-dielectric leaky-wave antenna with *no metallic ground plane*, fabricated from pure $"Al"_2"O"_3$ ceramic via stereolithography at 70-90 GHz @Francois2026.
  - The unidirectional radiation mechanism relies on a dual-grating unit cell with a constructive interference toward the top hemisphere, destructive interference toward the bottom.
  - The photonic bandgap is designed at the second Bragg condition, then closed by the grating shift to allow leaky-wave propagation while suppressing the open stopband.
  - Measured: $>85\\%$ of radiated power in the upper hemisphere, $>23 "dBi"$ gain, $-18 degree$ to $+22 degree$ scanning.
- *Research Opportunity — FDM Translation:*
  - The François design uses ceramic SLA (Lithoz CeraFab 7500) with $epsilon_r = 9.2$ $"Al"_2"O"_3$ — a high-end process with $25 mu"m"$ resolution and near-perfect surface quality.
  - The *physics* of the dual-grating unidirectional mechanism is material-agnostic — assuming that the permittivity is high enough to support the guided mode.
  - Zetamix Epsilon 7.5 filament ($epsilon_r = 7.5$, $tan delta approx 10^(-3)$) could potentially support this mechanism at a lower frequency (Ka-band or V-band), where the larger wavelength relaxes FDM resolution requirements.
  - The key open question: *how does FDM surface roughness and the inherent anisotropy of printed layers affect the photonic bandgap behavior that the design relies on?*
- *Research Value:*
  - Demonstrates whether a sophisticated photonic-bandgap-based LWA design can survive the transition from high-end ceramic SLA to commodity FDM.
  - Quantifies the surface roughness penalty on unidirectionality ($R$) — the François paper achieves $R = 85.6$~% measured.
  - If successful, establishes a path to truly metal-free, single-print, high-gain LWAs at mm-wave frequencies using accessible equipment.
- *Challenges:*
  - The dual-grating geometry has two grating layers at different heights within the substrate — this requires printing of internal air gaps (the lower grating cavity), which is challenging in FDM (overhangs).
  - #INFO The paper uses a Mikaelian lens integrated into the same dielectric slab for wavefront collimation — this adds another layer of printing complexity that could be deferred by using a simpler direct waveguide feed for initial validation.

=== Other Papers
- @Liu2026
  - talks about some Spoof Surface Plasmon Polaritons (SSPPs) -- looks cool but I have no idea what it is
  - construct is plated with metal -- (basically a radiating waveguide), but the geometry is way too complex to do some electroplating or whatever.
- @Araghi2024
  - similar to @Kaji2023, however instead of unit cells with cylindrical cutout uses a sinusoidal structure - combining air and material

== Reflectarray Antennas
- *Mechanism:* A reflectarray antenna (RA) is a hybrid architecture combining the spatial feeding of a parabolic reflector with the planar aperture of a phased array @Nayeri2018, @Huang2008.
- A horn feed illuminates a planar (or conformal) array of passive unit cells, each backed by a ground plane.
- Each unit cell applies a locally controlled phase shift $Delta phi_(m n)$ to the reflected wave to compensate for the spherical path-length difference from the feed, transforming the incident spherical wavefront into a focused plane wave in the desired direction:
  $ Delta phi (x_m, y_m) = (2 pi) / lambda_0 sqrt(x_m^2 + y_m^2 + F^2) $
  where $F$ is the focal length from the feed phase center to the array surface @Huang2008.
  - As incident angle on each cell is different - we are illuminating it with spherical waves (in best case), different incident angles need to be simulated and look up table created to correct needed permittivity.
- #TODO read @Nayeri2018 -- the definitive textbook on reflectarray theory, design procedures, and state-of-the-art implementations covering broadband, multi-band, multi-beam, contour-beam, beam-scanning, and reconfigurable configurations.

=== Why Reflectarrays?
- Compared to parabolic reflector antennas: flat/low-profile form factor, no complex curved mold tooling, easier integration onto satellite panels or building walls.
- Compared to phased arrays: no lossy, expensive, and heavy corporate feed network with discrete phase shifters -- the spatial feeding eliminates most RF distribution losses.
- By individually varying phase shift in each part of dish (where shifts can also be different for different polarization) polarization transformation can be achieved, or antennas XPD improved (only one polarization will be focused)
- Key trade-off: inherently narrower bandwidth than parabolic dishes due to the resonant nature of printed unit cells and differential spatial phase delay (frequency-dependent path-length differences from the feed) @Nayeri2018.

=== Phase Tuning Mechanisms
- The unit cell must deliver a reflection phase coverage of at least $360 degree$ with near-unity reflection magnitude ($|S_11| approx 1$) for high aperture efficiency.
  - however for smaller arrays (that require to be illuminated by already fairly tight beam) a smaller phase covererage is required @Nayeri2018;
- *Reflectarray is continous:*
  - There are no strictly defined physical boundaries between individual unit cells.
  - Propagation parameters of each cell are controlled via spatial variations in material density or perforation to achieve the desired phase shift.
  - While based on effective medium theory, it remains a reflectarray by definition, utilizing a planar aperture spatially discretized into a grid of unit cells that impart a position-dependent phase shift to shape or steer an incident wave.
  - A primary advantage of continuous structures is enhanced structural integrity and simplified manufacturing.
  - Continuous topologies also mitigate severe edge diffraction and scattering associated with abrupt vertical boundaries in discrete arrays.
  - @Massaccesi2023 utilizes this principle.
- *Reflectarray is discrete:*
  - Individual cells have strictly defined boundary conditions and typically operate as isolated resonators.
  - Cells are often connected using a common thin base layer to ensure manufacturability, though electromagnetic coupling via this base is actively minimized.
  - Discrete arrays offer superior spatial resolution and reduced inter-element coupling, allowing for highly independent polarization control and aggressive phase gradients.
  - Phase tuning mechanism  @Nayeri2018
    - Elements with phase/time-delay lines:
      - All elements are tuned to the same design frequency, signal gets absorbed, travels on a given delay line and then is re-emitted.
      - Not really usable for 3D printing applications.
    - Variable geometry:
      - Physical size of the element is changed to provide phase tuning.
      - Changing the length of a resonant element changes the resonance frequency of the antenna, which corresponds to a change in radiated phase at a certain frequency.
      - Whole $2 pi$ of phase change can be covered using resonator design @Zhang2017.
        - There the change in resonant frequency and phase was achieved by having fixed dielectric constant, fixing two dimensions of the resonator and altering the final one
        - Different approach would be altering the permittivity of the material thus tuning the resonant frequency - resonator blocks could then be of the same size.
    -  Variable rotation angle:
      - Restricted to CP designs.
      - Rotating the element by given angle base will change the phase delay by some angle (not neccesarily mapping 1:1).
      - Not sure if this could be applicable to dielectric resonators - probably yes.
  - In conventional discrete designs, two dimensions of the cell are fixed to establish a baseline resonance, while third one is varied to tune the phase shift.
    - @Zhang2017 utilizes this geometric tuning principle. - height and width is fixed with length being tuned
  - If the internal permittivity of the discrete cell is directly tunable, the physical dimensions can remain strictly constant.
  - Altering the localized permittivity directly shifts the resonant frequency of the fixed-geometry cell, thereby changing the reflection phase at the operating frequency without requiring length adjustments.
  - For non-resonant discrete cells acting as variable delay lines, altering permittivity modifies the propagation constant, providing the required phase delay independently of physical height.

=== Existing Research

==== 3D-Printed Dielectric Resonator Reflectarray
- *Source:* _IET Microwaves, Antennas & Propagation_, vol. 11, no. 14, 2017 @Zhang2017.
- *Research Context:* First demonstration of an FDM 3D-printed dielectric resonator reflectarray operating at mm-wave frequencies (30 GHz).
- Methodology & Construction
  - The reflectarray comprised 625 dielectric resonator elements on a $120 times 120 thin "mm"^2$ aperture with a total mass of only 67 g.
  - Fabricated using FDM in a single-step process without any machining, metal deposition, or post-processing.
  - Each dielectric resonator element acts as a weakly coupled radiator, with its height controlling the local reflection phase.
  - Used custom filament that raised the  permittivity to $epsilon_r = 4.4$ in order to achieve full $360 degree$ coverage
    - base material of $epsilon_r = 2.75$ achieved only roughly $270 degree$
- Experimental Findings
  - Ran into trouble with achieving resonant behavior - most affordable materials exhibited too low $epsilon_r$ to achieve resonance - their own custom filament needed to be manufactured.
  - Measured gain of 28 dBi at 30 GHz when offset-fed by a Ka-band horn antenna.
  - The dielectric resonator approach inherently minimizes ohmic losses and inter-element mutual coupling compared to metallic printed patches.
  - Demonstrated that FDM resolution is sufficient for mm-wave dielectric reflectarrays despite the relatively coarse nozzle diameters.

==== Dual Circularly Polarized Broadband Dielectric Reflectarray
- *Source:* _IEEE Transactions on Antennas and Propagation_, vol. 70, no. 7, 2022 @Cheng2022.
- *Research Context:* A broadband dual-circularly polarized (dual-CP) reflectarray fed by a single linearly polarized (LP) horn, realized entirely from 3D-printed dielectric materials.
- Methodology & Construction
  - The unit cell consists of two orthogonal dielectric blocks of independently variable heights.
  - The incident LP wave from the feed is decomposed into two orthogonal equal-amplitude components by the dielectric block pair.
  - By controlling the differential height of the two blocks, the reflected orthogonal components are recombined with a $+- 90 degree$ phase shift, synthesizing left-hand or right-hand circular polarization (LHCP/RHCP).
  - Full-wave simulations were validated against a fabricated prototype measured in an anechoic chamber.
- Experimental Findings
  - Achieved broadband dual-CP operation ($> 20$~% fractional bandwidth) without requiring a dual-CP feed or complex multi-layer PCB fabrication.
  - The all-dielectric construction eliminates conductor losses, resulting in high radiation efficiency even at Ka-band frequencies.
  - Demonstrated that 3D printing enables polarization diversity from a single LP feed -- a capability that would require multiple PCB layers with conventional fabrication.

==== 3D-Printed Wideband Reflectarray with Mechanical Beam-Steering
- *Source:* _International Journal of Microwave and Wireless Technologies_, vol. 16, Special Issue 1, 2024 @Massaccesi2023.
- *Research Context:* Ka-band dielectric reflectarray using a perforated dielectric unit cell for wideband performance combined with bifocal design for wide-angle mechanical beam-steering.
- Methodology & Construction
  - The unit cell consists of a single-layer dielectric element perforated with a square hole, whose side dimension controls the local reflection phase.
  - A $52 times 52$ element reflectarray was designed, 3D-printed, and measured.
  - Beam steering was implemented mechanically by moving the feed along an arc, with a bifocal phase distribution optimized for $+- 40 degree$ scanning.
  - The perforated dielectric approach avoids metallic inclusions entirely, reducing loss and simplifying fabrication to a single dielectric print.
- Experimental Findings
  - Less than 0.8 dB gain variation over the full $+- 40 degree$ scanning range in the vertical plane.
  - 3 dB gain bandwidth ranging from 13.5% to 28% depending on the beam pointing direction.
  - The unit cell demonstrated stable phase behavior with respect to both frequency and incident angle, enabling robust wide-angle scanning performance.
- *Personal notes*
  - If I had to guess the unit cell while simple will exhibit worse incidence incidence angle stability then if e.g. circular cutout would been used.
  - Of course the incidence angle change was considered during the design process so main correction have been implemented, still maybe there would be some room for improvement.

==== 3D-Printed Kirigami-Inspired Deployable Reflectarray
- *Source:* _IEEE Transactions on Antennas and Propagation_, vol. 70, no. 9, 2022 @Cui2022.
- *Research Context:* A dielectric reflectarray with one-shot deployability and wide-angle beam-scanning enabled by a kirigami-inspired (cut-and-fold) element structure combined with bifocal phase design.
- Methodology & Construction
  - The kirigami unit cell structure can be retracted into a compact, flat-folded state and deployed in a single motion, analogous to origami engineering.
  - The deployed structure maintains precise dielectric element alignment for mm-wave operation.
  - Bifocal phase synthesis provides wide-angle scanning capability without the gain collapse that single-focus designs suffer beyond narrow angular ranges.
- Experimental Findings
  - Demonstrated successful deployable operation at mm-wave frequencies with robust beam-scanning performance.
  - The combination of deployability and beam-scanning is uniquely enabled by 3D printing -- conventional rigid PCBs or machined metal cannot achieve this form factor.
- *Personal notes*
  - Deployable structures are particularly relevant for small satellites (CubeSats) where stowed volume is severely constrained but a large-aperture high-gain antenna is needed on orbit.
  - Definitely too complex for the thesis given the time constrains

==== Bi-Material Bragg-Based Reflectarray
- *Source:* _Sensors_, vol. 24, no. 20, 2024 @Bragg2024.
- *Research Context:* A fully dielectric bi-material reflectarray exploiting a 1D Bragg reflector unit cell to create bandgap (frequency-selective reflection) characteristics for multi-band applications.
- Methodology & Construction
  - The unit cell is based on a one-dimensional Bragg reflector -- alternating layers of two dielectric materials with different permittivities.
  - Bi-material 3D printing deposits the alternating dielectric layers.
  - The bandgap behavior creates frequency-selective reflectarray operation, reflecting strongly in designed passbands while being transparent elsewhere.
- Experimental Findings
  - Measured gain of 27.22 dBi at 27 GHz with aperture efficiency of 35.05%.
  - Verified transparency outside the design band, demonstrating the multi-band potential of the Bragg approach.

==== Ka-Band Reflectarray with Cylindrical Dielectric Unit Cells
- *Source:* _Sensors_, vol. 25, no. 17, 2025 @Beccaria2025.
- *Research Context:* A fully dielectric Ka-band reflectarray using cylindrical unit cells printed from Zetamix ceramic filament, where the infill density is tuned during fabrication to control effective permittivity -- treating infill as an additional design degree of freedom -- however, not in the manufacturing phase.
- Methodology & Construction
  - Uses array of cylindrical dielectric resonators.
  - Zetamix $epsilon_r$ 7.5 ceramic-loaded filament ($"TiO"_2$-based) was used with FDM printing.
  - Different unit cells designs were analyzed
    - Cylindrical unit cells of fixed external dimensions but variable internal infill produce the required $360 degree$ reflection phase range.
    - While testing effect of height of the unit cell, while keeping permittivity fixed, it was found that the base permittivity of the material needed to be fairly high to achieve the results -- permittivity of $epsilon_r = 5$ was unable to cover range of $360 degree$
    - Final design selected a fixed height and fixed permittivity (controlled with infill)
- Experimental Findings
  - Validated that infill density provides a practical, repeatable method for spatial permittivity control.

==== Other Papers
- @Whittaker2023 surveys 3D printing materials and techniques for antennas and metamaterials, highlighting dielectric resonator reflectarrays as a promising application area.
- @Wu2018 - 3D-printed dielectric reflectarrays at 220 GHz demonstrated wideband performance in the sub-THz regime -- shows that printing resolution is viable even at these high frequencies .
- Convex conformal reflectarrays with enhanced efficiency and reduced sidelobe levels using 3D-printed dielectric elements on a curved metallic ground @Beccaria2021.

=== Potential Research Directions for 3D-Printed Reflectarrays

==== Graded-Index (GRIN) Reflectarrays via Infill Density Control
- *Underlying Electromagnetic Problem:*
  - Conventional 3D-printed dielectric reflectarrays achieve phase control through geometric height variations of the unit cell elements.
  - This inherently creates a non-uniform physical profile -- taller elements protrude further from the ground plane, introducing shadowing effects at oblique incidence, complicating conformal mounting, and creating stress concentrations in mechanically loaded applications.
  - Geometric height variation also creates a stepped surface that introduces unwanted diffraction and scattering at element boundaries, reducing aperture efficiency at higher frequencies.
- *Additively Manufactured GRIN Reflectarray Architecture:*
  - Instead of varying geometry, the reflectarray maintains a constant, flat external profile while the local effective permittivity is spatially modulated through infill density control.
  - The reflection phase is controlled by the effective dielectric constant of each unit cell, which is tuned by adjusting the internal fill fraction during printing:
    $ epsilon_(r,"eff")(x,y) = epsilon_(r,"solid") dot "fill"(x,y) + epsilon_(r,"air") dot (1 - "fill"(x,y)) $
  - This creates a truly flat, homogeneous external surface with internal material grading -- impossible with conventional PCB or machining approaches.
- *Research Value:*
  - Enables completely flush-mounted reflectarrays for conformal aerospace and vehicular applications.
  - Eliminates geometric shadowing effects at oblique feed angles, potentially improving wide-angle scanning performance.
  - The smooth internal grading (vs. discrete step transitions) may reduce unwanted scattering, improving gain and sidelobe performance.
  - Somewhat close to what is in @Massaccesi2023 - there the infill is always 100 % but effect is the same - height stays the same, density is varied.
- *Challenges:*
  - Requires precise calibration of the infill-to-permittivity mapping function across the full 0-100% density range, including anisotropy effects from infill pattern orientation relative to the incident E-field.
  - Slicer software must be augmented or bypassed to assign unique infill percentages to each unit cell -- programmatic G-code generation is required.
  - At very low infill densities, mechanical integrity becomes a concern for larger apertures.
- *Problems with FDM/SLA Technology*
  - Cell design such as used in @Massaccesi2023 is more simpler, easier to characterize and doesn't really have any disadvantages (especially as the unit cells are rather small).
  - There is a problem with the unit cell size -- most papers require larger arrays with smaller sizes of cells to achieve good results.
  - Neither 3D-printing technology is that adapted to printing infill in small spaces, print quality consistency (or even actually infill value) cannot be guaranteed
    - It's common for both SLA/FDM to print such small features with 100 % infill which guarantees some quality.
    - Only infill pattern which is worth considering is concentric - however, there would still be abrupt stops (in case of square unit cell design where the infill would also have square shape)
  - While slicers support varying infill through the structure using information supplied in .3mf files the capabilities are limited.
    - Even in small array of 20 x 20 the number of cells is 400.
    - It's hard to say if the slicers would be able to handle this. The functionality is more designed for low tens of individual infill zones.
- It would generally be beneficial to connect regions of same infill level together - thus moving from reflectarray to more continous structure such as kinoform, phase fresnel reflector.

==== Reflectarrays with Form Birefringence
- *Underlying Electromagnetic Problems*
  - Utilizing clever unit cell design (cells that exhibit anisotropy along their principal axis) a polarization transformation (using similar mechanism as transmitarrays) or XPD improvement can be achieved.
  - Example in @Cheng2022 - cell geometry is different in $x$ and $y$ axis. Thus exhibits a form birefringence affective EM wave differently in each axis.
  - Or similarly while most feeders will have some cross-polar reception the array can be designed in such a way that only the desired polarization will be focused - thus improving XPD.
  - Typically such designs relied on blocks of differing height
- *Additively Manufactured Polarization Reflectarray Architecture:*
  - Instead of using blocks of different heights a uniform height array would be printed where different handling of each polarization would be achieved with unit cell design.
  - Basic cell design of @Massaccesi2023 could be modified to instead use a eliptical cutout - which would give different permittivity in both axis.
- *Research Value:*
  - Utilizing design based on @Massaccesi2023 would lead to more mechanically robust system then other solutions.
  - I don't think such design has been realized #TODO verify more thoroughly, haven't been able to find anything at a quick glance.
- *Challenges:*
  - Information on anisotropy of the material would be required complicating some measuring techniques -- would basically necessitate a measuring while having the material squeezed between two waveguides.
  - Properties of polarization would be entangled - some computer optimization would be required to achieve the correct properties.


==== Conformal 3D-Printed Reflectarrays on Arbitrary Curved Surfaces
- *Underlying Electromagnetic Problem:*
  - A reflectarray typically assumes a planar aperture for which the phase compensation formula $Delta phi (x_m, y_m) = (2 pi) / lambda_0 sqrt(x_m^2 + y_m^2 + F^2)$ is valid.
  - When the array is mapped onto a curved surface (cylindrical fuselage, spherical radome, aerodynamic wing leading edge), the path lengths from the feed to each element change non-trivially, and the element's local coordinate system is rotated relative to the feed.
  - Standard planar phase synthesis produces severe beam defocusing, gain collapse, and increased sidelobes on curved surfaces.
- *Additively Manufactured Conformal Reflectarray Architecture:*
  - 3D printing enables fabrication of the reflectarray directly onto a pre-shaped curved substrate or as a free-standing curved structure.
  - The phase distribution must be recalculated using full 3D ray tracing from feed to each element on the curved surface, accounting for local surface normal rotation.
  - Each element's geometry may need individual optimization not just for phase but also for polarization alignment as the incident E-field orientation rotates across the curved surface.
- *Research Value:*
  - Enables high-gain antennas integrated directly into aircraft fuselages, drone bodies, or vehicle roofs without external protrusions -- each surface becomes a potential antenna aperture.
  - The conformal approach combined with the flush GRIN concept (above) could produce truly aerodynamically neutral high-gain apertures.
  - Pushes programmatic CAD and computational electromagnetics co-design to new levels -- each element on a doubly curved surface is unique, requiring automated design workflows.
- *Challenges:*
  - The design space explodes - range of incidence angles is larger and also local surface normal rotates, which changes the relationship between feed coordinates and element coordinates
    - Unit cell needs to have high angular stability (Which is already desired in planar configuration) - still, as with normal design, simulations/measurements need to be run with different incident angles in order to accurately create a look up table - and the change of surface normal should also be considered.
    - Local incidence condition changes for each element (The change is there even for planar configuration but less pronounced) - combined with inherent anisotropy it might be too complex.
    - Surrogate modeling and surrogate based optimization will probably become necessary.
    - However there are some cell designs that exhibit very good angular stability.
  - Printing large curved structures with sub-millimeter accuracy requires advanced toolpath generation beyond standard planar slicers.
  - Feed placement and illumination taper optimization become significantly more complex on curved surfaces compared to planar apertures.


==== Reflectarray Printed With Integrated Dielectric Rod Feed Antenna
- A dielectric rod antenna is a traveling-wave antenna
  - Tapered dielectric cylinder (or rectangular rod) fed by a metallic waveguide.
  - The guided wave travels along the rod and gradually leaks into free space, producing an end-fire radiation pattern.
  - Mounted at the center or edge of a reflectarray, the rod points toward the array surface and illuminates it.
- *Underlying Problem:*
  - Nearly all published 3D-printed reflectarrays use a separate, commercially manufactured horn antenna as the feed.
  - This introduces alignment uncertainty during assembly, adds a separate component cost, and prevents full system miniaturization.
  - The feed-to-reflectarray distance (focal length) and alignment are critical parameters -- misalignment by even a fraction of a wavelength degrades gain and increases sidelobes.
- *Additively Manufactured Architecture:*
  - The rod can be printed as a vertical protrusion from the array surface -- there should be minimal overhang, the rod's taper should be fine.
  - The rod taper and cross-section can be optimized for the desired illumination pattern (e.g., to achieve a specific edge taper on the reflectarray).
  - The ground plane underneath the rod will be a in a plane - so either can be easily electroplated, or just attached to the top
  - Way to mount waveguide to the rod would need to be included in the design.
    - Or here the geometry shouldn't be that complicated so it could be partially also realized using electroplating.
- *Research Value:*
  - It's a novel approach.
  - Eliminates alignment as a variable in experimental validation, enabling more accurate comparison between simulated and measured performance.
- *Challenges:*
  - The focal length is locked at print time -- no post-fabrication adjustment is possible, so simulation accuracy must be extremely high.

== Other Papers
- @Oni2026 - just overview of current state of Metamaterial based antennas, not much related to 3D printing.
- @Dong2012 - overview of metamaterial antennas, has a section on antennas with metasurface.
- @Whittaker2023 - applications of 3D printing in antennas and metaantennas.

#pagebreak()
= Perfectly Matched Layer Absorbes and Radomes

== Impedance-Matched Stealth Metasurfaces
- *Mechanism:* Artificial boundary layers designed to balance effective permittivity and permeability to match free-space impedance ($377 Omega$).
- *Design Rule:* Drives the primary reflection coefficient to zero, allowing incoming radar energy to enter the structure unscattered.
- Classic metamaterial absorbers exhibit narrow, frequency-selective operational bands that are vulnerable to frequency-hopping radar sweeps.
  - Achieving wide-angle stability and polarization insensitivity requires intricate three-dimensional unit cells that resist standard subtractive milling.
  - Stealth radomes face the conflicting demands of wideband out-of-band absorption and sharp, transparent narrow-band transmission for communication.
  - Additive manufacturing enables complex 3D profiles like standing gears and vertical pyramids to secure wide incident angle performance.
- The lower electrical conductivity of carbon- or graphite-doped filaments provides the exact ohmic loss mechanism needed for wave dissipation.

=== Stereo Perfect Metamaterial Absorber
- *Source:* _Frontiers in Physics_, vol. 8, 2020 @Deng2020.
- *Research Context:* Achievement of wide-incident-angle stability via stereo three-dimensional resonant meta-atoms.
- Methodology & Construction
  - Manufactured a standing gear-shaped resonant matrix providing geometric depth to incoming signals.
  - Integrated multi-directional conducting boundaries to trap incident wavefronts.
- Experimental Findings
  - Maintained near-unity absorption efficiency at steep oblique angles of incidence up to 60 degrees.
  - Demonstrated robust polarization insensitivity across the targeted radar frequency window.

=== Micro and Nano Scale 3D Printing Review
- #INFO quite nice overview
- *Source:* _Virtual and Physical Prototyping_, vol. 19, no. 1, 2024 @Peng2024.
- *Research Context:* Structural tracking of manufacturing mechanisms and functional scaling for electromagnetic absorbers.
- Methodology & Construction
  - Categorized performance bounds across multi-axis material jetting and powder-bed fusion configurations.
- Experimental Findings
  - Outlined critical material formulation limits for carbon nanotube and graphene-loaded lossy polymer filaments.
  - Confirmed that multi-material gradient structures successfully optimize the impedance interface with free space.


#pagebreak()
= 3D-Printed All-Dielectric Beam-Forming and Polarization-Transforming Surfaces
- Beyond conventional reflectarrays, 3D printing enables a family of spatially-fed planar surfaces that function in transmission mode — manipulating both the phase and the polarization of an incident wavefront without relying on metallic patches, ground planes, or lossy feed networks.
- These structures fall broadly into two functional categories:
  - Polarization-Transforming Surfaces: Convert linear polarization to circular (LP-to-CP), rotate polarization angle, or perform asymmetric polarization-dependent filtering.
  - Beam-Forming Surfaces / Transmitarrays (TAs): Collimate an incident spherical wavefront into a focused plane wave in a desired direction — the transmission-mode counterpart of a reflectarray.
- Utilizing pure dielectric constructions eliminates conductor losses — the dominant loss mechanism at mm-wave and sub-THz frequencies — and reduces fabrication to a single-material 3D print.
- Unlike reflectarrays, transmitarrays are non-blocking — the feed is behind the aperture, so there is no feed blockage shadow in the radiation pattern.

== Physical Mechanisms for Dielectric-Based Polarization Control

=== Birefringent Quarter-Wave Plate (Form Birefringence)
- *Mechanism:*
  - Intrinsically isotropic material is structured with deep-subwavelength features (e.g., periodic cutouts, asymmetric holes.
  - Or a subwavelength gratings from two or more isotropic materials however final structure is anisotropic.
  - Structural variations are significantly smaller than the operating wavelength, the incident wave does not resolve or scatter off individual physical boundaries.
  - The effective refractive index differs for electric fields polarized parallel ($n_parallel$) versus perpendicular ($n_perp$) to the strip orientation.
  - The phase shift is accumulated through propagation delay.
    - As the orthogonal vector components of a wave travel through the depth ($d$) of the structure, they travel at different phase velocities.
    - The differential phase shift is linearly proportional to the depth and the difference in effective indices: .
- Design Rule for LP-to-CP Conversion: When a linearly polarized wave is incident at $45 degree$ to the strip axis, the parallel and perpendicular components acquire a differential phase delay:
  $ Delta phi = k_0 d |sqrt(epsilon_("eff",x)) - sqrt(epsilon_("eff",y))| $
  $ Delta phi = (2 pi f d) / c_0 (n_parallel - n_perp) $
  Setting $Delta phi = pi/2$ (quarter-wave retardation) and maintaining equal transmitted amplitudes produces a circularly polarized output wave @Isakov2018.

=== Anisotropic Dielectric Slab Arrays
- *Mechanism:*
  - Discrete, physically isolated elements (such as rectangular pillars, elongated slabs, or cross-shaped dielectric resonator antennas) with dimensions on the order of a half-wavelength within the medium
  - Elements act as isolated 3D electromagnetic cavities supporting localized resonant modes (e.g., Mie resonances). The anisotropy is established by the differing macroscopic physical dimensions of the discrete element itself.
  - The phase shift imparted to a specific polarization is dictated by resonance detuning.
    - An incident wave polarized along the $x$-axis excites a resonant mode governed by $L_x$, while a $y$-polarized wave excites a mode governed by $L_y$.
    - The reflection phase for each polarization depends on how far the fixed operating frequency is detuned from that specific axis's natural resonant frequency.
- *Key Distinction from QWP:*
  - The slabs are arranged at the macroscale (not subwavelength cells), with each slab acting as a bulk anisotropic phase element.
  - This can be arranged annularly for omnidirectional polarization conversion @Ma2022.

=== Chiral Metasurfaces (Three-Dimensional Helices)
- *Mechanism:*
  - True 3D chiral elements — such as dielectric helices or elliptic resonators — exhibit intrinsic chirality: they respond differently to left-handed (LHCP) and right-handed (RHCP) circularly polarized waves.
  - Producing circular dichroism (CD) and asymmetric transmission.
- *3D Printing Advantage:*
  - Chiral structures require truly three-dimensional geometry (not just patterned films).
  - FDM or SLA printing of dielectric helices or elliptic cylinders is straightforward, while conventional fabrication of 3D chiral elements is extremely difficult.

== Key Papers: Polarization-Transforming Surfaces

=== 3D-Printed $lambda$/4 Phase Plate
- *Source:* _Optics Express_, vol. 26, no. 22, 2018 @Isakov2018.
- *Research Context:* Dual-head FDM 3D-printed quarter-wave plate (QWP) operating at 12-18 GHz for broadband LP-to-CP conversion.
- Methodology & Construction
  - Alternating strips of two commercial filaments with different permittivities were printed to create an artificially anisotropic birefringent layer.
  - The strip width and layer thickness were designed to produce precisely $90 degree$ differential phase at the center frequency of 15 GHz.
  - No metal, no post-processing — the entire QWP is a single dielectric print.
- Experimental Findings
  - Broadband LP-to-CP conversion across 12-18 GHz ($approx 40\\%$ fractional bandwidth) with measured axial ratio well below 3 dB.
  - Demonstrated the viability of FDM for precision microwave polarization optics at consumer-printer resolution.
- *Personal notes*
  - Elementary geometry — strips of two materials — yet achieves broadband performance. This is a very clean, well-executed demonstration of the concept.
  - The limiting factor is the availability of two filaments with sufficiently different permittivities and compatible printing temperatures.

=== 3D-Printed Planar Dielectric LP-to-CP Coding Polarizer and Beam-Shaping Lens #COOL
- *Source:* _IEEE Transactions on Antennas and Propagation_, vol. 68, no. 6, 2020 @Zhu2020.
- *Research Context:* Simultaneous linear-to-circular polarization conversion and beam collimation/shaping using a single planar 3D-printed dielectric coding metasurface.
- Methodology & Construction
  - The unit cell is a dielectric quarter-wave plate (QWP) element whose in-plane dimensions (length and width) control the local transmission phase while the differential phase delay ($pi/2$) between orthogonal axes converts LP to CP.
    - Doesn't act as a dielectric resonator.
  - Unlike a conventional polarizer + lens cascade, the QWP cells themselves act as the spatial phase shifters — polarization conversion and wavefront focusing happen in the same layer.
  - Two lens types were demonstrated:
    - A basic beam-focusing lens
    - A Wollaston-prism-like and Rochon-prism-like planar CP beam-shaping lenses that split different polarization into two beams which can be independently controlled
- Experimental Findings
  - Successfully demonstrated simultaneous LP-to-CP conversion and beam focusing/collimation using only dielectric 3D-printed elements.
  - The coding polarizer approach enables spatially varying polarization states — different aperture regions can produce different CP handedness.
  - Aperture efficiency could potentially exceed that of cascaded polarizer + lens systems due to elimination of inter-component reflections.

=== 3D-Printed Annular Dielectric Polarizer for Omnidirectional Antennas
- *Source:* _IEEE Transactions on Antennas and Propagation_, vol. 70, no. 10, 2022 @Ma2022.
- *Research Context:* A 3D-printed dielectric polarizer for omnidirectional and multibeam antennas, using annually arranged dielectric slabs each rotated $45 degree$ relative to the azimuth plane.
- Methodology & Construction
  - The polarizer consists of multiple dielectric slabs arranged in a circular (annular) configuration around a central feed.
  - Each slab is rotated $45 degree$ to the azimuth plane, creating the differential phase needed to convert the azimuthally propagating LP wave to CP.
  - Fabricated entirely from dielectric material using FDM 3D printing.
- Experimental Findings
  - Demonstrated LP-to-CP conversion in the azimuth plane, enabling omnidirectional CP radiation — useful for terrestrial and satellite communications.
  - Extended the concept to multibeam configurations with independent CP handedness control per beam.


== Key Papers: Beam-Forming Transmitarrays



=== 3D-Printable Dielectric Transmitarray with Enhanced Bandwidth
- *Source:* _IEEE Access_, vol. 6, 2018 @Massaccesi2018TA.
- *Research Context:* The same Politecnico di Torino group's pioneering work on a three-layer perforated dielectric unit cell for wideband transmitarray antennas at mm-wave frequencies.
- Methodology & Construction
  - The unit cell is a three-layer dielectric structure: the central layer has a square hole (variable side length controls transmission phase), while the outer layers have truncated pyramid holes (impedance matching for bandwidth enhancement).
  - This three-layer approach yields much wider bandwidth than a single-layer perforated dielectric because the tapered outer layers act as impedance transformers, reducing reflection at the dielectric-air interfaces.
  - Fabricated using polymer-jetting 3D printing for high resolution.
- Experimental Findings
  - The three-layer TA achieved significantly wider bandwidth compared to single-layer designs.
  - Demonstrated a $36 times 36$ element transmitarray at Ka-band with high gain and good aperture efficiency.
  - The tapered matching concept is general: it can be applied to any dielectric-phase-shifting unit cell to improve bandwidth.

=== Beam-Scanning 3D-Printed Perforated Dielectric Transmitarray
- *Source:* _Electronics_, vol. 8, no. 4, 2019 @Massaccesi2019TA.
- *Research Context:* Demonstration of beam-scanning capability for a Ka-band 3D-printed dielectric transmitarray using the three-layer perforated unit cell (same as in previous article @Massaccesi2018TA).
- Methodology & Construction
  - Mechanical beam scanning was implemented by moving the feed laterally in the focal plane — each feed position illuminates a different portion of the aperture with a different effective progressive phase gradient.
  - The wide-angle impedance matching of the three-layer unit cell enabled scanning beyond $+- 30 degree$ without significant gain degradation.
- Experimental Findings
  - Validated wide-angle beam scanning with stable gain and pattern quality across the Ka-band.
  - Demonstrated that the perforated dielectric transmitarray rivals the scanning performance of much more complex and expensive phased arrays, but with zero active components.

=== 3D-Printed High-Gain Beam-Switching Dielectric Transmitarray
- *Source:* _Microwave and Optical Technology Letters_, 2024 @Kumar2024.
- *Research Context:* A high-gain linearly polarized dielectric transmitarray with 1336 unit cells of 16 different phase states ($22.5 degree$ quantization), fed by an integrated lens antenna (ILA).
- Methodology & Construction
  - 16 discrete unit cell types provide $22.5 degree$ phase quantization (4-bit) — a practical trade-off between continuous phase control and fabrication manageability.
  - The integrated lens antenna feed replaces the conventional horn, enabling a more compact overall system.
  - All-dielectric construction with 3D printing.
- Experimental Findings
  - Demonstrated high gain beam-switching suitable for mm-wave point-to-point links and radar.
  - The ILA feed + transmitarray configuration is more compact than an equivalent horn-fed design while maintaining competitive aperture efficiency.

== Beam-Forming Lenses
- Use blocks of continous properties as opposed to grid based cell of transmit arrays.
- Harder to design/optimize in case of ofset feed, or special beam steering requirements.
  - In case of inline feed relatively simple and when just basic collimating properties are requires just lead to centric rings.


=== Luneburg Lenses
- *Mechanism:* Spherical structure with a smoothly decreasing refractive index as radial distance from the geometric center increases.
- *Design Rule:* Theoretically follows the profile:
$ n(r)^2 = epsilon_r(r) = 2 - (r/R)^2 $
where $n$ represents the local refraction index, $epsilon_r$ is the relative permittivity, and $R$ is the total outer radius of the lens @Kristoffersen2017.
- Standard traditional manufacturing methods make the generation of smooth continuous 3D index gradients highly impractical.
- In additive implementations, the gradient is generated by varying the dimensions of a subwavelength unit cell cube positioned systematically at distinct grid intersection points @Yue2022.

==== Design of a metamaterial Luneburg lens antenna
- *Source:* _2022 2nd International Conference on Computer Science, Electronic Information Engineering and Intelligent Control Technology (CEI)_ @Yue2022
- *Research Context:* Demonstration of a 50 mm in radius Luneburg lens created using SLA printing, achieved an improvement in gain of 7.41 dB.
- Methodology & Construction
  - Unit Cell Design: Each unit consists of a variable-sized dielectric cube in the center with three connecting rods (0.8 mm fixed width) parallel to the X, Y, and Z axes.
  - A unit period of 5 mm was chosen to be significantly smaller than the center wavelength of the X-band at 10 GHz.
  - The lens was fed from a standard WR-90 waveguide open port without an external antenna element.
  - Parameter Retrieval: Used the S-parameter retrieval method proposed by D. R. Smith (2005) to extract equivalent permittivity.
  - Manufacturing: Produced a 50 mm radius lens using Stereo Lithography Apparatus (SLA) with C-UV 9400E photosensitive resin ($epsilon_r approx 3.2-4.0$).
- Experimental Findings
  - The antenna gain at 10 GHz was 14.98 dB, a 7.41 dB increase compared to a single waveguide feed @Yue2022.
  - No problems regarding simulations or manufacturing using SLA were mentioned in this @Yue2022, however @Kristoffersen2017 needed to use SLS
  - The lens rotated 45° with basically unchanged pattern and gain, proving good spatial dynamic scanning ability.
    - Interesting that the losses don't shift much, one would have thought there would be an larger difference.


=== GRIN (Gradient Index) Lenses
- *Mechanism:* Planar structures exhibiting radial permittivity gradients typically expressed as:
$ n(r)^2 = epsilon_r(r) = (n_0 - (sqrt(L^2+r^2)-L)/t)^2 $
where $n_0$ is the refractive index at 100% material infill, $r$ is the radial offset from the axis, $L$ is the focal length, and $t$ represents the physical thickness of the lens disk @Kristoffersen2017.
- These geometries are sometimes classified alongside or compared directly to flat Fresnel zone plate configurations due to their planar layout.
- The structural simplicity of the radial distribution makes it fully compatible with low-cost FDM extrusion tracks, serving as an optimal baseline for experimental validation.
- Rather thorough exploration of the topic in @Grigoriev2022, wouldn't say it's a prospective topic for the thesis
  - different approaches also demostrated in @Kristoffersen2017 (using Lattice Structure), @Paraskevopoulos2022 (optimized design),  or @Moschner2025 (use of foaming PLA)



== Potential Research Directions for All-Dielectric Polarization and Beam-Forming Surfaces

=== Transmitarray with Different Unit Cell Design
- Similar to idea proposed in reflectarray sections, such realized as transmitarray instead of reflectarray

=== All-Dielectric Transmitarray with Integrated Polarization Diversity
- *Underlying Electromagnetic Problem:*
  - The Zhu 2020 coding polarizer lens combines polarization conversion and beam forming in one layer @Zhu2020, but uses a single LP feed.
  - If each unit cell can be designed to independently control *both* the transmission phase and the output polarization state, the transmitarray can produce multiple beams with different polarizations from a single feed — a *polarization-multiplexed transmitarray*.
- *Additively Manufactured Architecture:*
  - The unit cell geometry (its in-plane aspect ratio, height, and rotation angle) encodes three independent degrees of freedom: $phi_parallel$ (phase for E-field parallel to one axis), $phi_perp$ (phase for perpendicular), and the rotation angle $theta$.
  - These three DOFs can independently control the transmitted phase and the output polarization ellipticity + orientation.
  - All-dielectric 3D printing of birefringent pillars or blocks realizes the anisotropic phase response.
- *Research Value:*
  - A single passive all-dielectric transmitarray that simultaneously:
    1. Collimates the feed's spherical wavefront into a plane wave,
    2. Converts LP feed to CP output,
    3. Spatially multiplexes LHCP and RHCP to different beam directions.
  - This would be a *three-in-one* device that normally requires a polarizer, a lens, and a beam splitter.
- *Challenges:*
  - The design space (three variables per cell × hundreds of cells) is very large — surrogate modeling and optimization-based synthesis are required.
  - The unit cell transmission magnitude must remain near-unity for both polarizations across all cell geometries — a stringent constraint that may limit the achievable phase range.

=== All-Dielectric Chiral Metasurfaces for Compact Polarization Filters and Isolators
- *Underlying Electromagnetic Problem:*
  - True chiral media exhibit *circular dichroism* — differential transmission of LHCP vs. RHCP waves — without requiring external magnetic bias (unlike Faraday rotators).
  - In the microwave/mm-wave regime, chiral metasurfaces can function as compact circular polarization filters, isolators (when combined with linear polarizers), or circular-polarization duplexers.
  - To date, microwave chiral metasurfaces predominantly use metallic helices or resonators All-dielectric implementations are essentially unexplored.
- *Additively Manufactured Architecture:*
  - 3D-printed dielectric helices, twisted strips, or interlocking chiral unit cells made from high-$epsilon_r$ ceramic filament or SLA ceramic.
  - The dielectric chirality arises from the 3D geometry rather than from conduction currents — eliminating ohmic loss entirely.
  - The design maps directly from optical-regime silicon chiral metasurfaces (well-studied in photonics) to microwave dimensions via geometric scaling.
- *Research Value:*
  - Opens a new sub-area: *microwave dielectric chiral metamaterials* — the microwave counterpart of a mature optical field.
  - Enables ultra-compact, zero-power-consumption polarization filters for satellite communications.
- *Challenges:*
  - The degree of circular dichroism (CD) in low-contrast all-dielectric structures is inherently weaker than in metal-dielectric hybrids — high-$epsilon_r$ ceramics ($epsilon_r > 8$) are likely necessary to achieve practically useful CD.
  - 3D printing of truly free-standing helical geometries may require soluble support material or specialized multi-axis printing.

== Metamaterial Phase-Screens
- There's essentially zero chance NTUST would be able to manufacture something like this.
  - Respectively it would maybe be possible in THz range with lithography, but not in GHz / tents of GHz range
- Phase Modulating Screens
  - *Mechanism:* Planar or conformal spatial phase modulators distributing subwavelength meta-atoms to dynamically or statically alter wavefront profiles.
  - *Design Rule:* Imparts localized phase shifts spanning a complete 360-degree envelope to replace traditional thick, curved refractive lenses.
  - Translating continuous phase distributions into discrete coding matrices creates phase quantization errors that induce parasitic scattering and side-lobe degradation.
  - Inter-layer bonding variations and microscopic air gaps introduce material anisotropy, causing phase deviations from simulated target metrics.

=== Spin-decoupled broadband transmissive metasurfaces
- *Source:* _IEEE Transactions on Antennas and Propagation_, vol. 71, no. 9, 2023 @Zhu2023.
- *Research Context:* Investigation of multi-layered transmissive metasurfaces utilizing spin-decoupled unit cells to achieve wideband performance.
- Methodology & Construction
  - Implemented nine-layer unit cells leveraging advanced 3D printing methods to handle precise spatial allocations.
  - Manufactured using multi-material integrated 3D printing with NIR lamp sintering of ink
- Experimental Findings
  - Demonstrated clean decoupling and independent phase control of orthogonal circular polarization components.
  - Verified that additive manufacturing successfully executes high-precision multi-layered geometries without cleanroom lithography.

=== The Phase Switched Screen
- #INFO not even related to 3D printing, not to mention it's an active component but it's cool.
- *Source:* _IEEE Antennas and Propagation Magazine_, vol. 46, no. 6, 2004 @Chambers2004.
- *Research Context:* Early development of phase-switched architectures for dynamic reflection and scattering control.
- Methodology & Construction
  - Explored dynamic modulation of surface impedance parameters under plane wave illumination.
- Experimental Findings
  - Formed the theoretical blueprint for digital coding arrays and dynamic wavefront manipulation techniques.

== Radomes
- A conventional antenna radome is fundamentally required to maximize electromagnetic transmission ($S_{21} approx 0 "dB"$) while protecting the enclosed antenna from mechanical and environmental forces.
- *Frequency-Selective Rasorbers (FSR):*
  - Act as FSS (Frequency Selective Surfaces)
  - The structure acts as a narrow-band passband filter at the antenna's operating frequency ($f_0$), permitting low-loss signal transmission.
  - At out-of-band threat radar frequencies, the rasorber switches behavior to function as a PML absorber, trapping and dissipating incoming radar energy as heat to reduce radar cross-section (RCS).
- *Impedance-Matched Transmission Radomes:*
  - Rather than absorbing energy, "perfect impedance matching" ($Z_("in") = 377 Omega$) is applied to the front and back boundaries of thick structural dielectric walls.
  - Matching the radome wall impedance to free space eliminates reflection coefficients at the interface, forcing 100% of the energy to transmit *through* the physical barrier without insertion loss or phase refraction.

== Inherent Engineering and Manufacturing Challenges
- Designing frequency-selective rasorbers requires co-integrating bandpass filtering elements alongside lossy resistive networks without distorting the in-band radiation pattern.
- Conformal 3D radomes (conical, spherical, or curved aircraft noses) suffer from severe angle-of-incidence degradation when using standard planar FSS designs.
- Subtractive milling or multi-layer etching cannot easily fabricate curved, non-planar 3D metasurfaces with uniform unit-cell spacing.
- Additive manufacturing enables conformal dome printing, which is subsequently metalized via electroplating, conductive painting, or co-extruded resistive filaments.

=== Conformal 3D-Printed Bandpass mm-Wave FSS Radome
- #INFO Also quite interesting and electroplating shouldn't be impossible at NTUST.
- *Source:* _Scientific Reports_, vol. 11, 2021 @Zhang2021.
- *Research Context:* Design, 3D printing, electroplating, and near-field measurement of a 3D conformal bandpass FSS radome operating in the 26–40 GHz millimeter-wave regime.
- Methodology & Construction
  - Fabricated a 3D spherical dome substrate using FDM additive manufacturing (Ultimaker 2+) with polylactic acid (PLA).
  - Electroplated the printed 3D surface with a uniform copper layer to create metallic bandpass resonant grids.
  - Placed the conformal radome in the immediate near-field region of an open-ended waveguide and horn antenna to measure passband stability.
- Experimental Findings
  - Measured results demonstrated excellent broadside transmission ($S_{21} approx -0.5 "dB"$) across the 26–40 GHz band.
  - Confirmed superior angular stability up to 30 degrees off broadside compared to flat planar FSS counterparts, validating 3D printing for non-planar radome hulls.

== Other Papers
- 3D printed absorbers in waveguides, not even related to metamaterials @ESASPCD2018.


#pagebreak()

#v(2em)
#bibliography("bibliography.bib", style: "ieee")
