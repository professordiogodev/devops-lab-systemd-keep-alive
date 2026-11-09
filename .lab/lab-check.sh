#!/usr/bin/env bash
rc=0
if [ -f clippy.service ] && grep -q '^ExecStart=' clippy.service && grep -qE '^Restart=(on-failure|always)' clippy.service; then echo "- ✅ clippy.service has ExecStart and a Restart policy"
else echo "- ❌ clippy.service is missing, or lacks ExecStart / Restart=on-failure|always"; rc=1; fi
if [ -f clippy.service ] && grep -q '^User=clippy' clippy.service; then echo "- ✅ the service runs as User=clippy"
else echo "- ❌ clippy.service must run as User=clippy"; rc=1; fi
grep -qE '^ALL CHECKS PASSED \(' SUBMISSION.md && echo "- ✅ SUBMISSION.md shows ALL CHECKS PASSED" || { echo "- ❌ paste the verify.sh output ('ALL CHECKS PASSED') into SUBMISSION.md"; rc=1; }
grep -q 'status=9/KILL' SUBMISSION.md && echo "- ✅ SUBMISSION.md has the kill -9 journal lines" || { echo "- ❌ paste the journal lines containing 'status=9/KILL' into SUBMISSION.md"; rc=1; }
[ "$(grep -c 'Overall exposure level' SUBMISSION.md)" -ge 2 ] && echo "- ✅ SUBMISSION.md has a before and an after security score" || { echo "- ❌ paste two 'Overall exposure level' lines (before and after) into SUBMISSION.md"; rc=1; }
exit $rc
