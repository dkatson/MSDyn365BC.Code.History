page 7 "Customer Price Groups"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Customer Price Groups';
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,Navigate';
    SourceTable = "Customer Price Group";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a code to identify the price group.';
                }
                field(Description; Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the description of the customer price group.';
                }
                field("Price Calculation Method"; "Price Calculation Method")
                {
                    Visible = ExtendedPriceEnabled;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the price calculation method that will override the method set in the sales setup for customers in this group.';
                }
                field("Allow Line Disc."; "Allow Line Disc.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies if a line discount will be calculated when the sales price is offered.';
                }
                field("Allow Invoice Disc."; "Allow Invoice Disc.")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the ordinary invoice discount calculation will apply to customers in this price group.';
                }
                field("Price Includes VAT"; "Price Includes VAT")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether the prices given for this price group will include VAT.';
                }
                field("VAT Bus. Posting Gr. (Price)"; "VAT Bus. Posting Gr. (Price)")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the VAT business group code for this price group. The code to find the VAT percentage rate in the VAT Posting Setup window that it uses to calculate the unit price.';
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
        area(navigation)
        {
            group("Cust. &Price Group")
            {
                Caption = 'Cust. &Price Group';
                action(SalesPrices)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales &Prices';
                    Image = SalesPrices;
                    Promoted = true;
                    PromotedCategory = Category4;
                    Visible = not ExtendedPriceEnabled;
                    ToolTip = 'Define how to set up sales price agreements. These sales prices can be for individual customers, for a group of customers, for all customers, or for a campaign.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                    ObsoleteTag = '17.0';

                    trigger OnAction()
                    var
                        SalesPrice: Record "Sales Price";
                    begin
                        SalesPrice.SetCurrentKey("Sales Type", "Sales Code");
                        SalesPrice.SetRange("Sales Type", SalesPrice."Sales Type"::"Customer Price Group");
                        SalesPrice.SetRange("Sales Code", Code);
                        Page.Run(Page::"Sales Prices", SalesPrice);
                    end;
                }
                action(PriceLists)
                {
                    AccessByPermission = TableData "Sales Price Access" = R;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Price Lists';
                    Image = Price;
                    Promoted = true;
                    PromotedCategory = Category4;
                    Visible = ExtendedPriceEnabled;
                    ToolTip = 'View or set up sales price lists with prices for products that you sell to customers that belong to the customer price group.';

                    trigger OnAction()
                    var
                        PriceUXManagement: Codeunit "Price UX Management";
                    begin
                        PriceUXManagement.ShowPriceLists(Rec);
                    end;
                }
            }
            group(ActionGroupCRM)
            {
                Caption = 'Dynamics 365 Sales';
                Visible = CRMIntegrationEnabled;
                action(CRMGoToPricelevel)
                {
                    ApplicationArea = Suite;
                    Caption = 'Pricelevel';
                    Image = CoupledItem;
                    ToolTip = 'View price information introduced through synchronization with Dynamics 365 Sales.';

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
                    ToolTip = 'Send updated data to Dynamics 365 Sales.';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.UpdateOneNow(RecordId);
                    end;
                }
                group(Coupling)
                {
                    Caption = 'Coupling', Comment = 'Coupling is a noun';
                    Image = LinkAccount;
                    ToolTip = 'Create, change, or delete a coupling between the Business Central record and a Dynamics 365 Sales record.';
                    action(ManageCRMCoupling)
                    {
                        AccessByPermission = TableData "CRM Integration Record" = IM;
                        ApplicationArea = Suite;
                        Caption = 'Set Up Coupling';
                        Image = LinkAccount;
                        ToolTip = 'Create or modify the coupling to a Dynamics 365 Sales product.';

                        trigger OnAction()
                        var
                            CRMIntegrationManagement: Codeunit "CRM Integration Management";
                        begin
                            CRMIntegrationManagement.DefineCoupling(RecordId);
                        end;
                    }
                    action(DeleteCRMCoupling)
                    {
                        AccessByPermission = TableData "CRM Integration Record" = IM;
                        ApplicationArea = Suite;
                        Caption = 'Delete Coupling';
                        Enabled = CRMIsCoupledToRecord;
                        Image = UnLinkAccount;
                        ToolTip = 'Delete the coupling to a Dynamics 365 Sales product.';

                        trigger OnAction()
                        var
                            CustomerPriceGroup: Record "Customer Price Group";
                            CRMCouplingManagement: Codeunit "CRM Coupling Management";
                            RecRef: RecordRef;
                        begin
                            CurrPage.SetSelectionFilter(CustomerPriceGroup);
                            RecRef.GetTable(CustomerPriceGroup);
                            CRMCouplingManagement.RemoveCoupling(RecRef);
                        end;
                    }
                }
                action(ShowLog)
                {
                    ApplicationArea = Suite;
                    Caption = 'Synchronization Log';
                    Image = Log;
                    ToolTip = 'View integration synchronization jobs for the customer price group table.';

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
    begin
        CRMIsCoupledToRecord := CRMIntegrationEnabled;
        if CRMIsCoupledToRecord then
            CRMIsCoupledToRecord := CRMCouplingManagement.IsRecordCoupledToCRM(RecordId);
    end;

    trigger OnOpenPage()
    begin
        CRMIntegrationEnabled := CRMIntegrationManagement.IsCRMIntegrationEnabled;
        ExtendedPriceEnabled := PriceCalculationMgt.IsExtendedPriceCalculationEnabled();
    end;

    var
        CRMIntegrationManagement: Codeunit "CRM Integration Management";
        CRMCouplingManagement: Codeunit "CRM Coupling Management";
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
        CRMIntegrationEnabled: Boolean;
        CRMIsCoupledToRecord: Boolean;
        ExtendedPriceEnabled: Boolean;

    procedure GetSelectionFilter(): Text
    var
        CustPriceGr: Record "Customer Price Group";
        SelectionFilterManagement: Codeunit SelectionFilterManagement;
    begin
        CurrPage.SetSelectionFilter(CustPriceGr);
        exit(SelectionFilterManagement.GetSelectionFilterForCustomerPriceGroup(CustPriceGr));
    end;
}

