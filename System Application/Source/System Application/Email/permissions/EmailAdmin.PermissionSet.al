PermissionSet 8902 "Email - Admin"
{
    Access = Public;
    Assignable = true;
    Caption = 'Email - Admin';

    IncludedPermissionSets = "Email - Edit";

    Permissions = tabledata "Email Scenario" = imd;
}
