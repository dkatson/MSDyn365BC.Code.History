permissionset 2066 "Data Exchange - Admin"
{
    Access = Public;
    Assignable = false;
    Caption = 'Data Exchange Setup';

    Permissions = tabledata "Data Exch. Column Def" = RIMD,
                  tabledata "Data Exch. Def" = RIMD,
                  tabledata "Data Exch. Field Mapping" = RIMD,
                  tabledata "Data Exch. Line Def" = RIMD,
                  tabledata "Data Exch. Mapping" = RIMD,
                  tabledata "Doc. Exch. Service Setup" = RIMD,
                  tabledata "Postcode Service Config" = RIMD,
                  tabledata "Referenced XML Schema" = RIMD,
                  tabledata "Transformation Rule" = RIMD,
                  tabledata "XML Buffer" = R,
                  tabledata "XML Schema" = RIMD,
                  tabledata "XML Schema Element" = RIMD,
                  tabledata "XML Schema Restriction" = RIMD;
}
