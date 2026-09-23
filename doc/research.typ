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
  - *OpenSCAD:* faster real time preview than CadQuery, much slower final output, cannot output to stl I think

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

=== SLA (Stereolithography)
- high resolutions, able to do overhangs with some consideration
- fairly frequently used, though some paper struggle with it for some reasons (even though their geometry doesn't seem to be that complicated)
- in case of composites there is a risk of sedimentation and loss of uniformity of the material

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

== High Permitivity Filaments
- Unfilled baseline polymers uniformly demonstrate low relative permittivity ($epsilon_r$) between 2.0 and 3.0.
  - Micro-voids caused by high feedstock viscosity and volatile outgassing systematically degrade the bulk dielectric constant.
  - Similarly some materials are for examples hygroscopic -- absorption of water/humidity increases $"tan" delta$ and deceases $epsilon_r$
- High permittivity filaments are created using blending standard polymer matrices with ceramic nanoparticles like barium titanate, titanium dioxide, or alumina.
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

=== Microwave Metamaterials Made by Fused Deposition (APL 2017)
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
= Permitivity Measurement
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
  - Because the system relies entirely on resonance, the extracted permittivity and loss tangent are valid only at that single resonant frequency point -- different ring resonators would need to be used to map out permitivity in discrete steps over larger interval.
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
= 3D Printed Metamaterial Lenses for Microwave Antennas

== Luneburg Lenses
- *Mechanism:* Spherical structure with a smoothly decreasing refractive index as radial distance from the geometric center increases.
- *Design Rule:* Theoretically follows the profile:
$ n(r)^2 = epsilon_r(r) = 2 - (r/R)^2 $
where $n$ represents the local refraction index, $epsilon_r$ is the relative permittivity, and $R$ is the total outer radius of the lens @Kristoffersen2017.
- Standard traditional manufacturing methods make the generation of smooth continuous 3D index gradients highly impractical.
- In additive implementations, the gradient is generated by varying the dimensions of a subwavelength unit cell cube positioned systematically at distinct grid intersection points @Yue2022.

=== Design of a metamaterial Luneburg lens antenna (CEI 2022)
- *Source:* 2022 2nd International Conference on Computer Science, Electronic Information Engineering and Intelligent Control Technology (CEI) @Yue2022
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


== GRIN (Gradient Index) Lenses
- *Mechanism:* Planar structures exhibiting radial permittivity gradients typically expressed as:
$ n(r)^2 = epsilon_r(r) = (n_0 - (sqrt(L^2+r^2)-L)/t)^2 $
where $n_0$ is the refractive index at 100% material infill, $r$ is the radial offset from the axis, $L$ is the focal length, and $t$ represents the physical thickness of the lens disk @Kristoffersen2017.
- These geometries are sometimes classified alongside or compared directly to flat Fresnel zone plate configurations due to their planar layout.
- The structural simplicity of the radial distribution makes it fully compatible with low-cost FDM extrusion tracks, serving as an optimal baseline for experimental validation.
- Rather thorough exploration of the topic in @Grigoriev2022, wouldn't say it's a prospective topic for the thesis
  - different approaches also demostrated in @Kristoffersen2017 (using Lattice Structure), @Paraskevopoulos2022 (optimized design),  or @Moschner2025 (use of foaming PLA)



#pagebreak()
= Metamaterial-Based Antennas

== Metantennas and Resonant Surfaces
- *Mechanism:* Incorporation of artificial subwavelength inclusions like split-ring resonators and electromagnetic bandgap grids into or around radiators.
- Multi-layer printed circuit board constraints limit conventional layouts to rigid, two-dimensional surfaces.
- Multi-material 3D printing circumvents PCB limits, facilitating the fabrication of spatial meta-atoms directly onto curved structural hulls.
  - Losses in the dielectric and limited conductivity degrade the performance significantly.
  - Printing layer variations and infill density fluctuations alter the local effective permittivity, shifting the antenna's tuned resonant frequency.

=== Low-Profile 3-D Printable Metastructure for Aperture Antennas (Scientific Reports 2024) #COOL
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

=== 3D Conductive Polymer Printed Metasurface Antenna for Fresnel Focusing (Designs 2019)
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

==== 3D Printed Spiral Leaky-Wave Antenna with Circular Polarization (IEEE OJAP 2023) #COOL
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


=== Possible Research Areas for Leaky-Wave Antennas

==== Monolithic Multi-Material Matched Terminations for LWAs #FAV
- #INFO: would need to verify how large of a problem is the lack of proper termination, study would probably necessitate constructing two antennas to verify the improvement
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
  - This continuous function is discretized into interlocking subwavelength geometric wedges or pyramid arrays where lossy filament volume fraction increases monotonically along the propagation axis.
  - Alternatively, variable-density infill or dual-tool spatial dithering smoothly shifts the complex effective permittivity:
  $ epsilon_("eff")(z) = epsilon'_("eff")(z) - j epsilon''_("eff")(z) $
  maintaining $epsilon'_("eff")$ matching while gradually ramping $epsilon''_("eff")$ to attenuate the forward traveling wave.
- *Research Value:*
  - I haven't found even a single study doing this.
- *Material Selection and Practical FDM Integration:*
  - *Static Dissipative PLA by Proto-pasta ESD:*
    - High surface resistivity ($10^6 - 10^9 Omega / "sq"$) allows gradual, distributed attenuation over extended electrical lengths without severe localized heating.
    - Generally all carbon-loaded filaments with low percentage of filling are applicable for this usecase.
    - Filaments have the same print settings as non conductive ones -- useful for printers with interchangeable extruders, not to mention print bed settings can remain constant.
  - *Conductive Carbon-Loaded TPU:*
    - Combines molecular dipolar relaxation loss with conductive ohmic dissipation.
    - High flexibility and viscoelastic mismatch increase risk of extruder buckling, stringing across dielectric voids, however it can be done.
    - One of the material with higher losses that is fairly easy to commercially acquire with many possible suppliers.

==== Continuous Sinusoidal Reactance Surfaces via Foaming PLA
- *Concept:* Standard 3D-printed LWAs discretize periodic modulation into square pulses (blocks of material vs. air). This abrupt quantization excites higher-order space harmonics ($n = -2, -3$, etc.), which can leak as unwanted grating lobes and reduce aperture efficiency.
  - #WARN This kinda falters when considering that many LWA's that use more complex unit cell design - for example ones with cylindrical cutouts where the transition is already fairly continuous and somewhat sinusoidal.
- *Mechanism:* Utilizing active temperature modulation of the FDM hotend during the print, the volumetric expansion of Foaming PLA (PolyLite LW-PLA or ColorFabb LW-PLA) can be continuously varied.
- *Research Value:*
  - Don't think anybody has done it use of Aero PLA or other foaming filaments is fairly novel
  - Instead of a square-wave permittivity profile, the LWA is printed with a mathematically continuous, sinusoidal spatial permittivity gradient.
  - A pure sinusoidal modulation theoretically couples energy *only* into the $n = -1$ radiating harmonic, suppressing all other parasitic modes and grating lobes, maximizing directivity and radiation efficiency.
- *Challenges:* \
  - Establishing a highly accurate, calibrated mapping between the G-code extrusion temperature, the resulting physical void fraction, and the extracted RF permittivity.
  - Need to develop completely new slicer, or more likely a program that would generate the gcode directly.
  - Print times would be long with need to constantly adjust nozzle temperature and wait for it to settle.

==== Chirped Conformal LWAs with Pre-Distorted Geometries #FAV
- *Concept:*
  - Mounting a standard periodic leaky-wave antenna onto a curved aerodynamic surface fundamentally bends the electromagnetic propagation axis.
  - This conformal curvature introduces a severe non-linear phase error ($Delta phi$) across the radiating aperture.
  - Uncompensated phase errors cause the main beam to defocus, directly collapsing the directivity and elevating parasitic side-lobe levels.
  - Standard planar printed circuit board manufacturing cannot easily pre-distort the substrate thickness or internal dielectric density to match the required phase gradient on a highly curved surface.
- *Mechanism:*
  - An inverse-design methodology is deployed where the unit-cell periodicity ($p$) and the effective dielectric constant ($epsilon_("eff")$) are progressively altered, or chirped, along the curved propagation axis @Bartley2025.
  - To synthesize a highly directive, collimated plane wave from an arbitrary curve, the phase of the leaking wave must satisfy a precise spatial gradient.
  - Additive manufacturing enables this phase correction by continuously modifying the internal geometric fill fraction to tune the effective dielectric constant at every discrete spatial coordinate.
- *Research Value:*
  - Very little research has been done on these.
  - This approach validates the unique capability of 3D printing to fabricate non-uniform, spatially varying electromagnetic structures that are geometrically impossible to machine via traditional subtractive milling.
  - By locally tuning both the propagation constant ($beta(z)$) to align the phase front and the attenuation constant ($alpha(z)$) to control aperture illumination, the conformal LWA can synthesize a perfectly collimated high-gain plane wave directly from a highly curved physical structure.
  - Recent studies employing effective dielectric constant modeling demonstrate that 3D-printable pre-distorted unit cells can scan coherent phase fronts over $plus.minus 28 degree$ directly from cylindrical surfaces @Bartley2025.
- *Challenges:*
  - The deterministic CAD generation for these conformal topologies cannot rely on simple linear arrays or standard planar microwave layout tools.
  - There will be massive problems with anisotropy.
    - If unit cells aren't always in parallel with the local surface normal, that is permitivity tensor isn't invariant there will be some error.
    - Even if unit cell is rotated correctly the raster lines of 3D printer lead inherently to anisotropic environment.
    - 3D print parameters must be rigorously characterized and mathematically inverted during the initial dispersion mapping phase.

=== Other Papers
- @Liu2026
  - talks about some Spoof Surface Plasmon Polaritons (SSPPs) -- looks cool but I have no idea what it is
  - construct is plated with metal -- (basically a radiating waveguide), but the geometry is way too complex to do some electroplating or whatever.

== Reflectarray Antennas
- *Mechanism:* A reflectarray antenna (RA) is a hybrid architecture combining the spatial feeding of a parabolic reflector with the planar aperture of a phased array @Nayeri2018, @Huang2008.
- A horn feed illuminates a planar (or conformal) array of passive unit cells, each backed by a ground plane.
- Each unit cell applies a locally controlled phase shift $Delta phi_(m n)$ to the reflected wave to compensate for the spherical path-length difference from the feed, transforming the incident spherical wavefront into a focused plane wave in the desired direction:
  $ Delta phi (x_m, y_m) = (2 pi) / lambda_0 sqrt(x_m^2 + y_m^2 + F^2) $
  where $F$ is the focal length from the feed phase center to the array surface @Huang2008.
- Beam scanning is achieved by adding a progressive phase gradient across the array, steering the reflected beam without physically moving the antenna.
- #INFO #TODO read @Nayeri2018 -- the definitive textbook on reflectarray theory, design procedures, and state-of-the-art implementations covering broadband, multi-band, multi-beam, contour-beam, beam-scanning, and reconfigurable configurations.

=== Why Reflectarrays?
- Compared to parabolic reflector antennas: flat/low-profile form factor, no complex curved mold tooling, easier integration onto satellite panels or building walls.
- Compared to phased arrays: no lossy, expensive, and heavy corporate feed network with discrete phase shifters -- the spatial feeding eliminates most RF distribution losses.
- Key trade-off: inherently narrower bandwidth than parabolic dishes due to the resonant nature of printed unit cells and differential spatial phase delay (frequency-dependent path-length differences from the feed) @Nayeri2018.

=== Phase Tuning Mechanisms
- The unit cell must deliver a reflection phase coverage of at least $360 degree$ with near-unity reflection magnitude ($|S_11| approx 1$) for high aperture efficiency.
- *Variable Patch Size:* Changing the dimensions of a printed metallic patch shifts its resonant frequency, producing a phase-frequency ($S$-curve) response @Nayeri2018.
- *Variable Stub/Delay Line Length:* Common in metal-only designs -- a received wave travels down a transmission line of adjustable length before being re-radiated.
- *Variable Dielectric Geometry (3D-Printed):* Using 3D-printed dielectric elements of varying height, width, or cross-sectional shape to adjust the local reflection phase -- the dominant approach in additively manufactured reflectarrays.
- *Variable Hole/Slot Size:* Perforating a uniform dielectric slab with holes of varying dimensions to spatially tune the effective permittivity and reflection phase.
- *Infill Density Control:* Tuning the effective permittivity by adjusting the 3D printing infill percentage, treating the material itself as a continuous design variable.

=== Existing Research

==== 3D-Printed Dielectric Resonator Reflectarray (IET MAP 2017)
- *Source:* _IET Microwaves, Antennas & Propagation_, vol. 11, no. 14, 2017 @Zhang2017.
- *Research Context:* First demonstration of an FDM 3D-printed dielectric resonator reflectarray operating at mm-wave frequencies (30 GHz).
- Methodology & Construction
  - The reflectarray comprised 625 dielectric resonator elements on a $120 times 120 "mm"^2$ aperture with a total mass of only 67 g.
  - Fabricated using FDM in a single-step process without any machining, metal deposition, or post-processing.
  - Each dielectric resonator element acts as a weakly coupled radiator, with its height controlling the local reflection phase.
- Experimental Findings
  - Measured gain of 28 dBi at 30 GHz when offset-fed by a Ka-band horn antenna.
  - The dielectric resonator approach inherently minimizes ohmic losses and inter-element mutual coupling compared to metallic printed patches.
  - Demonstrated that FDM resolution is sufficient for mm-wave dielectric reflectarrays despite the relatively coarse nozzle diameters.
  - #INFO This is the pioneering paper for the entire field -- @Zhang2017.

==== Dual Circularly Polarized Broadband Dielectric Reflectarray (IEEE TAP 2022) #COOL
- *Source:* _IEEE Transactions on Antennas and Propagation_, vol. 70, no. 7, 2022 @Cheng2022.
- *Research Context:* A broadband dual-circularly polarized (dual-CP) reflectarray fed by a single linearly polarized (LP) horn, realized entirely from 3D-printed dielectric materials.
- Methodology & Construction
  - The unit cell consists of two orthogonal dielectric blocks of independently variable heights.
  - The incident LP wave from the feed is decomposed into two orthogonal equal-amplitude components by the dielectric block pair.
  - By controlling the differential height of the two blocks, the reflected orthogonal components are recombined with a $+- 90 degree$ phase shift, synthesizing left-hand or right-hand circular polarization (LHCP/RHCP).
  - Full-wave simulations were validated against a fabricated prototype measured in an anechoic chamber.
- Experimental Findings
  - Achieved broadband dual-CP operation ($> 20\\%$ fractional bandwidth) without requiring a dual-CP feed or complex multi-layer PCB fabrication.
  - The all-dielectric construction eliminates conductor losses, resulting in high radiation efficiency even at Ka-band frequencies.
  - Demonstrated that 3D printing enables polarization diversity from a single LP feed -- a capability that would require multiple PCB layers with conventional fabrication.

==== 3D-Printed Wideband Reflectarray with Mechanical Beam-Steering (IJMWT 2023)
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

==== 3D-Printed Kirigami-Inspired Deployable Reflectarray (IEEE TAP 2022) #COOL
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

==== Wideband 3D-Printed Polarization-Reconfigurable Reflectarray (IEEE AWPL 2020)
- *Source:* _IEEE Antennas and Wireless Propagation Letters_, vol. 19, no. 10, 2020 @Mei2020.
- *Research Context:* A 3D-printed reflectarray with mechanically reconfigurable polarization for 5G mm-wave applications.
- Methodology & Construction
  - The unit cell uses an air-perforated dielectric stub that simultaneously provides polarization rotation and phase shifting.
  - Polarization reconfiguration is achieved mechanically by rotating the reflectarray elements relative to the feed orientation.
  - The entire structure is fabricated as a single dielectric print.
- Experimental Findings
  - Wideband impedance matching across the 5G mm-wave band (26.5-29.5 GHz).
  - Demonstrated switching between linear and circular polarization states with good axial ratio performance.

==== Bi-Material Bragg-Based Reflectarray (Sensors 2024)
- *Source:* _Sensors_, vol. 24, no. 20, 2024 @BiMaterialBragg2024.
- *Research Context:* A fully dielectric bi-material reflectarray exploiting a 1D Bragg reflector unit cell to create bandgap (frequency-selective reflection) characteristics for multi-band applications.
- Methodology & Construction
  - The unit cell is based on a one-dimensional Bragg reflector -- alternating layers of two dielectric materials with different permittivities.
  - Bi-material 3D printing (dual-extruder FDM or material jetting) deposits the alternating dielectric layers.
  - The bandgap behavior creates frequency-selective reflectarray operation, reflecting strongly in designed passbands while being transparent elsewhere.
- Experimental Findings
  - Measured gain of 27.22 dBi at 27 GHz with aperture efficiency of 35.05%.
  - Verified transparency outside the design band, demonstrating the multi-band potential of the Bragg approach.

==== Ka-Band Reflectarray with Infill-Controlled Permittivity (Sensors 2025)
- *Source:* _Sensors_, vol. 25, no. 17, 2025 @Beccaria2025.
- *Research Context:* A fully dielectric Ka-band reflectarray using cylindrical unit cells printed from Zetamix ceramic filament, where the infill density is tuned during fabrication to control effective permittivity -- treating infill as an additional design degree of freedom.
- Methodology & Construction
  - Zetamix $epsilon_r$ 7.5 ceramic-loaded filament ($"TiO"_2$-based) was used with FDM printing.
  - At 35% infill, the effective permittivity drops to approximately $epsilon_r approx 2$, enabling a wide continuous tuning range from a single filament material.
  - Cylindrical unit cells of fixed external dimensions but variable internal infill produce the required $360 degree$ reflection phase range.
- Experimental Findings
  - Validated that infill density provides a practical, repeatable method for spatial permittivity control without requiring multi-material printing or geometric height variations.
  - The approach decouples the unit cell's physical geometry from its electromagnetic phase response -- the cell dimensions can remain uniform while only the internal fill changes.

==== Metal-Only 3D-Printed Reflectarrays
- *Mechanism:* Using Selective Laser Melting (SLM) powder-bed fusion, metallic reflectarrays are printed with waveguide-type unit cells where the phase shift is controlled by the depth of a short-circuited waveguide section.
- *Advantages:* No dielectric materials means no dielectric loss, higher power handling, and suitability for space (no outgassing, radiation-hard).
- *Challenges:* SLM surface roughness at mm-wave frequencies introduces additional ohmic loss; post-processing (polishing, coating) is often required.
- *Key works:* Metallic 3D-printed reflectarrays with coaxial unit cells achieving full $360 degree$ phase range have been demonstrated for mm-wave applications @Kaddour2024.

==== Other Papers
- @Whittaker2023 surveys 3D printing materials and techniques for antennas and metamaterials, highlighting dielectric resonator reflectarrays as a promising application area.
- 3D-printed dielectric reflectarrays at 220 GHz demonstrated wideband performance in the sub-THz regime -- shows that printing resolution is viable even at these high frequencies @Wu2018.
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
  - Leverages the emerging capability demonstrated by @Beccaria2025 using Zetamix ceramic filaments -- extends it from a proof-of-concept to a rigorous design methodology.
- *Challenges:*
  - Requires precise calibration of the infill-to-permittivity mapping function across the full 0-100% density range, including anisotropy effects from infill pattern orientation relative to the incident E-field.
  - Slicer software must be augmented or bypassed to assign unique infill percentages to each unit cell -- programmatic G-code generation is required.
  - At very low infill densities, mechanical integrity becomes a concern for larger apertures.

==== Multi-Material Fully 3D-Printed Reflectarrays (Dielectric + Conductive)
- *Underlying Electromagnetic Problem:*
  - Most 3D-printed reflectarrays today are *either* fully dielectric (using geometry for phase control, with a separate metallic ground plane) *or* metal-only (via SLM).
  - Fully dielectric designs require a metallic ground plane that is typically a separate component (copper sheet, metal plate) -- breaking the "single monolithic print" promise.
  - The few attempts at fully 3D-printed conductive structures using filaments like Electrifi ($sigma approx 10^4 \"S/m\"$) suffer from dramatically reduced radiation efficiency due to ohmic losses in the low-conductivity polymer @Yurduseven2019, @Xie2017.
- *Additively Manufactured Multi-Material Reflectarray Architecture:*
  - A dual-extruder FDM system prints the dielectric substrate/unit cells from low-loss PLA, ABS, or ceramic-filled filament while simultaneously printing the ground plane and optional conductive patches from Electrifi or a copper-based composite filament.
  - The entire reflectarray -- dielectric aperture, conductive ground plane, and mounting struts -- is fabricated in a single uninterrupted print cycle.
  - Alternatively, the ground plane and conductive features could be printed first, then electroplated for improved conductivity -- this hybrid approach combines the geometric freedom of 3D printing with the RF performance of plated copper.
- *Research Value:*
  - True monolithic fabrication eliminates alignment errors between dielectric elements and ground plane, improving phase accuracy.
  - Dramatically reduces assembly labor and cost, making reflectarrays viable for low-cost consumer mm-wave applications (5G/6G CPE, automotive radar).
  - Quantifying the conductivity-performance trade-off would establish design guidelines for when conductive filament alone is sufficient vs. when electroplating is necessary.
- *Challenges:*
  - Differential thermal expansion and incompatible printing temperatures between conductive (Electrifi: $130-160 degree\"C\"$) and structural (PLA: $190-220 degree\"C\"$) filaments cause inter-layer delamination.
  - Nozzle cross-contamination between conductive and dielectric filaments creates microscopic conductive stringers that can short adjacent unit cells.
  - The low conductivity of printable filaments fundamentally limits efficiency -- a rigorous comparison study is needed to identify frequency bands and applications where this is acceptable.

==== Sub-THz 3D-Printed Reflectarrays for 6G and Beyond
- *Underlying Problem:*
  - Most 3D-printed reflectarrays operate in the Ka-band (26-40 GHz) or V-band (40-75 GHz).
  - Above 100 GHz (sub-THz, D-band at 110-170 GHz, and beyond), microstrip feed networks become prohibitively lossy and PCB fabrication tolerances become extremely tight.
  - Reflectarrays are inherently attractive at sub-THz because their spatial feeding eliminates the lossy feed network entirely -- the only losses are in the unit cells themselves.
- *Additively Manufactured Sub-THz Reflectarray Architecture:*
  - High-resolution printing technologies (micro-stereolithography with $<= 25 mu\"m\"$ voxel resolution, two-photon polymerization) can fabricate unit cells with the sub-100 μm feature sizes required for sub-THz operation.
  - The all-dielectric unit cell approach avoids conductor losses entirely, which become increasingly severe as frequency increases (skin depth in copper at 140 GHz is only $approx 0.18 mu\"m\"$).
  - A $220 "GHz"$ dielectric reflectarray has already been demonstrated using 3D printing @Wu2018, but systematic optimization across the full D-band and H-band remains unexplored.
- *Research Value:*
  - 6G communication systems target D-band (110-170 GHz) for access links and H-band (220-325 GHz) for backhaul -- high-gain antennas at these frequencies are a critical enabling technology.
  - All-dielectric reflectarrays eliminate the extremely high conductor losses that plague PCB-based designs at these frequencies.
  - Would establish the practical upper frequency limit of 3D-printed dielectric reflectarrays given current printing resolution constraints and material characterization at sub-THz frequencies.
- *Challenges:*
  - Dielectric material characterization (both permittivity and loss tangent) is poorly documented for 3D printing filaments above 100 GHz -- measurement campaigns using free-space or resonator techniques are prerequisite.
  - Surface roughness of printed dielectrics ($R_q$ typically 10-50 μm for FDM, 1-5 μm for SLA) can cause non-negligible scattering losses at sub-THz frequencies.
  - Printing resolution demands may push beyond the capabilities of standard FDM and even desktop SLA -- specialized high-resolution equipment may be necessary.

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
  - The design space explodes combinatorially -- each of hundreds or thousands of elements may require individual simulation. Surrogate modeling and machine-learning-assisted optimization become necessary.
  - Printing large curved structures with sub-millimeter accuracy requires advanced toolpath generation beyond standard planar slicers.
  - Feed placement and illumination taper optimization become significantly more complex on curved surfaces compared to planar apertures.

==== Reconfigurable 3D-Printed Reflectarrays with Embedded Functional Materials
- *Underlying Electromagnetic Problem:*
  - Reconfigurable reflectarrays using PIN diodes, varactors, or liquid crystals are actively researched for dynamic beam-steering without mechanical feed movement.
  - However, these designs universally rely on conventional multilayer PCB fabrication -- integrating active components into a 3D-printed structure is essentially unexplored.
- *Additively Manufactured Reconfigurable Reflectarray Architecture:*
  - Liquid crystal (LC) channels could be 3D-printed as hollow cavities within a dielectric reflectarray, then filled with LC material post-printing -- the LC's permittivity changes under applied bias voltage, tuning the reflection phase.
  - Mechanically reconfigurable elements (rotating dielectric blocks, sliding dielectric inserts) could be 3D-printed as monolithic compliant mechanisms, avoiding assembly of discrete moving parts.
  - Microfluidic channels for liquid-metal injection (e.g., Galinstan) could be printed into the unit cells, enabling continuous phase tuning by changing the effective geometry of a conductive inclusion.
- *Research Value:*
  - Combines the geometric freedom of 3D printing with the functionality of reconfigurable materials.
  - LC-based tuning is particularly promising because 3D printing can create the sealed cavity, alignment layers, and bias electrode channels in a single structure.
- *Challenges:*
  - Liquid crystal filling of 3D-printed cavities requires precise sealing and uniform alignment layer deposition -- processes well-established for flat glass cells but not for 3D-printed polymer cavities.
  - The bias voltage distribution network (transparent electrodes, wiring) must be integrated without blocking the RF aperture.

==== Co-Designed Feed-and-Reflectarray Monolithic Systems
- *Underlying Problem:*
  - Nearly all published 3D-printed reflectarrays use a separate, commercially manufactured horn antenna as the feed.
  - This introduces alignment uncertainty during assembly, adds a separate component cost, and prevents full system miniaturization.
  - The feed-to-reflectarray distance (focal length) and alignment are critical parameters -- misalignment by even a fraction of a wavelength degrades gain and increases sidelobes.
- *Additively Manufactured Co-Designed Architecture:*
  - The feed antenna (horn, dielectric rod, or printed waveguide) and the reflectarray are fabricated as a single monolithic structure with integrated mechanical registration features.
  - The focal length is determined by the printed geometry, eliminating assembly alignment errors.
  - A dielectric rod or lens-integrated feed could be printed seamlessly into the reflectarray substrate, creating a fully integrated aperture.
- *Research Value:*
  - Transforms the reflectarray from a "component" into a "system-in-a-print" -- attractive for mass-produced mm-wave terminals where assembly labor dominates cost.
  - Eliminates alignment as a variable in experimental validation, enabling more accurate comparison between simulated and measured performance.
- *Challenges:*
  - Co-printing the feed and reflectarray requires the feed to be designed from the same limited set of printable materials, constraining its performance.
  - The focal length is locked at print time -- no post-fabrication adjustment is possible, so simulation accuracy must be extremely high.

=== Research Direction Assessment Matrix
- #INFO For the thesis, the key criteria are: (1) feasibility with available equipment, (2) novelty gap in literature, (3) potential for publishable results, (4) alignment with 3D printing's unique advantages.

#figure(
  table(
    columns: (auto, auto, auto, auto, auto),
    align: left,
    stroke: 0.5pt,
    table.header([*Direction*], [*Feasibility*], [*Novelty*], [*Publishability*], [*3DP Uniqueness*]),
    [GRIN Reflectarrays via Infill],
    [Medium -- needs Zetamix, slicer automation],
    [High -- @Beccaria2025 is the only direct precedent],
    [High -- combines materials + EM design],
    [Very High -- impossible without 3DP],

    [Multi-Material (Dielectric+Conductive)],
    [Medium -- needs dual-extruder, material compatibility],
    [Medium-High -- only @Yurduseven2019 attempts this seriously],
    [Medium -- efficiency may be too low at mm-wave],
    [High -- monolithic print is uniquely 3DP],

    [Sub-THz Reflectarrays],
    [Low-Medium -- needs $> 100 "GHz"$ measurement capability],
    [High -- very few works above 100 GHz],
    [Very High -- 6G relevance],
    [Medium -- SLA resolution is key, not FDM],

    [Conformal Curved Reflectarrays],
    [Medium -- needs programmatic CAD, large curved printer bed],
    [High -- mostly unexplored],
    [High -- aerospace applications],
    [Very High -- conformal printing is unique to 3DP],

    [Reconfigurable Embedded LC/MEMS],
    [Low -- requires LC filling infrastructure],
    [Very High -- essentially unexplored],
    [Very High -- if it works],
    [Medium -- could be done with PCBs too],

    [Co-Designed Feed+Reflectarray],
    [High -- straightforward fabrication],
    [Medium -- incremental rather than breakthrough],
    [Medium],
    [Medium -- could be done with other methods],
  ),
  caption: [Assessment matrix for 3D-printed reflectarray research directions.],
  kind: "table",
  supplement: [Table],
)



== Other Papers
- @Oni2026 - just overview of current state of Metamaterial based antennas, not much related to 3D printing.
- @Dong2012 - overview of metamaterial antennas, has a section on antennas with metasurface.
- @Whittaker2023 - applications of 3D printing in antennas and metaantennas.
  - #INFO mentions reflectarray antennas with dielectric resonators realized using 3D printing - looks quite interesting.
- @Cheng2022 - reflectarray antenna
- @Shuping2024 - CRLH antenna, realized using 3D printing and electoplating

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

=== Stereo Perfect Metamaterial Absorber (Frontiers in Physics 2020)
- *Source:* _Frontiers in Physics_, vol. 8, 2020 @Deng2020.
- *Research Context:* Achievement of wide-incident-angle stability via stereo three-dimensional resonant meta-atoms.
- Methodology & Construction
  - Manufactured a standing gear-shaped resonant matrix providing geometric depth to incoming signals.
  - Integrated multi-directional conducting boundaries to trap incident wavefronts.
- Experimental Findings
  - Maintained near-unity absorption efficiency at steep oblique angles of incidence up to 60 degrees.
  - Demonstrated robust polarization insensitivity across the targeted radar frequency window.

=== Micro and Nano Scale 3D Printing Review (Virtual and Physical Prototyping 2024)
- #INFO quite nice overview
- *Source:* _Virtual and Physical Prototyping_, vol. 19, no. 1, 2024 @Peng2024.
- *Research Context:* Structural tracking of manufacturing mechanisms and functional scaling for electromagnetic absorbers.
- Methodology & Construction
  - Categorized performance bounds across multi-axis material jetting and powder-bed fusion configurations.
- Experimental Findings
  - Outlined critical material formulation limits for carbon nanotube and graphene-loaded lossy polymer filaments.
  - Confirmed that multi-material gradient structures successfully optimize the impedance interface with free space.

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

=== Conformal 3D-Printed Bandpass mm-Wave FSS Radome (Scientific Reports 2021)
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
= Metamaterial Phase-Screens
- There's essentially zero chance NTUST would be able to manufacture something like this.
  - Respectively it would maybe be possible in THz range with lithography, but not in GHz / tents of GHz range

== Phase Modulating Screens
- *Mechanism:* Planar or conformal spatial phase modulators distributing subwavelength meta-atoms to dynamically or statically alter wavefront profiles.
- *Design Rule:* Imparts localized phase shifts spanning a complete 360-degree envelope to replace traditional thick, curved refractive lenses.
- Translating continuous phase distributions into discrete coding matrices creates phase quantization errors that induce parasitic scattering and side-lobe degradation.
- Inter-layer bonding variations and microscopic air gaps introduce material anisotropy, causing phase deviations from simulated target metrics.

=== Spin-decoupled broadband transmissive metasurfaces (IEEE TAP 2023)
- *Source:* _IEEE Transactions on Antennas and Propagation_, vol. 71, no. 9, 2023 @Zhu2023.
- *Research Context:* Investigation of multi-layered transmissive metasurfaces utilizing spin-decoupled unit cells to achieve wideband performance.
- Methodology & Construction
  - Implemented nine-layer unit cells leveraging advanced 3D printing methods to handle precise spatial allocations.
  - Manufactured using multi-material integrated 3D printing with NIR lamp sintering of ink
- Experimental Findings
  - Demonstrated clean decoupling and independent phase control of orthogonal circular polarization components.
  - Verified that additive manufacturing successfully executes high-precision multi-layered geometries without cleanroom lithography.

=== The Phase Switched Screen (IEEE APM 2004)
- #INFO not even related to 3D printing, not to mention it's an active component but it's cool.
- *Source:* _IEEE Antennas and Propagation Magazine_, vol. 46, no. 6, 2004 @Chambers2004.
- *Research Context:* Early development of phase-switched architectures for dynamic reflection and scattering control.
- Methodology & Construction
  - Explored dynamic modulation of surface impedance parameters under plane wave illumination.
- Experimental Findings
  - Formed the theoretical blueprint for digital coding arrays and dynamic wavefront manipulation techniques.


#pagebreak()

#v(2em)
#bibliography("references.bib", style: "ieee")
