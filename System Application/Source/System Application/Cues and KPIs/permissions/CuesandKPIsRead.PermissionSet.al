PermissionSet 9701 "Cues and KPIs - Read"
{
    Access = Internal;
    Assignable = false;

    IncludedPermissionSets = "Field Selection - Read",
                             "User Selection - Read";

    Permissions = tabledata "Cue Setup" = r,
                  tabledata Field = r;
}
