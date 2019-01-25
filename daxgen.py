#!/usr/bin/env python

import sys
import os
import pwd
import time
from Pegasus.DAX3 import *

# The name of the DAX file is the first argument
if len(sys.argv) != 2:
   sys.stderr.write("Usage: %s DAXFILE\n" % sys.argv[0])
   sys.exit(1)

daxfile = sys.argv[1]
USER = pwd.getpwuid(os.getuid())[0]

dax = ADAG("namd_wf")
dax.metadata("name", "NAMD Example Workflow")
dax.metadata("creator", "%s@%s" % (USER, os.uname()[1]))
dax.metadata("created", time.ctime())

temperatures = ["200", "250"]

structure = File("Q42.psf")
coordinates = File("crd.md18_vmd_autopsf.pdb")
parameters = File("par_all27_prot_lipid.inp")
extended_system = File("init.xsc")

for temperature in temperatures:
    eq_conf = File("equilibrate_%s.conf" % temperature)
    eq_coord = File("equilibrate_%s.restart.coor" % temperature)
    eq_xsc = File("equilibrate_%s.restart.xsc" % temperature)
    eq_vel = File("equilibrate_%s.restart.vel" % temperature)

    prod_conf = File("production_%s.conf" % temperature)
    prod_dcd = File("production_%s.dcd" % temperature)

    eqjob = Job("shifter", node_label="shifter_namd_eq_%s" % temperature)
    eqjob.addArguments("--image=docker:papajim/namd_image:latest", "namd2", "+p 32", eq_conf)
    eqjob.uses(eq_conf, link=Link.INPUT)
    eqjob.uses(structure, link=Link.INPUT)
    eqjob.uses(coordinates, link=Link.INPUT)
    eqjob.uses(parameters, link=Link.INPUT)
    eqjob.uses(extended_system, link=Link.INPUT)
    eqjob.uses(eq_coord, link=Link.OUTPUT, transfer=False, register=False)
    eqjob.uses(eq_xsc, link=Link.OUTPUT, transfer=False, register=False)
    eqjob.uses(eq_vel, link=Link.OUTPUT, transfer=False, register=False)
    eqjob.profile("globus", "maxTime", "20")
    eqjob.profile("pegasus", "exitcode.successmsg", "End of program")
    dax.addJob(eqjob)

    prodjob = Job("shifter", node_label="shifter_namd_prod_%s" % temperature)
    prodjob.addArguments("--image=docker:papajim/namd_image:latest", "namd2", "+p 32", prod_conf)
    prodjob.uses(prod_conf, link=Link.INPUT)
    prodjob.uses(structure, link=Link.INPUT)
    prodjob.uses(coordinates, link=Link.INPUT)
    prodjob.uses(parameters, link=Link.INPUT)
    prodjob.uses(eq_coord, link=Link.INPUT)
    prodjob.uses(eq_xsc, link=Link.INPUT)
    prodjob.uses(eq_vel, link=Link.INPUT)
    prodjob.uses(prod_dcd, link=Link.OUTPUT, transfer=True, register=False)
    prodjob.profile("globus", "maxTime", "20")
    prodjob.profile("pegasus", "exitcode.successmsg", "End of program")
    dax.addJob(prodjob)
    dax.depends(prodjob, eqjob)

f = open(daxfile,"w")
dax.writeXML(f)
f.close()
print "Generated dax %s" % daxfile
