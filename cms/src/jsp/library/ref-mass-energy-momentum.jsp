<strong>Energy, Mass and Momentum in High-Energy Physics</strong>
<p>
The centerpiece of the relations among energy, momentum and mass is the following equation:<br />
<img src="../graphics/Energy-momentum-fig1.gif" alt="Energy Momentum"><br />
In particle physics, the speed of light, c, is often set as equal to 1 (in speed of light units), so that in those units the equation simplifies to 
<strong>E&#8743;2 = p&#8743;2 + m&#8743;2</strong>. (Note that the "&#8743;" symbol indicates that the term to its left is raised to the power of the term to its right, 
so that "E&#8743;2" is read as "E squared.") This simple equation reveals much.<br /><br />
To begin with, the equation reveals <strong>the practical equivalency in high-energy contexts of energy and momentum</strong>. As particles gain velocity, 
their momentum (p = &#947;mv) increases with the velocity term both on account of v in itself and its contribution to gamma (&#947;), whereas the mass term remains the same. 
(Verify for yourself that p increases with v in two ways. Which way matters more at velocities far from c? Near to c?) In the E&#8743;2 = p&#8743;2 + m&#8743;2 equation, the mass 
term goes to zero, then, as v approaches c, and E&#8743;2 becomes = p&#8743;2, and thus E = p in magnitude. (Recall that p is a vector, having both a magnitude and a direction, 
whereas E is a scalar, with simply a magnitude.)<br /><br />
This high-energy functional equivalency between energy and momentum allows energy to be calculated from tracker data. Once a particle's rest mass is determined 
from its identity (which follows, for example, for muons by their having been detected in the muon chamber coupled with other supporting data), the particle's 
velocity and thus its momentum can be calculated from the rate of change of its curvature in the magnetic field. Thus, while there is no muon calorimeter for CMS, 
muon energy can be calculated from tracker data. In the case of muon tracker, both momentum and rest mass can be used in the energy calculation, since the rest mass 
of the muon, or any known particle, follows whenever the particle's type can be identified, and with muons this is relatively easy. (They are the only particles to be 
detected in the muon chamber.) But for high-energy muons, the principle holds: energy can be calculated directly from momentum when rest mass is negligible. 
(This principle is useful for the inner tracker as well: neutral particles leave no tracks there, but their energy values in the calorimeter, coupled with the 
location of those energy deposits, suffice to calculate momentum and transverse momentum particularly.)<br /><br />
This same equation helps us see how <strong>the rest mass of a parent particle can be deduced from the energy and momenta of its offspring</strong>.<br /><br />
Given again our same equation, E&#8743;2 = p&#8743;2 + m&#8743;2, consider what happens when p = 0, which is the case for a particle at rest. When p is zero, E&#8743;2 = m&#8743;2, or E = m. 
One application of this equivalency we have already seen: for the Z created at rest at the LEP, we infer (by conservation of energy) the total energy of the daughter 
particles-the dimuon mass, in the case where Z decays to a muon/antimuon pair-to be the same as the rest mass of the parent particle. This equivalency is a reflection 
of conservation of energy; that conservation rule is expressed as the equality E = m in this case of a particle that decays at rest. We saw such a case when we 
considered Z production and decay at the LEP, which was tuned precisely to produce Z bosons at rest: with p = 0.<br /><br />
But at the LHC, neither Zs nor typically any particles are produced at rest. This motion (kinetic energy) of the parent particle is imparted to its decay products 
(as implied by conservation of energy), and thus the total energy of the decay products is no longer equivalent to the rest mass of the parent particle, making 
determination of the mass of the short-lived particle more complicated.<br /><br />
One way to address this complication is perform a mathematical transformation (called a Lorenz transformation) to consider the motion of the particles not from 
the perspective of the detector at rest (called the "lab frame"), but from the perspective of the parent particle at rest (from whose "perspective" the detector is in motion!). 
This transformation is easy enough to envision, but the mathematical transformation is a bit complicated. Happily, we do not need to perform it.<br /><br />
<strong>The E&#8743;2 - p&#8743;2 = m&#8743;2 formulation reveals an easier way to calculate the rest mass of a parent particle</strong>. Another way to consider the parent particle 
at rest is just to remove the component of its energy due to its motion, a component which is related to its momentum, p. Subtracting p&#8743;2 from E&#8743;2 yields the particle's 
rest mass without the need of the mathematical formalism of the Lorenz transformation. As we'll see below, it turns out that for muons, momentum data provides us with 
both terms in this equation, p&#8743;2 and E&#8743;2.<br /><br />
(Going Further: Because the rest mass is the same from every frame of reference, it is sometimes called the invariant mass. If you read about mass increasing with energy 
due to relativistic effects, you are reading about the relativistic mass, M, which is equivalent to &#947;m; this does increase with velocity and is thus relative to frame of 
reference. (Why?) Also, you've heard the expression E = mc&#8743;2; this is true for E0, the energy in the special case where the particle is at rest. (A similar equation is 
true for all cases, E = &#947;mc&#8743;2; in the case of a particle at rest, &#947; = 1, so E = mc&#8743;2.)<br /><br />
When any particle decays into two muons, the momentum for each muon is calculated from tracker data as described earlier.<br />
<img src="../graphics/MomentumVectorSum.png" alt=""><br />
These momenta are vectors (called A and B) which can be added; the resultant vector (A + B) has a magnitude which is the momentum of the whole system. 
(Going further: what does conservation of momentum imply about the relationship between that total momentum of the decay product system, and the momentum of the parent 
before it decayed?) To obtain E, the energy of each muon can be interpreted as its momentum, since its mass is negligible: E = p. The energy of the two muons are now added 
(as scalars, since energy is not a vector.) As you can see from the diagram, the sum of the magnitudes of each vector is greater than the magnitude of the resultant vector, 
as the sum of the lengths of any two sides of a triangle is always greater than the third side. Thus, an energy is calculated for the whole system which is greater than the 
magnitude of the momentum of the whole system. The difference between the squares of the energy and of the momentum is thus equivalent to the square of the invariant mass 
(E&#8743;2 - p&#8743;2 = m&#8743;2).<br /><br />
Once the energy due to momentum has been subtracted in this way, we are in effect looking at the dimuon system from the rest frame of the parent particle. 
<strong>From the rest frame of the parent particle, the total energy of the dimuon system</strong> (reported loosely, since E = m, as <strong>the dimuon mass</strong>), E, 
<strong>is equal to m, the rest mass of the parent particle</strong>.<br /><br />
<img src="../graphics/Vectors.png" alt="Vectors"><br /><br />
<strong>Energy, Mass and Momentum at CMS</strong><br /><br />
<strong>How we can't use conservation of momentum and energy at CMS</strong><br /><br />
Now that we have considered energy, mass and momentum in high-energy physics generally, let us notice how they apply particularly at CMS. CMS is a general purpose detector 
for the LHC, a proton-proton collider. Because the energies involved at the LHC are sufficient in a direct collision to overcome the electromagnetic repulsion and more 
significantly the strong force attraction of these particles, it is the quarks and gluons (partons) that are interacting in the highest-energy collisions. Since the 
portion of the energy of the proton present in any parton is unknown, the initial energies and momenta of primary collisions are not precisely known in advance. 
(In this respect the LHC as well as its proton-antiproton predecessor-the Tevatron at Fermilab-are unlike the LEP, which collided fundamental particles-electrons and 
positrons-at collision energies known and in fact carefully tuned in advance.) <strong>So we cannot use conservation of momentum and energy to determine the momentum and energy of 
the final states from precisely known initial values</strong>.<br /><br />
<strong>How we do use conservation of momentum and energy at CMS</strong><br /><br />
Happily, what is known at the LHC is that in the primary collisions particles are carefully steered along the z axis (the beam line), and thus have very small components 
of <strong>transverse momentum (Pt:</strong> momentum that is radial, or orthogonal, at right angles, to the beam line). So initial transverse momentum for primary collisions is treated 
as zero. Transverse momentum for secondary collisions can be calculated from tracker, calorimeter and timing data. <strong>Any difference between zero and the sum of all calculated 
Pt is thus "missing" transverse momentum</strong>. But since at high energies E = p, <strong>that difference from zero of the sum of all transverse momenta is known in HEP as missing energy, 
or missing Et (mEt)</strong>. This missing Et, when coupled with other telltale signs of neutrino production such as the production of a single lepton, can provide indirect evidence 
for neutrinos, which are not directly detected at CMS.) Once neutrino identification is added to the full set of identifications for particles directly detected at CMS, 
coherent event reconstruction under the Standard Model becomes possible, since now all collision products are accounted for (in the absence of new physics). So while all 
momentum is conserved in collisions at the LHC, it is transverse momentum whose initial value is known, and whose conservation is relied upon in calculations done with 
CMS data.<br />
<img src="../graphics/MEt.png" alt=""> 
</p>