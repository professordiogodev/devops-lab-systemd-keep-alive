# Submission

Fork URL: <!-- paste the URL of your fork here -->

## Files to commit

- [ ] `clipstr.service`: your unit file, committed to the repo

## Questions

Answer in your own words. Where a question asks for output, paste it in a code block.

### Q1. In Part 1, what supervised the app (what did `systemctl status` say), and why did that make it fragile? What exactly happened to it when you ran `chaos.sh reboot`?

**Your answer:**

<!-- replace this line with your answer -->

### Q2. Paste the journal lines showing systemd noticing your `kill -9` and restarting Clipstr (`Main process exited`, `Scheduled restart job`, `Started`).

**Your answer:**

<!-- replace this line with your answer -->

### Q3. You killed Clipstr with `kill -9` and with `kill -TERM`. Which one did `Restart=on-failure` bring back, and why? When would you choose `Restart=always` instead?

**Your answer:**

<!-- replace this line with your answer -->

### Q4. With the broken `ExecStart`, which line in `systemctl status` or `journalctl` told you the real cause? Copy it and explain it.

**Your answer:**

<!-- replace this line with your answer -->

### Q5. Paste the last line of `systemd-analyze security clipstr` before and after hardening. Name three directives you added and what each one prevents.

**Your answer:**

<!-- replace this line with your answer -->

### Q6. Paste the output of `sudo ./verify.sh`. It must end with **ALL CHECKS PASSED**.

**Your answer:**

<!-- replace this line with your answer -->
