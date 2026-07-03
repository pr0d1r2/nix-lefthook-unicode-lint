#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"
}

@test ".envrc uses flake" {
    run grep -F 'use flake' .envrc
    assert_success
}

@test ".envrc watches flake.nix for changes" {
    run grep -F 'watch_file flake.nix' .envrc
    assert_success
}

@test ".envrc watches dev.sh for changes" {
    run grep -F 'watch_file dev.sh' .envrc
    assert_success
}
