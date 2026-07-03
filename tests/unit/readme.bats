#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"
}

@test "README documents consensus algorithm" {
    run grep -F '2-of-3' README.md
    assert_success
}

@test "README documents degradation when one method is missing" {
    run grep -F '2-of-2' README.md
    assert_success
}

@test "README documents degradation when two methods are missing" {
    run grep 'false negative' README.md
    assert_success
}

@test "README documents Nix guarantees all three methods" {
    run bash -c "grep -E 'Nix.*(guarantees|ensures|provides)' README.md"
    assert_success
}

@test "README documents iconv method" {
    run grep -F 'iconv' README.md
    assert_success
}

@test "README documents python3 method" {
    run bash -c "grep -iE 'python.?3?' README.md"
    assert_success
}

@test "README documents perl method" {
    run bash -c "grep -iE 'perl' README.md"
    assert_success
}
