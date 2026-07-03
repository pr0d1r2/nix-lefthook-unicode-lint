# SPEC — nix-lefthook-unicode-lint

## §D — Description

Nix-flake-packaged lefthook-compatible Unicode lint checker that detects invalid UTF-8 byte sequences and U+FFFD replacement characters using 2-of-3 consensus (iconv, Python 3, Perl). Skips binary files. Targets Nix dev environments on Linux/macOS (amd64/arm64). Consumed as a lefthook remote or flake input.

## §V — Invariants

1. Exit 0 with no arguments
2. Non-existent files silently skipped
3. Binary files (null bytes) skipped
4. Valid ASCII/UTF-8 files pass
5. U+FFFD replacement characters fail with diagnostic on stderr
6. Invalid UTF-8 fails only with 2-of-3 method consensus
7. One bad file in a batch fails the entire run
8. Flake builds on aarch64-darwin, x86_64-darwin, x86_64-linux, aarch64-linux
9. CI passes on ubuntu-latest and macos-latest
10. Every .sh file has a 1-to-1 .bats test under tests/unit/
11. Lefthook checks in both pre-commit and pre-push
12. Every lefthook action has a timeout
13. No functions in shell scripts; separate scripts instead
14. No embedded shell in Nix files

## §I — Interfaces

**CLI**: `lefthook-unicode-lint [file ...]` — exit 0 pass, exit 1 fail.

**Env vars**: `LEFTHOOK_UNICODE_LINT_TIMEOUT` (default 30s), `BATS_LIB_PATH` (set by Nix).

**Flake outputs**: `packages.<sys>.default` (the wrapper), `devShells.<sys>.{default,ci}`.

**Config**: `lefthook-remote.yml` (consumer remote config with binary exclude glob).

## §T — Tasks

| status | id | goal |
|---|---|---|
| `x` | T1 | Fix python3 injection: `open('$f','rb')` breaks on `'` in names |
| `x` | T2 | Add binary exclude pattern to local lefthook.yml |
| `x` | T3 | Add bats test for special characters in filenames |
| `x` | T4 | Add bats test for invalid UTF-8 consensus path |
| `x` | T5 | Add bats test for empty files |
| `.` | T6 | Add watch_file entries to .envrc for flake.nix/dev.sh |
| `.` | T7 | Add bats test for multi-byte UTF-8 (CJK, emoji) |
| `.` | T8 | Document consensus algorithm degradation in README |

## §B — Bugs / Known Issues

1. **Python3 filename injection** (line 28): `open('$f','rb')` — single quotes in filenames cause a syntax error, producing a false "invalid" vote. Fix: use `sys.argv[1]`.
2. **Silent false negatives**: If python3 and perl are both absent, only iconv votes; consensus threshold (2) can never be reached. The Nix wrapper guarantees deps, but raw script consumers may lack them.
3. **Local/remote exclude mismatch**: lefthook-remote.yml excludes binary extensions; local lefthook.yml does not.
4. **grep -P portability**: PCRE mode requires GNU grep. Nix provides it, but raw script use on stock macOS fails.
