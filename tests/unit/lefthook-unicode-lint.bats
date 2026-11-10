#!/usr/bin/env bats

setup() {
  load "${BATS_LIB_PATH}/bats-support/load.bash"
  load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TMP="$BATS_TEST_TMPDIR"
}

@test "no args" {
    run lefthook-unicode-lint
    assert_success
}

@test "missing file" {
    run lefthook-unicode-lint /nonexistent/file.txt
    assert_success
}

@test "ASCII passes" {
    echo "hello world" > "$TMP/clean.txt"
    run lefthook-unicode-lint "$TMP/clean.txt"
    assert_success
}

@test "UTF-8 passes" {
    printf 'héllo wörld\n' > "$TMP/utf8.txt"
    run lefthook-unicode-lint "$TMP/utf8.txt"
    assert_success
}

@test "U+FFFD fails" {
    printf 'hello \xef\xbf\xbd world\n' > "$TMP/fffd.txt"
    run lefthook-unicode-lint "$TMP/fffd.txt"
    assert_failure
    assert_output --partial "U+FFFD"
}

@test "box drawing passes" {
    printf '┌──────┐\n│ test │\n└──────┘\n' > "$TMP/box.txt"
    run lefthook-unicode-lint "$TMP/box.txt"
    assert_success
}

@test "binary skipped" {
    printf 'hello\x00world' > "$TMP/binary.bin"
    run lefthook-unicode-lint "$TMP/binary.bin"
    assert_success
}

@test "large binary skipped" {
    dd if=/dev/urandom of="$TMP/image.gif" bs=1024 count=100 2>/dev/null
    run lefthook-unicode-lint "$TMP/image.gif"
    assert_success
}

@test "single quote filename" {
    echo "hello world" > "$TMP/it's_fine.txt"
    run lefthook-unicode-lint "$TMP/it's_fine.txt"
    assert_success
}

@test "space filename" {
    echo "hello world" > "$TMP/file name.txt"
    run lefthook-unicode-lint "$TMP/file name.txt"
    assert_success
}

@test "double quote filename" {
    echo "hello world" > "$TMP/file\"name.txt"
    run lefthook-unicode-lint "$TMP/file\"name.txt"
    assert_success
}

@test "dollar filename" {
    echo "hello world" > "$TMP/file\$name.txt"
    run lefthook-unicode-lint "$TMP/file\$name.txt"
    assert_success
}

@test "backtick filename" {
    echo "hello world" > "$TMP/file\`name.txt"
    run lefthook-unicode-lint "$TMP/file\`name.txt"
    assert_success
}

@test "parentheses filename" {
    echo "hello world" > "$TMP/file(name).txt"
    run lefthook-unicode-lint "$TMP/file(name).txt"
    assert_success
}

@test "semicolon filename" {
    echo "hello world" > "$TMP/file;name&here.txt"
    run lefthook-unicode-lint "$TMP/file;name&here.txt"
    assert_success
}

@test "special filename invalid UTF-8" {
    printf '\xff\xfe invalid' > "$TMP/it's a \$pecial file.txt"
    run lefthook-unicode-lint "$TMP/it's a \$pecial file.txt"
    assert_failure
    assert_output --partial "invalid UTF-8"
}

@test "special filename U+FFFD" {
    printf 'hello \xef\xbf\xbd world\n' > "$TMP/file\"with'special.txt"
    run lefthook-unicode-lint "$TMP/file\"with'special.txt"
    assert_failure
    assert_output --partial "U+FFFD"
}

@test "invalid UTF-8 consensus" {
    printf '\xff\xfe invalid' > "$TMP/bad_utf8.txt"
    run lefthook-unicode-lint "$TMP/bad_utf8.txt"
    assert_failure
    assert_output --partial "invalid UTF-8"
}

@test "consensus vote format" {
    printf '\xff\xfe' > "$TMP/v.txt"
    run lefthook-unicode-lint "$TMP/v.txt"
    assert_failure
    assert_output --partial "unicode-lint:"
    assert_output --partial "v.txt"
    assert_output --partial "/3 methods agree"
}

@test "consensus reflects missing methods" {
    printf '\xff\xfe' > "$TMP/degraded.txt"
    lint_path="$(command -v lefthook-unicode-lint)"
    mkdir -p "$TMP/bin"
    ln -s "$(command -v grep)" "$TMP/bin/grep"
    ln -s "$(command -v iconv)" "$TMP/bin/iconv"
    run env PATH="$TMP/bin" "$lint_path" "$TMP/degraded.txt"
    assert_failure
    assert_output --partial "2/2 methods agree"
}

@test "0x80 consensus" {
    printf '\x80\n' > "$TMP/c.txt"
    run lefthook-unicode-lint "$TMP/c.txt"
    assert_failure
    assert_output --partial "/3 methods agree"
}

@test "empty passes" {
    touch "$TMP/empty.txt"
    run lefthook-unicode-lint "$TMP/empty.txt"
    assert_success
}

@test "one bad file fails" {
    echo "clean" > "$TMP/good.txt"
    printf 'hello \xef\xbf\xbd world\n' > "$TMP/bad.txt"
    run lefthook-unicode-lint "$TMP/good.txt" "$TMP/bad.txt"
    assert_failure
}

@test "CJK passes" {
    printf '%s\n' '漢字テスト한국어' > "$TMP/cjk.txt"
    run lefthook-unicode-lint "$TMP/cjk.txt"
    assert_success
}

@test "emoji passes" {
    printf '%s\n' '🎉🚀💯🌍' > "$TMP/emoji.txt"
    run lefthook-unicode-lint "$TMP/emoji.txt"
    assert_success
}

@test "mixed Unicode passes" {
    printf '%s\n' 'Hello 世界 🚀 東京' > "$TMP/mix.txt"
    run lefthook-unicode-lint "$TMP/mix.txt"
    assert_success
}

@test "CJK U+FFFD fails" {
    printf '漢字\xef\xbf\xbd测试\n' > "$TMP/cf.txt"
    run lefthook-unicode-lint "$TMP/cf.txt"
    assert_failure
    assert_output --partial "U+FFFD"
}

@test "emoji invalid UTF-8" {
    printf '🎉\xff\xfe🚀\n' > "$TMP/eb.txt"
    run lefthook-unicode-lint "$TMP/eb.txt"
    assert_failure
    assert_output --partial "invalid UTF-8"
}
