MOS-RALLY-VERIFY

Steps:

1. Clone repo to controller
2. Run prepare_env.sh

Done

You can run tempest tests:

. openrc

rally verify start (all tests and scenario) or 
rally verify start --regex <test>

<test> example:
tempest.api.identity
tempest.api.identity.admin.test_roles
tempest.api.identity.admin.test_roles.RolesTestJSON
tempest.api.identity.admin.test_roles.RolesTestJSON.test_list_roles

Result:

rally verify results --html --output-file tempest-report.html
__________________________________________________________________

If you need rejoin to your last docker with rally - run rejoin.sh
If you want delete all dockers and files - run clean.sh

