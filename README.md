MOS-RALLY-VERIFY

Steps:

1. Clone repo to fuel
2. If you neeed fix openrc file(add v2.0) run fix_v2.sh
3. If you have env with rados_gw and ssl run fix_rados_ssl.sh (https://bugs.launchpad.net/fuel/+bug/1549328)
4. Run prepare_env.sh
5. Run install_tempest.sh

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
