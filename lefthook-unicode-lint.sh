# shellcheck shell=bash
# Lefthook-compatible Unicode lint checker.
# Detects invalid UTF-8 byte sequences and U+FFFD replacement characters.
# Uses 3 independent methods with 2-out-of-3 consensus.
# Usage: lefthook-unicode-lint file1 [file2 ...]
# Skips binary files automatically.
# NOTE: sourced by writeShellApplication — no shebang or set needed.

if [ $# -eq 0 ]; then
    exit 0
fi

failed=0
for f in "$@"; do
    [ -f "$f" ] || continue

    if LC_ALL=C grep -Plq '\x00' "$f" 2>/dev/null; then
        continue
    fi

    votes=0

    if ! iconv -f UTF-8 -t UTF-8 "$f" >/dev/null 2>&1; then
        votes=$((votes + 1))
    fi

    if command -v python3 >/dev/null 2>&1; then
        if ! python3 -c "open('$f','rb').read().decode('utf-8')" 2>/dev/null; then
            votes=$((votes + 1))
        fi
    fi

    if command -v perl >/dev/null 2>&1; then
        if ! perl -e 'use Encode; local $/; open my $fh, "<:raw", $ARGV[0] or die; my $d = <$fh>; decode("UTF-8", $d, Encode::FB_CROAK)' "$f" 2>/dev/null; then
            votes=$((votes + 1))
        fi
    fi

    if [ "$votes" -ge 2 ]; then
        echo "unicode-lint: $f: contains invalid UTF-8 byte sequences ($votes/3 methods agree)" >&2
        failed=1
        continue
    fi

    if LC_ALL=C grep -Pn '\xef\xbf\xbd' "$f" >/dev/null 2>&1; then
        echo "unicode-lint: $f: contains U+FFFD replacement character(s):" >&2
        LC_ALL=C grep -Pn '\xef\xbf\xbd' "$f" >&2
        failed=1
    fi
done

exit "$failed"
