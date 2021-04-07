page 495 "Currency Card"
{
    Caption = 'Currency Card';
    PageType = Card;
    PromotedActionCategories = 'New,Process,Report,Navigate';
    SourceTable = Currency;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("Code"; Code)
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies a currency code that you can select. The code must comply with ISO 4217.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies a text to describe the currency code.';
                }
                field("ISO Code"; "ISO Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a three-letter currency code defined in ISO 4217.';
                }
                field("ISO Numeric Code"; "ISO Numeric Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies a three-digit code number defined in ISO 4217.';
                }
                field(Symbol; Symbol)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the symbol for this currency that you wish to appear on checks and charts, $ for USD, CAD or MXP for example.';
                }
                field("Unrealized Gains Acc."; "Unrealized Gains Acc.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the general ledger account number to which unrealized exchange rate gains will be posted when the Adjust Exchange Rates batch job is run.';
                }
                field("Realized Gains Acc."; "Realized Gains Acc.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the general ledger account number to which realized exchange rate gains will be posted.';
                }
                field("Unrealized Losses Acc."; "Unrealized Losses Acc.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the general ledger account number to which unrealized exchange rate losses will be posted when the Adjust Exchange Rates batch job is run.';
                }
                field("Realized Losses Acc."; "Realized Losses Acc.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the general ledger account number to which realized exchange rate losses will be posted.';
                }
                field("EMU Currency"; "EMU Currency")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies whether the currency is an EMU currency, for example DEM or EUR.';
                }
                field("Last Date Modified"; "Last Date Modified")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the last date on which any information in the Currency table was modified.';
                }
                field("Last Date Adjusted"; "Last Date Adjusted")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies when the exchange rates were last adjusted, that is, the last date on which the Adjust Exchange Rates batch job was run.';
                }
                field("Payment Tolerance %"; "Payment Tolerance %")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the percentage that the payment or refund is allowed to be, less than the amount on the invoice or credit memo.';
                }
                field("Max. Payment Tolerance Amount"; "Max. Payment Tolerance Amount")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the maximum allowed amount that the payment or refund can differ from the amount on the invoice or credit memo.';
                }
                field("Search Method"; "Search Method")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the search method associated with the currency.';
                }
                field(Import; Import)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies if the currency has an imported exchange rate.';
                }
                field("RU Bank Code"; "RU Bank Code")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the Russian bank code associated with the currency.';
                }
                field("RU Bank Digital Code"; "RU Bank Digital Code")
                {
                    ApplicationArea = Suite;
                }
            }
            group(Rounding)
            {
                Caption = 'Rounding';
                field("Invoice Rounding Precision"; "Invoice Rounding Precision")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the size of the interval to be used when rounding amounts in this currency. You can specify invoice rounding for each currency in the Currency table.';
                }
                field("Invoice Rounding Type"; "Invoice Rounding Type")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies whether an invoice amount will be rounded up or down. The program uses this information together with the interval for rounding that you have specified in the Invoice Rounding Precision field.';
                }
                field("Amount Rounding Precision"; "Amount Rounding Precision")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the size of the interval to be used when rounding amounts in this currency.';
                }
                field("Amount Decimal Places"; "Amount Decimal Places")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the number of decimal places the program will display for amounts in this currency.';
                }
                field("Unit-Amount Rounding Precision"; "Unit-Amount Rounding Precision")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the size of the interval to be used when rounding unit amounts (that is, item prices per unit) in this currency.';
                }
                field("Unit-Amount Decimal Places"; "Unit-Amount Decimal Places")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the number of decimal places the program will display for amounts in this currency.';
                }
                field("Appln. Rounding Precision"; "Appln. Rounding Precision")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the size of the interval that will be allowed as a rounding difference when you apply entries in different currencies to one another.';
                }
                field("Conv. LCY Rndg. Debit Acc."; "Conv. LCY Rndg. Debit Acc.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies conversion information that must also contain a debit account if you wish to insert correction lines for rounding differences in the general journals using the Insert Conv. LCY Rndg. Lines function.';
                }
                field("Conv. LCY Rndg. Credit Acc."; "Conv. LCY Rndg. Credit Acc.")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies conversion information that must also contain a credit account if you wish to insert correction lines for rounding differences in the general journals using the Insert Conv. LCY Rndg. Lines function.';
                }
                field("Max. VAT Difference Allowed"; "Max. VAT Difference Allowed")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the maximum VAT correction amount allowed for the currency.';
                }
                field("VAT Rounding Type"; "VAT Rounding Type")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies how the program will round VAT when calculated for this currency.';
                }
            }
            group(Reporting)
            {
                Caption = 'Reporting';
                field("Realized G/L Gains Account"; "Realized G/L Gains Account")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the general ledger account to post exchange rate gains to, for currency adjustments between LCY and the additional reporting currency.';
                }
                field("Realized G/L Losses Account"; "Realized G/L Losses Account")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the general ledger account to post exchange rate losses to, for currency adjustments between LCY and the additional reporting currency.';
                }
                field("Residual Gains Account"; "Residual Gains Account")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the general ledger account to post residual amounts to that are gains, if you post in the general ledger application area in both LCY and an additional reporting currency.';
                }
                field("Residual Losses Account"; "Residual Losses Account")
                {
                    ApplicationArea = Suite;
                    Importance = Promoted;
                    ToolTip = 'Specifies the general ledger account to post residual amounts to that are gains, if you post in the general ledger application area in both LCY and an additional reporting currency.';
                }
            }
            group("Amount Difference")
            {
                Caption = 'Amount Difference';
                field(Conventional; Conventional)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies if you do not want to use the currency during the adjust exchange rates procedure.';
                }
            }
            group("In Words")
            {
                Caption = 'In Words';
                field("Unit Kind"; "Unit Kind")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the kind of unit associated with the currency.';
                }
                field("Unit Name 1"; "Unit Name 1")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the spelling for one unit of currency.';
                }
                field("Unit Name 2"; "Unit Name 2")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the spelling for two or more units of currency.';
                }
                field("Unit Name 5"; "Unit Name 5")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the spelling for five or more units of currency.';
                }
                field("Invoice Comment"; "Invoice Comment")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies an invoice comment that will be displayed in a report.';
                }
                field("Hundred Kind"; "Hundred Kind")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the kind of one one-hundredth unit of currency.';
                }
                field("Hundred Name 1"; "Hundred Name 1")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the spelling for one one-hundredth unit of currency.';
                }
                field("Hundred Name 2"; "Hundred Name 2")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the kind of two one-hundredths unit of currency.';
                }
                field("Hundred Name 5"; "Hundred Name 5")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the kind of five one-hundredths unit of currency.';
                }
            }
            group(Prepayment)
            {
                Caption = 'Prepayment';
                field("Sales PD Gains Acc. (TA)"; "Sales PD Gains Acc. (TA)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the sales prepayment document gains account for tax accounting associated with the currency.';
                }
                field("Sales PD Losses Acc. (TA)"; "Sales PD Losses Acc. (TA)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the sales prepayment document losses account for tax accounting associated with the currency.';
                }
                field("Purch. PD Gains Acc. (TA)"; "Purch. PD Gains Acc. (TA)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the purchase prepayment document gains account for tax accounting associated with the currency.';
                }
                field("Purch. PD Losses Acc. (TA)"; "Purch. PD Losses Acc. (TA)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the purchase prepayment document losses account for tax accounting associated with the currency.';
                }
                field("PD Bal. Gain/Loss Acc. (TA)"; "PD Bal. Gain/Loss Acc. (TA)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the prepayment document balance gains or losses account for tax accounting associated with the currency.';
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
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action("Change Payment &Tolerance")
                {
                    ApplicationArea = Suite;
                    Caption = 'Change Payment &Tolerance';
                    Image = ChangePaymentTolerance;
                    Promoted = true;
                    PromotedCategory = Process;
                    ToolTip = 'Change either or both the maximum payment tolerance and the payment tolerance percentage and filters by currency.';

                    trigger OnAction()
                    var
                        ChangePmtTol: Report "Change Payment Tolerance";
                    begin
                        ChangePmtTol.SetCurrency(Rec);
                        ChangePmtTol.RunModal;
                    end;
                }
            }
            action("Exch. &Rates")
            {
                ApplicationArea = Suite;
                Caption = 'Exch. &Rates';
                Image = CurrencyExchangeRates;
                Promoted = true;
                PromotedCategory = Category4;
                RunObject = Page "Currency Exchange Rates";
                RunPageLink = "Currency Code" = FIELD(Code);
                ToolTip = 'View updated exchange rates for the currencies that you use.';
            }
        }
        area(reporting)
        {
            action("Foreign Currency Balance")
            {
                ApplicationArea = Suite;
                Caption = 'Foreign Currency Balance';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Foreign Currency Balance";
                ToolTip = 'View the balances for all customers and vendors in both foreign currencies and in local currency (LCY). The report displays two LCY balances. One is the foreign currency balance converted to LCY by using the exchange rate at the time of the transaction. The other is the foreign currency balance converted to LCY by using the exchange rate of the work date.';
            }
            action("Aged Accounts Receivable")
            {
                ApplicationArea = Suite;
                Caption = 'Aged Accounts Receivable';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Aged Accounts Receivable";
                ToolTip = 'View an overview of when customer payments are due or overdue, divided into four periods. You must specify the date you want aging calculated from and the length of the period that each column will contain data for.';
            }
            action("Aged Accounts Payable")
            {
                ApplicationArea = Suite;
                Caption = 'Aged Accounts Payable';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Aged Accounts Payable";
                ToolTip = 'View an overview of when your payables to vendors are due or overdue (divided into four periods). You must specify the date you want aging calculated from and the length of the period that each column will contain data for.';
            }
            action("Trial Balance")
            {
                ApplicationArea = Suite;
                Caption = 'Trial Balance';
                Image = "Report";
                Promoted = true;
                PromotedCategory = "Report";
                RunObject = Report "Trial Balance";
                ToolTip = 'View a detailed trial balance for selected currency.';
            }
        }
        area(navigation)
        {
            group(ActionGroupCRM)
            {
                Caption = 'Dataverse';
                Image = Administration;
                Visible = CRMIntegrationEnabled or CDSIntegrationEnabled;
                action(CRMGotoTransactionCurrency)
                {
                    ApplicationArea = Suite;
                    Caption = 'Transaction Currency';
                    Image = CoupledCurrency;
                    ToolTip = 'Open the coupled Dataverse transaction currency.';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.ShowCRMEntityFromRecordID(RecordId);
                    end;
                }
                action(CRMSynchronizeNow)
                {
                    AccessByPermission = TableData "CRM Integration Record" = IM;
                    ApplicationArea = Suite;
                    Caption = 'Synchronize';
                    Image = Refresh;
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = Process;
                    ToolTip = 'Send updated data to Dataverse.';

                    trigger OnAction()
                    var
                        Currency: Record Currency;
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                        CurrencyRecordRef: RecordRef;
                    begin
                        CurrPage.SetSelectionFilter(Currency);
                        Currency.Next;

                        if Currency.Count = 1 then
                            CRMIntegrationManagement.UpdateOneNow(Currency.RecordId)
                        else begin
                            CurrencyRecordRef.GetTable(Currency);
                            CRMIntegrationManagement.UpdateMultipleNow(CurrencyRecordRef);
                        end
                    end;
                }
                group(Coupling)
                {
                    Caption = 'Coupling', Comment = 'Coupling is a noun';
                    Image = LinkAccount;
                    ToolTip = 'Create, change, or delete a coupling between the Business Central record and a Dataverse record.';
                    action(ManageCRMCoupling)
                    {
                        AccessByPermission = TableData "CRM Integration Record" = IM;
                        ApplicationArea = Suite;
                        Caption = 'Set Up Coupling';
                        Image = LinkAccount;
                        //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedCategory = Process;
                        ToolTip = 'Create or modify the coupling to a Dataverse Transaction Currency.';

                        trigger OnAction()
                        var
                            CRMIntegrationManagement: Codeunit "CRM Integration Management";
                        begin
                            CRMIntegrationManagement.DefineCoupling(RecordId);
                        end;
                    }
                    action(DeleteCRMCoupling)
                    {
                        AccessByPermission = TableData "CRM Integration Record" = D;
                        ApplicationArea = Suite;
                        Caption = 'Delete Coupling';
                        Enabled = CRMIsCoupledToRecord;
                        Image = UnLinkAccount;
                        //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedCategory = Process;
                        ToolTip = 'Delete the coupling to a Dataverse Transaction Currency.';

                        trigger OnAction()
                        var
                            CRMCouplingManagement: Codeunit "CRM Coupling Management";
                        begin
                            CRMCouplingManagement.RemoveCoupling(RecordId);
                        end;
                    }
                }
                action(ShowLog)
                {
                    ApplicationArea = Suite;
                    Caption = 'Synchronization Log';
                    Image = Log;
                    ToolTip = 'View integration synchronization jobs for the currency table.';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.ShowLog(RecordId);
                    end;
                }
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        CRMCouplingManagement: Codeunit "CRM Coupling Management";
    begin
        if CRMIntegrationEnabled or CDSIntegrationEnabled then begin
            CRMIsCoupledToRecord := CRMCouplingManagement.IsRecordCoupledToCRM(RecordId);
            if Code <> xRec.Code then
                CRMIntegrationManagement.SendResultNotification(Rec);
        end;
    end;

    trigger OnOpenPage()
    begin
        CRMIntegrationEnabled := CRMIntegrationManagement.IsCRMIntegrationEnabled;
        CDSIntegrationEnabled := CRMIntegrationManagement.IsCDSIntegrationEnabled;
    end;

    var
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
        CRMIntegrationEnabled: Boolean;
        CDSIntegrationEnabled: Boolean;
        CRMIsCoupledToRecord: Boolean;
}

