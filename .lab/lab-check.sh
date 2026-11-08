#!/usr/bin/env bash
rc=0
if [ -f clipstr.service ] && grep -q '^ExecStart=' clipstr.service && grep -qE '^Restart=(on-failure|always)' clipstr.service; then
  echo "- ✅ clipstr.service has ExecStart and a Restart policy"
else echo "- ❌ clipstr.service is missing, or lacks ExecStart / Restart=on-failure|always"; rc=1; fi
if [ -f clipstr.service ] && grep -q '^User=clipstr' clipstr.service; then echo "- ✅ the service runs as User=clipstr"
else echo "- ❌ clipstr.service must run as User=clipstr"; rc=1; fi
if [ -f evidence/verify.txt ] && grep -q 'ALL CHECKS PASSED' evidence/verify.txt; then echo "- ✅ evidence/verify.txt shows ALL CHECKS PASSED"
else echo "- ❌ evidence/verify.txt must contain 'ALL CHECKS PASSED' (sudo ./verify.sh | tee evidence/verify.txt)"; rc=1; fi
if [ -f evidence/journal.txt ] && grep -q 'status=9/KILL' evidence/journal.txt; then echo "- ✅ evidence/journal.txt shows the kill -9 and the restart"
else echo "- ❌ evidence/journal.txt must contain the journal lines with 'status=9/KILL'"; rc=1; fi
if [ -f evidence/security.txt ] && [ "$(grep -c 'Overall exposure level' evidence/security.txt)" -ge 2 ]; then echo "- ✅ evidence/security.txt has a before and an after score"
else echo "- ❌ evidence/security.txt must contain two 'Overall exposure level' lines (before and after)"; rc=1; fi
exit $rc
