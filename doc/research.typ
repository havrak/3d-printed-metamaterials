#set heading(numbering: "1.1.1)")
#set text(font: "Liberation Serif", size: 11pt)
#set page(paper: "a4", margin: (x: 2cm, y: 2.5cm))
#set par(justify: true, leading: 0.65em)
#align(center)[
  #text(size: 18pt, weight: "bold")[3D Printed Metamaterials] \
  #text(size: 14pt)[Exploratory study and Core Themes] \
  #link("https://typst.app/project/wBQGVX8CTMedKqXLVoBbtb")[Online Version]
]

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
  - This requires the designer to configure the internal infill toolpaths directly.
  - Simulating these arbitrary infill architectures is highly problematic because the complex internal mesh easily becomes uncomputable.
  - The entire structure must typically be remodeled as a collection of solid domains with discrete, homogeneous effective materials.
  - This modeling constraint limits the implementation of truly continuous, gradual infill gradients.

- *Multiple Materials:*
  - The basic approach resembles a lattice grid, but instead of air gaps, a second material forms the surrounding support structure or alternating cells.
  - The exact behavior within high-frequency simulation suites remains highly dependent on boundary mesh approximations.
  - Designing these alternating spatial allocations is straightforward using programmatic CAD environments like CadQuery.
  - This approach requires multi-head printers, as continuous autonomous filament swapping is necessary during the print.
  - Facilities such as NTUST host dedicated research groups focused on high-speed multi-head FDM architectures.

- *Design Automation Tools:*
  - Most geometries are easily described by mathematical equations, but manual modeling in classic parametric CAD engines is highly inefficient due to geometric complexity.
  - *CadQuery:* A Python-based programmatic CAD environment that describes models via explicit code loops rather than interactive 2D sketching. This simplifies lattice synthesis and mathematical infill variation, handling high component counts effectively for academic prototype scales.
  - *nTop:* A commercial engineering tool optimized for additive manufacturing that excels at creating advanced spatial lattices and complex field-driven infill profiles. However, it is not fundamentally integrated with electromagnetic simulation pipelines, meaning exported meshes remain challenging to analyze natively.

== Print Technologies Comparison
- Three main additive manufacturing techniques are prominently utilized: SLA, SLS, and standard FDM.
- SLA and SLS are widely adopted due to their high spatial resolution and superior management of complex geometric overhangs without extensive support arrays.
- FDM is less common in pure dielectrics, finding specific utility in multi-material applications where conductive paths must be integrated directly into a polymer block.
- *SLA (Stereolithography):* FFI characterized SLA resolutions as disappointing for fine-pitch micro-grids, whereas CEI 2022 successfully deployed it to yield a precise 50 mm spherical lens @Kristoffersen2017 @Yue2022.
- *SLS (Selective Laser Sintering):* Essential for the high-quality nylon grids in the FFI study, providing single-step execution of dense internal cavities @Kristoffersen2017. However, clearing unsintered powder from the inner chambers remains a difficult post-processing logistical hurdle.
- *FDM Multi-Material Extrusion:* Rarer due to material dielectric limits, as the permittivity delta between distinct plastics is smaller than a plastic-to-air boundary, and the co-polymers often introduce higher dielectric losses.

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
- *Research Context:* Demonstration of a 50 mm in radius Luneburg lens created using SLA printing, achieved an improvement in gain of 7.41 dB @Yue2022.

==== Methodology & Construction
- *Unit Cell Design:* Each unit consists of a variable-sized dielectric cube in the center with three connecting rods (0.8 mm fixed width) parallel to the X, Y, and Z axes @Yue2022.
- A unit period of 5 mm was chosen to be significantly smaller than the center wavelength of the X-band at 10 GHz @Yue2022.
- The lens was fed from a standard WR-90 waveguide open port without an external antenna element @Yue2022.
- *Parameter Retrieval:* Used the S-parameter retrieval method proposed by D. R. Smith (2005) to extract equivalent permittivity @Yue2022.
- *Manufacturing:* Produced a 50 mm radius lens using Stereo Lithography Apparatus (SLA) with C-UV 9400E photosensitive resin ($epsilon_r approx 3.2-4.0$) @Yue2022.

==== Experimental Findings
- *Gain Improvement:* The antenna gain at 10 GHz was 14.98 dB, a 7.41 dB increase compared to a single waveguide feed @Yue2022.
- *Calculation of Parameters:* Authors mention a method of calculating permittivity of these periodic structures @Yue2022.
- First, S-parameters of an individual cube are acquired using an EM field simulator @Yue2022.
- Then, the permittivity of the structure can be calculated using a specific retrieval formula @Smith2005.
- No problems regarding simulations or manufacturing using SLA were mentioned in this study @Yue2022.
- *Beamwidth:* Main lobe width narrowed from 28.26° at 8 GHz to 18.84° at 12 GHz @Yue2022.
- *Scanning Capability:* The lens rotated 45° with basically unchanged pattern and gain, proving good spatial dynamic scanning ability @Yue2022.


== GRIN (Gradient Index) Lenses
- *Mechanism:* Planar structures exhibiting radial permittivity gradients typically expressed as:
$ n(r)^2 = epsilon_r(r) = (n_0 - (sqrt(L^2+r^2)-L)/t)^2 $
where $n_0$ is the refractive index at 100% material infill, $r$ is the radial offset from the axis, $L$ is the focal length, and $t$ represents the physical thickness of the lens disk @Kristoffersen2017.
- These geometries are sometimes classified alongside or compared directly to flat Fresnel zone plate configurations due to their planar layout.
- The structural simplicity of the radial distribution makes it fully compatible with low-cost FDM extrusion tracks, serving as an optimal baseline for experimental validation.

=== 3D Printed Metamaterial Lenses for Microwave Antennas
- *Source:* FFI-RAPPORT 17/00415 @Kristoffersen2017
- *Research Context:* Exploratory study financed by the Norwegian Defence Research Establishment (FFI) to build competence in materials with spatially varying permittivity for military applications.
- *Filename:* 17-00415.pdf

==== Methodology & Construction
- *Unit Cell Design:* The study utilized a 3.55 mm lattice grid structure built by unit cubes intersected in three spatial directions
- The structure realized was a GRID lens, but varying density was achieved using a 3D lattice grid structure.
- *Material Selection:* Used PA2200 nylon, initially believed to have $epsilon_r approx 3.6$ (glass-mixed version), but measured at $epsilon_r approx 2.5 - 2.8$ for 100% density.
- *Simulations:* Performed using ANSYS HFSS, modeling $epsilon_r$ vs. frequency for various cube sizes.

==== Experimental Findings
- *Test Case 1 (Lattice Blocks):* Achieved a span in measured $epsilon_r$ from 1.25 to 2.45.
- *Test Case 2 (Flat Lens):* Demonstrated a frequency-independent gain increase of approximately 3 dB over the 8-18 GHz range.
- *Loss Characteristics:* Measurements with the lens at the antenna aperture showed very little loss, confirming the efficiency of the metamaterial approach.
- *3D Printing Challenges:* Authors mentioned repeated failures when trying to use standard SLA 3D printing and were forced to rely on SLS.
- Even in SLS they had to use a higher minimum thickness of 0.7 mm than desired.
- It is vital to measure the permittivity of the material manufactured using the same process as the final lens @Kristoffersen2017.
- The measured permittivity will be smaller than that of the material itself @Kristoffersen2017.
- The measured structures should probably have the same form as those used in the final lens @Kristoffersen2017.
- Authors reported significant problems in simulating the structure using ANSYS HFSS @Kristoffersen2017.


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
