#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"

    TMP="$BATS_TEST_TMPDIR"
}

@test "no args exits 0" {
    run lefthook-unicode-lint
    assert_success
}

@test "non-existent file is skipped" {
    run lefthook-unicode-lint /nonexistent/file.txt
    assert_success
}

@test "clean ASCII file passes" {
    echo "hello world" > "$TMP/clean.txt"
    run lefthook-unicode-lint "$TMP/clean.txt"
    assert_success
}

@test "clean UTF-8 file passes" {
    printf 'héllo wörld\n' > "$TMP/utf8.txt"
    run lefthook-unicode-lint "$TMP/utf8.txt"
    assert_success
}

@test "file with U+FFFD replacement character fails" {
    printf 'hello \xef\xbf\xbd world\n' > "$TMP/fffd.txt"
    run lefthook-unicode-lint "$TMP/fffd.txt"
    assert_failure
    assert_output --partial "U+FFFD"
}

@test "valid UTF-8 box-drawing characters pass" {
    printf '┌──────┐\n│ test │\n└──────┘\n' > "$TMP/box.txt"
    run lefthook-unicode-lint "$TMP/box.txt"
    assert_success
}

@test "binary file is skipped" {
    printf 'hello\x00world' > "$TMP/binary.bin"
    run lefthook-unicode-lint "$TMP/binary.bin"
    assert_success
}

@test "multiple files: one bad fails the run" {
    echo "clean" > "$TMP/good.txt"
    printf 'hello \xef\xbf\xbd world\n' > "$TMP/bad.txt"
    run lefthook-unicode-lint "$TMP/good.txt" "$TMP/bad.txt"
    assert_failure
}
