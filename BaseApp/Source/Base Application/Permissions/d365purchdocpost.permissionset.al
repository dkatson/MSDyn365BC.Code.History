permissionset 2909 "D365 PURCH DOC, POST"
{
    Assignable = true;
    Caption = 'Dyn. 365 Post purchase doc.';

    Permissions = tabledata "Approval Workflow Wizard" = RIMD,
                  tabledata "Avg. Cost Adjmt. Entry Point" = RIM,
                  tabledata "Bank Account" = Rm,
                  tabledata "Bank Account Ledger Entry" = rim,
                  tabledata "Batch Processing Parameter" = Rimd,
                  tabledata "Batch Processing Session Map" = Rimd,
                  tabledata "Cancelled Document" = Rimd,
                  tabledata "Check Ledger Entry" = rim,
                  tabledata "Contact Business Relation" = R,
                  tabledata Currency = RM,
                  tabledata "Customer Bank Account" = R,
                  tabledata "Detailed Vendor Ledg. Entry" = Rim,
                  tabledata "Dtld. Price Calculation Setup" = RIMD,
                  tabledata "Duplicate Price Line" = RIMD,
                  tabledata "G/L Entry - VAT Entry Link" = Ri,
                  tabledata "G/L Entry" = Rimd,
                  tabledata "G/L Register" = Rimd,
                  tabledata "General Ledger Setup" = rm,
                  tabledata "Interaction Template" = R,
                  tabledata "Interaction Tmpl. Language" = R,
                  tabledata "Item Charge" = R,
                  tabledata "Item Cross Reference" = R,
                  tabledata "Item Entry Relation" = R,
                  tabledata "Item Ledger Entry" = Rimd,
                  tabledata "Item Reference" = R,
                  tabledata "Item Register" = Rimd,
                  tabledata "Item Tracing Buffer" = Rimd,
                  tabledata "Item Tracing History Buffer" = Rimd,
                  tabledata "Item Tracking Code" = R,
                  tabledata "Job Queue Category" = RIMD,
                  tabledata "Notification Entry" = RIMD,
                  tabledata "Order Address" = RIMD,
                  tabledata "Payment Terms" = RMD,
                  tabledata "Planning Component" = RIm,
                  tabledata "Post Value Entry to G/L" = I,
                  tabledata "Price Asset" = RIMD,
                  tabledata "Price Calculation Buffer" = RIMD,
                  tabledata "Price Calculation Setup" = RIMD,
                  tabledata "Price Line Filters" = RIMD,
                  tabledata "Price List Header" = RIMD,
                  tabledata "Price List Line" = RIMD,
                  tabledata "Price Source" = RIMD,
                  tabledata "Purch. Cr. Memo Hdr." = RimD,
                  tabledata "Purch. Cr. Memo Line" = Rimd,
                  tabledata "Purch. Inv. Header" = RimD,
                  tabledata "Purch. Inv. Line" = Rimd,
                  tabledata "Purch. Rcpt. Header" = RimD,
                  tabledata "Purch. Rcpt. Line" = Rimd,
                  tabledata "Purchase Discount Access" = RIMD,
                  tabledata "Purchase Header" = RIMD,
                  tabledata "Purchase Header Archive" = RIMD,
                  tabledata "Purchase Line" = RIMD,
                  tabledata "Purchase Line Archive" = RIMD,
                  tabledata "Purchase Line Discount" = RIMD,
                  tabledata "Purchase Price" = RIMD,
                  tabledata "Purchase Price Access" = RIMD,
                  tabledata "Record Buffer" = Rimd,
                  tabledata "Requisition Line" = RIMD,
                  tabledata "Restricted Record" = RIMD,
                  tabledata "Return Reason" = R,
                  tabledata "Return Shipment Header" = Rim,
                  tabledata "Return Shipment Line" = Rim,
                  tabledata "Sales Shipment Header" = i,
                  tabledata "Sales Shipment Line" = Ri,
                  tabledata "Ship-to Address" = RIMD,
                  tabledata "Standard General Journal Line" = RIMD,
                  tabledata "Standard Purchase Code" = RIMD,
                  tabledata "Standard Purchase Line" = RIMD,
                  tabledata "Standard Vendor Purchase Code" = RIMD,
                  tabledata "Stockkeeping Unit" = R,
                  tabledata "Time Sheet Chart Setup" = RIMD,
                  tabledata "Time Sheet Comment Line" = RIMD,
                  tabledata "Time Sheet Detail" = RIMD,
                  tabledata "Time Sheet Header" = RIMD,
                  tabledata "Time Sheet Line" = RIMD,
                  tabledata "Time Sheet Posting Entry" = RIMD,
                  tabledata "Tracking Specification" = Rimd,
                  tabledata "Transaction Type" = R,
                  tabledata "Transport Method" = R,
                  tabledata "Unplanned Demand" = RIMD,
                  tabledata "User Task Group" = RIMD,
                  tabledata "User Task Group Member" = RIMD,
                  tabledata "Value Entry Relation" = R,
                  tabledata "VAT Amount Line" = RIMD,
                  tabledata "VAT Entry" = Rimd,
                  tabledata "VAT Rate Change Conversion" = R,
                  tabledata "VAT Rate Change Log Entry" = Ri,
                  tabledata "VAT Rate Change Setup" = R,
                  tabledata "VAT Registration No. Format" = R,
                  tabledata Vendor = RM,
                  tabledata "Vendor Bank Account" = R,
                  tabledata "Vendor Invoice Disc." = R,
                  tabledata "Vendor Ledger Entry" = RiMd,
                  tabledata "Warehouse Request" = RIMD,
                  tabledata "Whse. Item Entry Relation" = R,
                  tabledata "Whse. Put-away Request" = RIMD,
                  tabledata "Workflow - Table Relation" = RIMD,
                  tabledata Workflow = RIMD,
                  tabledata "Workflow Event" = RIMD,
                  tabledata "Workflow Event Queue" = RIMD,
                  tabledata "Workflow Response" = RIMD,
                  tabledata "Workflow Rule" = RIMD,
                  tabledata "Workflow Step" = RIMD,
                  tabledata "Workflow Step Argument" = RIMD,
                  tabledata "Workflow Step Instance" = RIMD,
                  tabledata "Workflow Table Relation Value" = RIMD,
                  tabledata "Workflow User Group" = RIMD,
                  tabledata "Workflow User Group Member" = RIMD;
}
