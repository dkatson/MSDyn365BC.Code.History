codeunit 136312 "Job Reservation"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Reservation] [Job]
        IsInitialized := false;
    end;

    var
        DummyJobsSetup: Record "Jobs Setup";
        Assert: Codeunit Assert;
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryJob: Codeunit "Library - Job";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryWarehouse: Codeunit "Library - Warehouse";
        LibraryPlanning: Codeunit "Library - Planning";
        LibraryRandom: Codeunit "Library - Random";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        IsInitialized: Boolean;
        ReservationError: Label '%1 must not be changed when a quantity is reserved in %2 %3=''%4'',%5=''%6'',%7=''%8''.', Comment = '%1 Field Caption must not be changed when a quantity is reserved in %2 Table Caption%3 Field Caption=''%4'',%5 Field Caption=''%6'',%7 Field Caption =''%8''.';
        PlanningLinesReservationErrorForReserve: Label '%1 must be equal to ''0''  in %2: %3=%4, %5=%6, %7=%8. Current value is ''%9''.', Comment = '%1 Field Caption %2 Table Caption %3 Field Caption%4 value, %5 Table Caption %6 value %7 Field Caption %8 value.%9 value.';
        PlanningDateError: Label 'The change leads to a date conflict with existing reservations.';
        ExpectedDateError: Label 'Validation error for Field: Expected Receipt Date,  Message = ''The change leads to a date conflict with existing reservations.';
        RequisitionLineError: Label 'You cannot reserve this entry because it is not a true demand or supply.';
        OriginalQuantity: Decimal;
        DescriptionEmptyErr: Label 'Description 2 should be empty.';
        DescriptionItemRefErr: Label 'Description in Requisition Line should be same as in Item Cross Reference';
        DescriptionErr: Label 'Description should be %1 which from Item Cross Reference card.';
        LocationCodeErr: Label 'Location Code should be %1 which from Vendor card.';
        NotResetErr: Label 'The field should be reset when Vendor No. is cleared.';
        VendorNoIsNotMatchErr: Label 'Vendor No. is not match.';
        VendorItemNoErr: Label 'Vendor Item No. should be %1';
        NotCreateReservationEntryErr: Label 'The Reservation Entry should not be created.';

    [Test]
    [Scope('OnPrem')]
    procedure AssignResourceLocationName()
    var
        Location: Record Location;
        ResourceLocation: Record "Resource Location";
    begin
        // Verify Location Name assigning from Location.Name

        // Setup.
        Initialize;
        LibraryWarehouse.CreateLocation(Location);
        Location.Validate(Name, PadStr(Location.Name, MaxStrLen(Location.Name), '.'));
        Location.Modify(true);

        // Exercise.
        ResourceLocation.Init;
        ResourceLocation."Location Code" := Location.Code;
        // Flow field calculation does not check for overflow, thus assign value explicitly
        ResourceLocation."Location Name" := Location.Name;
        ResourceLocation.Insert(true);

        // Verify.
        Assert.AreEqual(Location.Name, ResourceLocation."Location Name", ResourceLocation.FieldCaption("Location Name"));
    end;

    [Test]
    [HandlerFunctions('ReservationPageHandler')]
    [Scope('OnPrem')]
    procedure ChangePurchaseLineItemAfterReserve()
    var
        Item: Record Item;
        JobPlanningLine: Record "Job Planning Line";
        PurchaseLine: Record "Purchase Line";
    begin
        // Verify after Reserve Purchase Order, not possible to modify Item on Purchase Line.

        // Setup.
        Initialize;
        CreatePurchaseDocument(PurchaseLine);
        CreateJobAndPlanningLine(JobPlanningLine, PurchaseLine."No.");
        PurchaseLine.ShowReservation;
        LibraryInventory.CreateItem(Item);

        // Exercise.
        asserterror PurchaseLine.Validate("No.", Item."No.");

        // Verify.
        VerifyPurchaseLineError(PurchaseLine, Item.FieldCaption("No."));
    end;

    [Test]
    [HandlerFunctions('ReservationPageHandler')]
    [Scope('OnPrem')]
    procedure ChangePurchaseLineVariantAfterReserve()
    var
        ItemVariant: Record "Item Variant";
        JobPlanningLine: Record "Job Planning Line";
        PurchaseLine: Record "Purchase Line";
    begin
        // Verify after Reserve Purchase Order, not possible to modify Vairant Code on Purchase Line.

        // Setup.
        Initialize;
        CreatePurchaseDocument(PurchaseLine);
        CreateJobAndPlanningLine(JobPlanningLine, PurchaseLine."No.");
        PurchaseLine.ShowReservation;

        // Exercise.
        asserterror PurchaseLine.Validate("Variant Code", LibraryInventory.CreateItemVariant(ItemVariant, PurchaseLine."No."));

        // Verify.
        VerifyPurchaseLineError(PurchaseLine, PurchaseLine.FieldCaption("Variant Code"));
    end;

    [Test]
    [HandlerFunctions('ReservationPageHandler')]
    [Scope('OnPrem')]
    procedure ChangePurchaseLineLocationAfterReserve()
    var
        JobPlanningLine: Record "Job Planning Line";
        Location: Record Location;
        PurchaseLine: Record "Purchase Line";
    begin
        // Verify after Reserve Purchase Order, not possible to modify Location Code on Purchase Line.

        // Setup.
        Initialize;
        CreatePurchaseDocument(PurchaseLine);
        CreateJobAndPlanningLine(JobPlanningLine, PurchaseLine."No.");
        PurchaseLine.ShowReservation;

        // Exercise.
        asserterror PurchaseLine.Validate("Location Code", LibraryWarehouse.CreateLocation(Location));

        // Verify.
        VerifyPurchaseLineError(PurchaseLine, PurchaseLine.FieldCaption("Location Code"));
    end;

    [Test]
    [HandlerFunctions('ReservationPageHandler')]
    [Scope('OnPrem')]
    procedure ChangePurchaseLineExpectedReceiptDateAfterReserve()
    var
        JobPlanningLine: Record "Job Planning Line";
        PurchaseLine: Record "Purchase Line";
    begin
        // Verify after Reserve Purchase Order, not possible to modify Expected Receipt Date on Purchase Line.

        // Setup.
        Initialize;
        CreatePurchaseDocument(PurchaseLine);
        CreateJobAndPlanningLine(JobPlanningLine, PurchaseLine."No.");
        PurchaseLine.ShowReservation;

        // Exercise.
        asserterror OpenPurchaseOrderToChangeExpectedReceiptDate(
            PurchaseLine."Document No.", LibraryRandom.RandDateFrom(JobPlanningLine."Planning Date", 5));

        // Verify.
        Assert.ExpectedError(ExpectedDateError);
    end;

    [Test]
    [HandlerFunctions('ReservationPageHandler')]
    [Scope('OnPrem')]
    procedure ChangeJobPlanningLinesItemAfterReserve()
    var
        Item: Record Item;
        JobPlanningLine: Record "Job Planning Line";
        PurchaseLine: Record "Purchase Line";
    begin
        // Verify after Reserve Purchase Order, not possible to modify Item on Job Planning Line.

        // Setup.
        Initialize;
        CreatePurchaseDocument(PurchaseLine);
        CreateJobAndPlanningLine(JobPlanningLine, PurchaseLine."No.");
        PurchaseLine.ShowReservation;
        LibraryInventory.CreateItem(Item);

        // Exercise.
        asserterror JobPlanningLine.Validate("No.", Item."No.");

        // Verify.
        VerifyJobPlanningLineError(JobPlanningLine, JobPlanningLine.FieldCaption("No."));
    end;

    [Test]
    [HandlerFunctions('ReservationPageHandler')]
    [Scope('OnPrem')]
    procedure ChangeJobPlanningLinesVariantAfterReserve()
    var
        ItemVariant: Record "Item Variant";
        JobPlanningLine: Record "Job Planning Line";
        PurchaseLine: Record "Purchase Line";
    begin
        // Verify after Reserve Purchase Order, not possible to modify Variant Code on Job Planning Line.

        // Setup.
        Initialize;
        CreatePurchaseDocument(PurchaseLine);
        CreateJobAndPlanningLine(JobPlanningLine, PurchaseLine."No.");
        PurchaseLine.ShowReservation;

        // Exercise.
        asserterror JobPlanningLine.Validate("Variant Code", LibraryInventory.CreateItemVariant(ItemVariant, PurchaseLine."No."));

        // Verify.
        VerifyJobPlanningLineError(JobPlanningLine, JobPlanningLine.FieldCaption("Variant Code"));
    end;

    [Test]
    [HandlerFunctions('ReservationPageHandler')]
    [Scope('OnPrem')]
    procedure ChangeJobPlanningLinesLocationAfterReserve()
    var
        JobPlanningLine: Record "Job Planning Line";
        Location: Record Location;
        PurchaseLine: Record "Purchase Line";
    begin
        // Verify after Reserve Purchase Order, not possible to modify Location Code on Job Planning Line.

        // Setup.
        Initialize;
        CreatePurchaseDocument(PurchaseLine);
        CreateJobAndPlanningLine(JobPlanningLine, PurchaseLine."No.");
        PurchaseLine.ShowReservation;

        // Exercise.
        asserterror JobPlanningLine.Validate("Location Code", LibraryWarehouse.CreateLocation(Location));

        // Verify.
        VerifyJobPlanningLineError(JobPlanningLine, JobPlanningLine.FieldCaption("Location Code"));
    end;

    [Test]
    [HandlerFunctions('ReservationPageHandler')]
    [Scope('OnPrem')]
    procedure ChangeJobPlanningLinesPlanningDateAfterReserve()
    var
        JobPlanningLine: Record "Job Planning Line";
        PurchaseLine: Record "Purchase Line";
    begin
        // Verify after Reserve Purchase Order, not possible to modify Planning Date on Job Planning Line.

        // Setup.
        Initialize;
        CreatePurchaseDocument(PurchaseLine);
        CreateJobAndPlanningLine(JobPlanningLine, PurchaseLine."No.");
        PurchaseLine.ShowReservation;

        // Exercise.
        asserterror JobPlanningLine.Validate(
            "Planning Date", CalcDate('<' + Format(-LibraryRandom.RandInt(5)) + 'Y>', JobPlanningLine."Planning Date"));

        // Verify.
        Assert.ExpectedError(PlanningDateError);
    end;

    [Test]
    [HandlerFunctions('ReservationPageHandler')]
    [Scope('OnPrem')]
    procedure ChangeJobPlanningLinesUsageLinkAfterReserve()
    var
        JobPlanningLine: Record "Job Planning Line";
        PurchaseLine: Record "Purchase Line";
    begin
        // Verify after Reserve Purchase Order, not possible to modify Usage Link on Job Planning Line.

        // Setup.
        Initialize;
        CreatePurchaseDocument(PurchaseLine);
        CreateJobAndPlanningLine(JobPlanningLine, PurchaseLine."No.");
        PurchaseLine.ShowReservation;

        // Exercise.
        asserterror JobPlanningLine.Validate("Usage Link", false);

        // Verify.
        VerifyJobPlanningLineError(JobPlanningLine, JobPlanningLine.FieldCaption("Usage Link"));
    end;

    [Test]
    [HandlerFunctions('ReservationPageHandler')]
    [Scope('OnPrem')]
    procedure ChangeJobPlanningLinesReserveAfterReserve()
    var
        JobPlanningLine: Record "Job Planning Line";
        PurchaseLine: Record "Purchase Line";
    begin
        // Verify after Reserve Purchase Order, not possible to modify Reserve on Job Planning Line.

        // Setup.
        Initialize;
        CreatePurchaseDocument(PurchaseLine);
        CreateJobAndPlanningLine(JobPlanningLine, PurchaseLine."No.");
        PurchaseLine.ShowReservation;
        JobPlanningLine.CalcFields("Reserved Qty. (Base)");

        // Exercise.
        asserterror JobPlanningLine.Validate(Reserve, JobPlanningLine.Reserve::Never);

        // Verify.
        Assert.ExpectedError(
          StrSubstNo(
            PlanningLinesReservationErrorForReserve, JobPlanningLine.FieldCaption("Reserved Qty. (Base)"), JobPlanningLine.TableCaption,
            JobPlanningLine.FieldCaption("Job No."), JobPlanningLine."Job No.",
            JobPlanningLine.FieldCaption("Job Task No."), JobPlanningLine."Job Task No.", JobPlanningLine.FieldCaption("Line No."),
            JobPlanningLine."Line No.", JobPlanningLine."Reserved Qty. (Base)"));
    end;

    [Test]
    [HandlerFunctions('ReservationPageHandler')]
    [Scope('OnPrem')]
    procedure ModifyFactorsFromPurchaseOrderToJobOrder()
    var
        JobPlanningLine: Record "Job Planning Line";
        PurchaseLine: Record "Purchase Line";
    begin
        // Verify Reserved Quantity on Purchase Line and Job Planning Line after modifying the various field on Purchase and Job Planning Line after Reservation.

        // Setup: Create and modify Purchase Order, create Job Planning Line, again modify Purchase Line after Reservation.
        Initialize;
        CreatePurchaseDocument(PurchaseLine);
        ModifyPurchaseLineReceiptDate(PurchaseLine, LibraryRandom.RandDate(5));  // Using Random for calculating Expected Receipt Date.
        CreateJobAndPlanningLine(JobPlanningLine, PurchaseLine."No.");
        PurchaseLine.ShowReservation;
        PurchaseLine.Validate(Quantity, PurchaseLine.Quantity - LibraryUtility.GenerateRandomFraction);  // Using Random to modify Quantity.
        ModifyPurchaseLineReceiptDate(PurchaseLine, JobPlanningLine."Planning Date");

        // Exercise: Modify various feilds on Demand. Using Random to modify Quantity and Planning Date.
        UpdateJobPlanningLine(
          JobPlanningLine, JobPlanningLine.Quantity - LibraryUtility.GenerateRandomFraction,
          LibraryRandom.RandDateFrom(JobPlanningLine."Planning Date", 5), JobPlanningLine.Reserve::Always, '');

        // Verify: Verify Purchase Line and Job Planning Line for Reserved Quantity.
        PurchaseLine.CalcFields("Reserved Quantity");
        PurchaseLine.TestField("Reserved Quantity", PurchaseLine.Quantity);
        VerifyJobPlanningLine(JobPlanningLine, PurchaseLine.Quantity);
    end;

    [Test]
    [HandlerFunctions('ReserveFromCurrentLineHandler')]
    [Scope('OnPrem')]
    procedure ModifyFactorsFromJobOrderToItemLedgerEntry()
    var
        JobPlanningLine: Record "Job Planning Line";
        PurchaseLine: Record "Purchase Line";
    begin
        // Verify Reserved Quantity on Job Planning Line after modifying the various field on Job Planning Line after Reservation.

        // Setup: Create and receive Purchase Order and create Job Planning Lines. Reserve Job Planning Line against Item Ledger Entry.
        Initialize;
        CreateAndReceivePurchaseOrder(PurchaseLine, '');  // Pass blank Location Code.
        CreateJobAndPlanningLine(JobPlanningLine, PurchaseLine."No.");
        JobPlanningLine.ShowReservation;

        // Exercise: Modify various feilds on Demand.
        UpdateJobPlanningLine(
          JobPlanningLine, PurchaseLine.Quantity - LibraryUtility.GenerateRandomFraction, LibraryRandom.RandDate(-5),
          JobPlanningLine.Reserve, '');  // Using Random to modify Quantity and Planning Date.

        // Verify: Verify Job Planning Line for Reserved Quantity.
        VerifyJobPlanningLine(JobPlanningLine, JobPlanningLine.Quantity);
    end;

    [Test]
    [HandlerFunctions('ReserveFromCurrentLineHandler')]
    [Scope('OnPrem')]
    procedure ReservationFromRequisitionLine()
    var
        JobPlanningLine: Record "Job Planning Line";
        RequisitionLine: Record "Requisition Line";
    begin
        // Verify that Reservation from Requisition Line to Job Order is not allowed.

        // Setup.
        Initialize;
        CreateRequisitionLine(RequisitionLine);
        CreateJobAndPlanningLine(JobPlanningLine, RequisitionLine."No.");

        // Exercise.
        asserterror RequisitionLine.ShowReservation;

        // Verify.
        Assert.ExpectedError(RequisitionLineError);
    end;

    [Test]
    [HandlerFunctions('TransferOrderStringMenuHandler,ReserveFromCurrentLineHandler')]
    [Scope('OnPrem')]
    procedure ModifyFactorsFromTransferOrderReceiptToJobOrder()
    var
        JobPlanningLine: Record "Job Planning Line";
        Location: Record Location;
        PurchaseLine: Record "Purchase Line";
        TransferLine: Record "Transfer Line";
    begin
        // Verify Reserved Quantity on Job Planning Line after modifying the various field on Transfer Order and Job Planning Line after Reservation.

        // Setup: Create Purchase Order and receive it, Create Transfer Order and Job Planning Line.
        Initialize;
        CreateAndReceivePurchaseOrder(PurchaseLine, LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location));
        CreateTransferOrder(TransferLine, PurchaseLine);
        CreateJobAndPlanningLine(JobPlanningLine, PurchaseLine."No.");
        UpdateJobPlanningLine(
          JobPlanningLine, NewValue(TransferLine.Quantity - 1, TransferLine.Quantity), JobPlanningLine."Planning Date",
          JobPlanningLine.Reserve, TransferLine."Transfer-to Code");  // Using Random to modify Quantity.

        // Reserve Transfer Order against Job Planning Line and modify Transfer Line with Random value.
        TransferLine.ShowReservation;
        TransferLine.Validate(Quantity, NewValue(JobPlanningLine.Quantity, TransferLine.Quantity));
        TransferLine.Validate("Receipt Date", JobPlanningLine."Planning Date");
        TransferLine.Modify(true);

        // Exercise.
        UpdateJobPlanningLine(
          JobPlanningLine, NewValue(JobPlanningLine.Quantity - 1, JobPlanningLine.Quantity),
          LibraryRandom.RandDateFrom(JobPlanningLine."Planning Date", 5), JobPlanningLine.Reserve,
          JobPlanningLine."Location Code");  // Using Random to modify Quantity and Planning Date.

        // Verify: Verify Job Planning Line for Reserved Quantity.
        VerifyJobPlanningLine(JobPlanningLine, JobPlanningLine.Quantity);
    end;

    [Test]
    [HandlerFunctions('ReserveFromCurrentLineHandler')]
    [Scope('OnPrem')]
    procedure ReservationEntryWhenReserveIsOptional()
    var
        JobPlanningLine: Record "Job Planning Line";
        PurchaseLine: Record "Purchase Line";
    begin
        // Verify Reservation entry created by a Purchase Order and Job Planning Line while Reserve type is Optional.

        // Setup.
        Initialize;
        CreatePurchaseDocument(PurchaseLine);
        CreateJobAndPlanningLine(JobPlanningLine, PurchaseLine."No.");

        // Exercise.
        PurchaseLine.ShowReservation;

        // Verify.
        VerifyReservationEntry(JobPlanningLine, PurchaseLine.Quantity);
    end;

    local procedure CreateAndReceivePurchaseOrder(var PurchaseLine: Record "Purchase Line"; LocationCode: Code[10])
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        CreatePurchaseDocument(PurchaseLine);
        PurchaseLine.Validate("Location Code", LocationCode);
        PurchaseLine.Modify(true);
        PurchaseHeader.Get(PurchaseLine."Document Type", PurchaseLine."Document No.");
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, false);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CreateRequisitionWorksheetlineAndUpdateVendorNo()
    var
        Vendor: Record Vendor;
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemCrossReference: Record "Item Cross Reference";
        RequisitionLine: Record "Requisition Line";
        ReqWorksheet: TestPage "Req. Worksheet";
        OriginalDescription: Text[100];
        OriginalLocationCode: Code[20];
    begin
        // [FEATURE] [Requisition Worksheet]
        // [SCENARIO] Description and Location Code are updated when updating "Vendor No." in Requisition Worksheet line.

        // Fill the Item No. in Requisition Line - Description updated according to "Item" card;
        // Fill the Item No. and Variant Code in Requisition Line - Description updated according to "Item Variants" card;
        // Fill the Item No. and Variant Code and Vendor No. in Requisition Line - Description updated according to "Item Cross Reference" card;

        // [GIVEN] Create a vendor with Location, create a item with Item Variant and Item Cross Reference.
        CreateVendorWithLocation(Vendor);
        LibraryInventory.CreateItem(Item);
        LibraryInventory.CreateItemVariant(ItemVariant, Item."No.");
        CreateItemCrossReference(
          ItemCrossReference, Item."No.", ItemVariant.Code, ItemCrossReference."Cross-Reference Type"::Vendor, Vendor."No.");

        // [GIVEN] Create a line in Requisition Worksheet
        CreateRequisitionWorksheetline(RequisitionLine, Item."No.", ItemVariant.Code);
        OpenRequisitionWorksheetPage(ReqWorksheet, RequisitionLine."Journal Batch Name");
        OriginalDescription := ReqWorksheet.Description.Value;
        OriginalLocationCode := ReqWorksheet."Location Code".Value;

        // [WHEN] Change Vendor No..
        ReqWorksheet."Vendor No.".SetValue(Vendor."No.");
        // [THEN] Description and Location Code are updated.
        Assert.AreEqual(
          ItemCrossReference.Description, ReqWorksheet.Description.Value, StrSubstNo(DescriptionErr, ItemCrossReference.Description));
        Assert.AreEqual(
          Vendor."Location Code", ReqWorksheet."Location Code".Value, StrSubstNo(LocationCodeErr, Vendor."Location Code"));

        // [WHEN] Clear "Vendor No.".
        ReqWorksheet."Vendor No.".SetValue('');
        // [THEN] Description and Location Code are reset.
        Assert.AreEqual(OriginalDescription, ReqWorksheet.Description.Value, NotResetErr);
        Assert.AreEqual(OriginalLocationCode, ReqWorksheet."Location Code".Value, NotResetErr);

        // [WHEN] Reset Vendor No., remove the Location Code.
        ReqWorksheet."Vendor No.".SetValue(Vendor."No.");
        ReqWorksheet."Location Code".SetValue('');

        // [THEN] Vendor No. is not changed. Description is copied from the item cross reference.
        Assert.AreEqual(Vendor."No.", ReqWorksheet."Vendor No.".Value, VendorNoIsNotMatchErr);
        Assert.AreEqual(ItemCrossReference.Description, ReqWorksheet.Description.Value, NotResetErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CreateRequisitionWorksheetlineAndValidateVendorNo()
    var
        Vendor: Record Vendor;
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
        RequisitionLine: Record "Requisition Line";
        ReqWorksheet: TestPage "Req. Worksheet";
    begin
        // [FEATURE] [Requisition Worksheet] [Item Cross Reference]
        // [SCENARIO 378246] "Description 2" in Requisition Line should be empty when vendor with Item Cross Reference is selected in "Vendor No."

        // [GIVEN] Create Item with filled "Description 2" field
        LibraryInventory.CreateItem(Item);
        Item.Validate("Description 2", LibraryUtility.GenerateGUID);
        Item.Modify(true);

        // [GIVEN] Create Vendor
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] Create Requisition Line with filled "Description 2" field
        CreateRequisitionWorksheetline(RequisitionLine, Item."No.", '');
        RequisitionLine.Validate("Description 2", LibraryUtility.GenerateGUID);
        RequisitionLine.Modify(true);

        // [GIVEN] Generate Item Cross Reference with Description = "X"
        LibraryInventory.CreateItemCrossReference(
          ItemCrossReference, Item."No.", ItemCrossReference."Cross-Reference Type"::Vendor, Vendor."No.");
        ItemCrossReference.Validate(Description, LibraryUtility.GenerateGUID);
        ItemCrossReference.Modify(true);

        // [GIVEN] Open Requisition Worksheet Page with Requisition Line inside
        OpenRequisitionWorksheetPage(ReqWorksheet, RequisitionLine."Journal Batch Name");

        // [WHEN] Set "Vendor No." in Requisition Line
        ReqWorksheet."Vendor No.".SetValue(Vendor."No.");

        RequisitionLine.Find;

        // [THEN] "Description" in Requisition Line should be same as in ItemCrossReference
        Assert.AreEqual(ItemCrossReference.Description, RequisitionLine.Description, DescriptionItemRefErr);

        // [THEN] "Description 2" in Requisition Line should be empty
        Assert.AreEqual('', RequisitionLine."Description 2", DescriptionEmptyErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure LocationCodeNotUpdateWhenUpdateVendorNoForReservedEntry()
    var
        Vendor: Record Vendor;
        Vendor2: Record Vendor;
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        RequisitionWkshName: Record "Requisition Wksh. Name";
        ReqWorksheet: TestPage "Req. Worksheet";
    begin
        // Verify Location Code is not updated when updating Vendor No. in Requisition Worksheet line which contain Reservation Entry.

        // Setup: Create 2 vendor with Location. Create a item.
        CreateVendorWithLocation(Vendor);
        CreateVendorWithLocation(Vendor2);
        CreateItem(Item, Vendor."No.", Item."Reordering Policy"::Order);

        // Create a demand and Calculate Plan for Requisition Worksheet.
        CreateSalesOrder(
          SalesHeader, WorkDate + LibraryRandom.RandInt(5), Vendor."Location Code", Item."No.", LibraryRandom.RandDec(5, 2));
        CalculatePlanForRequisitionWorksheet(RequisitionWkshName, Item, WorkDate - 30, WorkDate + 30);

        // Exercise: Change Vendor No..
        // Verify: Location Code is not updated.
        OpenRequisitionWorksheetPage(ReqWorksheet, RequisitionWkshName.Name);
        ReqWorksheet."Vendor No.".SetValue(Vendor2."No.");
        Assert.AreEqual(
          Vendor."Location Code", ReqWorksheet."Location Code".Value, StrSubstNo(LocationCodeErr, Vendor."Location Code"));

        // Exercise: Clear Vendor No..
        // Verify: Location Code is not updated.
        ReqWorksheet."Vendor No.".SetValue('');
        Assert.AreEqual(
          Vendor."Location Code", ReqWorksheet."Location Code".Value, StrSubstNo(LocationCodeErr, Vendor."Location Code"));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CreateRequisitionWorksheetlineAndVerifyVendorItemNo()
    var
        Vendor: Record Vendor;
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemCrossReference1: Record "Item Cross Reference";
        ItemCrossReference2: Record "Item Cross Reference";
        RequisitionLine: Record "Requisition Line";
        ReqWorksheet: TestPage "Req. Worksheet";
    begin
        // Verify Vendor Item No. is correct when creating Requisition Worksheet line manually.

        // Setup: Create a item with Variant and Cross Reference.
        CreateItemWithVariantAndCrossReference(Vendor, Item, ItemVariant, ItemCrossReference1, ItemCrossReference2);

        // Exercise: Create a line in Requisition Worksheet
        CreateRequisitionWorksheetline(RequisitionLine, Item."No.", ItemVariant.Code);

        // Verify: Vendor Item No. is displayed correctly with Variant Code
        OpenRequisitionWorksheetPage(ReqWorksheet, RequisitionLine."Journal Batch Name");
        Assert.AreEqual(
          ItemCrossReference2."Cross-Reference No.", ReqWorksheet."Vendor Item No.".Value,
          StrSubstNo(VendorItemNoErr, ItemCrossReference2."Cross-Reference No."));

        // Exercise and Verify: Vendor Item No. is displayed correctly when clear and reset the Vendor No..
        ResetAndVerifyVendorItemNo(ReqWorksheet, ItemCrossReference2."Cross-Reference No.", Vendor."No.");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CalculatePlanInRequisitionWorksheetAndVerifyVendorItemNo()
    var
        Vendor: Record Vendor;
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ItemCrossReference1: Record "Item Cross Reference";
        ItemCrossReference2: Record "Item Cross Reference";
        SalesHeader: Record "Sales Header";
        RequisitionWkshName: Record "Requisition Wksh. Name";
        ReqWorksheet: TestPage "Req. Worksheet";
    begin
        // Verify Vendor Item No. is correct when calculate plan in Requisition Worksheet.

        // Setup: Create a item with Variant and Cross Reference.
        CreateItemWithVariantAndCrossReference(Vendor, Item, ItemVariant, ItemCrossReference1, ItemCrossReference2);

        // Create 2 demands.
        CreateSalesOrderWithVariantCode(
          SalesHeader, WorkDate + LibraryRandom.RandInt(5),
          Vendor."Location Code", Item."No.", LibraryRandom.RandDec(5, 2), '');
        Clear(SalesHeader);
        CreateSalesOrderWithVariantCode(
          SalesHeader, WorkDate + LibraryRandom.RandInt(5),
          Vendor."Location Code", Item."No.", LibraryRandom.RandDec(5, 2), ItemVariant.Code);

        // Exercise: Calculate Plan for Requisition Worksheet.
        CalculatePlanForRequisitionWorksheet(RequisitionWkshName, Item, WorkDate - 30, WorkDate + 30);

        // Verify: Vendor Item No. is displayed correctly with Variant Code
        OpenRequisitionWorksheetPage(ReqWorksheet, RequisitionWkshName.Name);
        Assert.AreEqual(
          ItemCrossReference1."Cross-Reference No.", ReqWorksheet."Vendor Item No.".Value,
          StrSubstNo(VendorItemNoErr, ItemCrossReference1."Cross-Reference No."));

        ReqWorksheet.Next;
        Assert.AreEqual(
          ItemCrossReference2."Cross-Reference No.", ReqWorksheet."Vendor Item No.".Value,
          StrSubstNo(VendorItemNoErr, ItemCrossReference2."Cross-Reference No."));

        // Exercise and Verify: Vendor Item No. is displayed correctly when clear and reset the Vendor No..
        ResetAndVerifyVendorItemNo(ReqWorksheet, ItemCrossReference2."Cross-Reference No.", Vendor."No.");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CreateReqWorksheetlineAndVerifyDefaultLocationCodeFromVendorCard()
    var
        Vendor: Record Vendor;
        Vendor2: Record Vendor;
        Item: Record Item;
        RequisitionLine: Record "Requisition Line";
        ReqWorksheet: TestPage "Req. Worksheet";
    begin
        // Verify default Location Code from Vendor Card is filled when creating Requisition Worksheet line manually.

        // Setup: Create a vendor with Location, create a item with Vendor No..
        CreateVendorWithLocation(Vendor);
        CreateItem(Item, Vendor."No.", Item."Reordering Policy"::Order);

        // Exercise: Set the Item No. in Requisition Worksheet line
        CreateBlankRequisitionLine(RequisitionLine);
        OpenRequisitionWorksheetPage(ReqWorksheet, RequisitionLine."Journal Batch Name");
        ReqWorksheet.Type.SetValue(RequisitionLine.Type::Item);
        ReqWorksheet."No.".SetValue(Item."No.");

        // Verify: Vendor No. and Location Code from Vendor Card is filled in Req. Worksheet line.
        Assert.AreEqual(Vendor."No.", ReqWorksheet."Vendor No.".Value, VendorNoIsNotMatchErr);
        Assert.AreEqual(
          Vendor."Location Code", ReqWorksheet."Location Code".Value, StrSubstNo(LocationCodeErr, Vendor."Location Code"));

        // Exercise: Clear Vendor No..
        // Verify: Location Code are cleared
        ReqWorksheet."Vendor No.".SetValue('');
        Assert.AreEqual('', ReqWorksheet."Location Code".Value, NotResetErr);

        // Exercise: Create a new vendor, and change Vendor No. to the new one
        // Verify: Location Code is updated according to the new vendor.
        CreateVendorWithLocation(Vendor2);
        ReqWorksheet."Vendor No.".SetValue(Vendor2."No.");
        Assert.AreEqual(
          Vendor2."Location Code", ReqWorksheet."Location Code".Value, StrSubstNo(LocationCodeErr, Vendor."Location Code"));
    end;

    [Test]
    [HandlerFunctions('ReservationPageHandler,MessageHandler')]
    [Scope('OnPrem')]
    procedure ValidateItemNoOnReservedPurchaseLine()
    var
        PurchaseLine: Record "Purchase Line";
    begin
        // Verify no Surplus Reservation Entry is created after validating the same Item No. on reserved Purchase Line.

        // Setup: Create Purchase Order and Sales Order. Auto Reserve the Purchase Line to Sales Line.
        Initialize;
        AutoReservePurchaseLineToSalesLine(PurchaseLine);

        // Exercise: Validated the No. field on Purchase Line with the same Item No..
        PurchaseLine.Validate("No.", PurchaseLine."No.");
        PurchaseLine.Modify(true);

        // Verify: Verify no Surplus Reservation Entry is created.
        VerifyNoSurplusReservationEntry(PurchaseLine."No.");
    end;

    [Test]
    [HandlerFunctions('ReservationPageHandler')]
    [Scope('OnPrem')]
    procedure DateConflictRaisedWhenPlannedDeliveryDateInJobPlLineReservedFromPurchOrderIsChanged()
    var
        JobPlanningLine: Record "Job Planning Line";
        PurchaseLine: Record "Purchase Line";
    begin
        // [FEATURE] [Date conflict]
        // [SCENARIO 381252] The date conflict is raised when "Planned Delivery Date" in Job Planning Line reserved from Purchase Order is changed

        Initialize;

        // [GIVEN] Purchase Order with "Expected Receipt Date" = 10.01
        CreatePurchaseDocument(PurchaseLine);

        // [GIVEN] Job Planning Line with "Planning Date" and "Planned Delivery Date" equal 10.01 and reserved from Purchase Order
        CreateJobAndPlanningLine(JobPlanningLine, PurchaseLine."No.");
        PurchaseLine.ShowReservation;

        // [WHEN] Change "Planned Delivery Date" of Job Planning Line to 01.01
        asserterror
          JobPlanningLine.Validate("Planned Delivery Date", LibraryRandom.RandDate(-5));

        // [THEN] Error message "The change leads to a date conflict with existing reservations" is raised
        Assert.ExpectedError(PlanningDateError);
    end;

    [Test]
    [HandlerFunctions('ReservationPageHandler')]
    [Scope('OnPrem')]
    procedure JobPlanningLineIsPlannedWhenFullQtyIsAutoReserved()
    var
        JobPlanningLine: Record "Job Planning Line";
        PurchaseLine: Record "Purchase Line";
    begin
        // [SCENARIO 381257] The value of field "Planned" in Job Planning Line is TRUE when Job Planning Line auto-reserved from Purchase Order

        Initialize;

        // [GIVEN] Purchase Order with Item "X" and Quantity = 10
        CreatePurchaseDocument(PurchaseLine);

        // [GIVEN] Job Planning Line with Item "X" and Quantity = 10
        CreateJobAndPlanningLine(JobPlanningLine, PurchaseLine."No.");
        JobPlanningLine.Validate(Quantity, PurchaseLine.Quantity);
        JobPlanningLine.Modify(true);

        // [THEN] Auto-reserve Job Planning Line from Purchase Line
        JobPlanningLine.ShowReservation;

        // [THEN] Planned is TRUE in Job Planning Line
        JobPlanningLine.Find;
        JobPlanningLine.TestField(Planned);
    end;

    [Test]
    [HandlerFunctions('ReserveFromCurrentLineHandler')]
    [Scope('OnPrem')]
    procedure JobPlanningLineIsPlannedWhenFullQtyIsReservedFromCurrPurchLine()
    var
        JobPlanningLine: Record "Job Planning Line";
        PurchaseLine: Record "Purchase Line";
    begin
        // [SCENARIO 381257] The value of field "Planned" in Job Planning Line is TRUE when Job Planning Line reserved from current Purchase Line

        Initialize;

        // [GIVEN] Purchase Order with Item "X" and Quantity = 10
        CreatePurchaseDocument(PurchaseLine);

        // [GIVEN] Job Planning Line with Item "X" and Quantity = 10
        CreateJobAndPlanningLine(JobPlanningLine, PurchaseLine."No.");
        JobPlanningLine.Validate(Quantity, PurchaseLine.Quantity);
        JobPlanningLine.Modify(true);

        // [THEN] Reserve Job Planning Line from current Purchase Line
        JobPlanningLine.ShowReservation;

        // [THEN] Planned is TRUE in Job Planning Line
        JobPlanningLine.Find;
        JobPlanningLine.TestField(Planned);
    end;

    [Test]
    [HandlerFunctions('ReserveOrCancelReservationPageHandler,ConfirmHandler')]
    [Scope('OnPrem')]
    procedure JobPlanningLineIsNotPlannedWhenReservationIsCanceled()
    var
        JobPlanningLine: Record "Job Planning Line";
        PurchaseLine: Record "Purchase Line";
    begin
        // [SCENARIO 381257] The value of field "Planned" in Job Planning Line is FALSE when reservation of Job Planning Line is canceled

        Initialize;

        // [GIVEN] Purchase Order with Item "X" and Quantity = 10
        CreatePurchaseDocument(PurchaseLine);

        // [GIVEN] Job Planning Line with Item "X" and Quantity = 10 reserved from current Purchase Line
        CreateJobAndPlanningLine(JobPlanningLine, PurchaseLine."No.");
        JobPlanningLine.Validate(Quantity, PurchaseLine.Quantity);
        JobPlanningLine.Modify(true);
        LibraryVariableStorage.Enqueue(true); // Set TRUE to reserve entry in ReserveOrCancelReservationPageHandler
        JobPlanningLine.ShowReservation;

        LibraryVariableStorage.Enqueue(false); // Set FALSE to cancel reservation in ReserveOrCancelReservationPageHandler

        // [WHEN] Cancel Reservation from current Purchase Line
        JobPlanningLine.ShowReservation;

        // [THEN] Planned is FALSE in Job Planning Line
        JobPlanningLine.Find;
        JobPlanningLine.TestField(Planned, false);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure JobPlanningLineBelongsToJobOfPlanningTypeIsNotAutoReserved()
    var
        Item: Record Item;
        PurchaseLine: Record "Purchase Line";
        Job: Record Job;
        JobPlanningLine: Record "Job Planning Line";
    begin
        // [SCENARIO 380618] Job planning line for a job of "Planning" status is not automatically reserved despite always reserve item.
        Initialize();

        // [GIVEN] Create an post purchase order for item "I".
        CreateAndReceivePurchaseOrder(PurchaseLine, '');

        // [GIVEN] Item "I" is set up for Reserve = Always.
        Item.Get(PurchaseLine."No.");
        Item.Validate(Reserve, Item.Reserve::Always);
        Item.Modify(true);

        // [GIVEN] Create job of "Planning" status.
        LibraryJob.CreateJob(Job);
        Job.Validate(Status, Job.Status::Planning);
        Job.Modify(true);

        // [GIVEN] Job planning line with item "I".
        CreateJobTaskWithJobPlanningLineWithUsageLink(JobPlanningLine, Job, Item."No.", LibraryRandom.RandInt(5));

        // [WHEN] Auto-reserve the job planning line.
        JobPlanningLine.AutoReserve();

        // [THEN] The job planning line is not reserved.
        JobPlanningLine.CalcFields("Reserved Quantity");
        JobPlanningLine.TestField("Reserved Quantity", 0);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure JobPlanningLineBelongsToJobOfOpenTypeIsAutoReserved()
    var
        Item: Record Item;
        PurchaseLine: Record "Purchase Line";
        Job: Record Job;
        JobPlanningLine: Record "Job Planning Line";
    begin
        // [SCENARIO 380618] Job planning line for a job of "Open" status is automatically reserved for always reserve item.
        Initialize();

        // [GIVEN] Create an post purchase order for item "I".
        CreateAndReceivePurchaseOrder(PurchaseLine, '');

        // [GIVEN] Item "I" is set up for Reserve = Always.
        Item.Get(PurchaseLine."No.");
        Item.Validate(Reserve, Item.Reserve::Always);
        Item.Modify(true);

        // [GIVEN] Create job of "Open" status.
        LibraryJob.CreateJob(Job);
        Job.Validate(Status, Job.Status::Open);
        Job.Modify(true);

        // [GIVEN] Job planning line with item "I".
        CreateJobTaskWithJobPlanningLineWithUsageLink(JobPlanningLine, Job, Item."No.", LibraryRandom.RandInt(5));

        // [WHEN] Auto-reserve the job planning line.
        JobPlanningLine.AutoReserve();

        // [THEN] The job planning line is fully reserved.
        JobPlanningLine.CalcFields("Reserved Quantity");
        JobPlanningLine.TestField("Reserved Quantity", JobPlanningLine.Quantity);
    end;

    local procedure Initialize()
    var
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"Job Reservation");
        OriginalQuantity := 0;
        LibraryVariableStorage.Clear;
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"Job Reservation");
        LibraryERMCountryData.CreateVATData;
        LibraryERMCountryData.UpdateGeneralPostingSetup;

        DummyJobsSetup."Allow Sched/Contract Lines Def" := false;
        DummyJobsSetup."Apply Usage Link by Default" := false;
        DummyJobsSetup.Modify;

        IsInitialized := true;
        Commit;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Job Reservation");
    end;

    local procedure CalculatePlanForRequisitionWorksheet(var RequisitionWkshName: Record "Requisition Wksh. Name"; Item: Record Item; StartDate: Date; EndDate: Date)
    var
        ReqWkshTemplate: Record "Req. Wksh. Template";
    begin
        SelectRequisitionTemplate(ReqWkshTemplate, ReqWkshTemplate.Type::"Req.");
        LibraryPlanning.CreateRequisitionWkshName(RequisitionWkshName, ReqWkshTemplate.Name);
        LibraryPlanning.CalculatePlanForReqWksh(Item, ReqWkshTemplate.Name, RequisitionWkshName.Name, StartDate, EndDate);
    end;

    local procedure CreateBlankRequisitionLine(var RequisitionLine: Record "Requisition Line")
    var
        RequisitionWkshName: Record "Requisition Wksh. Name";
        ReqWkshTemplate: Record "Req. Wksh. Template";
    begin
        ReqWkshTemplate.SetRange(Type, ReqWkshTemplate.Type::"Req.");
        ReqWkshTemplate.FindFirst;
        LibraryPlanning.CreateRequisitionWkshName(RequisitionWkshName, ReqWkshTemplate.Name);
        LibraryPlanning.CreateRequisitionLine(RequisitionLine, RequisitionWkshName."Worksheet Template Name", RequisitionWkshName.Name);
    end;

    local procedure CreateVendorWithLocation(var Vendor: Record Vendor)
    var
        Location: Record Location;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Location Code", LibraryWarehouse.CreateLocation(Location));
        Vendor.Modify(true);
    end;

    local procedure CreateItem(var Item: Record Item; VendorNo: Code[20]; ReorderingPolicy: Option)
    begin
        LibraryInventory.CreateItem(Item);
        Item.Validate("Vendor No.", VendorNo);
        Item.Validate("Reordering Policy", ReorderingPolicy);
        Item.Modify(true);
    end;

    local procedure CreateItemCrossReference(var ItemCrossReference: Record "Item Cross Reference"; ItemNo: Code[20]; ItemVariantNo: Code[10]; CrossReferenceType: Option; CrossReferenceTypeNo: Code[30])
    begin
        with ItemCrossReference do begin
            Init;
            Validate("Item No.", ItemNo);
            Validate("Variant Code", ItemVariantNo);
            Validate("Cross-Reference Type", CrossReferenceType);
            Validate("Cross-Reference Type No.", CrossReferenceTypeNo);
            Validate(
              "Cross-Reference No.",
              LibraryUtility.GenerateRandomCode(FieldNo("Cross-Reference No."), DATABASE::"Item Cross Reference"));
            Validate(Description, CrossReferenceTypeNo);
            Insert(true);
        end;
    end;

    local procedure CreateItemWithVariantAndCrossReference(var Vendor: Record Vendor; var Item: Record Item; var ItemVariant: Record "Item Variant"; var ItemCrossReference1: Record "Item Cross Reference"; var ItemCrossReference2: Record "Item Cross Reference")
    begin
        CreateVendorWithLocation(Vendor);
        CreateItem(Item, Vendor."No.", Item."Reordering Policy"::"Lot-for-Lot");

        LibraryInventory.CreateItemVariant(ItemVariant, Item."No.");

        CreateItemCrossReference(
          ItemCrossReference1, Item."No.", '', ItemCrossReference1."Cross-Reference Type"::Vendor, Vendor."No.");
        CreateItemCrossReference(
          ItemCrossReference2, Item."No.", ItemVariant.Code, ItemCrossReference2."Cross-Reference Type"::Vendor, Vendor."No.");
    end;

    local procedure CreateRequisitionWorksheetline(var RequisitionLine: Record "Requisition Line"; ItemNo: Code[20]; ItemVariantCode: Code[10])
    begin
        CreateBlankRequisitionLine(RequisitionLine);
        with RequisitionLine do begin
            Validate(Type, Type::Item);
            Validate("No.", ItemNo);
            Validate("Variant Code", ItemVariantCode);
            Validate(Quantity, LibraryRandom.RandDec(10, 2));  // Use Random for Quantity.
            Validate("Due Date", WorkDate);
            Modify(true);
        end;
    end;

    local procedure CreateSalesOrder(var SalesHeader: Record "Sales Header"; ShipmentDate: Date; LocationCode: Code[10]; ItemNo: Code[20]; Quantity: Decimal)
    var
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        SalesHeader.Validate("Location Code", LocationCode);
        SalesHeader.Validate("Shipment Date", ShipmentDate);
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, ItemNo, Quantity);
    end;

    local procedure CreateSalesOrderWithVariantCode(var SalesHeader: Record "Sales Header"; ShipmentDate: Date; LocationCode: Code[10]; ItemNo: Code[20]; Quantity: Decimal; VariantCode: Code[10])
    var
        SalesLine: Record "Sales Line";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Order, '');
        SalesHeader.Validate("Location Code", LocationCode);
        SalesHeader.Validate("Shipment Date", ShipmentDate);
        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, ItemNo, Quantity);
        SalesLine.Validate("Variant Code", VariantCode);
        SalesLine.Modify(true);
    end;

    local procedure CreatePurchaseDocument(var PurchaseLine: Record "Purchase Line")
    var
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        Vendor: Record Vendor;
        LibraryPurchase: Codeunit "Library - Purchase";
    begin
        // Create Purchase Order with Random Quantity.
        LibraryPurchase.CreateVendor(Vendor);
        OriginalQuantity := LibraryRandom.RandDecInRange(5, 10, 2);  // Assign in global variable.
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Order, Vendor."No.");
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, LibraryInventory.CreateItem(Item), OriginalQuantity);
    end;

    local procedure CreateJobAndPlanningLine(var JobPlanningLine: Record "Job Planning Line"; No: Code[20])
    var
        JobTask: Record "Job Task";
    begin
        CreateJobWithJobTask(JobTask);
        CreateJobPlanningLine(JobPlanningLine, JobPlanningLine."Line Type"::Budget, JobTask, No);
    end;

    local procedure CreateJobPlanningLine(var JobPlanningLine: Record "Job Planning Line"; LineType: Option; JobTask: Record "Job Task"; No: Code[20])
    begin
        // Use Random values for Quantity, Planning Date and Unit Cost because values are not important.
        LibraryJob.CreateJobPlanningLine(LineType, LibraryJob.ItemType, JobTask, JobPlanningLine);
        JobPlanningLine.Validate("No.", No);
        JobPlanningLine.Validate("Planning Date", CalcDate('<' + Format(LibraryRandom.RandIntInRange(6, 10)) + 'M>', WorkDate)); // The Planning Date is later than Receipt Date on Transfer Line.
        JobPlanningLine.Validate("Usage Link", true);
        JobPlanningLine.Validate(Quantity, OriginalQuantity + LibraryRandom.RandDec(100, 2));
        JobPlanningLine.Validate(Reserve, JobPlanningLine.Reserve::Optional);
        JobPlanningLine.Modify(true);
    end;

    local procedure CreateJobWithJobTask(var JobTask: Record "Job Task")
    var
        Job: Record Job;
    begin
        LibraryJob.CreateJob(Job);
        LibraryJob.CreateJobTask(Job, JobTask);
    end;

    local procedure CreateJobTaskWithJobPlanningLineWithUsageLink(var JobPlanningLine: Record "Job Planning Line"; Job: Record Job; ItemNo: Code[20]; Qty: Decimal)
    var
        JobTask: Record "Job Task";
    begin
        LibraryJob.CreateJobTask(Job, JobTask);
        LibraryJob.CreateJobPlanningLine(JobPlanningLine."Line Type"::Budget, JobPlanningLine.Type::Item, JobTask, JobPlanningLine);
        JobPlanningLine.Validate("No.", ItemNo);
        JobPlanningLine.Validate("Usage Link", true);
        JobPlanningLine.Validate(Quantity, Qty);
        JobPlanningLine.Modify(true);
    end;

    local procedure CreateRequisitionLine(var RequisitionLine: Record "Requisition Line")
    var
        Item: Record Item;
        RequisitionWkshName: Record "Requisition Wksh. Name";
        ReqWkshTemplate: Record "Req. Wksh. Template";
        LibraryPlanning: Codeunit "Library - Planning";
    begin
        ReqWkshTemplate.SetRange(Type, ReqWkshTemplate.Type::"Req.");
        ReqWkshTemplate.FindFirst;
        LibraryPlanning.CreateRequisitionWkshName(RequisitionWkshName, ReqWkshTemplate.Name);
        LibraryPlanning.CreateRequisitionLine(RequisitionLine, RequisitionWkshName."Worksheet Template Name", RequisitionWkshName.Name);
        RequisitionLine.Validate(Type, RequisitionLine.Type::Item);
        RequisitionLine.Validate("No.", LibraryInventory.CreateItem(Item));
        RequisitionLine.Validate(Quantity, LibraryRandom.RandDec(10, 2));  // Use Random for Quantity.
        RequisitionLine.Validate("Due Date", WorkDate);
        RequisitionLine.Modify(true);
    end;

    local procedure CreateTransferOrder(var TransferLine: Record "Transfer Line"; PurchaseLine: Record "Purchase Line")
    var
        Location: Record Location;
        Location2: Record Location;
        TransferHeader: Record "Transfer Header";
    begin
        Location.SetRange("Use As In-Transit", true);
        Location.FindFirst;
        LibraryWarehouse.CreateTransferHeader(
          TransferHeader, PurchaseLine."Location Code", LibraryWarehouse.CreateLocation(Location2), Location.Code);
        LibraryWarehouse.CreateTransferLine(
          TransferHeader, TransferLine, PurchaseLine."No.", PurchaseLine.Quantity - LibraryUtility.GenerateRandomFraction);  // Use Random for Quantity.
        TransferLine.Validate("Receipt Date", CalcDate('<' + Format(LibraryRandom.RandInt(5)) + 'M>', WorkDate));  // Use Random value to calculate the Receipt Date.
        TransferLine.Modify(true);
    end;

    local procedure ModifyPurchaseLineReceiptDate(var PurchaseLine: Record "Purchase Line"; ExpectedReceiptDate: Date)
    begin
        PurchaseLine.Validate("Expected Receipt Date", ExpectedReceiptDate);
        PurchaseLine.Modify(true);
    end;

    local procedure ModifyItemOrderTrackingPolicy(ItemNo: Code[20])
    var
        Item: Record Item;
    begin
        Item.Get(ItemNo);
        Item.Validate("Order Tracking Policy", Item."Order Tracking Policy"::"Tracking Only");
        Item.Modify(true);
    end;

    local procedure NewValue(MinValue: Decimal; MaxValue: Decimal): Decimal
    begin
        if MinValue < 0 then
            MinValue := 0;
        exit(LibraryRandom.RandDecInDecimalRange(MinValue, MaxValue, 2));
    end;

    local procedure OpenPurchaseOrderToChangeExpectedReceiptDate(No: Code[20]; ExpectedReceiptDate: Date)
    var
        PurchaseOrder: TestPage "Purchase Order";
    begin
        PurchaseOrder.OpenEdit;
        PurchaseOrder.FILTER.SetFilter("No.", No);
        PurchaseOrder.PurchLines."Expected Receipt Date".SetValue(ExpectedReceiptDate);
    end;

    local procedure OpenRequisitionWorksheetPage(var ReqWorksheet: TestPage "Req. Worksheet"; Name: Code[20])
    begin
        ReqWorksheet.OpenEdit;
        ReqWorksheet.CurrentJnlBatchName.SetValue(Name);
    end;

    local procedure SelectRequisitionTemplate(var ReqWkshTemplate: Record "Req. Wksh. Template"; Type: Option)
    begin
        ReqWkshTemplate.SetRange(Type, Type);
        ReqWkshTemplate.SetRange(Recurring, false);
        ReqWkshTemplate.FindFirst;
    end;

    local procedure UpdateJobPlanningLine(var JobPlanningLine: Record "Job Planning Line"; Quantity: Decimal; PlanningDate: Date; Reserve: Option; LocationCode: Code[10])
    begin
        JobPlanningLine.Validate(Quantity, Quantity);
        JobPlanningLine.Validate("Planning Date", PlanningDate);
        JobPlanningLine.Validate(Reserve, Reserve);
        JobPlanningLine.Validate("Location Code", LocationCode);
        JobPlanningLine.Modify(true);
    end;

    local procedure AutoReservePurchaseLineToSalesLine(var PurchaseLine: Record "Purchase Line")
    var
        SalesHeader: Record "Sales Header";
    begin
        CreatePurchaseDocument(PurchaseLine);
        ModifyItemOrderTrackingPolicy(PurchaseLine."No.");
        CreateSalesOrder(
          SalesHeader, CalcDate('<' + Format(LibraryRandom.RandInt(10)) + 'D>', PurchaseLine."Expected Receipt Date"),
          '', PurchaseLine."No.", PurchaseLine.Quantity);
        PurchaseLine.ShowReservation;
    end;

    local procedure VerifyPurchaseLineError(PurchaseLine: Record "Purchase Line"; ColumnCaption: Text[30])
    begin
        Assert.ExpectedError(
          StrSubstNo(
            ReservationError, ColumnCaption, PurchaseLine.TableCaption, PurchaseLine.FieldCaption("Document Type"),
            PurchaseLine."Document Type",
            PurchaseLine.FieldCaption("Document No."), PurchaseLine."Document No.", PurchaseLine.FieldCaption("Line No."),
            PurchaseLine."Line No."));
    end;

    local procedure VerifyJobPlanningLineError(JobPlanningLine: Record "Job Planning Line"; ColumnCaption: Text[30])
    begin
        Assert.ExpectedError(
          StrSubstNo(
            ReservationError, ColumnCaption, JobPlanningLine.TableCaption, JobPlanningLine.FieldCaption("Job No."),
            JobPlanningLine."Job No.",
            JobPlanningLine.FieldCaption("Job Task No."), JobPlanningLine."Job Task No.", JobPlanningLine.FieldCaption("Line No."),
            JobPlanningLine."Line No."));
    end;

    local procedure VerifyJobPlanningLine(JobPlanningLine: Record "Job Planning Line"; ReservedQuantity: Decimal)
    begin
        JobPlanningLine.CalcFields("Reserved Quantity");
        JobPlanningLine.TestField("Reserved Quantity", ReservedQuantity);
    end;

    local procedure VerifyReservationEntry(JobPlanningLine: Record "Job Planning Line"; Quantity: Decimal)
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        ReservationEntry.SetRange("Source Type", DATABASE::"Job Planning Line");
        ReservationEntry.SetRange("Source ID", JobPlanningLine."Job No.");
        ReservationEntry.FindFirst;
        ReservationEntry.TestField("Item No.", JobPlanningLine."No.");
        ReservationEntry.TestField("Quantity (Base)", -Quantity);
    end;

    local procedure VerifyNoSurplusReservationEntry(ItemNo: Code[20])
    var
        ReservationEntry: Record "Reservation Entry";
    begin
        ReservationEntry.SetRange("Item No.", ItemNo);
        ReservationEntry.SetRange("Reservation Status", ReservationEntry."Reservation Status"::Surplus);
        Assert.IsTrue(ReservationEntry.IsEmpty, NotCreateReservationEntryErr);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ReservationPageHandler(var Reservation: TestPage Reservation)
    begin
        Reservation."Auto Reserve".Invoke;
        Reservation.OK.Invoke;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ReserveFromCurrentLineHandler(var Reservation: TestPage Reservation)
    begin
        Reservation."Reserve from Current Line".Invoke;
        Reservation.OK.Invoke;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ReserveOrCancelReservationPageHandler(var Reservation: TestPage Reservation)
    begin
        if LibraryVariableStorage.DequeueBoolean then
            Reservation."Reserve from Current Line".Invoke
        else
            Reservation.CancelReservationCurrentLine.Invoke;
        Reservation.OK.Invoke;
    end;

    local procedure ResetAndVerifyVendorItemNo(ReqWorksheet: TestPage "Req. Worksheet"; CrossReferenceNo: Code[20]; VendorNo: Code[20])
    begin
        ReqWorksheet."Vendor No.".SetValue('');
        Assert.AreEqual('', ReqWorksheet."Vendor Item No.".Value, NotResetErr);

        ReqWorksheet."Vendor No.".SetValue(VendorNo);
        Assert.AreEqual(
          CrossReferenceNo, ReqWorksheet."Vendor Item No.".Value,
          StrSubstNo(VendorItemNoErr, CrossReferenceNo));
    end;

    [StrMenuHandler]
    [Scope('OnPrem')]
    procedure TransferOrderStringMenuHandler(Option: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := 2;
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandler(Msg: Text[1024])
    begin
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;
}
