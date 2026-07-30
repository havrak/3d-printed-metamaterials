#set heading(numbering: "1.1.1)")
#set text(font: "Liberation Serif", size: 11pt)
#set page(paper: "a4", margin: (x: 2cm, y: 2.5cm))
#set par(justify: true, leading: 0.65em)
#align(center)[
  #text(size: 18pt, weight: "bold")[3D Printed Metamaterials] \
  #text(size: 14pt)[Exploratory study and Core Themes] \
  #link("https://typst.app/project/wBQGVX8CTMedKqXLVoBbtb")[Online Version]
]

#let warn(input) = {
  box(
    inset: 0.2em,
    radius: 0.2em,
    fill: rgb("#ffffff"),
    stroke: rgb("#ff0000"),
    text(fill: rgb("#ff0000"), weight: "bold",input)
  )
}

#let note(input) = {
  box(
    inset: 0.2em,
    radius: 0.2em,
    fill: rgb("#ffffff"),
    stroke: rgb("#0000ff"),
    text(fill: rgb("#0000ff"), weight: "bold",input)
  )
}

#let info(input) = {
  box(
    inset: 0.2em,
    radius: 0.2em,
    fill: rgb("#00ff00"),
    stroke: rgb("#00ff00"),
    text(fill: rgb("#ffffff"), weight: "bold",input)
  )
}

#let TODO = warn("TODO")
#let XXX = warn("XXX")
#let DELETE = warn("DELETE")
#let WARN = warn("WARN")
#let NOTE = note("NOTE")
#let INFO = info("INFO")
#let OPTIONAL = info("OPTIONAL")
#let DONE = info("DONE")

// Usage:


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
  - This approach requires multi-head printers, as continuous autonomous filament swapping is necessary during the print.
  - Facilities such as NTUST host dedicated research groups focused on high-speed multi-head FDM architectures.

- *Design Automation Tools:*
  - Most geometries are easily described by mathematical equations, but manual modeling in classic parametric CAD engines is highly inefficient due to geometric complexity.
  - *CadQuery:* A Python-based programmatic CAD environment that describes models via explicit code loops rather than interactive 2D sketching. This simplifies lattice synthesis and mathematical infill variation, handling high component counts effectively for academic prototype scales.
  - *OpenSCAD:* faster real time preview than CadQuery, much slower final output, cannot output to stl I think

== Print Technologies Comparison
- Three main additive manufacturing techniques are prominently utilized: SLA, SLS, and standard FDM.
- SLA and SLS are widely adopted due to their high spatial resolution and superior management of complex geometric overhangs without extensive support arrays.
- *FDM (Fused Deposition Modeling)*
  - Unable to reliably handle overhangs, applicable only to methods relying on varying infill.
  - Extrusion nozzle diameters ($>= 0.4 "mm"$) impose lower bounds on minimum spatial feature size, limiting metamaterials primarily to Sub-6 GHz and X-band frequencies.
  - Setups with multiple print heads enable innovative construction techniques -- use of conductive filaments supported by non conductive one, on instead of controlling ratio of air to filament one can use two filaments with widely different permitivities (However there are problems with different print temperature, how well do the materials combine and such).
- *SLA (Stereolithography):* FFI characterized SLA resolutions as disappointing for fine-pitch micro-grids, whereas CEI 2022 successfully deployed it to yield a precise 50 mm spherical lens @Kristoffersen2017 @Yue2022.
  - Seems to be gold standard to
- *SLS (Selective Laser Sintering):* Essential for the high-quality nylon grids in the FFI study, providing single-step execution of dense internal cavities @Kristoffersen2017. However, clearing unsintered powder from the inner chambers remains a difficult post-processing logistical hurdle.
  - NTUST has printers based on SLS technology

== Materials
- Foaming PLA:
  - Increasing volumetric expansion with higher printing temperatures.
  - GRIN lense printed using this material demonstrated in @Moschner2025.
- Electrically Conductive filaments
  - Interesting field of research
  - Only applicable to FDM and multiple print heads, no other configuration makes sense.
  - Proto-pasta:
    - #link("https://proto-pasta.com/products/conductive-pla?variant=27767315720")
    - PLA with carbon black, prints with standard PLA settings.
    - 1 cm of 1.75 mmm wire has resistance of about 200 to 350 Ohm
    - Seems more useful for EMC shielding than making anything that needs to be really conductive.
    - \$90 per 1.75 mm 1 kg spool
  - Electrifi Conductive Filament
    - #link("https://www.multi3dllc.com/product/electrifi/")
    - Copper-polymer composite, prints at low temperatures around 130-160 degrees - well bellow what's needed for PLA.
    - Conductivity of 10 000 S/m
    - Super expensive at \$215 per 1.75 mm 100 g spool (17 meters), offered in 200 g or 500 g spools.
    - Actually used for antennas or in replacing stacked PCBs to create metamaterials.
  - Spectrum Electrically Conductive
    - Enhanced with carbon nano tubes.
    - PLA based
      - #link("https://shop.spectrumfilaments.com/product-eng-3298-Spectrum-PLA-Electrically-Conductive-1-75mm-BLACK-0-75kg.html?query_id=1")
      - Print temperature at the higher end of PLA 210 - 230 degrees.
      - 4x4x120 mm test print (Idk the orientation so this value is useless) had resistance of 97 to 120 Ohm depending on the print temperature (lower resistance with higher print temperature).
      - \$70 per 1.75 mm of 750 g spool
      - Seems price comparable to Proto-pasta, with roughly 4 times lower resistance.
    - ASA based
      - #link("https://shop.spectrumfilaments.com/product-eng-3297-Spectrum-ASA-Electrically-Conductive-1-75mm-BLACK-0-75kg.html?query_id=1")
      - High print temperatures of 270 to 290 degrees.
      - 4x4x120 mm test print had resistance of 41 to 51 Ohm depending on the print temperature.
      - \$70 per 1.75 mm of 750 g spool
      - Again price comparable to Proto-pasta, but with 8 times lower resistance.

#pagebreak()
= Monolithic Multi-Filament FDM Metamaterials
- Traditional way of constructing left handed metamaterials (not just materials with varying permitivity) relied on stacking PCBs .
  - Their alignment needs to be precisely controlled to ensure proper function.
  - Two possible solutions
    - Printing support structure from plastic and inserting copper wires, seen it done, but looks incredibly laborious.
    - Using combination of support filament with conductive one.
- Dual-filament FDM utilizes an Independent Dual Extruder (IDEX) or multi-hotend toolhead to deposit a dielectric base polymer alongside a conductive composite filament in a single uninterrupted print job.
- This continuous deposition unlocks genuine three-dimensional spatial meta-atoms, such as vertical helices, embedded inter-unit capacitive walls, and non-planar 3D conductive loops.

== Electrodynamics of Low-Conductivity Filaments vs. Electrifi
- Standard commercial conductive filaments rely on microscopic carbon black, carbon nanotube, or graphite filler networks dispersed in thermoplastics.
- These carbon-loaded composite filaments exhibit low electrical conductivity, typically ranging from $sigma approx 0.01 "S/m"$ to hundreds $"S/m"$, with linear resistance measuring in tens to hundreds of $Omega / "cm"$.
  - At frequency of 1 GHz, a low conductivity of $sigma < 100 "S/m"$ prevents complete boundary reflection, causing incoming waves to penetrate deep into the material where energy is absorbed via ohmic losses. @Xie2017
  - #WARN I'm not totally sure, to what degree what they've numerically calculated is applicable to composite materials, they blabber about skin depth but simple skin depth calculation isn't applicable to this case and so I would say 100 S/m is quite generous and real conductivity needs to be higher.
- Low-conductivity filaments fail as high-Q resonant radiators or highly reflective phase-screen elements, but excel as single-step monolithic electromagnetic absorbers and radar cross-section dampeners.
- Conversely, copper-loaded filaments such as Electrifi achieve significantly higher bulk conductivities ($sigma approx 1.67 times 10^4 "S/m"$), placing them in a distinct performance tier - allowing them to act like a true metallic conductor at microwave bands @Xie2017, @Yurduseven2019

== Inherent Manufacturing Challenges
- Multi-filament printing introduces severe nozzle cross-contamination and micro-stringing, where minute conductive polymer droplets drag across dielectric boundary zones to create unwanted electrical shorts.
- Differential thermal expansion coefficients between carbon-filled conductive filaments and pristine dielectric substrates cause severe inter-layer delamination and Z-axis warping during cooling - though  I probably could get some guidance on this.

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

===  3D Conductive Polymer Printed Metasurface Antenna for Fresnel Focusing (Designs 2019)
- *Source:*  _Designs_, vol. 3, no. 3,2017  @Yurduseven2019
- *Research Context:* holographic metasurface antenna for beam-focusing applications at 10 GHz using Electrifi filament
- Methodology & Construction
  - A PLA substrate was sandwiched between two surfaces from Electrifi - one ground plane second a Metasurface
  - Metasurface layer is patterned into an array of subwavelength slot-shaped metamaterial elements (or meta-elements). These meta-elements couple to the guided mode (or the reference wave) launched into the PLA substrate by a coaxial feed placed in the center of the antenna
- Experimental Findings
   -  It was also observed that improving the material conductivity could significantly enhance the radiation characteristics of the proposed antenna.
   - Antenna exhibited relatively low gain, both lower conductivity and losses in substrate significantly degraded performance of the antenna.

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
  - different approaches also demostrated in @Kristoffersen2017 (using Lattice Structure), @Paraskevopoulos2022 (optimized design),  or @Moschner2025 (Foaming PLA)


#pagebreak()
= Metamaterial Phase-Screens

== Phase Modulating Screens
- *Mechanism:* Planar or conformal spatial phase modulators distributing subwavelength meta-atoms to dynamically or statically alter wavefront profiles.
- *Design Rule:* Imparts localized phase shifts spanning a complete 360-degree envelope to replace traditional thick, curved refractive lenses.
- Translating continuous phase distributions into discrete coding matrices creates phase quantization errors that induce parasitic scattering and side-lobe degradation.
- Cross-polarization conversion elements frequently possess narrow operating bands, while high-aspect-ratio subwavelength meta-atoms face structural fragility at terahertz frequencies.
- Fused Filament Fabrication enables the co-deposition of low-loss polymer dielectrics and conductive filaments to bypass multi-step lithography.
- The limited bulk conductivity ($sigma approx 1.67 times 10^4 "S/m"$) of conductive polymers increases the electromagnetic skin depth ($d = sqrt(2 / (omega mu sigma))$).
- This skin-depth expansion forces deeper wave penetration into the lossy matrix, yielding high volumetric dissipation that degrades transmission efficiency.
- Inter-layer bonding variations and microscopic air gaps introduce material anisotropy, causing phase deviations from simulated target metrics.

=== Spin-decoupled broadband transmissive metasurfaces (IEEE TAP 2023)
- *Source:* _IEEE Transactions on Antennas and Propagation_, vol. 71, no. 9, 2023 @Zhu2023.
- *Research Context:* Investigation of multi-layered transmissive metasurfaces utilizing spin-decoupled unit cells to achieve wideband performance.

==== Methodology & Construction
- Implemented nine-layer unit cells leveraging advanced 3D printing methods to handle precise spatial allocations @Zhu2023.
- Exploited the geometric Pancharatnam-Berry phase mechanism by systematically rotating identical dielectric pillars @Zhu2023.

==== Experimental Findings
- Demonstrated clean decoupling and independent phase control of orthogonal circular polarization components @Zhu2023.
- Verified that additive manufacturing successfully executes high-precision multi-layered geometries without cleanroom lithography @Zhu2023.

=== The Phase Switched Screen (IEEE APM 2004)
- *Source:* _IEEE Antennas and Propagation Magazine_, vol. 46, no. 6, 2004 @Chambers2004.
- *Research Context:* Early development of phase-switched architectures for dynamic reflection and scattering control.

==== Methodology & Construction
- Explored dynamic modulation of surface impedance parameters under plane wave illumination @Chambers2004.

==== Experimental Findings
- Formed the theoretical blueprint for digital coding arrays and dynamic wavefront manipulation techniques @Chambers2004.

#pagebreak()
= Metamaterial-Based Antennas

== Metantennas and Resonant Surfaces
- *Mechanism:* Incorporation of artificial subwavelength inclusions like split-ring resonators and electromagnetic bandgap grids into or around radiators.
- *Design Rule:* Bypasses classic Chu-Harrington performance limits to achieve miniature antenna footprints alongside enhanced operational parameters.
- Multi-layer printed circuit board constraints limit conventional layouts to rigid, two-dimensional surfaces.
- This restriction prevents the optimization of multi-directional polarization states and complex non-planar conformal arrays.
- Subwavelength meta-atoms inherently possess high quality-factors, which restrict operational bandwidths and create severe impedance matching hurdles.
- Multi-material 3D printing circumvents PCB limits, facilitating the fabrication of spatial meta-atoms directly onto curved structural hulls.
- Extruding conductive patterns directly onto dielectrics consolidates microstrip patches and ground elements into a single processing run.
- Host polymer binders dilute the metal filler concentration, increasing radiofrequency losses due to expanded current penetration depths.
- Ohmic attenuation inside the lossy conductive composite skin layer degrades the broadside radiation efficiency and total antenna gain.
- Printing layer variations and infill density fluctuations alter the local effective permittivity, shifting the antenna's tuned resonant frequency.

=== Low-Profile 3-D Printable Metastructure for Aperture Antennas (Scientific Reports 2024)
- *Source:* _Scientific Reports_, vol. 14, 2024 @Ali2024.
- *Research Context:* Enhancement of broadside directivity and radiation efficiency using a low-profile 3D-printed meta-superstrate.

==== Methodology & Construction
- Configured a periodic metamaterial array as an unexcited superstrate suspended directly above an active patch radiator @Ali2024.
- Formed a highly resonant Fabry-Pérot cavity to manipulate outgoing phase fronts @Ali2024.

==== Experimental Findings
- Transformed expanding spherical wave distributions into highly directive broadside plane waves @Ali2024.
- Achieved notable gain improvements while maintaining a compact, lightweight antenna profile @Ali2024.

=== Metamaterials and Reconfigurable Antennas Review (Micromachines 2023)
- *Source:* _Micromachines_, vol. 14, no. 2, 2023 @Hussain2023.
- *Research Context:* Comprehensive review tracking single-negative and double-negative inclusions for reconfigurable systems.

==== Methodology & Construction
- Systematized performance changes achieved by incorporating reactive impedance surfaces and metasurface backings @Hussain2023.

==== Experimental Findings
- Documented average antenna footprint reduction thresholds reaching up to 75 percent @Hussain2023.
- Confirmed simultaneous enhancements in operational bandwidth and side-lobe suppression across diverse topologies @Hussain2023.

#pagebreak()
= Perfectly Matched Layer Radomes and Absorbers

== Impedance-Matched Stealth Metasurfaces
- *Mechanism:* Artificial boundary layers designed to balance effective permittivity and permeability to match free-space impedance ($377 Omega$).
- *Design Rule:* Drives the primary reflection coefficient to zero, allowing incoming radar energy to enter the structure unscattered.
- Classic metamaterial absorbers exhibit narrow, frequency-selective operational bands that are vulnerable to frequency-hopping radar sweeps.
- Achieving wide-angle stability and polarization insensitivity requires intricate three-dimensional unit cells that resist standard subtractive milling.
- Stealth radomes face the conflicting demands of wideband out-of-band absorption and sharp, transparent narrow-band transmission for communication.
- Additive manufacturing enables complex 3D profiles like standing gears and vertical pyramids to secure wide incident angle performance.
- The lower electrical conductivity of carbon- or graphite-doped filaments provides the exact ohmic loss mechanism needed for wave dissipation.
- Selective Laser Sintering of carbon composites builds gradient-index transitions that smoothly guide waves from free space to high-loss zones.
- Small defects in layer height, geometric rounding at sharp corners, or internal air voids distort the local effective medium values.
- These geometric deviations disrupt the boundary impedance match, triggering parasitic radar reflections that degrade low-observable metrics.

=== Stereo Perfect Metamaterial Absorber (Frontiers in Physics 2020)
- *Source:* _Frontiers in Physics_, vol. 8, 2020 @Deng2020.
- *Research Context:* Achievement of wide-incident-angle stability via stereo three-dimensional resonant meta-atoms.

==== Methodology & Construction
- Manufactured a standing gear-shaped resonant matrix providing geometric depth to incoming signals @Deng2020.
- Integrated multi-directional conducting boundaries to trap incident wavefronts @Deng2020.

==== Experimental Findings
- Maintained near-unity absorption efficiency at steep oblique angles of incidence up to 60 degrees @Deng2020.
- Demonstrated robust polarization insensitivity across the targeted radar frequency window @Deng2020.

=== Micro and Nano Scale 3D Printing Review (Virtual and Physical Prototyping 2024)
- *Source:* _Virtual and Physical Prototyping_, vol. 19, no. 1, 2024 @Peng2024.
- *Research Context:* Structural tracking of manufacturing mechanisms and functional scaling for electromagnetic absorbers.

==== Methodology & Construction
- Categorized performance bounds across multi-axis material jetting and powder-bed fusion configurations @Peng2024.

==== Experimental Findings
- Outlined critical material formulation limits for carbon nanotube and graphene-loaded lossy polymer filaments @Peng2024.
- Confirmed that multi-material gradient structures successfully optimize the impedance interface with free space @Peng2024.

#v(2em)
#bibliography("references.bib", style: "ieee")
