page 385 "Report Selection - Bank Acc."
{
    ApplicationArea = Basic, Suite;
    Caption = 'Report Selection - Bank Account';
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Report Selections";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            field(ReportUsage2; ReportUsage2)
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Usage';
                ToolTip = 'Specifies which type of document the report is used for.';

                trigger OnValidate()
                begin
                    SetUsageFilter(true);
                end;
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field(Sequence; Rec.Sequence)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a number that indicates where this report is in the printing order.';
                }
                field("Report ID"; Rec."Report ID")
                {
                    ApplicationArea = Basic, Suite;
                    LookupPageID = Objects;
                    ToolTip = 'Specifies the object ID of the report.';
                }
                field("Report Caption"; Rec."Report Caption")
                {
                    ApplicationArea = Basic, Suite;
                    DrillDown = false;
                    ToolTip = 'Specifies the display name of the report.';
                }
                field(Default; Rec.Default)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if the report ID is the default for the report selection.';
                }
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.NewRecord();
    end;

    trigger OnOpenPage()
    begin
        SetUsageFilter(false);
    end;

    var
        ReportUsage2: Enum "Report Selection Usage Bank";

    local procedure SetUsageFilter(ModifyRec: Boolean)
    begin
        if ModifyRec then
            if Rec.Modify() then;
        Rec.FilterGroup(2);
        case ReportUsage2 of
            "Report Selection Usage Bank"::Statement:
                Rec.SetRange(Usage, "Report Selection Usage"::"B.Stmt");
            "Report Selection Usage Bank"::"Reconciliation - Test":
                Rec.SetRange(Usage, "Report Selection Usage"::"B.Recon.Test");
            "Report Selection Usage Bank"::"Posted Payment Reconciliation":
                SetRange(Usage, Usage::"Posted Payment Reconciliation");
            "Report Selection Usage Bank"::Check:
                Rec.SetRange(Usage, "Report Selection Usage"::"B.Check");
            "Report Selection Usage Bank"::"Unposted Cash Ingoing Order":
                Rec.SetRange(Usage, "Report Selection Usage"::UCI);
            "Report Selection Usage Bank"::"Unposted Cash Outgoing Order":
                Rec.SetRange(Usage, "Report Selection Usage"::UCO);
            "Report Selection Usage Bank"::"Cash Book":
                Rec.SetRange(Usage, "Report Selection Usage"::CB);
            "Report Selection Usage Bank"::"Cash Ingoing Order":
                Rec.SetRange(Usage, "Report Selection Usage"::CI);
            "Report Selection Usage Bank"::"Cash Outgoing Order":
                Rec.SetRange(Usage, "Report Selection Usage"::CO);
        end;
        OnSetUsageFilterOnAfterSetFiltersByReportUsage(Rec, ReportUsage2);
        Rec.FilterGroup(0);
        CurrPage.Update();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnSetUsageFilterOnAfterSetFiltersByReportUsage(var Rec: Record "Report Selections"; ReportUsage2: Enum "Report Selection Usage Bank")
    begin
    end;
}

