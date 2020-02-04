# TODO: instead of echo command call my psp_workflow, but rewrite to accept directory, not textfile as input

cat run1.txt | parallel "bash if_test_parallel.sh {} "ls
