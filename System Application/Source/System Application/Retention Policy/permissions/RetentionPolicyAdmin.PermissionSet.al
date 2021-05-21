PermissionSet 3902 "Retention Policy - Admin"
{
    Access = Public;
    Assignable = false;

    IncludedPermissionSets = "Retention Policy - View";

    Permissions = tabledata "Retention Period" = IMD,
                  tabledata "Retention Policy Setup" = IMD,
                  tabledata "Retention Policy Setup Line" = IMD;
}
