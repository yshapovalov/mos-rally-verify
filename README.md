MOS-RALLY-VERIFY

Steps:

1. Clone repo to mcp node
2. Run run_tempest.sh

Done


./run_tempest.sh - run all test
./run_tempest.sh "--regex <test>"

<test> example:
tempest.api.identity
tempest.api.identity.admin.test_roles
tempest.api.identity.admin.test_roles.RolesTestJSON
tempest.api.identity.admin.test_roles.RolesTestJSON.test_list_roles

Result:

In /home/rally/vagrant/rally script create two report file:
1. html
2. json(you can convert json to xml and then upload result to testrail)
__________________________________________________________________

