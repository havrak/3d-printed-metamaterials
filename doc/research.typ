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

=== Electrodynamics of Low-Conductivity Filaments vs. Electrifi
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
= Real Permitivity Retrieval and Measurement Methodologies
- Characterization of 3D-printed metamaterials requires mapping physical geometries to effective medium parameters.
- A standard unit cell comprising a dielectric block with a cylindrical void exhibits inherent electromagnetic anisotropy.
- The effective permittivity parallel to the cylinder axis ($epsilon_(r,parallel)$) differs significantly from the perpendicular effective permittivity ($epsilon_(r,perp)$).
- Consequently, the orientation of the incident electric field during measurement strictly dictates the retrieved values.
- This anisotropy presents a critical challenge when the material is deployed in a leaky-wave antenna (LWA) architecture.
- A typical LWA operates utilizing a grounded substrate, exciting a transverse magnetic ($"TM"_0$) or transverse electric ($"TE"_1$) surface wave bound to the metal plane.
- Measurement setups impose their own boundary conditions, often generating field modes that do not match the operational environment of the LWA.
- Ensuring the measured effective permittivity accurately reflects the operational tensor requires careful selection between free-space and closed-waveguide methodologies.

== Free-Space Measurement Techniques
- Free-space characterization involves illuminating a planar slab of the printed metamaterial using directive horn antennas.
- The use of high-gain horn antennas coupled with dielectric lenses produces a highly planar wavefront, minimizing edge diffraction and phase curvature across the device under test.
- This quasi-TEM plane-wave incidence closely preserves the Bloch-Floquet mode structure inherent to periodic media.
- According to Bloch-Floquet theory, electromagnetic waves propagating through an infinite periodic lattice can be expressed as a superposition of spatial harmonics @Collin1990:
  $ beta_n = beta_0 + (2 pi n) / p $
  where $beta_n$ is the propagation constant of the $n$-th harmonic, $beta_0$ is the fundamental propagation constant, and $p$ is the unit cell periodicity.
- Because the free-space setup lacks metallic sidewalls, the metamaterial array interacts electromagnetically with adjacent unit cells rather than conductive boundaries.
- This preserves the natural inter-cell coupling and allows for direct evaluation of spatial dispersion without severe edge truncation effects.
- Furthermore, rotating the sample by 90 degrees relative to the incident electric field provides an independent measurement of orthogonal permittivity tensor components.
- Effective medium parameters are predominantly extracted from the measured scattering parameters ($S_11$ and $S_21$) using the Nicolson-Ross-Weir (NRW) retrieval algorithm @Nicolson1970.
- The NRW method mathematically relates the reflection ($Gamma$) and transmission ($T$) coefficients of a finite slab to its complex bulk parameters:
  $ S_11 = (Gamma (1 - T^2)) / (1 - Gamma^2 T^2) $
  $ S_21 = (T (1 - Gamma^2)) / (1 - Gamma^2 T^2) $
- It assumes a normally incident uniform plane wave and an isotropic, homogeneous medium.
- While computationally efficient, the NRW equations suffer from phase ambiguity phenomena at frequencies where the sample thickness equals integer multiples of half-wavelengths.
- Advanced extraction algorithms often augment standard NRW with Kramers-Kronig relations or time-domain gating to stabilize the extracted permittivity across broad frequency sweeps.

== Closed Waveguide Measurements
- Inserting the 3D-printed metamaterial directly into a metallic rectangular waveguide provides an alternative bounded measurement environment.
- This methodology operates in the dominant $"TE"_10$ mode, necessitating exact mechanical alignment to avoid the introduction of parasitic series capacitance.
- Microscopic air gaps between the printed dielectric and the upper or lower waveguide walls force the electric field to concentrate in the air void, drastically depressing the measured effective permittivity:
  $ epsilon_(r,"meas") approx epsilon_r / (1 + ((Delta d) / b) (epsilon_r - 1)) $
  where $Delta d$ is the cumulative gap height and $b$ is the waveguide height.
- Unlike the TEM waves in free-space setups, the $"TE"_10$ mode exhibits spatial dispersion dictated by the waveguide dimensions:
  $ beta_g = sqrt(omega^2 mu_0 epsilon_0 epsilon_r - (pi / a)^2) $
  where $a$ is the broad wall dimension of the waveguide.
- Standard NRW equations cannot be applied directly without substituting the free-space wave impedance and wavelength with the respective waveguide dispersion parameters.
- The conductive waveguide boundaries enforce perfect electric conductor (PEC) conditions, functioning as mirror planes via image theory.
- Unless the printed sample consists of an exact integer multiple of unit cells truncated precisely along mirror symmetry planes, the metallic walls alter the local field distribution.
- To bypass analytical dispersion limitations, inverse parameter fitting is frequently employed.
- The exact physical unit cell geometry, including any measured mechanical air gaps, is recreated within a full-wave electromagnetic simulator.
- The intrinsic material permittivity of the solid polymer is subsequently tuned via optimization algorithms until the simulated S-parameters converge with the empirical waveguide measurements.

== Manufacturing Tolerances and Slicer Quantization
- Additive manufacturing techniques inherently introduce physical deviations from ideal electromagnetic models due to mechanical tolerances and slicing approximations.
- Infill uncertainty directly translates into effective permittivity variations, fundamentally shifting the designed resonance and phase delay of the metamaterial @InfillVariation2026.
- Slicer software translates continuous radial gradients or discrete parametric unit cells into planar layers of G-code, creating spatial quantization errors across the z-axis @Schard2022.
- The standard analytical baseline for mixed media is often the Maxwell-Garnett Approximation (MGA), which predicts effective permittivity based on volume fill fractions: $ epsilon_("eff") = epsilon_m (epsilon_i + 2 epsilon_m + 2 delta_i (epsilon_i - epsilon_m)) / (epsilon_i + 2 epsilon_m - delta_i (epsilon_i - epsilon_m)) $.
- In this expression, $epsilon_m$ represents the matrix permittivity, $epsilon_i$ the inclusion permittivity, and $delta_i$ the volume fill fraction of the inclusions @Schard2022.
- However, MGA loses predictive accuracy at high fill fractions, necessitating rigorous numerical techniques like the Plane Wave Expansion Method (PWEM) to resolve actual Bloch-mode phase boundaries.
- Defining unit cells via discrete spatial harmonics rather than basic parametric shapes offers enhanced resolution control for index-graded devices, mitigating some of the sharp boundary quantization induced by standard slicers @Schard2022.
- For 3D-printed leaky-wave antennas relying on periodic corrugations, uncompensated manufacturing tolerances shift the fundamental propagation constant ($beta$).
- Because the beam pointing angle is defined by $sin(theta_0) approx beta / k_0$, these beta shifts directly degrade the pointing accuracy of the antenna.
- Recent evaluations of 3D-printed spiral LWAs at 18 GHz demonstrate that dimensional variations in the printed corrugations modify both the radiation bandwidth and the axial ratio of the circular polarization @LiraSpiral2026.
- Mitigating these errors requires iterative reverse-fitting, where the printed metamaterial is characterized, and the subsequent CAD model is pre-distorted to compensate for the systematic slicer over-extrusion or under-extrusion.

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

===  3D Conductive Polymer Printed Metasurface Antenna for Fresnel Focusing (Designs 2019)
- *Source:*  _Designs_, vol. 3, no. 3,2017  @Yurduseven2019
- *Research Context:* holographic metasurface antenna for beam-focusing applications at 10 GHz using Electrifi filament
- Methodology & Construction
  - A PLA substrate was sandwiched between two surfaces from Electrifi - one ground plane second a Metasurface
  - Metasurface layer is patterned into an array of subwavelength slot-shaped metamaterial elements (or meta-elements). These meta-elements couple to the guided mode (or the reference wave) launched into the PLA substrate by a coaxial feed placed in the center of the antenna
- Experimental Findings
   -  It was also observed that improving the material conductivity could significantly enhance the radiation characteristics of the proposed antenna.
   - Antenna exhibited relatively low gain, both lower conductivity and losses in substrate significantly degraded performance of the antenna.

== Leaky-Wave Antennas (LWAs) and Traveling-Wave Metasurfaces
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

=== 3D Printed Spiral Leaky-Wave Antenna with Circular Polarization (IEEE OJAP 2023) #COOL
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
- #NOTE: would need to verify how large of a problem is the lack of proper termination, study would probably necessitate constructing two antennas to verify the improvement
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
- *Material Selection and Practical FDM Integration:*
  - *Static Dissipative PLA by Proto-pasta ESD:*
    - High surface resistivity ($10^6 - 10^9 Omega / "sq"$) allows gradual, distributed attenuation over extended electrical lengths without severe localized heating.
    - Generally all carbon-loaded filaments with low percentage of filling are applicable for this usecase.
    - Filaments have the same print settings as non conductive ones -- useful for printers with interchangeable extruders, not to mention print bed settings can remain constant.
  - *Conductive Carbon-Loaded TPU:*
    - Combines molecular dipolar relaxation loss with conductive ohmic dissipation.
    - High flexibility and viscoelastic mismatch increase risk of extruder buckling, stringing across dielectric voids, however it can be done.
    - One of the material with higher losses that is fairly easy to commercially acquire with many possible suppliers.

==== Loss-Modulated (Non-Hermitian) Flat Leaky-Wave Antennas
- *Concept:* Conventional periodic LWAs rely on geometric modulation (e.g., cutting grooves or adding teeth) to excite the $n = -1$ space harmonic. A loss-modulated LWA maintains a perfectly flat, uniform physical geometry, but achieves periodic modulation by alternating low-loss and high-loss materials.
- *Mechanism:* Using dual-extrusion FDM, a flat dielectric slab is printed with periodic inclusions of a highly lossy filament (e.g., carbon-loaded PLA or static dissipative PLA). The periodic variation occurs entirely within the imaginary part of the complex permittivity ($epsilon''_r$), creating a complex grating.
- *Research Value:*
  - Produces a perfectly flush, aerodynamic radiating surface without physical corrugations, highly relevant for conformal aerospace applications.
  - Explores parity-time ($cal(P)cal(T)$) symmetric or purely non-Hermitian leaky-wave physics, which theoretically allows for single-beam radiation (suppressing the backward $-1$ harmonic that normally arises in pure geometric gratings).
- *Challenges:* Balancing the loss fraction is critical. If the carbon-loaded regions are too wide or too conductive, the attenuation constant ($alpha$) will become excessive, dissipating the guided wave entirely before it can radiate efficiently.
  - #WARN the two materials will probably have different $epsilon'_r$ permittivities - totally ruining any Exceptional-Point behavior that might have been possible otherwise
  - Out of question as a topic same for all other exceptional-point related topics.

==== Continuous Sinusoidal Reactance Surfaces via Foaming PLA
- *Concept:* Standard 3D-printed LWAs discretize periodic modulation into square pulses (blocks of material vs. air). This abrupt quantization excites higher-order space harmonics ($n = -2, -3$, etc.), which can leak as unwanted grating lobes and reduce aperture efficiency.
  - #WARN This kinda falters when considering that many LWA's that use more complex unit cells - for example ones with cylindrical cutouts where the transition is already fairly continuous.
- *Mechanism:* Utilizing active temperature modulation of the FDM hotend during the print, the volumetric expansion of Foaming PLA (PolyLite LW-PLA or ColorFabb LW-PLA) can be continuously varied.
- *Research Value:*
  - Instead of a square-wave permittivity profile, the LWA is printed with a mathematically continuous, sinusoidal spatial permittivity gradient:
    $ epsilon_r (z) = epsilon_("avg") + Delta epsilon_r sin((2 pi z) / p) $
  - A pure sinusoidal modulation theoretically couples energy *only* into the $n = -1$ radiating harmonic, suppressing all other parasitic modes and grating lobes, maximizing directivity and radiation efficiency.
- *Challenges:* Establishing a highly accurate, calibrated mapping between the G-code extrusion temperature, the resulting physical void fraction, and the extracted RF permittivity.

==== Chirped Conformal LWAs with Pre-Distorted Geometries #FAV
- *Concept:* Mounting a standard periodic LWA onto a curved surface (e.g., a cylinder or aerodynamic leading edge) bends the propagation axis. This curvature induces a phase error across the aperture, causing the main beam to defocus and the directivity to collapse.
- *Mechanism:* Develop an inverse-design methodology where the unit-cell period ($p$) and fill fraction are progressively altered (chirped) along the length of the antenna to compensate for the geometric curvature.
- *Research Value:*
  - Validates the unique capability of 3D printing to fabricate non-uniform, spatially varying structures that are impossible to machine subtractively.
  - By locally tuning the propagation constant $beta(z)$ and attenuation constant $alpha(z)$ through varying the 3D-printed cell density, the conformal LWA can synthesize a perfectly collimated, high-gain plane wave from a highly curved physical surface.
- *Challenges:* The CAD generation cannot rely on simple linear arrays; it requires programmatic CAD (e.g., CadQuery or OpenSCAD) to generate unique, progressively scaling unit cells mapped to a spline or cylindrical coordinate system.

=== Other Papers
- @Liu2026
  - talks about some Spoof Surface Plasmon Polaritons (SSPPs) -- looks cool but I have no idea what it is
  - construct is plated with metal -- (basically a radiating waveguide), but the geometry is way too complex to do some electroplating or whatever.

== Reflectarray antennas
-



== Other Papers
- @Oni2026 - just overview of current state of Metamaterial based antennas, not much related to 3D printing.
- @Dong2012 - overview of metamaterial antennas, has a section on antennas with metasurface.
- @Whittaker2023 - applications of 3D printing in antennas and metaantennas.
    - #NOTE mentions reflectarray antennas with dielectric resonators realized using 3D printing - looks quite interesting.
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
- #NOTE quite nice overview
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
- #NOTE Also quite interesting and electroplating shouldn't be impossible at NTUST.
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
- #NOTE not even related to 3D printing, not to mention it's an active component but it's cool.
- *Source:* _IEEE Antennas and Propagation Magazine_, vol. 46, no. 6, 2004 @Chambers2004.
- *Research Context:* Early development of phase-switched architectures for dynamic reflection and scattering control.
- Methodology & Construction
  - Explored dynamic modulation of surface impedance parameters under plane wave illumination.
- Experimental Findings
  - Formed the theoretical blueprint for digital coding arrays and dynamic wavefront manipulation techniques.


#pagebreak()

#v(2em)
#bibliography("references.bib", style: "ieee")
