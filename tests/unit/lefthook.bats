#!/usr/bin/env bats

setup() {
    load "${BATS_LIB_PATH}/bats-support/load.bash"
    load "${BATS_LIB_PATH}/bats-assert/load.bash"
}

@test "pre-commit unicode-lint has binary exclude pattern" {
    run bash -c "sed -n '/^pre-commit:/,/^pre-push:/p' lefthook.yml | grep 'exclude:'"
    assert_success
}

@test "pre-push unicode-lint has binary exclude pattern" {
    run bash -c "sed -n '/^pre-push:/,\$p' lefthook.yml | grep 'exclude:'"
    assert_success
}

@test "local exclude pattern matches remote exclude pattern" {
    local_excludes=$(grep 'exclude:' lefthook.yml | sed "s/.*exclude: //" | sort -u)
    remote_excludes=$(grep 'exclude:' lefthook-remote.yml | sed "s/.*exclude: //" | sort -u)
    [ "$local_excludes" = "$remote_excludes" ]
}
