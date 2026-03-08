#set heading(numbering: "1.1.1)")
#set text(font: "helvetica", size: 11pt)
#set page("a4")
#outline()

#pagebreak()
= Existing Studies

== 3D printed metamaterial lenses for microwave antennas (FFI 2017)
- *Authors:* Stein Kristoffersen, Karina Vieira Hoel
- *Source:* FFI-RAPPORT 17/00415
- *Research Context:* Exploratory study financed by the Norwegian Defence Research Establishment (FFI) to build competence in materials with spatially varying permittivity for military applications.
- *Filename:* 17-00415.pdf
- *Link:* #link("https://www.ffi.no/en/publications-archive/3d-printed-metamaterial-lenses-for-microwave-antennas")[www.ffi.no]

=== Exploratory study
- Overview of existing use cases - Luneburg, GRIN lenses, brief mention of useage of metamaterials in creation of phase screen, antennas or radomes
- Most of the menioned papers were more theoretical and on the older side.

=== Methodology & Construction
- *Unit Cell Design:* The study utilized a 3.55 mm lattice grid structure built by unit cubes intersected in three spatial directions.
  - structure realized was a GRID lense, but varying density was achived using a 3D lattice grid strucure.
- *Material Selection:* Used PA2200 nylon, initially believed to have $epsilon_r approx 3.6$ (glass-mixed version), but measured at $epsilon_r approx 2.5 - 2.8$ for 100% density.
- *Simulations:* Performed using ANSYS HFSS, modeling $epsilon_r$ vs. frequency for various cube sizes.

=== Experimental Findings
- *Test Case 1 (Lattice Blocks):* Achieved a span in measured $epsilon_r$ from 1.25 to 2.45.
- *Test Case 2 (Flat Lens):* Demonstrated a frequency-independent gain increase of approximately 3 dB over the 8-18 GHz range.
- Loss Characteristics: Measurements with the lens at the antenna aperture showed very little loss, confirming the efficiency of the metamaterial approach.
- 3D printing
  - Authors mentioned repeated failures when trying to use standard SLA 3D printeing  to use normal SLA 3D printing and were forces to rely on SLS.
  - Even in SLS they had to use higher minimum thicnkess of 0.7~mm then desired.
- It's vital to measure permitvity of the material that has been manufactured using the same process as the final lens.
  - Measured permitivty will be smaller than that of material itself.
  - Note: authors haven't borthered with it but probably the measured strucutres should have same form as those used in the final lens.
- Authors reported significant problems in simulating the structure using ANSYS HFSS.



== Design of a metamaterial Luneburg lens antenna (CEI 2022)
- *Authors:* Jiaxuan Yue, Shunlian Chai, Chengmian Zhou, Ke Xiao
- *Source:* 2022 2nd International Conference on Computer Science, Electronic Information Engineering and Intelligent Control Technology (CEI)
- *Research Context:* Demonstration of a 50~mm in radius Luneburg lense created using SLA pritning, achived an improvement in gain of 7.41~dB
- *Filename:* Design_of_a_metamaterial_Luneburg_lens_antenna_based_on_3D_printing_technology.pdf
- *Link:* #link("https://ieeexplore.ieee.org/document/9950224")[www.ieeexplore.ieee.org]

=== Methodology & Construction
- *Unit Cell Design:* Each unit consists of a variable-sized dielectric cube in the center with three connecting rods (0.8 mm fixed width) parallel to the X, Y, and Z axes.
  - Unit period of 5 mm was chosen to be significantly smaller than the center wavelength of the X-band (10~GHz).
  - Lens was fed from a standard WR-90 wageguide (Just open port without any antenna,).
- *Parameter Retrieval:* Used the S-parameter retrieve method proposed by D. R. Smith (2005) to extract equivalent permittivity.
- *Manufacturing:* Produced a 50 mm radius lens using Stereo Lithography Apparatus (SLA) with C-UV 9400E photosensitive resin ($epsilon_r approx 3.2-4.0$).

=== Experimental Findings
- *Gain Improvement:* The antenna gain at 10 GHz was 14.98 dB, a 7.41 dB increase compared to a single waveguide feed.
- *Calculation of parmaters:* Authors mention a method of calculating permitivity of theses period strucutres
  - First S pamaraters of individual cube are aquired using  EM field simulator.
  - Then using formula
    $
    n &= plus.minus 1 / (k d) { arccos [ (1 - S_11^2 + S_21^2) / (2 S_21) ] + 2 pi m } \
    z &= plus.minus sqrt( ((1 + S_11)^2 - S_21^2) / ((1 - S_11)^2 - S_21^2) ) \
    epsilon &= n / z
    $
    - Formula described in: D. R. Smith, D. C. Vier, T. Koschny, and C. M. Soukoulis, "Electromagnetic parameter retrieval from inhomogeneous metamaterials," Phys. Rev. E., vol. 71, no. 3, p. 036617, 03/22/ 2005
    - No problems in regards to simulations or manufacturing using SLA were mentioned in the study
- *Beamwidth:* Main lobe width narrowed from $28.26#sym.degree$ at 8 GHz to $18.84#sym.degree$ at 12 GHz.
- *Scanning Capability:* The lens rotated $45#sym.degree$ with basically unchanged pattern and gain, proving "good spatial dynamic scanning ability".

#pagebreak()
= Manufacturing Observations
- The effective relative permittivity ($epsilon_r$) depends on the material density in a systematic and predictable way, provided the resolution is significantly higher than the wavelength.
- *Note:* need to figure out how to design these strucutres - using starndard slicers will not cut it, there cannot be any support and we cannot realy on classic infill algorithms - whole structure needs to be described in STL file. Unless some STL supports some "density" paramter that the slicers would be able to understandard.

== SLA (Stereolithography)
- *Contradictory Results:* FFI found SLA resolution "disappointing" for fine grids, whereas CEI 2022 successfully used it for a 50mm sphere

== SLS (Selective Laser Sintering)
- *Efficiency:* Required for high-quality grids in the FFI study, allowing for one-print production of complex objects.
- *Note:* Expensive to use, would need to verify if even is avaialbe in NTUST

== Manufacturing Pitfalls
- *Density Achievement:* Printing often fails to reach 100% density, shifting measured $epsilon_r$ lower than theoretical values.
- *Maintenance:* Removing excess powder from the internal grid of larger objects is a significant logistical hurdle.

== FMD with multiple printheads
- Haven't found a study that uses it
- *Note:* NTUST has a whole reseach group dedicated to this

#pagebreak()
= Construction Types

== Luneburg Lenses
- *Mechanism:* Spherial structure with decreasing refractive index with higher distance from the center.
- *Design Rule:* Theoretically follows
$
n(r)^2 = epsilon_r(r) = 2-(r/R)^2,
$

where $n$ is the refraction index, $epsilon_r$ the permitivity, and $R$ is the total radius of lense.
- Using normal manufacturing methods creating of Luneburg Lenses is exceedingly difficult.
- Strucure is creating using an uniform latice with cubes being placed in intersection points, with increasing dimensions of cubes permitivity increases.
- *Mentioned in:*
  - 3D printed metamaterial lenses for microwave antennas (FFI 2017)
  - Design of a metamaterial Luneburg lens antenna (CEI 2022)

== GRIN (Gradient Index) Lenses
- *Mechanism:* Flat structures with radial permittivity gradients expressed as
$
n(r)^2 = epsilon_r(r) = (n_0 - (sqrt(L^2+r^2)-L)/t)^2,
$
where $n$ is the refraction index, $epsilon_r$ the permitivitym, $n_0$ refactive index at 100~% infill, $r$ distance from center, $L$ the local distance, and $t$the lens thickness.
- *Note:* Really easy construction, definitely compatible with FDM process, might be usefull as a starting point.
- *Mentioned in:*
  - 3D printed metamaterial lenses for microwave antennas (FFI 2017)

== Phase-Screens
- *Function:* Phase-Switched Screens (PSS) used for radar signature control and interference mitigation (e.g., wind turbine blades).
- surface is made up of electronically controllable or passive elemtns, that enable deflection in specific direction or absrob the energy
- *Mentioned in:*
  - passsing menition: 3D printed metamaterial lenses for microwave antennas (FFI 2017)
  - concept demonsration:  B. Chambers, A. Tennant: “The phase switched screen”, IEEE Antennas and Propagation Magazine, Vol 46, No 6 (2004)

== Metamaterial based antennas
- *Function:* Enables construction of physically smaller antennas, or achieves beam steering using different mechanism then phase array atennas.
- *Mentioned in:*
  - passsing menition: 3D printed metamaterial lenses for microwave antennas (FFI 2017)
  - Y. Dong, T. Itoh: "Metamaterial-based antennas", Proceedings of the IEEE, Vol 100, No 7, (July 2012)


== Perfectly matched Layer Radome
- *Function:* Creation of close to ideal radome, that doesn't refract EM waves, regardless of the incidence angle
- *Mentioned in:*
  - passsing menition: 3D printed metamaterial lenses for microwave antennas (FFI 2017)
  - Schultz et al.: “Radome compenzaton usingmatched negative index or refraction materials” US patent no 6,788,273 B1, (September 2004)
  - N Michishita, Y. Yamada: “Metamaterial radome composed of negative refractive index lens for mobile base station antennas”, Presented at IEEE ATC’14, (2014)

