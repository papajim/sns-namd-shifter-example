Shifter Example Using NAMD
===========================

Usage
-----
1. Get NERSC grid proxy using:

    $ myproxy-logon -s nerscca.nersc.gov:7512 -t 72 -T -l YOUR_NERSC_USERNAME

   If you have enabled NERSC's MFA use your PASSWORD+OTP to authenticate yourself.
   The above command will retrieve a grid certificate that's valid for 72 hours.

2. Edit sites.xml:
   * Set the path to your scratch directory
   * Set the path to your output directory
   * Set the project number
    
3. Run daxgen.py to generate the workflow dax (e.g. test.dax):

    $ python daxgen.py test.dax

4. Run plan\_dax.sh to plan the workflow:

    $ ./plan_dax.sh test.dax

5. Follow output of plan.sh to submit workflow

    $ pegasus-run submit/.../run0001

6. Monitor the workflow:

    $ pegasus-status -l submit/.../run0001

