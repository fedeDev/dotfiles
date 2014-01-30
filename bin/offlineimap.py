import os, subprocess
def mailpasswd(acct):
  cmd = "pass %s/email" % acct
  pipe = subprocess.Popen(cmd, shell=True, cwd=None, env=None, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
  (output, errout) = pipe.communicate()
  assert not errout
  assert pipe.returncode == 0
  return output.strip()
