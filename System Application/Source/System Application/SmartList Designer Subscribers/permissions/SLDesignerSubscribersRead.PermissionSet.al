PermissionSet 2888 "SL Designer Subscribers - Read"
{
    Access = Internal;
    Assignable = false;

    Permissions = tabledata "Query Navigation" = r,
                  tabledata "Query Navigation Validation" = R, // Needed because the record is Public
                  tabledata "SmartList Designer Handler" = R;
}
