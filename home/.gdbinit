python
import sys
sys.path.insert(0, '/home/fede/bin/pyprinters')
from libstdcxx.v6.printers import register_libstdcxx_printers
register_libstdcxx_printers (None)
sys.path.insert(0, '/home/fede/bin/gdbeigen')
from printers import register_eigen_printers
register_eigen_printers (None)
end

set print pretty on
set print object on
set print static-members on
set print vtbl on
set print sevenbit-strings off
set print thread-events on
set print type methods on
set print type typedefs on
set print null-stop on
