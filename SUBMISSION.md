# Submission

Fork URL: <!-- paste the URL of your fork here -->

## Evidence checklist

- [ ] `evidence/before.txt`: how the app runs today (output of the recon commands in Part 1)
- [ ] `clipstr.service`: your unit file, committed to the repo
- [ ] `evidence/journal.txt`: the journal lines showing systemd noticing the kill and restarting Clipstr
- [ ] `evidence/security.txt`: `systemd-analyze security clipstr` before and after hardening
- [ ] `evidence/verify.txt`: the output of `sudo ./verify.sh` showing **ALL CHECKS PASSED**

## Questions

### Q1. In Part 1, what supervised the app (what did `systemctl status` say), and why did that make it fragile? What exactly happened to it when you ran `chaos.sh reboot`?

**Your answer:**

<!-- replace this line with your answer -->

### Q2. You killed Clipstr with `kill -9` and with `kill -TERM`. Which one did `Restart=on-failure` bring back, and why? When would you choose `Restart=always` instead?

**Your answer:**

<!-- replace this line with your answer -->

### Q3. With the broken `ExecStart`, which line in `systemctl status` or `journalctl` told you the real cause? Copy it and explain it.

**Your answer:**

<!-- replace this line with your answer -->

### Q4. What did `systemd-analyze security` score before and after hardening? Name three directives you added and what each one prevents.

**Your answer:**

<!-- replace this line with your answer -->
