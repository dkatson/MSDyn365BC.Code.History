PermissionSet 1433 "Satisfaction Survey - View"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Satisfaction Survey - Read",
                             "Upgrade Tags - View";

    Permissions = tabledata "Add-in" = i,
                  tabledata "Net Promoter Score" = imd,
                  tabledata "Net Promoter Score Setup" = imd;
}
