codeunit 136201 "Marketing Contacts"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Contact] [Marketing]
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryMarketing: Codeunit "Library - Marketing";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        Assert: Codeunit Assert;
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        ActiveDirectoryMockEvents: Codeunit "Active Directory Mock Events";
        IsInitialized: Boolean;
        RelationErrorServiceTier: Label '%1 must have a value in %2: Primary Key=. It cannot be zero or empty.';
        ValidationError: Label '%1: %2 must exist.';
        ErrorMessage: Label '%1: %2 must not exist.';
        ExpectedMessage: Label 'The field IBAN is mandatory. You will not be able to use the account in a payment file until the IBAN is correctly filled in.\\Are you sure you want to continue?';
        BusinessRelationError: Label '%1 %2 already has a Contact Business Relation with %3 %4.', Comment = '%1: Table Caption;%2: Field Value,%3: Table Caption2; %4: Field Value2';
        WrongDescriptionFieldLengthErr: Label 'Wrong description field length in table %1.';
        EmptyAttachmentErr: Label 'The attachment is empty';
        ExtensionTxt: Label 'txt';
        WrongCalcdCurValueErr: Label '%1 should be updated with "Sales (LCY)" value.';
        BusRelContactValidationErr: Label '%1 %2 is used when a %3 is linked with a %4.', Comment = '.';
        WrongValueErr: Label 'Function returned wrong value';
        SelectCustomerTemplateQst: Label 'Do you want to select the customer template?';
        CustTemplateListErr: Label 'Customer Template List contains wrong data.';
        YouCanGetContactFromCustTxt: Label 'You can create contacts automatically from newly created customers.';
        YouCanGetContactFromVendTxt: Label 'You can create contacts automatically from newly created vendors.';
        CustomerContNotifTok: Label '351199d7-6c9b-40f1-8e78-ff9e67c546c9';
        VendorContNotifTok: Label '08db77db-1f41-4379-8615-1b581a0225fa';
        RelationAlreadyExistWithVendorErr: Label 'Contact %1 already has a %2 with Vendor %3.', Comment = '%1=Contact table caption;%2=Contact number;%3=Contact Business Relation table caption;%4=Contact Business Relation Link to Table value;%5=Contact Business Relation number';
        RelationAlreadyExistWithCustomerErr: Label 'Contact %1 already has a %2 with Customer %3.', Comment = '%1=Contact table caption;%2=Contact number;%3=Contact Business Relation table caption;%4=Contact Business Relation Link to Table value;%5=Contact Business Relation number';
        ContactNotRelatedToVendorErr: Label 'Contact %1 %2 is not related to vendor %3 %4.';
        ContactNotRelatedToCustomerErr: Label 'Contact %1 %2 is not related to customer %3 %4.';
        ExpectedToFindRecErr: Label 'Expected to find Contact Business Relation record.';

    [Test]
    [Scope('OnPrem')]
    procedure AlternativeAddressForContact()
    var
        Contact: Record Contact;
        ContactAltAddress: Record "Contact Alt. Address";
        ContactAltAddrDateRange: Record "Contact Alt. Addr. Date Range";
        SegmentHeader: Record "Segment Header";
        SegmentLine: Record "Segment Line";
    begin
        // Covers document number TC0054 - refer to TFS ID 21740.
        // Test assignment and activation of Alternative Address linked to a Contact.

        // 1. Setup: Create a new Contact, Contact Alternative Address and Contact Alternative Address Date Range.
        Initialize;
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.Validate(
          Address,
          CopyStr(
            LibraryUtility.GenerateRandomCode(Contact.FieldNo(Address), DATABASE::Contact),
            1,
            LibraryUtility.GetFieldLength(DATABASE::Contact, Contact.FieldNo(Address))));
        Contact.Modify(true);

        LibraryMarketing.CreateContactAltAddress(ContactAltAddress, Contact."No.");
        LibraryMarketing.CreateContactAltAddrDateRange(ContactAltAddrDateRange, Contact."No.", WorkDate);
        ContactAltAddrDateRange.Validate("Contact Alt. Address Code", ContactAltAddress.Code);
        ContactAltAddrDateRange.Modify(true);

        // 2. Exercise: Create a new Segment Header for the date range in which alternative address is activated, Segment Line and link the
        // Contact to the Segment Line.
        LibraryMarketing.CreateSegmentHeader(SegmentHeader);
        LibraryMarketing.CreateSegmentLine(SegmentLine, SegmentHeader."No.");
        SegmentLine.Validate("Contact No.", Contact."No.");
        SegmentLine.Modify(true);

        // 3. Verify: Check that the Contact Alternative Address Code on the Segment Line is the same as that created earlier.
        SegmentLine.TestField("Contact Alt. Address Code", ContactAltAddress.Code);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure IndustryGroupForContact()
    var
        Contact: Record Contact;
        ContactIndustryGroup: Record "Contact Industry Group";
        IndustryGroup: Record "Industry Group";
    begin
        // Covers document number TC0054 - refer to TFS ID 21740.
        // Test creation and linking of Industry Group for Contact.

        // 1. Setup: Create a new Contact. Find an Industry Group.
        Initialize;
        LibraryMarketing.CreateCompanyContact(Contact);
        IndustryGroup.FindFirst;

        // 2. Exercise: Create a Contact Industry Group for the Contact created earlier.
        LibraryMarketing.CreateContactIndustryGroup(ContactIndustryGroup, Contact."No.", IndustryGroup.Code);

        // 3. Verify: Check that the field No. of Industry Groups on Contact is updated.
        Contact.CalcFields("No. of Industry Groups");
        Contact.TestField("No. of Industry Groups", 1);  // Value 1 is important to test case since one Industry Group has been linked.
    end;

    [Test]
    [Scope('OnPrem')]
    procedure BusinessRelationForContact()
    var
        Contact: Record Contact;
        BusinessRelation: Record "Business Relation";
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // Covers document number TC0054 - refer to TFS ID 21740.
        // Test creation and linking of Business Relation for Contact.

        // 1. Setup: Create a new Contact, Business Relation.
        Initialize;
        LibraryMarketing.CreateCompanyContact(Contact);
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);

        // 2. Exercise: Create a new Contact Business Relation for the Contact and Business Relation created earlier.
        LibraryMarketing.CreateContactBusinessRelation(ContactBusinessRelation, Contact."No.", BusinessRelation.Code);

        // 3. Verify: Check that the field No. of Business Relations on Contact is updated.
        Contact.CalcFields("No. of Business Relations");
        // Value 1 is important to test case since one Business Relation has been linked.
        Contact.TestField("No. of Business Relations", 1);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure BusinessRelationForPersonContact()
    var
        CompanyContact: Record Contact;
        PersonContact: Record Contact;
        ContactCard: TestPage "Contact Card";
    begin
        // [SCENARIO] Test business relations for person contacts who are customers and belong to a company who are also customers.
        Initialize;

        // [GIVEN] A company contact and a person contact in the same company
        LibraryMarketing.CreateCompanyContact(CompanyContact);
        LibraryMarketing.CreatePersonContact(PersonContact);
        PersonContact.Validate("Company No.", CompanyContact."Company No.");
        PersonContact.Modify(true);

        // [WHEN] They are both a Customer
        CompanyContact.CreateCustomer('');
        PersonContact.CreateCustomer('');

        // [THEN] The company contact has 1 business relation and the person contact has 2.
        OpenContactCard(ContactCard, PersonContact);
        ContactCard.Control31."No. of Business Relations".AssertEquals(2);
        ContactCard.GotoRecord(CompanyContact);
        ContactCard.Control31."No. of Business Relations".AssertEquals(1);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure MailingGroupForContact()
    var
        Contact: Record Contact;
        MailingGroup: Record "Mailing Group";
        ContactMailingGroup: Record "Contact Mailing Group";
    begin
        // Covers document number TC0054 - refer to TFS ID 21740.
        // Test creation and linking of Mailing Group for Contact.

        // 1. Setup: Create a new Contact, Mailing Group.
        Initialize;
        LibraryMarketing.CreateCompanyContact(Contact);
        LibraryMarketing.CreateMailingGroup(MailingGroup);

        // 2. Exercise: Create a new Contact Mailing Group for the Contact and Mailing Group created earlier.
        LibraryMarketing.CreateContactMailingGroup(ContactMailingGroup, Contact."No.", MailingGroup.Code);

        // 3. Verify: Check that the field No. of Mailing Groups on Contact is updated.
        Contact.CalcFields("No. of Mailing Groups");
        Contact.TestField("No. of Mailing Groups", 1);  // Value 1 is important to test case since one Mailing Group has been linked.
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ContactBusinessRelationDescription()
    var
        BusinessRelation: Record "Business Relation";
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        Initialize;
        Assert.AreEqual(
          LibraryUtility.GetFieldLength(DATABASE::"Business Relation", BusinessRelation.FieldNo(Description)),
          LibraryUtility.GetFieldLength(DATABASE::"Contact Business Relation",
            ContactBusinessRelation.FieldNo("Business Relation Description")),
          StrSubstNo(WrongDescriptionFieldLengthErr, ContactBusinessRelation.TableCaption));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ContactIndustryGroupDescription()
    var
        IndustryGroup: Record "Industry Group";
        ContactIndustryGroup: Record "Contact Industry Group";
    begin
        Initialize;
        Assert.AreEqual(
          LibraryUtility.GetFieldLength(DATABASE::"Industry Group", IndustryGroup.FieldNo(Description)),
          LibraryUtility.GetFieldLength(DATABASE::"Contact Industry Group",
            ContactIndustryGroup.FieldNo("Industry Group Description")),
          StrSubstNo(WrongDescriptionFieldLengthErr, ContactIndustryGroup.TableCaption));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ContactWebSourceDescription()
    var
        WebSource: Record "Web Source";
        ContactWebSource: Record "Contact Web Source";
    begin
        Initialize;
        Assert.AreEqual(
          LibraryUtility.GetFieldLength(DATABASE::"Web Source", WebSource.FieldNo(Description)),
          LibraryUtility.GetFieldLength(DATABASE::"Contact Web Source",
            ContactWebSource.FieldNo("Web Source Description")),
          StrSubstNo(WrongDescriptionFieldLengthErr, ContactWebSource.TableCaption));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ContactJobResponsibilityDescription()
    var
        JobResponsibility: Record "Job Responsibility";
        ContactJobResponsibility: Record "Contact Job Responsibility";
    begin
        Initialize;
        Assert.AreEqual(
          LibraryUtility.GetFieldLength(DATABASE::"Job Responsibility", JobResponsibility.FieldNo(Description)),
          LibraryUtility.GetFieldLength(DATABASE::"Contact Job Responsibility",
            ContactJobResponsibility.FieldNo("Job Responsibility Description")),
          StrSubstNo(WrongDescriptionFieldLengthErr, ContactJobResponsibility.TableCaption));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CommentForContact()
    var
        Contact: Record Contact;
        RlshpMgtCommentLine: Record "Rlshp. Mgt. Comment Line";
        Comment: Text[80];
    begin
        // Covers document number TC0054 - refer to TFS ID 21740.
        // Test creation and linking of Comment for Contact.

        // 1. Setup: Create a new Contact.
        Initialize;
        LibraryMarketing.CreateCompanyContact(Contact);

        // 2. Exercise: Create Comment for Contact.
        LibraryMarketing.CreateRlshpMgtCommentContact(RlshpMgtCommentLine, Contact."No.");
        Comment :=
          CopyStr(
            LibraryUtility.GenerateRandomCode(RlshpMgtCommentLine.FieldNo(Comment), DATABASE::"Rlshp. Mgt. Comment Line"),
            1,
            LibraryUtility.GetFieldLength(DATABASE::"Rlshp. Mgt. Comment Line", RlshpMgtCommentLine.FieldNo(Comment)));
        RlshpMgtCommentLine.Validate(Comment, Comment);
        RlshpMgtCommentLine.Modify(true);

        // 3. Verify: Verify that the Comment has been linked correctly with Contact.
        RlshpMgtCommentLine.SetRange("Table Name", RlshpMgtCommentLine."Table Name"::Contact);
        RlshpMgtCommentLine.SetRange("No.", Contact."No.");
        RlshpMgtCommentLine.FindFirst;
        RlshpMgtCommentLine.TestField(Comment, Comment);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ContactOfTypePerson()
    var
        Contact: Record Contact;
        Contact2: Record Contact;
    begin
        // Covers document number TC0055 - refer to TFS ID 21740.
        // Test creation of an independent Contact of the Person type and linking it with the existing Contact of the Company type.

        // 1. Setup: Create a new Contact and input Type as Person.
        Initialize;
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.Validate(Type, Contact.Type::Person);

        // 2. Exercise: Search for another Contact of Type as Company and link it to the Contact created earlier.
        Contact2.SetRange(Type, Contact2.Type::Company);
        Contact2.FindFirst;
        Contact.Validate("Company No.", Contact2."No.");
        Contact.Modify(true);

        // Verify: Check that the values populated on the new Contact are the same as those on Contact of Type as Company.
        Contact.TestField(Address, Contact2.Address);
        Contact.TestField("Address 2", Contact2."Address 2");
        Contact.TestField(City, Contact2.City);
        Contact.TestField("Post Code", Contact2."Post Code");
        Contact.TestField("Salesperson Code", Contact2."Salesperson Code");
    end;

    [Test]
    [HandlerFunctions('NameDetailsModalFormHandler')]
    [Scope('OnPrem')]
    procedure ContactAfterUpdateNameDetails()
    var
        Contact: Record Contact;
        Salutation: Record Salutation;
        Language: Record Language;
    begin
        // Covers document number TC0055, TC0062 - refer to TFS ID 21740.
        // Test updating of Contact after updation of Name Details associated with the Contact.
        Initialize;

        // 1. Setup: Create a new Contact and input Type as Person. Find Salutation and Language.
        CreateContactAsPerson(Contact);
        Salutation.FindFirst;
        Language.FindFirst;

        // 2. Exercise: Open the Name Details form and fill in the details.
        LibraryVariableStorage.Enqueue(Salutation.Code);
        LibraryVariableStorage.Enqueue(Language.Code);
        RunNameDetails(Contact);

        // 3. Verify: Check that the Contact has been updated with the details filled earlier.
        Contact.Get(Contact."No.");  // Get refreshed instance.
        VerifyContactNameDetails(Contact, Salutation.Code, Language.Code);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure JobResponsibilityForContact()
    var
        Contact: Record Contact;
        JobResponsibility: Record "Job Responsibility";
        ContactJobResponsibility: Record "Contact Job Responsibility";
    begin
        // Covers document number TC0055 - refer to TFS ID 21740.
        // Test creation and linking of Job Responsibility for Contact.
        Initialize;

        // 1. Setup: Create a new Contact and input Type as Person. Create a new Job Responsibility.
        CreateContactAsPerson(Contact);
        LibraryMarketing.CreateJobResponsibility(JobResponsibility);

        // 2. Exercise: Create Contact Job Responsibility for Contact and Job Responsibility created earlier.
        LibraryMarketing.CreateContactJobResponsibility(ContactJobResponsibility, Contact."No.", JobResponsibility.Code);

        // 3. Verify: Check that the field No. of Job Responsibilities on Contact is updated.
        Contact.CalcFields("No. of Job Responsibilities");
        // Value 1 is important to test case since one Job Responsibility has been linked.
        Contact.TestField("No. of Job Responsibilities", 1);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure LinkContactWithCustomerError()
    var
        Contact: Record Contact;
        MarketingSetup: Record "Marketing Setup";
    begin
        // Covers document number TC0058 - refer to TFS ID 21740.
        // Test error generated on linking Contact with an existing Customer if Bus. Rel. Code for Customers field in Marketing
        // Setup is blank.

        // 1. Setup: Input the field Bus. Rel. Code for Customers of Marketing Setup as blank. Create a new Contact.
        Initialize;
        ChangeBusinessRelationCodeForCustomers('');
        LibraryMarketing.CreateCompanyContact(Contact);

        // 2. Exercise: Try to link Contact with an existing Customer.
        asserterror Contact.CreateCustomerLink;

        // 3. Verify: Check that the application generates an error on linking Contact with an existing Customer if Bus. Rel.
        // Code for Customers field in Marketing Setup is blank.
        VerifyContactErrorMessage(MarketingSetup.FieldCaption("Bus. Rel. Code for Customers"), MarketingSetup.TableCaption);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure LinkContactWithVendorError()
    var
        Contact: Record Contact;
        MarketingSetup: Record "Marketing Setup";
    begin
        // Covers document number TC0058 - refer to TFS ID 21740.
        // Test error generated on linking Contact with an existing Vendor if Bus. Rel. Code for Vendors field in Marketing
        // Setup is blank.

        // 1. Setup: Input the field Bus. Rel. Code for Vendors of Marketing Setup as blank. Create a new Contact.
        Initialize;
        ChangeBusinessRelationCodeForVendors('');
        LibraryMarketing.CreateCompanyContact(Contact);

        // 2. Exercise: Try to link Contact with an existing Vendor.
        asserterror Contact.CreateVendorLink;

        // 3. Verify: Check that the application generates an error on linking Contact with an existing Vendor if Bus. Rel.
        // Code for Vendors field in Marketing Setup is blank.
        VerifyContactErrorMessage(MarketingSetup.FieldCaption("Bus. Rel. Code for Vendors"), MarketingSetup.TableCaption);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure LinkContactWithBankAccError()
    var
        Contact: Record Contact;
        MarketingSetup: Record "Marketing Setup";
        BusRelCodeForBankAccs: Code[10];
    begin
        // Covers document number TC0058 - refer to TFS ID 21740.
        // Test error generated on linking Contact with an existing Bank Account if Bus. Rel. Code for Bank Accs. field in Marketing
        // Setup is blank.

        // 1. Setup: Input the field Bus. Rel. Code for Bank Accs. of Marketing Setup as blank. Create a new Contact.
        Initialize;
        BusRelCodeForBankAccs := ChangeBusinessRelationCodeForBankAccount('');
        LibraryMarketing.CreateCompanyContact(Contact);

        // 2. Exercise: Try to link Contact with an existing Bank Account.
        asserterror Contact.CreateBankAccountLink;

        // 3. Verify: Check that the application generates an error on linking Contact with an existing Bank Account if Bus. Rel.
        // Code for Bank Accs. field in Marketing Setup is blank.
        VerifyContactErrorMessage(MarketingSetup.FieldCaption("Bus. Rel. Code for Bank Accs."), MarketingSetup.TableCaption);

        // 4. Cleanup: Input the original value of the field Bus. Rel. Code for Bank Accs. in Marketing Setup.
        ChangeBusinessRelationCodeForBankAccount(BusRelCodeForBankAccs);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,CustomerTempModalFormHandler,MessageHandler')]
    [Scope('OnPrem')]
    procedure CreationOfCustomerFromContact()
    var
        Contact: Record Contact;
        BusinessRelation: Record "Business Relation";
        CustomerPriceGroup: Record "Customer Price Group";
        CustomerTemplate: Record "Customer Template";
    begin
        // Covers document number TC0059 - refer to TFS ID 21740.
        // [FEATURE] [Customer]
        // [SCENARIO 378041] Test creation of a Customer from Customer using the Customer Template from Demodata.
        // "Invoice Disc. Code" should not be set to blank on the Customer page if create a new Customer from a Contact using a template where this field was not informed

        // [GIVEN] Create a new Business Relation and input it in the field Bus. Rel. Code for Customers of Marketing Setup. Create a
        // new Customer Price Group and link it with a new Customer Template. Create a new Contact.
        Initialize;
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        ChangeBusinessRelationCodeForCustomers(BusinessRelation.Code);

        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup);
        CreateCustomerTemplate(CustomerTemplate, CustomerPriceGroup.Code);
        LibraryMarketing.CreateCompanyContact(Contact);

        // [GIVEN] Blank "Invoice Disc. Code" in the Customer Template
        CustomerTemplate.Validate("Invoice Disc. Code", '');
        CustomerTemplate.Modify(true);

        // [WHEN] Create Customer from Contact (the Customer Template created earlier is being chosen through Modal Form Handler).
        Contact.CreateCustomer(Contact.ChooseCustomerTemplate);

        // [THEN] Check that the values in the Customer created match the values in the Customer Template and Customer Price Group.
        // [THEN] "Invoice Disc. Code" is not blank in Customer card
        // [THEN] "Territory Code", "Currency Code" and "Country/Region Code" in the Customer created match the values in the Customer Template and Customer Price Group - TFS 380269
        VerifyCustomerCreatedByContact(CustomerTemplate, Contact."No.", CustomerPriceGroup.Code);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,CustomerTempModalFormHandler')]
    [Scope('OnPrem')]
    procedure CreateCustomerFromContactError()
    var
        Contact: Record Contact;
        MarketingSetup: Record "Marketing Setup";
        CustomerPriceGroup: Record "Customer Price Group";
        CustomerTemplate: Record "Customer Template";
    begin
        // Covers document number TC0059 - refer to TFS ID 21740.
        // Test error generated on creation of a Customer from Contact if Bus. Rel. Code for Customers field in Marketing Setup is blank.

        // 1. Setup: Input the field Bus. Rel. Code for Customers of Marketing Setup as blank. Create a new Contact.
        Initialize;
        ChangeBusinessRelationCodeForCustomers('');
        LibrarySales.CreateCustomerPriceGroup(CustomerPriceGroup);
        CreateCustomerTemplate(CustomerTemplate, CustomerPriceGroup.Code);
        LibraryMarketing.CreateCompanyContact(Contact);

        // 2. Exercise: Try to create Customer from Contact.
        asserterror Contact.CreateCustomer(Contact.ChooseCustomerTemplate);

        // 3. Verify: Check that the application generates an error on creation of a Customer from Contact if Bus. Rel. Code for Customers
        // field in Marketing Setup is blank.
        VerifyContactErrorMessage(MarketingSetup.FieldCaption("Bus. Rel. Code for Customers"), MarketingSetup.TableCaption);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,CustomerTemplateListPageHandler,MessageHandler')]
    [Scope('OnPrem')]
    procedure CreateCustFromCompanyContWithTemplateUI()
    var
        Contact: Record Contact;
        CustomerTemplate: array[2] of Record "Customer Template";
    begin
        // [SCENARIO 211037] Customer Template List contains only "company" templates when create customer from "Company" contact
        Initialize;
        DeleteCustomerTemplates;
        // [GIVEN] Customer template "CT1" with "Contact Type" = "Company"
        // [GIVEN] Customer template "CT2" with "Contact Type" = "Person"
        CreateCustomerTemplates(CustomerTemplate);
        LibraryVariableStorage.Enqueue(CustomerTemplate[1].Code);
        // [GIVEN] Contact "C" of Company type
        LibraryMarketing.CreateCompanyContact(Contact);
        // [WHEN] Create customer from contact using template
        Contact.CreateCustomer(Contact.ChooseCustomerTemplate);
        // [THEN] Customer Template List page contains only "CT1"
        // Verification in CustomerTemplateListPageHandler
        DeleteCustomerTemplates;
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,CustomerTemplateListPageHandler,MessageHandler')]
    [Scope('OnPrem')]
    procedure CreateCustFromPersonContWithTemplateUI()
    var
        Contact: Record Contact;
        CustomerTemplate: array[2] of Record "Customer Template";
    begin
        // [SCENARIO 211037] Customer Template List contains only "person" templates when create customer from "Person" contact
        Initialize;
        DeleteCustomerTemplates;
        // [GIVEN] Customer template "CT1" with "Contact Type" = "Company"
        // [GIVEN] Customer template "CT2" with "Contact Type" = "Person"
        CreateCustomerTemplates(CustomerTemplate);
        LibraryVariableStorage.Enqueue(CustomerTemplate[2].Code);
        // [GIVEN] Contact "C" of Person type
        LibraryMarketing.CreatePersonContact(Contact);
        // [WHEN] Create customer from contact using template
        Contact.CreateCustomer(Contact.ChooseCustomerTemplate);
        // [THEN] Customer Template List page contains only "CT2"
        // Verification in CustomerTemplateListPageHandler
        DeleteCustomerTemplates;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CreateVendorFromContactError()
    var
        Contact: Record Contact;
        MarketingSetup: Record "Marketing Setup";
    begin
        // Covers document number TC0059 - refer to TFS ID 21740.
        // Test error generated on creation of Vendor from Contact if Bus. Rel. Code for Vendors field in Marketing Setup is blank.

        // 1. Setup: Input the field Bus. Rel. Code for Vendors of Marketing Setup as blank. Create a new Contact.
        Initialize;
        ChangeBusinessRelationCodeForVendors('');
        LibraryMarketing.CreateCompanyContact(Contact);

        // 2. Exercise: Try to create Vendor from Contact.
        asserterror Contact.CreateVendor;

        // 3. Verify: Check that the application generates an error on creation of a Vendor from Contact if Bus. Rel. Code for Vendors
        // field in Marketing Setup is blank.
        VerifyContactErrorMessage(MarketingSetup.FieldCaption("Bus. Rel. Code for Vendors"), MarketingSetup.TableCaption);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CreateBankAccFromContactError()
    var
        Contact: Record Contact;
        MarketingSetup: Record "Marketing Setup";
        BusRelCodeForBankAccs: Code[10];
    begin
        // Covers document number TC0059 - refer to TFS ID 21740.
        // Test error generated on creation of a Bank Account from Contact if Bus. Rel. Code for Bank Accs. field in Marketing Setup
        // is blank.

        // 1. Setup: Input the field Bus. Rel. Code for Bank Accs. of Marketing Setup as blank. Create a new Contact.
        Initialize;
        BusRelCodeForBankAccs := ChangeBusinessRelationCodeForBankAccount('');
        LibraryMarketing.CreateCompanyContact(Contact);

        // 2. Exercise: Try to create Bank Account from Contact.
        asserterror Contact.CreateBankAccount;

        // 3. Verify: Check that the application generates an error on creation of a Bank Account from Contact if Bus. Rel. Code for
        // Bank Accs. field in Marketing Setup is blank.
        VerifyContactErrorMessage(MarketingSetup.FieldCaption("Bus. Rel. Code for Bank Accs."), MarketingSetup.TableCaption);

        // 4. Cleanup: Input the original value of the field Bus. Rel. Code for Bank Accs. in Marketing Setup.
        ChangeBusinessRelationCodeForBankAccount(BusRelCodeForBankAccs);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue')]
    [Scope('OnPrem')]
    procedure CreateContactFromCustomerError()
    var
        Customer: Record Customer;
        MarketingSetup: Record "Marketing Setup";
    begin
        // Covers document number TC0058, TC0060 - refer to TFS ID 21740.
        // Test error generated on creation of a Contact from Customer if Bus. Rel. Code for Customers field in Marketing Setup is blank.

        // 1. Setup: Input the field Bus. Rel. Code for Customers of Marketing Setup as blank. Create a new Customer.
        Initialize;
        ChangeBusinessRelationCodeForCustomers('');
        LibrarySales.CreateCustomer(Customer);

        // 2. Exercise: Try to create Contact from Customer.
        asserterror Customer.ShowContact;

        // 3. Verify: Check that the application generates an error on creation of a Contact from Customer if Bus. Rel. Code for Customers
        // field in Marketing Setup is blank.
        VerifyContactErrorMessage(MarketingSetup.FieldCaption("Bus. Rel. Code for Customers"), MarketingSetup.TableCaption);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue')]
    [Scope('OnPrem')]
    procedure CreateContactFromVendorError()
    var
        Vendor: Record Vendor;
        MarketingSetup: Record "Marketing Setup";
    begin
        // Covers document number TC0058, TC0060 - refer to TFS ID 21740.
        // Test error generated on creation of a Contact from Vendor if Bus. Rel. Code for Vendors field in Marketing Setup is blank.

        // 1. Setup: Input the field Bus. Rel. Code for Vendors of Marketing Setup as blank. Create a new Vendor.
        Initialize;
        ChangeBusinessRelationCodeForVendors('');
        LibraryPurchase.CreateVendor(Vendor);

        // 2. Exercise: Try to create Contact from Vendor.
        asserterror Vendor.ShowContact;

        // 3. Verify: Check that the application generates an error on creation of a Contact from Vendor if Bus. Rel. Code for Vendors
        // field in Marketing Setup is blank.
        VerifyContactErrorMessage(MarketingSetup.FieldCaption("Bus. Rel. Code for Vendors"), MarketingSetup.TableCaption);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue')]
    [Scope('OnPrem')]
    procedure CreateContactFromBankAccError()
    var
        BankAccount: Record "Bank Account";
        MarketingSetup: Record "Marketing Setup";
        BusRelCodeForBankAccs: Code[10];
    begin
        // Covers document number TC0058, TC0060 - refer to TFS ID 21740.
        // Test error generated on creation of a Contact from Bank Account if Bus. Rel. Code for Bank Accs. field in Marketing Setup
        // is blank.

        // 1. Setup: Input the field Bus. Rel. Code for Bank Accs. of Marketing Setup as blank. Create a new Bank Account.
        Initialize;
        BusRelCodeForBankAccs := ChangeBusinessRelationCodeForBankAccount('');
        LibraryERM.CreateBankAccount(BankAccount);

        // 2. Exercise: Try to create Contact from Bank Account.
        asserterror BankAccount.ShowContact;

        // 3. Verify: Check that the application generates an error on creation of a Contact from Bank Account if Bus. Rel. Code
        // for Bank Accs. field in Marketing Setup is blank.
        VerifyContactErrorMessage(MarketingSetup.FieldCaption("Bus. Rel. Code for Bank Accs."), MarketingSetup.TableCaption);

        // 4. Cleanup: Input the original value of the field Bus. Rel. Code for Bank Accs. in Marketing Setup.
        ChangeBusinessRelationCodeForBankAccount(BusRelCodeForBankAccs);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CreateContactFromCustomer()
    var
        Customer: Record Customer;
        Contact: Record Contact;
        BusinessRelation: Record "Business Relation";
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // Covers document number TC0060 - refer to TFS ID 21740.
        // Test creation of a Contact from Customer.

        // 1. Setup: Create a new Business Relation and input it in the field Bus. Rel. Code for Customers of Marketing Setup. Create a
        // new Customer.
        Initialize;
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        ChangeBusinessRelationCodeForCustomers(BusinessRelation.Code);
        LibrarySales.CreateCustomer(Customer);

        // 2. Exercise: Create Contact from Customer by running the report Create Conts. from Customers.
        Customer.SetRange("No.", Customer."No.");
        RunCreateContsFromCustomersReport(Customer);

        // 3. Verify: Check that the Contact has been created from the Customer.
        ContactBusinessRelation.SetRange("Business Relation Code", BusinessRelation.Code);
        ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
        ContactBusinessRelation.SetRange("No.", Customer."No.");
        ContactBusinessRelation.FindFirst;
        Contact.Get(ContactBusinessRelation."Contact No.");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CreateContactFromVendor()
    var
        Vendor: Record Vendor;
        Contact: Record Contact;
        BusinessRelation: Record "Business Relation";
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // Covers document number TC0060 - refer to TFS ID 21740.
        // Test creation of a Contact from Vendor.

        // 1. Setup: Create a new Business Relation and input it in the field Bus. Rel. Code for Vendors of Marketing Setup. Create a
        // new Vendor.
        Initialize;
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        ChangeBusinessRelationCodeForVendors(BusinessRelation.Code);
        LibraryPurchase.CreateVendor(Vendor);

        // 2. Exercise: Create Contact from Vendor by running the report Create Conts. from Vendors.
        Vendor.SetRange("No.", Vendor."No.");
        RunCreateContsFromVendorsReport(Vendor);

        // 3. Verify: Check that the Contact has been created from the Vendor.
        ContactBusinessRelation.SetRange("Business Relation Code", BusinessRelation.Code);
        ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Vendor);
        ContactBusinessRelation.SetRange("No.", Vendor."No.");
        ContactBusinessRelation.FindFirst;
        Contact.Get(ContactBusinessRelation."Contact No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue')]
    [Scope('OnPrem')]
    procedure CreateContactFromBankAcc()
    var
        BankAccount: Record "Bank Account";
        Contact: Record Contact;
        BusinessRelation: Record "Business Relation";
        ContactBusinessRelation: Record "Contact Business Relation";
        CreateContsFromBankAccs: Report "Create Conts. from Bank Accs.";
        BusRelCodeForBankAccs: Code[10];
    begin
        // Covers document number TC0060 - refer to TFS ID 21740.
        // Test creation of a Contact from Bank Account.

        // 1. Setup: Create a new Business Relation and input it in the field Bus. Rel. Code for Bank Accs. of Marketing Setup. Create a
        // new Bank Account.
        Initialize;
        ExecuteUIHandler;
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        BusRelCodeForBankAccs := ChangeBusinessRelationCodeForBankAccount(BusinessRelation.Code);
        LibraryERM.CreateBankAccount(BankAccount);

        // 2. Exercise: Create Contact from Bank Account by running the report Create Conts. from Bank Account.
        BankAccount.SetRange("No.", BankAccount."No.");
        CreateContsFromBankAccs.UseRequestPage(false);
        CreateContsFromBankAccs.SetTableView(BankAccount);
        CreateContsFromBankAccs.Run;

        // 3. Verify: Check that the Contact has been created from the Bank Account.
        ContactBusinessRelation.SetRange("Business Relation Code", BusinessRelation.Code);
        ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::"Bank Account");
        ContactBusinessRelation.SetRange("No.", BankAccount."No.");
        ContactBusinessRelation.FindFirst;
        Contact.Get(ContactBusinessRelation."Contact No.");

        // 4. Cleanup: Input the original value of the field Bus. Rel. Code for Bank Accs. in Marketing Setup.
        ChangeBusinessRelationCodeForBankAccount(BusRelCodeForBankAccs);
    end;

    [Test]
    [HandlerFunctions('CreateInteractModalFormHandler')]
    [Scope('OnPrem')]
    procedure InteractionStatisticsOnContact()
    var
        Contact: Record Contact;
        InteractionTemplate: Record "Interaction Template";
        CostLCY: Decimal;
        DurationMin: Decimal;
    begin
        // Covers document number TC0061 - refer to TFS ID 21740.
        // Test the Interaction statistics information on the Contact card.

        // 1. Setup: Create a new Contact, Interaction Template.
        Initialize;
        LibraryMarketing.CreateCompanyContact(Contact);
        LibraryMarketing.CreateInteractionTemplate(InteractionTemplate);

        // Set global variables for form handler with any random decimal value.
        CostLCY := LibraryRandom.RandDec(100, 2);
        DurationMin := LibraryRandom.RandDec(100, 2);
        LibraryVariableStorage.Enqueue(InteractionTemplate.Code);
        LibraryVariableStorage.Enqueue(CostLCY);
        LibraryVariableStorage.Enqueue(DurationMin);

        // 2. Exercise: Create a new Interaction for Contact.
        Contact.CreateInteraction;

        // 3. Verify: Check that the Statistics for Interaction has been updated on Contact.
        Contact.CalcFields("Cost (LCY)", "Duration (Min.)", "No. of Interactions");
        Contact.TestField("No. of Interactions", 1);
        Contact.TestField("Cost (LCY)", CostLCY);
        Contact.TestField("Duration (Min.)", DurationMin);
    end;

    [Test]
    [HandlerFunctions('CreateInteractModalFormHandler,ConfirmHandlerTrue')]
    [Scope('OnPrem')]
    procedure CancelInteractionOnContact()
    var
        Contact: Record Contact;
        InteractionTemplate: Record "Interaction Template";
        InteractionLogEntry: Record "Interaction Log Entry";
        CostLCY: Decimal;
        DurationMin: Decimal;
    begin
        // Covers document number TC0061 - refer to TFS ID 21740.
        // Test the Interaction statistics information on the Contact card.

        // 1. Setup: Create a new Contact, Interaction Template. Create a new Interaction for Contact.
        Initialize;
        LibraryMarketing.CreateCompanyContact(Contact);
        LibraryMarketing.CreateInteractionTemplate(InteractionTemplate);

        // Set global variables for form handler with any random decimal value.
        CostLCY := LibraryRandom.RandDec(100, 2);
        DurationMin := LibraryRandom.RandDec(100, 2);
        LibraryVariableStorage.Enqueue(InteractionTemplate.Code);
        LibraryVariableStorage.Enqueue(CostLCY);
        LibraryVariableStorage.Enqueue(DurationMin);
        Contact.CreateInteraction;

        // 2. Exercise: Cancel the Interaction.
        InteractionLogEntry.SetRange("Contact No.", Contact."No.");
        InteractionLogEntry.SetRange("Interaction Template Code", InteractionTemplate.Code);
        InteractionLogEntry.ToggleCanceledCheckmark;

        // 3. Verify: Check that the Statistics for Interaction has been updated on Contact.
        Contact.CalcFields("Cost (LCY)", "Duration (Min.)", "No. of Interactions");
        Contact.TestField("No. of Interactions", 0);
        Contact.TestField("Cost (LCY)", 0);
        Contact.TestField("Duration (Min.)", 0);
    end;

    [Test]
    [HandlerFunctions('CreateOpportModalFormHandler')]
    [Scope('OnPrem')]
    procedure OpportunityStatisticsOnContact()
    var
        Contact: Record Contact;
        Opportunity: Record Opportunity;
        SalesCycle: Record "Sales Cycle";
        TempOpportunity: Record Opportunity temporary;
        WizardEstimatedValueLCY: Decimal;
        WizardChancesofSuccessPercent: Decimal;
    begin
        // Covers document number TC0061 - refer to TFS ID 21740.
        // Test the Opportunity statistics information on the Contact card.

        // 1. Setup: Create a new Contact and Sales Cycle.
        Initialize;
        LibraryMarketing.CreateCompanyContact(Contact);
        LibraryMarketing.CreateSalesCycle(SalesCycle);

        // 2. Exercise: Create a new Opportunity for Contact. Set global variables for Form Handler with any random decimal values.
        WizardEstimatedValueLCY := LibraryRandom.RandDec(100, 2);
        WizardChancesofSuccessPercent := LibraryRandom.RandDec(100, 2);
        Opportunity.SetRange("Contact No.", Contact."No.");
        LibraryVariableStorage.Enqueue(SalesCycle.Code);
        LibraryVariableStorage.Enqueue(WizardEstimatedValueLCY);
        LibraryVariableStorage.Enqueue(WizardChancesofSuccessPercent);
        TempOpportunity.CreateOppFromOpp(Opportunity);

        // 3. Verify: Check that the Statistics for Opportunity has been updated on Contact.
        Contact.CalcFields("Estimated Value (LCY)", "Calcd. Current Value (LCY)", "No. of Opportunities");
        Contact.TestField("No. of Opportunities", 1);  // Since one opportunity has been created and linked.
        Contact.TestField("Estimated Value (LCY)", WizardEstimatedValueLCY);
        TempOpportunity.TestField(
          "Calcd. Current Value (LCY)", TempOpportunity."Estimated Value (LCY)" * TempOpportunity."Probability %" / 100);
    end;

    [Test]
    [HandlerFunctions('CreateOpportModalFormHandler,CloseOpportModalFormHandler,MessageHandler')]
    [Scope('OnPrem')]
    procedure CloseOpportunityOnContact()
    var
        Contact: Record Contact;
        Opportunity: Record Opportunity;
        SalesCycle: Record "Sales Cycle";
        CloseOpportunityCode: Record "Close Opportunity Code";
        TempOpportunity: Record Opportunity temporary;
        WizardEstimatedValueLCY: Decimal;
        WizardChancesofSuccessPercent: Decimal;
        CalcCurrentValueLCY: Decimal;
    begin
        // Covers document number TC0061 - refer to TFS ID 21740.
        // Test the Opportunity statistics information on the Contact card after Closing the Opportunity.

        // 1. Setup: Create a new Contact and Sales Cycle. Create a new Opportunity for Contact. Set global variables for Form Handler with
        // any random decimal values. Create a new Close Opportunity Code.
        Initialize;
        LibraryMarketing.CreateCompanyContact(Contact);
        LibraryMarketing.CreateSalesCycle(SalesCycle);

        // Set global variables for form handler with any random decimal values.
        WizardEstimatedValueLCY := LibraryRandom.RandDec(100, 2);
        WizardChancesofSuccessPercent := LibraryRandom.RandDec(100, 2);
        LibraryVariableStorage.Enqueue(SalesCycle.Code);
        LibraryVariableStorage.Enqueue(WizardEstimatedValueLCY);
        LibraryVariableStorage.Enqueue(WizardChancesofSuccessPercent);

        Opportunity.SetRange("Contact No.", Contact."No.");
        TempOpportunity.CreateOppFromOpp(Opportunity);
        LibraryMarketing.CreateCloseOpportunityCode(CloseOpportunityCode);

        // Set global variable for form handler with any random decimal value.
        CalcCurrentValueLCY := LibraryRandom.RandDec(100, 2);
        LibraryVariableStorage.Enqueue(CloseOpportunityCode.Code);
        LibraryVariableStorage.Enqueue(CalcCurrentValueLCY);

        // 2. Exercise: Close the Opportunity.
        Opportunity.SetRange("Contact No.", Contact."No.");
        Opportunity.FindFirst;
        Opportunity.CloseOpportunity;

        // 3. Verify: Check that the Statistics for Opportunity has been updated on Contact.
        Contact.CalcFields("Estimated Value (LCY)", "Calcd. Current Value (LCY)", "No. of Opportunities");
        Contact.TestField("No. of Opportunities", 1);  // Since one opportunity has been closed as Won.
        TempOpportunity.TestField("Calcd. Current Value (LCY)", TempOpportunity."Estimated Value (LCY)");
        // Verify: Check that the Opportunity Entry field "Calcd. Current Value" was updated with (Sales (LCY)) value.
        VerifyOpportunityEntry(Opportunity."No.", CalcCurrentValueLCY);
    end;

    [Test]
    [HandlerFunctions('VerifyNameModalFormHandler')]
    [Scope('OnPrem')]
    procedure NameDetailsAfterUpdateContact()
    var
        Contact: Record Contact;
        Salutation: Record Salutation;
        Language: Record Language;
    begin
        // Covers document number TC0062 - refer to TFS ID 21740.
        // Test updation of Name Details after updation of Contact associated with the Name Details.
        Initialize;

        // 1. Setup: Create a new Contact and input Type as Person. Find Salutation and Language.
        CreateContactAsPerson(Contact);
        Salutation.FindFirst;
        Language.FindFirst;

        // 2. Exercise: Fill in the details in the Contact.
        LibraryVariableStorage.Enqueue(Salutation.Code);
        LibraryVariableStorage.Enqueue(Language.Code);
        UpdateContactNameDetails(Contact, Salutation.Code, Language.Code);

        // 3. Verify: Open the Name Details form and check that the Name Details has been updated with the details filled earlier. This
        // will be done within the form Handler.
        RunNameDetails(Contact);
    end;

    [Test]
    [HandlerFunctions('CompanyDetailsModalFormHandler')]
    [Scope('OnPrem')]
    procedure ContactUpdateCompanyDetails()
    var
        Contact: Record Contact;
        PostCode: Record "Post Code";
        PhoneNumber: Text[30];
    begin
        // Covers document number TC0062 - refer to TFS ID 21740.
        // Test updation of Contact after updation of Company Details associated with the Contact.

        // 1. Setup: Create a new Contact. Find a Post Code and Country/Region.
        Initialize;
        LibraryMarketing.CreateCompanyContact(Contact);

        PostCode.FindFirst;
        PhoneNumber := Format(LibraryRandom.RandIntInRange(1000000, 9999999));

        // 2. Exercise: Open the Company Details form and fill in the details.
        LibraryVariableStorage.Enqueue(PostCode.Code);
        LibraryVariableStorage.Enqueue(PostCode."Country/Region Code");
        LibraryVariableStorage.Enqueue(PhoneNumber);
        RunCompanyDetails(Contact);

        // 3. Verify: Check that the Contact has been updated with the details filled earlier.
        Contact.Get(Contact."No.");  // Get refreshed instance.
        VerifyContactCompanyDetails(Contact, PostCode.Code, PostCode."Country/Region Code", PhoneNumber);
    end;

    [Test]
    [HandlerFunctions('VerifyCompanyModalFormHandler')]
    [Scope('OnPrem')]
    procedure CompanyDetailsAfterContact()
    var
        Contact: Record Contact;
        PostCode: Record "Post Code";
        PhoneNumber: Text[30];
    begin
        // Covers document number TC0062 - refer to TFS ID 21740.
        // Test updation of Company Details after updation of Contact associated with the Company Details.

        // 1. Setup: Create a new Contact. Find a Post Code and Country/Region.
        Initialize;
        LibraryMarketing.CreateCompanyContact(Contact);
        PostCode.FindFirst;
        PhoneNumber := Format(LibraryRandom.RandIntInRange(1000000, 9999999));

        // 2. Exercise: Fill in the details in the Contact.
        LibraryVariableStorage.Enqueue(PostCode.Code);
        LibraryVariableStorage.Enqueue(PostCode."Country/Region Code");
        LibraryVariableStorage.Enqueue(PhoneNumber);
        UpdateContactCompanyDetails(Contact, PostCode.Code, PostCode."Country/Region Code", PhoneNumber);

        // 3. Verify: Open the Company Details form and check that the Company Details have been updated with the details
        // filled earlier. This will be done within the form Handler.
        RunCompanyDetails(Contact);
    end;

    [Test]
    [HandlerFunctions('ModalFormMarketingSetup,ConfirmHandlerTrue')]
    [Scope('OnPrem')]
    procedure RelocateAttachments()
    var
        Attachment: Record Attachment;
        MarketingSetup2: Record "Marketing Setup";
        MarketingSetup: Page "Marketing Setup";
    begin
        // Covers document number TC0001 - refer to TFS ID 160766.
        // Test Relocation of Attachment.

        // 1. Setup:
        Initialize;
        MarketingSetup2.Get;

        // 2. Exercise: Change the Location for the Attachments.
        Clear(MarketingSetup);
        MarketingSetup.SetRecord(MarketingSetup2);
        MarketingSetup.RunModal;

        // 3. Verify: Check that location has been changed for attachments.
        Attachment.FindSet;
        repeat
            LibraryUtility.CheckFileNotEmpty(TemporaryPath + Format(Attachment."No."))
        until Attachment.Next = 0;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ContactFromCustomerCurrency()
    var
        Currency: Record Currency;
        Customer: Record Customer;
        Contact: Record Contact;
        BusinessRelation: Record "Business Relation";
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // Covers document number TC0001 - refer to TFS ID 160766.
        // Test creation of a Contact from Customer With Currency.

        // 1. Setup: Create a new Business Relation and input it in the field Bus. Rel. Code for Customers of Marketing Setup. Create a
        // new Customer. Update Currency on Customer.
        Initialize;
        LibraryERM.CreateCurrency(Currency);
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        ChangeBusinessRelationCodeForCustomers(BusinessRelation.Code);
        CreateCustomerWithCurrency(Customer, Currency.Code);

        // 2. Exercise: Create Contact from Customer by running the report Create Conts. from Customer report with Customer Currency Filter.
        Customer.SetRange("No.", Customer."No.");
        Customer.SetRange("Currency Code", Currency.Code);
        RunCreateContsFromCustomersReport(Customer);

        // 3. Verify: Check that the Contact has been created from the Customer.
        FindContactBusinessRelation(
          ContactBusinessRelation, BusinessRelation.Code, ContactBusinessRelation."Link to Table"::Customer, Customer."No.");
        Contact.Get(ContactBusinessRelation."Contact No.");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ContactFromVendorCurrency()
    var
        Vendor: Record Vendor;
        Contact: Record Contact;
        Currency: Record Currency;
        BusinessRelation: Record "Business Relation";
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // Covers document number TC0001 - refer to TFS ID 160766.
        // Test creation of a Contact from Vendor With Currency.

        // 1. Setup: Create a new Business Relation and input it in the field Bus. Rel. Code for Vendor of Marketing Setup. Create a
        // new Vendor. Update Currency on Vendor.
        Initialize;
        LibraryERM.CreateCurrency(Currency);
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        ChangeBusinessRelationCodeForVendors(BusinessRelation.Code);
        CreateVendorWithCurrency(Vendor, Currency.Code);

        // 2. Exercise: Create Contact from Vendor by running the report Create Conts. from Vendors report with Vendor Currency Filter.
        Vendor.SetRange("No.", Vendor."No.");
        Vendor.SetRange("Currency Code", Currency.Code);
        RunCreateContsFromVendorsReport(Vendor);

        // 3. Verify: Check that the Contact has been created from the Vendor.
        FindContactBusinessRelation(
          ContactBusinessRelation, BusinessRelation.Code, ContactBusinessRelation."Link to Table"::Vendor, Vendor."No.");
        Contact.Get(ContactBusinessRelation."Contact No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue')]
    [Scope('OnPrem')]
    procedure ContactFromBankAccountCurrency()
    var
        BankAccount: Record "Bank Account";
        Contact: Record Contact;
        Currency: Record Currency;
        BusinessRelation: Record "Business Relation";
        ContactBusinessRelation: Record "Contact Business Relation";
        CreateContsFromBankAccs: Report "Create Conts. from Bank Accs.";
        BusRelCodeForBankAccs: Code[10];
    begin
        // Covers document number TC0001 - refer to TFS ID 160766.
        // Test creation of a Contact from Bank Account With Currency.

        // 1. Setup: Create a new Business Relation and input it in the field Bus. Rel. Code for Bank Accs. of Marketing Setup. Create a
        // new Bank Account. Update Currency on Bank Account.
        Initialize;
        ExecuteUIHandler;
        LibraryERM.CreateCurrency(Currency);
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        BusRelCodeForBankAccs := ChangeBusinessRelationCodeForBankAccount(BusinessRelation.Code);
        LibraryERM.CreateBankAccount(BankAccount);
        CreateBankAccountWithCurrency(BankAccount, Currency.Code);

        // 2. Exercise: Create Contact from Bank Account by running the report Create Conts. from Bank report
        // with Bank Account Currency Filter.
        BankAccount.SetRange("No.", BankAccount."No.");
        BankAccount.SetRange("Currency Code", Currency.Code);
        CreateContsFromBankAccs.UseRequestPage(false);
        CreateContsFromBankAccs.SetTableView(BankAccount);
        CreateContsFromBankAccs.Run;

        // 3. Verify: Check that the Contact has been created from the Bank Account.
        FindContactBusinessRelation(
          ContactBusinessRelation, BusinessRelation.Code, ContactBusinessRelation."Link to Table"::"Bank Account", BankAccount."No.");
        Contact.Get(ContactBusinessRelation."Contact No.");

        // 4. Cleanup: Input the original value of the field Bus. Rel. Code for Bank Accs. in Marketing Setup.
        ChangeBusinessRelationCodeForBankAccount(BusRelCodeForBankAccs);
    end;

    [Test]
    [HandlerFunctions('CustomerLinkPageHandler')]
    [Scope('OnPrem')]
    procedure LinkContactWithCustomerAsContact()
    var
        Contact: Record Contact;
        Customer: Record Customer;
        BusinessRelation: Record "Business Relation";
        Name: Text[100];
        CurrMasterFields: Option Contact,Customer;
    begin
        // Check that Contact Name has not been changed after linking Customer to a Contact as Contact.

        // 1. Setup: Blank the Business Relation code for Customer to create Customer without Contact, Again update it with some value, Create a new Contact.
        Initialize;
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        ChangeBusinessRelationCodeForCustomers('');
        LibrarySales.CreateCustomer(Customer);
        LibraryVariableStorage.Enqueue(Customer."No.");
        LibraryVariableStorage.Enqueue(CurrMasterFields::Contact);
        ChangeBusinessRelationCodeForCustomers(BusinessRelation.Code);
        LibraryMarketing.CreateCompanyContact(Contact);
        Name := Contact.Name;  // Store contact name into a variable to use it for verification.

        // 2. Exercise: Link Contact with an existing Customer.
        Contact.CreateCustomerLink;

        // 3. Verify: Verify that Contact still has same name as it has prior to linking with Customer.
        Contact.Get(Contact."No.");
        Contact.TestField(Name, Name);
    end;

    [Test]
    [HandlerFunctions('CustomerLinkPageHandler')]
    [Scope('OnPrem')]
    procedure LinkContactWithCustomer()
    var
        Contact: Record Contact;
        Customer: Record Customer;
        CurrMasterFields: Option Contact,Customer;
    begin
        // Check that Contact Name has changed to Customer Name after linking Customer to a Company Contact as Customer.

        // 1. Setup: Blank the Business Relation code for Customer to create Customer without Contact, Again update it with some value, Create a new Contact.
        Initialize;
        CreateCustomerWithSetupBusinessRelation(Customer);
        LibraryVariableStorage.Enqueue(Customer."No.");
        LibraryVariableStorage.Enqueue(CurrMasterFields::Customer);
        LibraryMarketing.CreateCompanyContact(Contact);

        // 2. Exercise: Link Contact with an existing Customer.
        Contact.CreateCustomerLink;

        // 3. Verify: Verify that Contact Name updated with Customer Name after Linking with Customer.
        Contact.Get(Contact."No.");
        Contact.TestField(Name, Customer.Name);
    end;

    [Test]
    [HandlerFunctions('CustomerLinkPageHandler')]
    [Scope('OnPrem')]
    procedure LinkPersonContactWithCustomer()
    var
        Contact: Record Contact;
        Customer: Record Customer;
        CurrMasterFields: Option Contact,Customer;
    begin
        // Check that Contact Name has changed to Customer Name after linking Customer to a Person Contact as Customer.

        // 1. Setup: Blank the Business Relation code for Customer to create Customer without Contact, Again update it with some value, Create a new Contact.
        Initialize;
        CreateCustomerWithSetupBusinessRelation(Customer);
        LibraryVariableStorage.Enqueue(Customer."No.");
        LibraryVariableStorage.Enqueue(CurrMasterFields::Customer);
        LibraryMarketing.CreatePersonContact(Contact);

        // 2. Exercise: Link Contact with an existing Customer.
        Contact.CreateCustomerLink;

        // 3. Verify: Verify that Contact Name updated with Customer Name after Linking with Customer.
        Contact.Get(Contact."No.");
        Contact.TestField(Name, Customer.Name);
    end;

    [Test]
    [HandlerFunctions('VendorLinkPageHandler')]
    [Scope('OnPrem')]
    procedure LinkContactWithVendor()
    var
        Contact: Record Contact;
        BusinessRelation: Record "Business Relation";
        Vendor: Record Vendor;
    begin
        // Check that Contact Name has changed to Vendor Name after linking Vendor to a Contact as Vendor.

        // 1. Setup: Blank the Business Relation code for Vendor to create Vendor without Contact, Again update it with some value, Create a new Contact.
        Initialize;
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        ChangeBusinessRelationCodeForVendors('');
        LibraryPurchase.CreateVendor(Vendor);
        LibraryVariableStorage.Enqueue(Vendor."No.");

        ChangeBusinessRelationCodeForVendors(BusinessRelation.Code);
        LibraryMarketing.CreateCompanyContact(Contact);

        // 2. Exercise: Link Contact with an existing Vendor.
        Contact.CreateVendorLink;

        // 3. Verify: Verify that Contact Name updated with Vendor Name after Linking with Vendor.
        Contact.Get(Contact."No.");
        Contact.TestField(Name, Vendor.Name);
    end;

    [Test]
    [HandlerFunctions('BankAccountLinkPageHandler,ConfirmHandlerTrue')]
    [Scope('OnPrem')]
    procedure LinkContactWithBankAccount()
    var
        BankAccount: Record "Bank Account";
        Contact: Record Contact;
        BusinessRelation: Record "Business Relation";
        BusRelCodeForBankAccount: Code[10];
    begin
        // Check that Contact Name has changed to Bank Account Name after linking Bank Account to a Contact as Bank.

        // 1. Setup: Blank the Business Relation code for Bank Account to create Bank Account without Contact, Again update it with some value, Create a new Contact.
        Initialize;
        ExecuteUIHandler;
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        BusRelCodeForBankAccount := ChangeBusinessRelationCodeForBankAccount('');
        LibraryERM.CreateBankAccount(BankAccount);
        LibraryVariableStorage.Enqueue(BankAccount."No.");

        ChangeBusinessRelationCodeForBankAccount(BusinessRelation.Code);
        LibraryMarketing.CreateCompanyContact(Contact);

        // 2. Exercise: Link Contact with Bank Account.
        Contact.CreateBankAccountLink;

        // 3. Verify: Verify that Contact Name updated with Bank Account Name after Linking with Bank Account.
        Contact.Get(Contact."No.");
        Contact.TestField(Name, BankAccount.Name);

        // 4. Tear Down: Input the original value of the field Bus. Rel. Code for Bank Account in Marketing Setup.
        ChangeBusinessRelationCodeForBankAccount(BusRelCodeForBankAccount);
    end;

    [Test]
    [HandlerFunctions('CustomerLinkPageHandler')]
    [Scope('OnPrem')]
    procedure CustomerLinkedContact()
    var
        Contact: Record Contact;
        Customer: Record Customer;
        ContactList: TestPage "Contact List";
        CurrMasterFields: Option Contact,Customer;
    begin
        // Check that Correct Contact No and Name appears on Contact List Page after Linking Contact to Customer.

        // 1. Setup: Blank the Business Relation code for Customer to create Customer without Contact, Again update it with some value, Create a new Contact.
        // Link Contact with an existing Customer.
        Initialize;
        CreateCustomerWithSetupBusinessRelation(Customer);
        LibraryVariableStorage.Enqueue(Customer."No.");
        LibraryVariableStorage.Enqueue(CurrMasterFields::Customer);
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.CreateCustomerLink;

        // 2. Exercise: Open Contact List Page for Customer.
        ContactList.Trap;
        Customer.ShowContact;

        // 3. Verify: Verify Contact No. and Name in Contact List Page.
        ContactList."No.".AssertEquals(Contact."No.");
        ContactList.Name.AssertEquals(Customer.Name);
    end;

    [Test]
    [HandlerFunctions('VendorLinkPageHandler')]
    [Scope('OnPrem')]
    procedure VendorLinkedContact()
    var
        Contact: Record Contact;
        BusinessRelation: Record "Business Relation";
        Vendor: Record Vendor;
        ContactList: TestPage "Contact List";
    begin
        // Check that Correct Contact No and Name appears on Contact List Page after Linking Contact to Vendor.

        // 1. Setup: Blank the Business Relation code for Vendor to create Vendor without Contact, Again update it with some value, Create a new Contact.
        // Link Contact with an existing Vendor.
        Initialize;
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        ChangeBusinessRelationCodeForVendors('');
        LibraryPurchase.CreateVendor(Vendor);
        LibraryVariableStorage.Enqueue(Vendor."No.");
        ChangeBusinessRelationCodeForVendors(BusinessRelation.Code);
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.CreateVendorLink;

        // 2. Exercise: Open Contact List Page for Vendor.
        ContactList.Trap;
        Vendor.ShowContact;

        // 3. Verify: Verify correct Contact No. and Name appearing in Contact List Page.
        ContactList."No.".AssertEquals(Contact."No.");
        ContactList.Name.AssertEquals(Vendor.Name);
    end;

    [Test]
    [HandlerFunctions('BankAccountLinkPageHandler,ConfirmHandlerTrue')]
    [Scope('OnPrem')]
    procedure BankAccountLinkedContact()
    var
        BankAccount: Record "Bank Account";
        Contact: Record Contact;
        BusinessRelation: Record "Business Relation";
        ContactList: TestPage "Contact List";
        BusRelCodeForBankAccount: Code[10];
    begin
        // Check that Correct Contact No and Name appears on Contact List Page after Linking Contact to Bank Account.

        // 1. Setup: Blank the Business Relation code for Bank Account to create Bank Account without Contact, Again update it with some value, Create a new Contact.
        // Link Contact with an existing Bank Account.
        Initialize;
        ExecuteUIHandler;
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        BusRelCodeForBankAccount := ChangeBusinessRelationCodeForBankAccount('');
        LibraryERM.CreateBankAccount(BankAccount);
        LibraryVariableStorage.Enqueue(BankAccount."No.");

        ChangeBusinessRelationCodeForBankAccount(BusinessRelation.Code);
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.CreateBankAccountLink;

        // 2. Exercise: Open Contact List Page for Bank Account.
        ContactList.Trap;
        BankAccount.ShowContact;

        // 3. Verify: Verify correct Contact No. and Name appearing in Contact List Page.
        ContactList."No.".AssertEquals(Contact."No.");
        ContactList.Name.AssertEquals(BankAccount.Name);

        // 4. Tear Down: Input the original value of the field Bus. Rel. Code for Bank Account in Marketing Setup.
        ChangeBusinessRelationCodeForBankAccount(BusRelCodeForBankAccount);
    end;

    [Test]
    [HandlerFunctions('CustomerLinkPageHandler')]
    [Scope('OnPrem')]
    procedure ContactWithUpdatedCustomer()
    var
        Contact: Record Contact;
        Customer: Record Customer;
        CustomerCard: TestPage "Customer Card";
        NewName: Text[100];
        CurrMasterFields: Option Contact,Customer;
    begin
        // Check that Contact Name gets updated after updating Customer Name for a Customer linked with Contact.

        // 1. Setup: Blank the Business Relation code for Customer to create Customer without Contact, Again update it with some value, Create a new Contact.
        // Link Contact with an existing Customer.
        Initialize;
        NewName := LibraryUtility.GenerateGUID;
        CreateCustomerWithSetupBusinessRelation(Customer);
        LibraryVariableStorage.Enqueue(Customer."No.");
        LibraryVariableStorage.Enqueue(CurrMasterFields::Customer);
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.CreateCustomerLink;

        // 2. Exercise: Update Customer Name with some new name.
        CustomerCard.OpenEdit;
        CustomerCard.FILTER.SetFilter("No.", Customer."No.");
        CustomerCard.Name.SetValue(NewName);
        CustomerCard.OK.Invoke;

        // 3. Verify: Verify that Contact Name gets updated with the new Customer Name.
        Contact.Get(Contact."No.");
        Contact.TestField(Name, NewName);
    end;

    [Test]
    [HandlerFunctions('VendorLinkPageHandler')]
    [Scope('OnPrem')]
    procedure ContactWithUpdatedVendor()
    var
        Contact: Record Contact;
        BusinessRelation: Record "Business Relation";
        Vendor: Record Vendor;
        VendorCard: TestPage "Vendor Card";
        NewName: Text[100];
    begin
        // Check that Contact Name gets updated after updating Vendor Name for a Vendor linked with Contact.

        // 1. Setup: Blank the Business Relation code for Vendor to create Vendor without Contact, Again update it with some value, Create a new Contact.
        // Link Contact with an existing Vendor.
        Initialize;
        NewName := LibraryUtility.GenerateGUID;
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        ChangeBusinessRelationCodeForVendors('');
        LibraryPurchase.CreateVendor(Vendor);
        LibraryVariableStorage.Enqueue(Vendor."No.");
        ChangeBusinessRelationCodeForVendors(BusinessRelation.Code);
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.CreateVendorLink;

        // 2. Exercise: Update Vendor Name.
        VendorCard.OpenEdit;
        VendorCard.FILTER.SetFilter("No.", Vendor."No.");
        VendorCard.Name.SetValue(NewName);
        VendorCard.OK.Invoke;

        // 3. Verify: Verify that updated Vendor Name reflected in Contact Name.
        Contact.Get(Contact."No.");
        Contact.TestField(Name, NewName);
    end;

    [Test]
    [HandlerFunctions('BankAccountLinkPageHandler,ConfirmHandlerTrue')]
    [Scope('OnPrem')]
    procedure ContactWithUpdatedBankAccount()
    var
        BankAccount: Record "Bank Account";
        Contact: Record Contact;
        BusinessRelation: Record "Business Relation";
        BankAccountCard: TestPage "Bank Account Card";
        BusRelCodeForBankAccount: Code[10];
        NewName: Text[100];
    begin
        // Check that Contact Name gets updated after updating Bank Account Name for a Bank Account linked with Contact.

        // 1. Setup: Blank the Business Relation code for Bank Account to create Bank Account without Contact, Again update it with some value, Create a new Contact.
        // Link Contact with an existing Bank Account.
        Initialize;
        ExecuteUIHandler;
        NewName := LibraryUtility.GenerateGUID;
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        BusRelCodeForBankAccount := ChangeBusinessRelationCodeForBankAccount('');
        LibraryERM.CreateBankAccount(BankAccount);
        LibraryVariableStorage.Enqueue(BankAccount."No.");
        ChangeBusinessRelationCodeForBankAccount(BusinessRelation.Code);
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.CreateBankAccountLink;

        // 2. Exercise: Update Bank Account Name on Bank Account Card.
        BankAccountCard.OpenEdit;
        BankAccountCard.FILTER.SetFilter("No.", BankAccount."No.");
        BankAccountCard.Name.SetValue(NewName);
        BankAccountCard.OK.Invoke;

        // 3. Verify: Verify that updated Bank Account Name reflects on Contact.
        Contact.Get(Contact."No.");
        Contact.TestField(Name, NewName);

        // 4. Tear Down: Input the original value of the field Bus. Rel. Code for Bank Account in Marketing Setup.
        ChangeBusinessRelationCodeForBankAccount(BusRelCodeForBankAccount);
    end;

    [Test]
    [HandlerFunctions('CustomerLinkPageHandler')]
    [Scope('OnPrem')]
    procedure UpdateContactLinkedToCustomer()
    var
        Contact: Record Contact;
        Customer: Record Customer;
        NewName: Text[100];
        CurrMasterFields: Option Contact,Customer;
    begin
        // Check that Customer Name updated after Linking Contact to Customer and updating Contact Name on Contact Card.

        // 1. Setup: Blank the Business Relation code for Customer to create Customer without Contact, Again update it with some value, Create a new Contact.
        Initialize;
        CreateCustomerWithSetupBusinessRelation(Customer);
        LibraryVariableStorage.Enqueue(Customer."No.");
        LibraryVariableStorage.Enqueue(CurrMasterFields::Customer);
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.CreateCustomerLink;
        NewName := LibraryUtility.GenerateGUID;

        // 2. Exercise.
        UpdateNameOnContactCard(Contact."No.", NewName);

        // 3. Verify: Verify that updated Contact Name reflected on Customer.
        Customer.Get(Customer."No.");
        Customer.TestField(Name, NewName);
    end;

    [Test]
    [HandlerFunctions('VendorLinkPageHandler')]
    [Scope('OnPrem')]
    procedure UpdateContactLinkedToVendor()
    var
        Contact: Record Contact;
        BusinessRelation: Record "Business Relation";
        Vendor: Record Vendor;
        NewName: Text[100];
    begin
        // Check that Vendor Name updated after Linking Contact to Vendor and updating Contact Name on Contact Card.

        // 1. Setup: Blank the Business Relation code for Vendor to create Vendor without Contact, Again update it with some value, Create a new Contact.
        Initialize;
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        ChangeBusinessRelationCodeForVendors('');
        LibraryPurchase.CreateVendor(Vendor);
        LibraryVariableStorage.Enqueue(Vendor."No.");

        ChangeBusinessRelationCodeForVendors(BusinessRelation.Code);
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.CreateVendorLink;
        NewName := LibraryUtility.GenerateGUID;

        // 2. Exercise.
        UpdateNameOnContactCard(Contact."No.", NewName);

        // 3. Verify: Verify that updated Contact Name reflected on Vendor.
        Vendor.Get(Vendor."No.");
        Vendor.TestField(Name, NewName);
    end;

    [Test]
    [HandlerFunctions('BankAccountLinkPageHandler,ConfirmHandlerTrue')]
    [Scope('OnPrem')]
    procedure UpdateContactLinkedToBankAccount()
    var
        BankAccount: Record "Bank Account";
        Contact: Record Contact;
        BusinessRelation: Record "Business Relation";
        NewName: Text[100];
        BusRelCodeForBankAccount: Code[10];
    begin
        // Check that Bank Account Name updated after Linking Contact to Bank Account and updating Contact Name on Contact Card.

        // 1. Setup: Blank the Business Relation code for Bank Account to create Bank Account without Contact, Again update it with some value, Create a new Contact.
        Initialize;
        ExecuteUIHandler;
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        BusRelCodeForBankAccount := ChangeBusinessRelationCodeForBankAccount('');
        LibraryERM.CreateBankAccount(BankAccount);
        LibraryVariableStorage.Enqueue(BankAccount."No.");
        ChangeBusinessRelationCodeForBankAccount(BusinessRelation.Code);
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.CreateBankAccountLink;
        NewName := LibraryUtility.GenerateGUID;

        // 2. Exercise.
        UpdateNameOnContactCard(Contact."No.", NewName);

        // 3. Verify: Verify that updated Contact Name reflected on Bank Account.
        BankAccount.Get(BankAccount."No.");
        BankAccount.TestField(Name, NewName);

        // 4. Cleanup: Input the original value of the field Bus. Rel. Code for Bank Account in Marketing Setup.
        ChangeBusinessRelationCodeForBankAccount(BusRelCodeForBankAccount);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ContactDeletion()
    var
        Contact: Record Contact;
    begin
        // Check Deletion of Contact Created.

        // 1. Setup.
        Initialize;
        LibraryMarketing.CreateCompanyContact(Contact);

        // 2. Exercise: Delete the contact created earlier.
        Contact.Delete(true);

        // 3. Verify: Verify that Contact not exist after deletion.
        Contact.SetRange("No.", Contact."No.");
        Assert.IsFalse(Contact.FindFirst, StrSubstNo(ErrorMessage, Contact.TableCaption, Contact."No."));
    end;

    [Test]
    [HandlerFunctions('CustomerLinkPageHandler')]
    [Scope('OnPrem')]
    procedure DeleteContactLinkedToCustomer()
    var
        Contact: Record Contact;
        Customer: Record Customer;
        CurrMasterFields: Option Contact,Customer;
    begin
        // Check that Customer still exists after deleting Contact linked with Customer.

        // 1. Setup: Blank the Business Relation code for Customer to create Customer without Contact, Again update it with some value, Create a new Contact.
        // Create Contact Link for Customer.
        Initialize;
        CreateCustomerWithSetupBusinessRelation(Customer);
        LibraryVariableStorage.Enqueue(Customer."No.");
        LibraryVariableStorage.Enqueue(CurrMasterFields::Customer);
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.CreateCustomerLink;

        // 2. Exercise.
        Contact.Delete(true);

        // 3. Verify: Verify that Customer linked to Contact still exists.
        Customer.SetRange("No.", Customer."No.");
        Assert.IsTrue(Customer.FindFirst, StrSubstNo(ValidationError, Customer.TableCaption, Customer."No."));
    end;

    [Test]
    [HandlerFunctions('VendorLinkPageHandler')]
    [Scope('OnPrem')]
    procedure DeleteContactLinkedToVendor()
    var
        Contact: Record Contact;
        BusinessRelation: Record "Business Relation";
        Vendor: Record Vendor;
    begin
        // Check that Vendor still exists after deleting Contact linked with Vendor.

        // 1. Setup: Blank the Business Relation code for Vendor to create Vendor without Contact, Again update it with some value, Create a new Contact.
        // Create Contact Link for Vendor.
        Initialize;
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        ChangeBusinessRelationCodeForVendors('');
        LibraryPurchase.CreateVendor(Vendor);
        LibraryVariableStorage.Enqueue(Vendor."No.");
        ChangeBusinessRelationCodeForVendors(BusinessRelation.Code);
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.CreateVendorLink;

        // 2. Exercise.
        Contact.Delete(true);

        // 3. Verify: Verify that Vendor linked to Contact still exists.
        Assert.IsTrue(Vendor.Get(Vendor."No."), StrSubstNo(ValidationError, Vendor.TableCaption, Vendor."No."));
    end;

    [Test]
    [HandlerFunctions('BankAccountLinkPageHandler,ConfirmHandlerTrue')]
    [Scope('OnPrem')]
    procedure DeleteContactLinkedToBankAccount()
    var
        BankAccount: Record "Bank Account";
        Contact: Record Contact;
        BusinessRelation: Record "Business Relation";
        BusRelCodeForBankAccount: Code[10];
    begin
        // Check that Bank Account still exists after deleting Contact linked with Bank Account.

        // 1. Setup: Blank the Business Relation code for Bank Account to create Bank Account without Contact, Again update it with some value, Create a new Contact.
        // Create Contact Link for Bank Account.
        Initialize;
        ExecuteUIHandler;
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        BusRelCodeForBankAccount := ChangeBusinessRelationCodeForBankAccount('');
        LibraryERM.CreateBankAccount(BankAccount);
        LibraryVariableStorage.Enqueue(BankAccount."No.");

        ChangeBusinessRelationCodeForBankAccount(BusinessRelation.Code);
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.CreateBankAccountLink;

        // 2. Exercise.
        Contact.Delete(true);

        // 3. Verify: Verify that Bank Account linked to Contact still exists.
        Assert.IsTrue(BankAccount.Get(BankAccount."No."), StrSubstNo(ValidationError, BankAccount.TableCaption, BankAccount."No."));

        // 4. Tear Down: Input the original value of the field Bus. Rel. Code for Bank Account in Marketing Setup.
        ChangeBusinessRelationCodeForBankAccount(BusRelCodeForBankAccount);
    end;

    [Test]
    [HandlerFunctions('CustomerLinkPageHandler,ConfirmHandlerTrue')]
    [Scope('OnPrem')]
    procedure DeleteCustomerLinkedToContact()
    var
        Contact: Record Contact;
        Customer: Record Customer;
        BusinessRelation: Record "Business Relation";
        ContactBusinessRelation: Record "Contact Business Relation";
        ContactList: TestPage "Contact List";
        ContactNo: Code[20];
        CurrMasterFields: Option Contact,Customer;
    begin
        // Check that new Contact exists after deleting Contact and then its linked Customer.

        // 1. Setup: Blank the Business Relation code for Customer to create Customer without Contact, Again update it with some value, Create a new Contact.
        // Create Customer link for Contact. Delete the Contact and then open Contact List Page for Customer.
        Initialize;
        CreateCustomerWithSetupBusinessRelation(Customer);
        LibraryVariableStorage.Enqueue(Customer."No.");
        LibraryVariableStorage.Enqueue(CurrMasterFields::Customer);
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.CreateCustomerLink;  // Create Customer Link for Contact.

        // 2. Exercise.
        Contact.Delete(true);

        // 3. Verify
        Assert.IsFalse(ContactBusinessRelation.Get(Contact."No.", BusinessRelation.Code), '');

        // 2. Exercise
        ContactList.Trap;
        Customer.ShowContact;  // Show contact for Customer.
        ContactNo := ContactList."No.".Value;
        Customer.Get(Customer."No.");
        Customer.Delete(true);

        // 3. Verify: Verify that Contact still exists after deleting linked Customer.
        Assert.IsTrue(Contact.Get(ContactNo), StrSubstNo(ValidationError, Contact.TableCaption, ContactNo));
    end;

    [Test]
    [HandlerFunctions('VendorLinkPageHandler,ConfirmHandlerTrue')]
    [Scope('OnPrem')]
    procedure DeleteVendorLinkedToContact()
    var
        Contact: Record Contact;
        BusinessRelation: Record "Business Relation";
        ContactBusinessRelation: Record "Contact Business Relation";
        Vendor: Record Vendor;
        ContactList: TestPage "Contact List";
        ContactNo: Code[20];
    begin
        // Check that new Contact exists after deleting Contact and then its linked Vendor.

        // 1. Setup: Blank the Business Relation code for Vendor to create Vendor without Contact, Again update it with some value, Create a new Contact.
        // Create Vendor link for Contact. Delete the Contact and then open Contact List Page for Vendor.
        Initialize;
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        ChangeBusinessRelationCodeForVendors('');
        LibraryPurchase.CreateVendor(Vendor);
        LibraryVariableStorage.Enqueue(Vendor."No.");
        ChangeBusinessRelationCodeForVendors(BusinessRelation.Code);
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.CreateVendorLink;

        // 2. Exercise
        Contact.Delete(true);

        // 3. Verify
        Assert.IsFalse(ContactBusinessRelation.Get(Contact."No.", BusinessRelation.Code), '');

        // 2. Exercise.
        ContactList.Trap;
        Vendor.ShowContact;  // Show contact for Customer.
        ContactNo := ContactList."No.".Value;
        Vendor.Get(Vendor."No.");
        Vendor.Delete(true);

        // 3. Verify: Verify that Contact still exists after deleting linked Vendor.
        Assert.IsTrue(Contact.Get(ContactNo), StrSubstNo(ValidationError, Contact.TableCaption, ContactNo));
    end;

    [Test]
    [HandlerFunctions('BankAccountLinkPageHandler,ConfirmHandlerTrue')]
    [Scope('OnPrem')]
    procedure DeleteBankAccountLinkedToContact()
    var
        BankAccount: Record "Bank Account";
        Contact: Record Contact;
        BusinessRelation: Record "Business Relation";
        ContactList: TestPage "Contact List";
        ContactNo: Code[20];
        BusRelCodeForBankAccount: Code[10];
    begin
        // Check that new Contact exists after deleting Contact and then its linked Bank Account.

        // 1. Setup: Blank the Business Relation code for Bank Account to create Bank Account without Contact, Again update it with some value, Create a new Contact.
        // Create Bank Account link for Contact. Delete the Contact and then open Contact List Page for Bank Account.
        Initialize;
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        BusRelCodeForBankAccount := ChangeBusinessRelationCodeForBankAccount('');
        LibraryERM.CreateBankAccount(BankAccount);
        LibraryVariableStorage.Enqueue(BankAccount."No.");
        ChangeBusinessRelationCodeForBankAccount(BusinessRelation.Code);
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.CreateBankAccountLink;
        Contact.Delete(true);

        ContactList.Trap;
        BankAccount.ShowContact;  // Show contact for Customer.
        ContactNo := ContactList."No.".Value;

        // 2. Exercise.
        BankAccount.Find;
        BankAccount.Delete(true);

        // 3. Verify: Verify that Contact still exists after deleting linked Bank Account.
        Assert.IsTrue(Contact.Get(ContactNo), StrSubstNo(ValidationError, Contact.TableCaption, ContactNo));

        // 4. Tear Down: Input the original value of the field Bus. Rel. Code for Bank Account in Marketing Setup.
        ChangeBusinessRelationCodeForBankAccount(BusRelCodeForBankAccount);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ContactLinkErrorForCustomer()
    var
        Contact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
        MarketingSetup: Record "Marketing Setup";
        CurrMasterFields: Option Contact,Customer;
    begin
        // Check Error Message while trying to create a new Customer Link for Contact that is already having Customer Link.
        Initialize;

        // 1. Setup: Find a Contact that is having Customer as Business Relation.
        MarketingSetup.Get;
        FindContactBusinessRelation(
          ContactBusinessRelation, MarketingSetup."Bus. Rel. Code for Customers", ContactBusinessRelation."Link to Table"::Customer,
          '<>''''');
        Contact.Get(ContactBusinessRelation."Contact No.");
        LibraryVariableStorage.Enqueue(ContactBusinessRelation."No.");
        LibraryVariableStorage.Enqueue(CurrMasterFields::Customer);

        // 2. Exercise: Try to create Customer Link for Contact, Verify Error Message.
        asserterror Contact.CreateCustomerLink;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ContactLinkErrorForVendor()
    var
        Contact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
        MarketingSetup: Record "Marketing Setup";
    begin
        // Check Error Message while trying to create a new Vendor Link for Contact that is already having Vendor Link.
        Initialize;

        // 1. Setup: Find a Contact that is having Vendor as Business Relation.
        MarketingSetup.Get;
        FindContactBusinessRelation(
          ContactBusinessRelation, MarketingSetup."Bus. Rel. Code for Vendors", ContactBusinessRelation."Link to Table"::Vendor, '<>''''');
        Contact.Get(ContactBusinessRelation."Contact No.");
        LibraryVariableStorage.Enqueue(ContactBusinessRelation."No.");

        // 2. Exercise and Verify: Try to create Vendor Link for Contact, Verify Error Message.
        asserterror Contact.CreateVendorLink;
    end;

    [Test]
    [HandlerFunctions('BankAccountLinkPageHandler,MessageHandler')]
    [Scope('OnPrem')]
    procedure ContactLinkErrorForBank()
    var
        Contact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
        MarketingSetup: Record "Marketing Setup";
    begin
        // Check Error Message while trying to create a new Bank Account Link for Contact that is already having Bank Account Link.
        Initialize;

        // 1. Setup: Find a Contact that is having Bank Account as Business Relation.
        MarketingSetup.Get;
        FindContactBusinessRelation(
          ContactBusinessRelation, MarketingSetup."Bus. Rel. Code for Bank Accs.",
          ContactBusinessRelation."Link to Table"::"Bank Account", '<>''''');
        Contact.Get(ContactBusinessRelation."Contact No.");
        LibraryVariableStorage.Enqueue(ContactBusinessRelation."No.");

        // 2. Exercise: Try to create Bank Account Link for Contact.
        Contact.CreateBankAccountLink;

        // 3. Verify: Verify Error Message.
        Assert.ExpectedError(
          StrSubstNo(
            BusinessRelationError, Contact.TableCaption, Contact."No.", ContactBusinessRelation."Link to Table",
            ContactBusinessRelation."No."));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ModifyAttachmentOnContactInteraction()
    var
        SegmentLine: Record "Segment Line";
        Attachment: Record Attachment;
        TempNewAttachment: Record Attachment temporary;
        TempInterLogEntryCommentLine: Record "Inter. Log Entry Comment Line" temporary;
        SegMgt: Codeunit SegManagement;
    begin
        // create new interaction with attachment
        Initialize;

        CreateWriteAttachment(Attachment);
        CreateSegmentLine(SegmentLine, Attachment."No.");
        CreateInteractLogEntry(SegmentLine."Line No.");

        // create new attachment
        CreateWriteAttachment(TempNewAttachment);

        // update current interaction with new attachment
        SegMgt.LogInteraction(SegmentLine, TempNewAttachment, TempInterLogEntryCommentLine, false, true);

        // verify that attachment is exist
        Attachment.Find;
        Assert.IsTrue(Attachment."Attachment File".HasValue, EmptyAttachmentErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ContactBracketsOpenContactCard()
    var
        Contact: Record Contact;
        ContactCard: TestPage "Contact Card";
    begin
        // [SCENARIO] Check Contact with brackets in 'No.' can be opened without errors
        Initialize;
        // [GIVEN] Contact with Brackets symbols in 'No.' field
        CreateSimpleContact(Contact, CreateContactNameWithBrackets);
        // [WHEN] Contact Card for Contact with brackets in 'No.' is opened
        OpenContactCard(ContactCard, Contact);
        // [THEN] Contact Card successfully opened with no Errors
        ContactCard.OK.Invoke;

        // Tear Down
        Contact.Delete;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ContactBracketsOpenTaskList()
    var
        Contact: Record Contact;
        ContactCard: TestPage "Contact Card";
        TaskList: TestPage "Task List";
    begin
        // [SCENARIO] Check Task List page can be opened without errors for Contact with brackets in 'No.'
        Initialize;
        // [GIVEN] Contact with Brackets symbols in 'No.' field
        CreateSimpleContact(Contact, CreateContactNameWithBrackets);
        // [WHEN] To-do List page opened from Contact with Brackets symbols in 'No.' field
        OpenContactCard(ContactCard, Contact);
        TaskList.Trap;
        ContactCard."T&asks".Invoke;
        // [THEN] Page Task List successfully opened
        TaskList.Close;

        // Tear Down
        Contact.Delete;
    end;

    [Test]
    [HandlerFunctions('ContactHandler')]
    [Scope('OnPrem')]
    procedure InsertContactWithCompanyFilter()
    var
        Contact: Record Contact;
        CompanyFilter: Code[20];
    begin
        // [SCENARIO 375315] New Contact for the Company should be of Type Person linked to the Company
        Initialize;

        // [GIVEN] Filter "X" on field "Company No." of Contact Page
        CompanyFilter := LibraryUtility.GenerateGUID;
        CreateCompanyContact(CompanyFilter);
        Contact.Init;
        Contact.SetRange("Company No.", CompanyFilter);

        // [WHEN] Insert Contact
        LibraryVariableStorage.Enqueue(Contact."Company Name"); // Enqueue for ContactHandler
        LibraryVariableStorage.Enqueue('Person');
        PAGE.Run(PAGE::"Contact Card", Contact);

        // [THEN] Contact is created where "Company No." is "X", Type = "Person"
        // Verified in ContactHandler
    end;

    [Test]
    [HandlerFunctions('ContactHandler')]
    [Scope('OnPrem')]
    procedure InsertContactWithoutCompanyFilter()
    var
        Contact: Record Contact;
    begin
        // [SCENARIO 375315] New Contact should be of Type Company not linked to a Company
        Initialize;

        // [GIVEN] No filters applied on field "Company No." of Contact Page
        Contact.Init;

        // [WHEN] Insert Contact
        LibraryVariableStorage.Enqueue(''); // Enqueue for ContactHandler
        LibraryVariableStorage.Enqueue('Company');
        PAGE.Run(PAGE::"Contact Card", Contact);

        // [THEN] Contact is created where "Company No." is blank, Type = "Company"
        // Verified in ContactHandler
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ContactBusinessRelationIsCreatedWithoutValidationCheckWhenNonUIRun()
    var
        Contact: Record Contact;
        BusinessRelation: Record "Business Relation";
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // [FEATURE] [Contact Business Relation]
        // [SCENARIO 375531] Contact Business Relation record is created without "Business Relation Code" field validation check in case of non-UI running
        Initialize;

        // [GIVEN] Create new Business Relation Code "X".
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);

        // [GIVEN] Modify MarketingSetup."Bus. Rel. Code for Customers" = "X".
        ChangeBusinessRelationCodeForCustomers(BusinessRelation.Code);

        // [GIVEN] Create Contact "C"
        LibraryMarketing.CreateCompanyContact(Contact);

        // [WHEN] Create Contact Business Relation without UI validation: "Contact No." = "C", "Business Relation Code" = "X"
        LibraryMarketing.CreateContactBusinessRelation(ContactBusinessRelation, Contact."No.", BusinessRelation.Code);

        // [THEN] New Contact Business Relation record is created without "Business Relation Code" field validation check
        ContactBusinessRelation.SetRange("Contact No.", Contact."No.");
        Assert.RecordIsNotEmpty(ContactBusinessRelation);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ContactBusinessRelationIsCreatedWithValidationCheckWhenUIRun()
    var
        Contact: Record Contact;
        Customer: Record Customer;
        BusinessRelation: Record "Business Relation";
        ContactBusinessRelation: Record "Contact Business Relation";
        BusinessRelationContacts: TestPage "Business Relation Contacts";
    begin
        // [FEATURE] [Contact Business Relation]
        // [SCENARIO 375531] Contact Business Relation record is created with "Business Relation Code" field validation check in case of UI running
        Initialize;

        // [GIVEN] Create new Business Relation Code "X".
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);

        // [GIVEN] Modify MarketingSetup."Bus. Rel. Code for Customers" = "X".
        ChangeBusinessRelationCodeForCustomers(BusinessRelation.Code);

        // [GIVEN] Create Contact "C"
        LibraryMarketing.CreateCompanyContact(Contact);

        // [WHEN] Create Contact Business Relation with through UI page: "Contact No." = "C"
        BusinessRelationContacts.OpenEdit;
        BusinessRelationContacts.FILTER.SetFilter("Business Relation Code", BusinessRelation.Code);
        BusinessRelationContacts.New;
        asserterror BusinessRelationContacts."Contact No.".SetValue(Contact."No.");

        // [THEN] Error occurs: "Business Relation Code" field validation check
        Assert.ExpectedErrorCode('TestValidation');
        Assert.ExpectedError(
          StrSubstNo(
            BusRelContactValidationErr,
            ContactBusinessRelation.FieldCaption("Business Relation Code"),
            BusinessRelation.Code,
            Contact.TableCaption, Customer.TableCaption));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PageContactBusinessRelationsShowsDetailsFields()
    var
        Customer: Record Customer;
        BusinessRelation: Record "Business Relation";
        ContactBusinessRelation: Record "Contact Business Relation";
        ContactBusinessRelations: TestPage "Contact Business Relations";
    begin
        // [SCENARIO 375706] Check "Contact Business Relations" page 5061 shows "Link to Table" and "No." fields
        Initialize;

        // [GIVEN] Business Relation "X". Set "X" as default Business Relation Code for Customers.
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        ChangeBusinessRelationCodeForCustomers(BusinessRelation.Code);

        // [GIVEN] Customer "A" linked to Contact "B".
        LibrarySales.CreateCustomer(Customer);

        // [WHEN] Open "Contact Business Relations" page for Contact "B".
        FindContactBusinessRelation(
          ContactBusinessRelation, BusinessRelation.Code, ContactBusinessRelation."Link to Table"::Customer, Customer."No.");
        ContactBusinessRelations.OpenView;
        ContactBusinessRelations.GotoRecord(ContactBusinessRelation);

        // [THEN] Contact Business Relation "B" is shown, where "Business Relation Code" = "X", "Link to Table" = Customer, "No."= "A"
        ContactBusinessRelations."Business Relation Code".AssertEquals(BusinessRelation.Code);
        ContactBusinessRelations."Link to Table".AssertEquals(ContactBusinessRelation."Link to Table"::Customer);
        ContactBusinessRelations."No.".AssertEquals(Customer."No.");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PageBusinessRelationContactsShowsDetailsFields()
    var
        Customer: Record Customer;
        BusinessRelation: Record "Business Relation";
        ContactBusinessRelation: Record "Contact Business Relation";
        BusinessRelationContacts: TestPage "Business Relation Contacts";
    begin
        // [SCENARIO 375706] Check "Business Relation Contacts" page 5062 shows "Link to Table" and "No." fields
        Initialize;

        // [GIVEN] Business Relation "X". Set "X" as default Business Relation Code for Customers.
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        ChangeBusinessRelationCodeForCustomers(BusinessRelation.Code);

        // [GIVEN] Customer "A" linked to Contact "B".
        LibrarySales.CreateCustomer(Customer);

        // [WHEN] Open "Business Relation Contacts" page for "X" code.
        FindContactBusinessRelation(
          ContactBusinessRelation, BusinessRelation.Code, ContactBusinessRelation."Link to Table"::Customer, Customer."No.");
        BusinessRelationContacts.OpenView;
        BusinessRelationContacts.GotoRecord(ContactBusinessRelation);

        // [THEN] Business Relation Contact "X" is shown, where "Contact No." = "B", "Link to Table" = Customer, "No."= "A"
        BusinessRelationContacts."Contact No.".AssertEquals(ContactBusinessRelation."Contact No.");
        BusinessRelationContacts."Link to Table".AssertEquals(ContactBusinessRelation."Link to Table"::Customer);
        BusinessRelationContacts."No.".AssertEquals(Customer."No.");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ContactWithBlankAddressGetsUpdatedWhenAssignToCompany()
    var
        Contact: Record Contact;
        CompanyContact: Record Contact;
    begin
        // Check that empty contact address fields get updated after linking contact to company.

        // [GIVEN] Person contact with blank address and company contact with address exist
        Initialize;
        CreateContactAsPerson(Contact);
        Contact.Validate("Company No.", '');
        Contact.Modify;
        CompanyContact.Get(CreateCompanyContact(LibraryUtility.GenerateGUID));
        SetAddress(CompanyContact);
        CompanyContact.Modify;

        // [WHEN] Person contact is assigned to the company contact
        Contact.Validate("Company No.", CompanyContact."No.");

        // [THEN] Person contact address fields are updated to the company contact address fields
        VerifySameAddress(CompanyContact, Contact);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ContactWithNonBlankAddressNotUpdatedWhenAssignToCompany()
    var
        OldContact: Record Contact;
        Contact: Record Contact;
        CompanyContact: Record Contact;
    begin
        // Check that non empty contact address fields don't get updated after linking contact to company.

        // [GIVEN] Person contact and company contact exist, each with nonempty address fields
        Initialize;
        CreateContactAsPerson(Contact);
        CompanyContact.Get(CreateCompanyContact(LibraryUtility.GenerateGUID));
        SetAddress(CompanyContact);
        CompanyContact.Modify;
        SetAddress(Contact);
        Contact.Validate("Company No.", '');
        Contact.Modify;
        OldContact.TransferFields(Contact);

        // [WHEN] Person contact is assigned to the company contact
        Contact.Validate("Company No.", CompanyContact."No.");

        // [THEN] Address fields of person contact did not change
        VerifySameAddress(OldContact, Contact);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ContactWithCompanyAddressGetsUpdatedWhenAssignToNewCompany()
    var
        Contact: Record Contact;
        CompanyContact1: Record Contact;
        CompanyContact2: Record Contact;
    begin
        // Check that contact address fields get updated after linking contact to a new company.

        // [GIVEN] Person contact and two company contacts exist
        Initialize;
        CreateContactAsPerson(Contact);
        Contact.Validate("Company No.", '');
        Contact.Modify;
        CompanyContact1.Get(CreateCompanyContact(LibraryUtility.GenerateGUID));
        CompanyContact2.Get(CreateCompanyContact(LibraryUtility.GenerateGUID));

        // [WHEN] Company contacts are given different addresses
        SetAddress(CompanyContact1);
        SetAddress(CompanyContact2);
        CompanyContact1.Modify;
        CompanyContact2.Modify;

        // [WHEN] Person contact is assigned to a company
        Contact.Validate("Company No.", CompanyContact1."No.");

        // [WHEN] Person contact is assigned to a different company
        Contact.Validate("Company No.", CompanyContact2."No.");

        // [THEN] Person contact address gets changed to the company address
        VerifySameAddress(CompanyContact2, Contact);
    end;

    [Test]
    [HandlerFunctions('ContactListModalPageHandler,ConfirmHandlerTrue,CustomerTempModalFormHandler,SalesQuoteReportRequestPageHandler')]
    [Scope('OnPrem')]
    procedure SalesQuoteForContactCustomerTemplate()
    var
        Contact: Record Contact;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        CustomerTemplateCode: Code[10];
    begin
        // [SCENARIO 180155] Create Sales Quote for Contact with Customer Template selection
        Initialize;
        UpdateCompanyInformationPaymentInfo(true);

        // [GIVEN] Customer Template "CT", Contact "C" with type Company
        CreateVATPostingSetup(VATPostingSetup);
        LibraryMarketing.CreateCompanyContact(Contact);
        LibraryVariableStorage.Enqueue(Contact."No.");
        CustomerTemplateCode := CreateCustomerTemplateForContact(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] New Sales Quote "SQ"
        CreateSalesQuote(SalesHeader);

        // [WHEN] User looks up in Sell-to Contact field, selects Contact "C" and selects Customer Template "CT"
        SalesQuoteContactNoLookup(SalesHeader);

        // [THEN] Sales Document "SQ" has Customer Template = "CT"
        SalesHeader.TestField("Sell-to Customer Template Code", CustomerTemplateCode);

        // [WHEN] Sales Line with Item added
        LibraryERM.CreateGenProdPostingGroup(GenProductPostingGroup);
        LibrarySales.CreateSalesLine(
          SalesLine, SalesHeader, SalesLine.Type::Item,
          LibraryInventory.CreateItemNoWithPostingSetup(GenProductPostingGroup.Code, VATPostingSetup."VAT Prod. Posting Group"),
          LibraryRandom.RandInt(10));

        // [THEN] Sales Quote Report can be printed
        PrintSalesQuoteReport(SalesHeader);
    end;

    [Test]
    [HandlerFunctions('ContactListModalPageHandler,ConfirmHandlerTrue,CustomerTempModalFormHandler,SalesQuoteReportRequestPageHandler')]
    [Scope('OnPrem')]
    procedure SalesQuoteForContactPersonCustomerTemplate()
    var
        ContactPerson: Record Contact;
        ContactCompany: Record Contact;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        CustomerTemplateCode: Code[10];
    begin
        // [SCENARIO 180155] Create Sales Quote for Contact which is a contact for Company Contact
        Initialize;
        UpdateCompanyInformationPaymentInfo(true);

        // [GIVEN] Contact "C1" with type Company
        ContactCompany.Get(CreateCompanyContact(LibraryUtility.GenerateGUID));

        // [GIVEN] Contact "C2" with type Person and Company No = "C1"
        CreateContactAsPerson(ContactPerson);
        ContactPerson."Company No." := ContactCompany."No.";
        ContactPerson.Modify;
        LibraryVariableStorage.Enqueue(ContactPerson."No.");

        // [GIVEN] Customer Template "CT"
        CreateVATPostingSetup(VATPostingSetup);
        CustomerTemplateCode := CreateCustomerTemplateForContact(VATPostingSetup."VAT Bus. Posting Group");

        // [GIVEN] New Sales Quote "SQ"
        CreateSalesQuote(SalesHeader);

        // [WHEN] User looks up in Sell-to Contact field, selects Contact "C2" and selects Customer Template "CT"
        SalesQuoteContactNoLookup(SalesHeader);

        // [THEN] Sales Document "SQ" has Customer Template = "CT"
        SalesHeader.TestField("Sell-to Customer Template Code", CustomerTemplateCode);

        // [WHEN] Sales Line with Item added
        LibraryERM.CreateGenProdPostingGroup(GenProductPostingGroup);
        LibrarySales.CreateSalesLine(
          SalesLine, SalesHeader, SalesLine.Type::Item,
          LibraryInventory.CreateItemNoWithPostingSetup(GenProductPostingGroup.Code, VATPostingSetup."VAT Prod. Posting Group"),
          LibraryRandom.RandInt(10));

        // [THEN] Sales Quote Report can be printed
        PrintSalesQuoteReport(SalesHeader);
    end;

    [Test]
    [HandlerFunctions('ContactListModalPageHandler,MessageHandler')]
    [Scope('OnPrem')]
    procedure SalesQuoteForContactWithBusinessRelation()
    var
        ContactCompany: Record Contact;
        SalesHeader: Record "Sales Header";
        CustomerTemplateCode: Code[10];
        CustomerNo: Code[20];
    begin
        // [SCENARIO 180155] Customer Template is not asked for Contact with Contact Business Relation
        Initialize;

        // [GIVEN] Contact "C1" with type Company
        LibraryMarketing.CreateCompanyContact(ContactCompany);
        LibraryVariableStorage.Enqueue(ContactCompany."No.");

        // [GIVEN] Customer Template "CT"
        CustomerTemplateCode := CreateCustomerTemplateForContact('');

        // [GIVEN] Customer "CU1" with relation to Contact "C1"
        CustomerNo := CreateCustomerForContact(ContactCompany, CustomerTemplateCode);

        // [GIVEN] New Sales Quote "SQ"
        CreateSalesQuote(SalesHeader);

        // [WHEN] User looks up in Sell-to Contact field, selects Contact "C1"
        SalesQuoteContactNoLookup(SalesHeader);
        SalesHeader.Get(SalesHeader."Document Type"::Quote, SalesHeader."No.");

        // [THEN] Customer Template is not asked, Sell-to Customer No. = "CU1"
        SalesHeader.TestField("Sell-to Customer Template Code", '');
        SalesHeader.TestField("Sell-to Customer No.", CustomerNo);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,CustomerTempModalFormHandler')]
    [Scope('OnPrem')]
    procedure ContactListNewSalesQuoteForContactCompanyCustomerTemplate()
    var
        Contact: Record Contact;
        SalesHeader: Record "Sales Header";
        ContactList: TestPage "Contact List";
        SalesQuote: TestPage "Sales Quote";
        CustomerTemplateCode: Code[10];
    begin
        // [SCENARIO 198367] Create Sales Quote from Contact List page for Contact with Customer Template selection
        Initialize;

        // [GIVEN] Customer Template "CT", Contact "C" with type Company
        LibraryMarketing.CreateCompanyContact(Contact);
        CustomerTemplateCode := CreateCustomerTemplateForContact('');

        // [GIVEN] Contact List page is opened and focus is set on Contact "C"
        ContactList.OpenView;
        ContactList.GotoRecord(Contact);

        // [WHEN] "New Sales Quote" Action is pressed
        SalesQuote.Trap;

        ContactList.NewSalesQuote.Invoke;

        SalesQuote.Close;
        // [THEN] User is asked for Customer Template selection
        // [THEN] After user selected Customer Template "CT" - new Sales Quote with Customer opens
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        SalesHeader.SetRange("Sell-to Contact No.", Contact."No.");
        SalesHeader.SetRange("Sell-to Customer Template Code", CustomerTemplateCode);
        Assert.RecordIsNotEmpty(SalesHeader);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerFalseWithTextVerification')]
    [Scope('OnPrem')]
    procedure ContactListSalesQuoteForContactPerson()
    var
        Contact: Record Contact;
        ContactList: TestPage "Contact List";
        SalesQuote: TestPage "Sales Quote";
    begin
        // [SCENARIO 198367] Create Sales Quote from Contact List for Customer with Person Type
        Initialize;

        // [GIVEN] Contact with Type = Person
        LibraryMarketing.CreatePersonContact(Contact);

        // [GIVEN] Contact List page is opened and focus is set on Contact "C"
        ContactList.OpenView;
        ContactList.GotoRecord(Contact);

        // [WHEN] "New Sales Quote" Action is pressed
        LibraryVariableStorage.Enqueue(SelectCustomerTemplateQst);
        SalesQuote.Trap;

        ContactList.NewSalesQuote.Invoke;

        SalesQuote.Close;
        // [THEN] SalesQuote Page opens (handled in ModalPageHandler)
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    [Scope('OnPrem')]
    procedure ContactListSalesQuoteForContactWithBusinessRelation()
    var
        ContactCompany: Record Contact;
        SalesHeader: Record "Sales Header";
        ContactList: TestPage "Contact List";
        SalesQuote: TestPage "Sales Quote";
        CustomerTemplateCode: Code[10];
        CustomerNo: Code[20];
    begin
        // [SCENARIO 198367] Create Sales Quote from Contact List page for Contact with Customer Business Relation
        Initialize;

        // [GIVEN] Contact "C" with type Company
        LibraryMarketing.CreateCompanyContact(ContactCompany);
        CustomerTemplateCode := CreateCustomerTemplateForContact('');

        // [GIVEN] Customer "CU1" with relation to Contact "C"
        CustomerNo := CreateCustomerForContact(ContactCompany, CustomerTemplateCode);

        // [GIVEN] Contact List page is opened and focus is set on Contact "C"
        ContactList.OpenView;
        ContactList.GotoRecord(ContactCompany);

        // [WHEN] "New Sales Quote" Action is pressed
        SalesQuote.Trap;

        ContactList.NewSalesQuote.Invoke;

        SalesQuote.Close;

        // [THEN] Sales Quote page opened, Customer Template selection is not asked
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Quote);
        SalesHeader.SetRange("Sell-to Contact No.", ContactCompany."No.");
        SalesHeader.SetRange("Sell-to Customer No.", CustomerNo);
        SalesHeader.SetRange("Sell-to Customer Template Code", '');
        Assert.RecordIsNotEmpty(SalesHeader);
    end;

    [Test]
    [HandlerFunctions('ContactListModalPageHandler,ConfirmHandlerTrue,CustomerTempModalFormHandler,EmailVerifyModalPageHandler')]
    [Scope('OnPrem')]
    procedure SalesQuoteEmailDialogForContact()
    var
        Contact: Record Contact;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        VATPostingSetup: Record "VAT Posting Setup";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        SalesQuote: TestPage "Sales Quote";
    begin
        // [SCENARIO 199641] Email Dialog shows Contact Email when Sales Quote created for Contact
        Initialize;
        UpdateCompanyInformationPaymentInfo(true);

        // [GIVEN] Customer Template "CT", Contact "C" with type Company and Email "Email"
        CreateVATPostingSetup(VATPostingSetup);
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.Validate("E-Mail", LibraryUtility.GenerateRandomEmail);
        Contact.Modify;
        LibraryVariableStorage.Enqueue(Contact."No.");
        CreateCustomerTemplateForContact(VATPostingSetup."VAT Bus. Posting Group");
        LibraryVariableStorage.Enqueue(Contact."E-Mail");

        // [GIVEN] Sales Quote with selected Contact and Customer Template
        CreateSalesQuote(SalesHeader);

        SalesQuoteContactNoLookup(SalesHeader);
        LibraryERM.CreateGenProdPostingGroup(GenProductPostingGroup);
        LibrarySales.CreateSalesLine(
          SalesLine, SalesHeader, SalesLine.Type::Item,
          LibraryInventory.CreateItemNoWithPostingSetup(GenProductPostingGroup.Code, VATPostingSetup."VAT Prod. Posting Group"),
          LibraryRandom.RandInt(10));

        // [WHEN] "Send by Email" action invoked
        SalesQuote.OpenEdit;
        SalesQuote.GotoRecord(SalesHeader);
        SalesQuote.Email.Invoke;

        // [THEN] Email Dialog opened and "To:" = "Email"
        // Checked in EmailVerifyModalPageHandler handler
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue')]
    [Scope('OnPrem')]
    procedure SalesHeaderGetBillToNoForContCust()
    var
        SalesHeader: Record "Sales Header";
        Contact: Record Contact;
        CustomerTemplateCode: Code[10];
        CustomerNo: Code[20];
    begin
        // [FEATURE] [UT]
        // [SCENARIO 199641] Unit Test for function GetBillToNo of Sales Header table

        Initialize;
        // [GIVEN] Contact "C", Customer Template "CT" for Contact "C" and Customer "CUST"
        LibraryMarketing.CreateCompanyContact(Contact);
        CustomerTemplateCode := CreateCustomerTemplateForContact('');
        CustomerNo := LibrarySales.CreateCustomerNo;

        // [GIVEN] Sales Quote "SQ" with Bill-to Contact No. = "C" and Bill-to Customer Template Code = "CT"
        CreateSalesQuote(SalesHeader);
        SalesHeader.Validate("Bill-to Contact No.", Contact."No.");
        SalesHeader.Validate("Bill-to Customer Template Code", CustomerTemplateCode);
        SalesHeader.Modify;

        // [WHEN] GetBillToNo run
        // [THEN] Return value = "C"
        Assert.AreEqual(Contact."No.", SalesHeader.GetBillToNo, WrongValueErr);

        // [WHEN] Bill-to Customer Template Code = '' and GetBillToNo run
        // [THEN] Return value = ""
        SalesHeader.Validate("Bill-to Customer Template Code", '');
        SalesHeader.Modify;
        Assert.AreEqual('', SalesHeader.GetBillToNo, WrongValueErr);

        // [WHEN] Bill-to Customer Template Code = "CT", "Bill-to Contact No." = '' and GetBillToNo run
        // [THEN] Return value = ""
        SalesHeader.Validate("Bill-to Customer Template Code", CustomerTemplateCode);
        SalesHeader.Validate("Bill-to Contact No.", '');
        SalesHeader.Modify;
        Assert.AreEqual('', SalesHeader.GetBillToNo, WrongValueErr);

        // [WHEN] Bill-to Customer No. = "CUST" and GetBillToNo run
        // [THEN] Return value = "CUST"
        SalesHeader.Validate("Bill-to Customer No.", CustomerNo);
        SalesHeader.Modify;

        Assert.AreEqual(CustomerNo, SalesHeader.GetBillToNo, WrongValueErr);
    end;

    [Test]
    [HandlerFunctions('ContactCoverSheetReportRequestPageHandler')]
    [Scope('OnPrem')]
    procedure ContactCoverSheetReportLog()
    var
        Contact: Record Contact;
        InteractionLogEntry: Record "Interaction Log Entry";
        InteractionTemplateSetup: Record "Interaction Template Setup";
        ContactCard: TestPage "Contact Card";
    begin
        // [FEATURE] [Cover Sheet]
        // [SCENARIO 180159] Verify Contact Cover Sheet report print Company and Contact Information
        Initialize;

        // [GIVEN] Contact with filled Address fields
        CreateContactWithAddress(Contact);

        // [WHEN] Report is printed from Contact Card Page, Log Interaction = TRUE
        OpenContactCard(ContactCard, Contact);
        LibraryVariableStorage.Enqueue(true);
        Commit;
        ContactCard.ContactCoverSheet.Invoke;
        LibraryReportDataset.LoadDataSetFile;

        // [THEN] Contact address and Company Information fields are filled
        VerifyContactCoverSheetCompanyInfoReport;
        VerifyContactCoverSheetContactInfoReport(Contact);

        // [THEN] Interation Log Entries created for "C1" Contact
        InteractionTemplateSetup.Get;
        InteractionLogEntry.SetRange("Contact No.", Contact."No.");
        InteractionLogEntry.SetRange("Interaction Template Code", InteractionTemplateSetup."Cover Sheets");
        Assert.RecordIsNotEmpty(InteractionLogEntry);
    end;

    [Test]
    [HandlerFunctions('ContactCoverSheetReportRequestPageHandler')]
    [Scope('OnPrem')]
    procedure ContactCoverSheetReportNoLog()
    var
        Contact: Record Contact;
        InteractionLogEntry: Record "Interaction Log Entry";
        InteractionTemplateSetup: Record "Interaction Template Setup";
        ContactCard: TestPage "Contact Card";
    begin
        // [FEATURE] [Cover Sheet]
        // [SCENARIO 180159] Verify no interaction log entry created when Log Interaction = FALSE on report request form
        Initialize;

        // [GIVEN] Contact with filled Address fields
        CreateContactAsPerson(Contact);

        // [WHEN] Report is printed from Contact Card Page, Log Interaction = FALSE
        OpenContactCard(ContactCard, Contact);
        LibraryVariableStorage.Enqueue(false);
        Commit;
        ContactCard.ContactCoverSheet.Invoke;
        LibraryReportDataset.LoadDataSetFile;

        // [THEN] No Interation Log Entries created for "C1" Contact
        VerifyContactCoverSheetCompanyInfoReport;
        InteractionTemplateSetup.Get;
        InteractionLogEntry.SetRange("Contact No.", Contact."No.");
        InteractionLogEntry.SetRange("Interaction Template Code", InteractionTemplateSetup."Cover Sheets");
        Assert.RecordIsEmpty(InteractionLogEntry);
    end;

    [Test]
    [HandlerFunctions('ContactCoverSheetReportRequestPageHandler')]
    [Scope('OnPrem')]
    procedure ContactCoverSheetReportMultipleContacts()
    var
        Contact: Record Contact;
        Contact1: Record Contact;
        Contact2: Record Contact;
    begin
        // [FEATURE] [Cover Sheet]
        // [SCENARIO 180159] Verify Contact Cover Sheet printed for 2 Contacts
        Initialize;

        // [GIVEN] Contacts "C1" and "C2" with filled Address fields
        CreateContactWithAddress(Contact1);
        CreateContactWithAddress(Contact2);

        // [WHEN] Report Contact Cover Sheet is printed for Contacts "C1" and "C2"
        Contact.SetFilter("No.", '%1|%2', Contact1."No.", Contact2."No.");
        LibraryVariableStorage.Enqueue(false);
        Commit;
        REPORT.Run(REPORT::"Contact Cover Sheet", true, false, Contact);
        LibraryReportDataset.LoadDataSetFile;

        // [THEN] Report is printed for Contacts "C1" and "C2"
        VerifyContactCoverSheetContactInfoReport(Contact1);
        VerifyContactCoverSheetContactInfoReport(Contact2);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PersonalContactPhoneEmailToCustomer()
    var
        CompanyContact: Record Contact;
        PersonContact: Record Contact;
        Customer: Record Customer;
    begin
        // [SCENARIO 202046] Customer Email and Phone No. updated when Primary Contact field updated
        Initialize;

        // [GIVEN] Company Contact "CC"
        LibraryMarketing.CreateCompanyContact(CompanyContact);

        // [GIVEN] Person Contact "PC" related to "CC" with E-Mail = "EMAIL" and Phone No. = "PHONENO"
        LibraryMarketing.CreatePersonContact(PersonContact);
        PersonContact.Validate("Company No.", CompanyContact."Company No.");
        PersonContact.Validate("E-Mail", LibraryUtility.GenerateRandomEmail);
        PersonContact.Validate("Phone No.", CopyStr(LibraryUtility.GenerateRandomText(20), 1, MaxStrLen(PersonContact."Phone No.")));
        PersonContact.Modify(true);

        // [GIVEN] Customer created from "CC" Company Contact
        CompanyContact.SetHideValidationDialog(true);
        CompanyContact.CreateCustomer('');
        Customer.SetRange(Name, CompanyContact.Name);
        Customer.FindFirst;

        // [WHEN] Customer Primary Contact No. changed to "PC"
        Customer.Validate("Primary Contact No.", PersonContact."No.");
        Customer.Modify;

        // [THEN] Customer E-Mail = "EMAIL", Phone No. = "PHONENO"
        Customer.TestField("E-Mail", PersonContact."E-Mail");
        Customer.TestField("Phone No.", PersonContact."Phone No.");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure PersonalContactPhoneEmailToVendor()
    var
        CompanyContact: Record Contact;
        PersonContact: Record Contact;
        Vendor: Record Vendor;
    begin
        // [SCENARIO 202046] Vendor Email and Phone No. updated when Primary Contact field updated
        Initialize;

        // [GIVEN] Company Contact "CC"
        LibraryMarketing.CreateCompanyContact(CompanyContact);

        // [GIVEN] Person Contact "PC" related to "CC" with E-Mail = "EMAIL" and Phone No. = "PHONENO"
        LibraryMarketing.CreatePersonContact(PersonContact);
        PersonContact.Validate("Company No.", CompanyContact."Company No.");
        PersonContact.Validate("E-Mail", LibraryUtility.GenerateRandomEmail);
        PersonContact.Validate("Phone No.", CopyStr(LibraryUtility.GenerateRandomText(20), 1, MaxStrLen(PersonContact."Phone No.")));
        PersonContact.Modify(true);

        // [GIVEN] Vendor created from "CC" Company Contact
        CompanyContact.SetHideValidationDialog(true);
        CompanyContact.CreateVendor;
        Vendor.SetRange(Name, CompanyContact.Name);
        Vendor.FindFirst;

        // [WHEN] Vendor Primary Contact No. changed to "PC"
        Vendor.Validate("Primary Contact No.", PersonContact."No.");
        Vendor.Modify;

        // [THEN] Vendor E-Mail = "EMAIL", Phone No. = "PHONENO"
        Vendor.TestField("E-Mail", PersonContact."E-Mail");
        Vendor.TestField("Phone No.", PersonContact."Phone No.");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ContactCountryRegionToCustTemplateEmptyCountryRegion()
    var
        Contact: Record Contact;
        CustomerTemplate: Record "Customer Template";
        Customer: Record Customer;
        CountryRegion: Record "Country/Region";
    begin
        // [SCENARIO 202044] Customer creation from Contact with Country/Region Code using Template with empty Country/Region Code
        Initialize;

        // [GIVEN] Contact "C" with Country/Region Code = "CRC"
        LibraryERM.CreateCountryRegion(CountryRegion);
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.Validate("Country/Region Code", CountryRegion.Code);
        Contact.Modify;

        // [GIVEN] Customer Template "CT" with Country/Region Code = ''
        CustomerTemplate.Get(CreateCustomerTemplateForContact(''));
        CustomerTemplate.Validate("Country/Region Code", '');
        CustomerTemplate.Modify;

        // [WHEN] Create Customer "CU" from Contact "C" with Customer Template "CT"
        CreateCustomerFromContact(Contact, CustomerTemplate.Code, Customer);

        // [THEN] Customer "CU" created with Country/Region Code = "CRC"
        Customer.TestField("Country/Region Code", Contact."Country/Region Code");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ContactEmptyCountryRegionToCustTemplateCountryRegion()
    var
        Contact: Record Contact;
        CustomerTemplate: Record "Customer Template";
        Customer: Record Customer;
        CountryRegion: Record "Country/Region";
    begin
        // [SCENARIO 202044] Customer creation from Contact without Country/Region Code using Template with Country/Region Code
        Initialize;

        // [GIVEN] Contact "C" with Country/Region Code = ''
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.Validate("Country/Region Code", '');
        Contact.Modify;

        // [GIVEN] Customer Template "CT" with Country/Region Code = "CRC"
        LibraryERM.CreateCountryRegion(CountryRegion);
        CustomerTemplate.Get(CreateCustomerTemplateForContact(''));
        CustomerTemplate.Validate("Country/Region Code", CountryRegion.Code);
        CustomerTemplate.Modify;

        // [WHEN] Create Customer "CU" from Contact "C" with Customer Template "CT"
        CreateCustomerFromContact(Contact, CustomerTemplate.Code, Customer);

        // [THEN] Customer "CU" created with Country/Region Code = "CRC"
        Customer.TestField("Country/Region Code", CustomerTemplate."Country/Region Code");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ContactCountryRegionToCustTemplateCountryRegion()
    var
        Contact: Record Contact;
        CustomerTemplate: Record "Customer Template";
        Customer: Record Customer;
        ContactCountryRegion: Record "Country/Region";
        TemplateCountryRegion: Record "Country/Region";
    begin
        // [SCENARIO 202044] Customer creation from Contact with Country/Region Code using Template with Country/Region Code
        Initialize;

        // [GIVEN] Contact "C" with Country/Region Code = "CRC1"
        LibraryERM.CreateCountryRegion(ContactCountryRegion);
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.Validate("Country/Region Code", ContactCountryRegion.Code);
        Contact.Modify;

        // [GIVEN] Customer Template "CT" with Country/Region Code = "CRC2"
        LibraryERM.CreateCountryRegion(TemplateCountryRegion);
        CustomerTemplate.Get(CreateCustomerTemplateForContact(''));
        CustomerTemplate.Validate("Country/Region Code", TemplateCountryRegion.Code);
        CustomerTemplate.Modify;

        // [WHEN] Create Customer "CU" from Contact "C" with Customer Template "CT"
        CreateCustomerFromContact(Contact, CustomerTemplate.Code, Customer);

        // [THEN] Customer "CU" created with Country/Region Code = "CRC1"
        Customer.TestField("Country/Region Code", Contact."Country/Region Code");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ContactEmptyCountryRegionToCustTemplateEmptyCountryRegion()
    var
        Contact: Record Contact;
        CustomerTemplate: Record "Customer Template";
        Customer: Record Customer;
    begin
        // [SCENARIO 202044] Customer creation from Contact with empty Country/Region Code using Template with empty Country/Region Code
        Initialize;

        // [GIVEN] Contact "C" with Country/Region Code = ''
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.Validate("Country/Region Code", '');
        Contact.Modify;

        // [GIVEN] Customer Template "CT" with Country/Region Code = ''
        CustomerTemplate.Get(CreateCustomerTemplateForContact(''));
        CustomerTemplate.Validate("Country/Region Code", '');
        CustomerTemplate.Modify;

        // [WHEN] Create Customer "CU" from Contact "C" with Customer Template "CT"
        CreateCustomerFromContact(Contact, CustomerTemplate.Code, Customer);

        // [THEN] Customer "CU" created with Country/Region Code = ''
        Customer.TestField("Country/Region Code", '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure ContactCityCountyToCustTemplateEmptyCountryRegion()
    var
        Contact: Record Contact;
        CustomerTemplate: Record "Customer Template";
        Customer: Record Customer;
        PostCode: Record "Post Code";
        ContactCountryRegion: Record "Country/Region";
    begin
        // [SCENARIO 282816] Customer creation from Contact using Template in case of two Post Codes with the same Code, Country/Region, but with different City, County.
        Initialize;

        // [GIVEN] Two Post Codes with the same Code and "Country/Region Code", but with different City and County.
        // [GIVEN] "Post Code" = "PC2" for the second Post Code.
        LibraryERM.CreateCountryRegion(ContactCountryRegion);
        CreatePostCode(
          PostCode, LibraryUtility.GenerateGUID, LibraryUtility.GenerateGUID,
          ContactCountryRegion.Code, LibraryUtility.GenerateGUID);
        CreatePostCode(
          PostCode, PostCode.Code, LibraryUtility.GenerateGUID,
          ContactCountryRegion.Code, LibraryUtility.GenerateGUID);

        // [GIVEN] Contact with "Post Code" = "PC2". City, "Country/Region Code", County are from "PC2".
        LibraryMarketing.CreateCompanyContact(Contact);
        Contact.Validate(City, PostCode.City);
        Contact.Modify(true);

        // [GIVEN] Customer Template with empty "Country/Region Code".
        CustomerTemplate.Get(CreateCustomerTemplateForContact(''));
        CustomerTemplate.Validate("Country/Region Code", '');
        CustomerTemplate.Modify;

        // [WHEN] Create Customer from Contact with Customer Template.
        CreateCustomerFromContact(Contact, CustomerTemplate.Code, Customer);

        // [THEN] Customer is created. "Post Code", City, "Country/Region Code", County are from Contact.
        Customer.TestField("Post Code", Contact."Post Code");
        Customer.TestField(City, Contact.City);
        Customer.TestField("Country/Region Code", Contact."Country/Region Code");
        Customer.TestField(County, Contact.County);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,CustomerTempModalPageHandlerWithEnqueue')]
    [Scope('OnPrem')]
    procedure CreateSalesQuoteFromContactListAndCustTemplateConfirmation()
    var
        Contact: Record Contact;
        ContactList: TestPage "Contact List";
        SalesQuote: TestPage "Sales Quote";
    begin
        // [FEATURE] [UI] [Sales Quote]
        // [SCENARIO 205513] Stan can create sales quote from "Contact List" when press action "New Sales Quote", confirm and select "Customer Template"

        Initialize;

        // [GIVEN] Contact
        LibraryMarketing.CreateCompanyContact(Contact);

        // [GIVEN] "Contact list" page is opened
        ContactList.OpenView;
        ContactList.GotoRecord(Contact);

        // [GIVEN] Press action "New Sales Quote", confirm message "Do you want to select the customer template?" and select template "X"
        // The CustomerTempModalPageHandlerWithEnqueue gets the expected customer template into LibraryVariableStorage
        SalesQuote.Trap;

        // [WHEN] Move cursor to the next field in "Sales Quote" page to create new record
        ContactList.NewSalesQuote.Invoke;

        // [THEN] Sales Quote is populated with "Sell-To Customer Template Code" = "X"
        SalesQuote."Sell-to Address".SetValue('');
        SalesQuote."Sell-to Customer Template Code".AssertEquals(LibraryVariableStorage.DequeueText);
        SalesQuote.Close;
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerFalseWithTextVerification')]
    [Scope('OnPrem')]
    procedure UT_CustTemplateConfirmationWhenContactPersonHasNoBusRelation()
    var
        ContactPerson: Record Contact;
        ContactCompany: Record Contact;
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO 205513] Confirmation is raised when Sales Quote validates with Contact (Type = Person) which does not have business relation with customer

        Initialize;

        // [GIVEN] New Sales Quote
        CreateSalesQuote(SalesHeader);

        // [GIVEN] Contact "X" with Type = Company without business relation with Customer
        LibraryMarketing.CreateCompanyContact(ContactCompany);

        // [GIVEN] Contact "Y" with Type = Person and "Company No." = "X"
        LibraryMarketing.CreatePersonContact(ContactPerson);
        ContactPerson.Validate("Company No.", ContactCompany."No.");
        ContactPerson.Modify(true);
        LibraryVariableStorage.Enqueue(SelectCustomerTemplateQst);

        // [WHEN] Validate "Sell-to Contact No." with "Y"
        SalesHeader.Validate("Sell-to Contact No.", ContactPerson."No.");

        // [THEN] Confirmation "Do you want to select the customer template?" is thrown
        // Verification done by ConfirmHandlerFalseWithTextVerification
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_NoCustTemplateConfirmationWhenContactPersonHasBusRelation()
    var
        ContactBusinessRelation: Record "Contact Business Relation";
        ContactPerson: Record Contact;
        ContactCompany: Record Contact;
        SalesHeader: Record "Sales Header";
    begin
        // [SCENARIO 205513] Confirmation is not raised when Sales Quote validates with Contact (Type = Person) which have business relation with customer

        Initialize;

        // [GIVEN] New Sales Quote
        CreateSalesQuote(SalesHeader);

        // [GIVEN] Contact "X" with Type = Company with business relation to Customer
        LibraryMarketing.CreateCompanyContact(ContactCompany);
        LibraryMarketing.CreateBusinessRelationWithContact(ContactBusinessRelation, ContactCompany."No.");

        // [GIVEN] Contact "Y" with Type = Person and "Company No." = "X"
        LibraryMarketing.CreatePersonContact(ContactPerson);
        ContactPerson.Validate("Company No.", ContactCompany."No.");
        ContactPerson.Modify(true);
        LibraryVariableStorage.Enqueue(SelectCustomerTemplateQst);

        // [WHEN] Validate "Sell-to Contact No." with "Y"
        SalesHeader.Validate("Sell-to Contact No.", ContactPerson."No.");

        // [THEN] Confirmation is not thrown and "Sell-to Customer Template" is blank
        SalesHeader.TestField("Sell-to Customer Template Code", '');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CreateContsFromCustomersPersonContact()
    var
        Customer: Record Customer;
        Contact: Record Contact;
    begin
        // [FEATURE] [Create Contacts from Customers]
        // [SCENARIO 215237] Create Contacts from Customers report create Person Contact for Customer imported using Data Migration
        Initialize;

        // [GIVEN] Customer "CUST" with no Contacts created using Data Migration, Contact = "C", PhoneNo = "PN"
        Customer.SetInsertFromContact(true);  // avoid creation on Contact in OnInsert trigger
        Customer.Contact := CopyStr(LibraryUtility.GenerateRandomText(10), 1, MaxStrLen(Customer.Contact));
        Customer."Phone No." := CopyStr(LibraryUtility.GenerateRandomText(10), 1, MaxStrLen(Customer."Phone No."));
        Customer.Insert(true);

        // [WHEN] Run report Create Contact for Customers for Customer "CUST"
        Customer.SetRange("No.", Customer."No.");
        RunCreateContsFromCustomersReport(Customer);
        Customer.Find;

        // [THEN] Contact "C" created with Type = Person, Name = "C", Phone No. = "PN"
        // [THEN] Contact "C" is Primary Contact for Customer "CUST"
        VerifyContact(Customer."Primary Contact No.", Contact.Type::Person, Customer.Contact, Customer."Phone No.")
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CreateContsFromVendorsPersonContact()
    var
        Vendor: Record Vendor;
        Contact: Record Contact;
    begin
        // [FEATURE] [Create Contacts from Vendors]
        // [SCENARIO 215237] Create Contacts from Vendors report create Person Contact for Vendor imported using Data Migration
        Initialize;

        // [GIVEN] Vendor "VEND" with no Contacts created using Data Migration, Contact = "C", PhoneNo = "PN"
        Vendor.SetInsertFromContact(true); // avoid creation on Contact in OnInsert trigger
        Vendor.Contact := CopyStr(LibraryUtility.GenerateRandomText(10), 1, MaxStrLen(Vendor.Contact));
        Vendor."Phone No." := CopyStr(LibraryUtility.GenerateRandomText(10), 1, MaxStrLen(Vendor."Phone No."));
        Vendor.Insert(true);

        // [WHEN] Run report Create Contact for Vendors for Vendor "VEND"
        Vendor.SetRange("No.", Vendor."No.");
        RunCreateContsFromVendorsReport(Vendor);
        Vendor.Find;

        // [THEN] Contact "C" created with Type = Person, Name = "C", Phone No. = "PN"
        // [THEN] Contact "C" is Primary Contact for Vendor "VEND"
        VerifyContact(Vendor."Primary Contact No.", Contact.Type::Person, Vendor.Contact, Vendor."Phone No.")
    end;

    [Test]
    [Scope('OnPrem')]
    procedure DrillDownOnToDosContactName()
    var
        Contact: Record Contact;
        ContactCard: TestPage "Contact Card";
        TaskList: TestPage "Task List";
        TaskCard: TestPage "Task Card";
        ContactList: TestPage "Contact List";
    begin
        // [FEATURE] [To-Do] [UI]
        // [SCENARIO 379509] DrillDown on To-Do's field "Contact Name" should open Contact List page

        Initialize;

        CreateContactWithToDos(Contact);

        ContactCard.OpenEdit;
        ContactCard.FILTER.SetFilter("No.", Contact."No.");
        TaskList.Trap;
        ContactCard."T&asks".Invoke;
        TaskCard.Trap;
        TaskList."Edit Organizer Task".Invoke;
        ContactList.Trap;
        TaskCard."Contact Name".DrillDown;

        ContactList."No.".AssertEquals(Contact."No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,CustomerTempModalFormHandler,MessageHandler')]
    [Scope('OnPrem')]
    procedure PredefinedDataInContactAssignsToCustomer()
    var
        Contact: Record Contact;
        BusinessRelation: Record "Business Relation";
        CustomerPriceGroup: Record "Customer Price Group";
        CustomerTemplate: Record "Customer Template";
    begin
        // [FEATURE] [Customer]
        // [SCENARIO 216960] The predefined data from Contact assigns to Customer when create Customer from Contact

        Initialize;

        // [GIVEN] Business Relation and input it in the field Bus. Rel. Code for Customers of Marketing Setup.
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        ChangeBusinessRelationCodeForCustomers(BusinessRelation.Code);

        // [GIVEN] Customer Template with "Currency Code" = EUR, "Country/Region" = DE, "Territory" = "FOREIGN"
        CreateCustomerTemplate(CustomerTemplate, CustomerPriceGroup.Code);

        // [GIVEN] Contact with "Currency Code" = GBP, "Country/Region" = GB, "Territory" = "LONDON"
        CreateContactWithData(Contact);

        // [WHEN] Create Customer from Contact with selected Customer Template
        Contact.CreateCustomer(Contact.ChooseCustomerTemplate);

        // [THEN] Contact is created with "Currency Code" = GBP, "Country/Region" = GB, "Territory" = "LONDON"
        VerifyCustomerInheritsDataFromContact(Contact);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTrue,CustomerTempModalFormHandler,MessageHandler')]
    [Scope('OnPrem')]
    procedure CustomerCreatedFromContactWithNoData()
    var
        Contact: Record Contact;
        BusinessRelation: Record "Business Relation";
        CustomerTemplate: Record "Customer Template";
    begin
        // [FEATURE] [Customer]
        // [SCENARIO 216960] Customer creates from Contact with no data assigned if no data specified in Contact

        Initialize;

        // [GIVEN] Business Relation and input it in the field Bus. Rel. Code for Customers of Marketing Setup.
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        ChangeBusinessRelationCodeForCustomers(BusinessRelation.Code);

        // [GIVEN] Customer Template with "blank Currency Code", "Country/Region" and "Territory"
        LibrarySales.CreateCustomerTemplate(CustomerTemplate);
        LibraryVariableStorage.Enqueue(CustomerTemplate.Code);

        // [GIVEN] Contact with blank "Currency Code", "Country/Region" and "Territory"
        LibraryMarketing.CreatePersonContact(Contact);

        // [WHEN] Create Customer from Contact with selected Customer Template
        Contact.CreateCustomer(Contact.ChooseCustomerTemplate);

        // [THEN] Contact is created with blank "Currency Code", "Country/Region" and "Territory"
        VerifyCustomerInheritsDataFromContact(Contact);
    end;

    [Test]
    [HandlerFunctions('NotificationHandler')]
    [Scope('OnPrem')]
    procedure ShowSuggestCreateContactForCustomerNotification()
    var
        Customer: Record Customer;
        CustomerList: TestPage "Customer List";
        CustomerCard: TestPage "Customer Card";
    begin
        // [FEATURE] [Notification] [Customer]
        // [SCENARIO 216150] Notifications suggesting to create Contacts appear in Customer List page
        Initialize;

        // [GIVEN] Customer "C" exist with no Contact assigned (no business relations)
        CreateCustomer(Customer);

        // [WHEN] Customer List page is opened
        CustomerList.OpenEdit;
        CustomerList.GotoRecord(Customer);

        // [THEN] Notification is shown
        Assert.ExpectedMessage(YouCanGetContactFromCustTxt, LibraryVariableStorage.DequeueText);

        // [WHEN] Customer List page is opened
        CustomerCard.OpenEdit;
        CustomerCard.GotoRecord(Customer);

        // [THEN] Notification is shown
        Assert.ExpectedMessage(YouCanGetContactFromCustTxt, LibraryVariableStorage.DequeueText);
        Customer.Delete;
    end;

    [Test]
    [HandlerFunctions('NotificationHandler')]
    [Scope('OnPrem')]
    procedure ShowSuggestCreateContactForVendorNotification()
    var
        Vendor: Record Vendor;
        VendorList: TestPage "Vendor List";
        VendorCard: TestPage "Vendor Card";
    begin
        // [FEATURE] [Notification] [Vendor]
        // [SCENARIO 216150] Notifications suggesting to create Contacts appear in Vendor List page
        Initialize;

        // [GIVEN] Vendor "V" exist with no Contact assigned (no business relations)
        CreateVendor(Vendor);

        // [WHEN] Vendor List page is opened
        VendorList.OpenEdit;
        VendorList.GotoRecord(Vendor);

        // [THEN] Notification is shown
        Assert.ExpectedMessage(YouCanGetContactFromVendTxt, LibraryVariableStorage.DequeueText);

        // [WHEN] Vendor List page is opened
        VendorCard.OpenEdit;
        VendorCard.GotoRecord(Vendor);

        // [THEN] Notification is shown
        Assert.ExpectedMessage(YouCanGetContactFromVendTxt, LibraryVariableStorage.DequeueText);
        Vendor.Delete;
    end;

    [Test]
    [HandlerFunctions('NotificationHandler')]
    [Scope('OnPrem')]
    procedure ShowSuggestCreateContForCustSaleRelationshipRoleCenter()
    var
        Customer: Record Customer;
        SalesRelationshipMgrAct: TestPage "Sales & Relationship Mgr. Act.";
    begin
        // [FEATURE] [Notification] [Customer]
        // [SCENARIO 216150] Notifications suggesting to create Contacts for Customer appear in Sales & Relationship Manager role center
        Initialize;

        // [GIVEN] Customer "C" exist with no Contact assigned
        CreateCustomer(Customer);

        // [WHEN] Sales & Relationship Manager role center is opened
        SalesRelationshipMgrAct.OpenView;

        // [THEN] Notification is shown
        Assert.ExpectedMessage(YouCanGetContactFromCustTxt, LibraryVariableStorage.DequeueText);
        Customer.Delete;
        SalesRelationshipMgrAct.Close;
    end;

    [Test]
    [HandlerFunctions('NotificationHandler')]
    [Scope('OnPrem')]
    procedure ShowSuggestCreateContForVendSaleRelationshipRoleCenter()
    var
        Vendor: Record Vendor;
        Customer: Record Customer;
        SalesRelationshipMgrAct: TestPage "Sales & Relationship Mgr. Act.";
    begin
        // [FEATURE] [Notification] [Vendor]
        // [SCENARIO 216150] Notifications suggesting to create Contacts for Vendor appear in Sales & Relationship Manager role center
        Initialize;
        Customer.DeleteAll;
        // [WHEN] Vendor "V" exist with no Contact assigned and Sales & Relationship Manager role center is opened
        CreateVendor(Vendor);
        SalesRelationshipMgrAct.OpenView;

        // [THEN] Notification is shown
        Assert.ExpectedMessage(YouCanGetContactFromVendTxt, LibraryVariableStorage.DequeueText);
        Vendor.Delete;
        SalesRelationshipMgrAct.Close;
    end;

    [Test]
    [HandlerFunctions('MyNotificationsModalPageHandler')]
    [Scope('OnPrem')]
    procedure DisabledContactNotificationsDontAppear()
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        SalesRelationshipMgrAct: TestPage "Sales & Relationship Mgr. Act.";
        VendorList: TestPage "Vendor List";
        CustomerList: TestPage "Customer List";
    begin
        // [FEATURE] [Notification] [Customer] [Vendor]
        // [SCENARIO 216150] Notifications suggesting to create Contacts don't appear if Disabled
        Initialize;

        // [GIVEN] Notifications for Contacts creation from Customers are off
        LibraryVariableStorage.Enqueue(false);

        // [GIVEN] Notifications for Contacts creation from Vendors are off
        LibraryVariableStorage.Enqueue(false);
        OpenMyNotificationsFromSettings;

        // [GIVEN] Customer "C" and Vendor "B" exist without Contacts assigned
        CreateCustomer(Customer);
        CreateVendor(Vendor);

        // [WHEN] Sales & Relationship Manager role center is opened
        SalesRelationshipMgrAct.OpenView;
        // [THEN] No notifications suggesting to create Contacts appear
        SalesRelationshipMgrAct.Close;

        // [WHEN] Customer List is opened
        CustomerList.OpenEdit;
        // [THEN] No notifications suggesting to create Contacts appear
        CustomerList.Close;

        // [WHEN] Vendor List is opened
        VendorList.OpenEdit;
        // [THEN] No notifications suggesting to create Contacts appear
        VendorList.Close;
    end;

    [Test]
    [Scope('OnPrem')]
    procedure DisableNotInitializedCustomerNotification()
    var
        Customer: Record Customer;
        MyNotifications: Record "My Notifications";
        DataMigrationNotifier: Codeunit "Data Migration Notifier";
        DummyNotification: Notification;
    begin
        // [FEATURE] [Notification] [UT] [Customer]
        // [SCENARIO 216150] Not initialized notification for customer can be disabled
        Initialize;

        // [GIVEN] Customer "C"
        CreateCustomer(Customer);

        // [GIVEN] Customer Notification entry does not exist in MyNotification table
        // [WHEN] Disabling action is invoked from notification
        DataMigrationNotifier.RemoveCustomerContactNotification(DummyNotification);

        // [THEN] Customer notification is disabled
        Assert.IsFalse(MyNotifications.IsEnabled(CustomerContNotifTok), 'Wrong notification state');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure DisableNotInitializedVendorNotification()
    var
        Vendor: Record Vendor;
        MyNotifications: Record "My Notifications";
        DataMigrationNotifier: Codeunit "Data Migration Notifier";
        DummyNotification: Notification;
    begin
        // [FEATURE] [Notification] [UT] [Vendor]
        // [SCENARIO 216150] Not initialized notification for vendor can be disabled
        Initialize;

        // [GIVEN] Vendor "V"
        CreateVendor(Vendor);

        // [GIVEN] Vendor Notification entry does not exist in MyNotification table

        // [WHEN] Disabling action is invoked from vendor notification
        DataMigrationNotifier.RemoveCustomerContactNotification(DummyNotification);

        // [THEN] Vendor notification is disabled
        Assert.IsFalse(MyNotifications.IsEnabled(CustomerContNotifTok), 'Wrong notification state');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AssignUnlinkedContact_ToUnlinkedVendorPrimaryContactNo()
    var
        Vendor: Record Vendor;
        ContactPerson: Record Contact;
        ContactCompany: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Vendor]
        // [SCENARIO 257273] Assign standalone unlinked Contact with Type::Person to a unlinked Vendor as a Primary Contact No.
        Initialize;

        // [GIVEN] Vendor "V" without ContactBusinessRelation record.
        CreateVendorWithSetupBusinessRelation(Vendor);

        // [GIVEN] Contact "C" with Type::Person.
        LibraryMarketing.CreatePersonContact(ContactPerson);

        // [WHEN] Assign "C" to "V" as "Primary Contact No.".
        Vendor.Validate("Primary Contact No.", ContactPerson."No.");
        Vendor.Modify(true);

        // [THEN] Contact with Type::Company created for "C"
        ContactPerson.Find;
        ContactCompany.Get(ContactPerson."Company No.");

        // [THEN] ContactBusinessRelation record created for "V" and "C".CompanyNo.
        VerifyContactBusinessRelationForLinkTableAndContact(
          ContactCompany."No.", Vendor."No.", ContactBusinessRelation."Link to Table"::Vendor);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AssignUnlinkedContact_ToUnlinkedCustomerPrimaryContactNo()
    var
        Customer: Record Customer;
        ContactPerson: Record Contact;
        ContactCompany: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Customer]
        // [SCENARIO 257273] Assign standalone unlinked Contact with Type::Person to a unlinked Customer as a Primary Contact No.
        Initialize;

        // [GIVEN] Customer "Cus" without ContactBusinessRelation record.
        CreateCustomerWithSetupBusinessRelation(Customer);

        // [GIVEN] Contact "C" with Type::Person.
        LibraryMarketing.CreatePersonContact(ContactPerson);

        // [WHEN] Assign "C" to "Cus" as "Primary Contact No.".
        Customer.Validate("Primary Contact No.", ContactPerson."No.");
        Customer.Modify(true);

        // [THEN] Contact with Type::Company created for "C"
        ContactPerson.Find;
        ContactCompany.Get(ContactPerson."Company No.");

        // [THEN] ContactBusinessRelation record created for "Cus" and "C".CompanyNo.
        VerifyContactBusinessRelationForLinkTableAndContact(
          ContactCompany."No.", Customer."No.", ContactBusinessRelation."Link to Table"::Customer);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AssignUnlinkedContactWithCompany_ToUnlinkedVendorPrimaryContactNo()
    var
        Vendor: Record Vendor;
        ContactPerson: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Vendor]
        // [SCENARIO 257273] Assign unlinked Contact with Type::Person and with Company No. to a unlinked Vendor as a Primary Contact No.
        Initialize;

        // [GIVEN] Vendor "V" without ContactBusinessRelation record.
        CreateVendorWithSetupBusinessRelation(Vendor);

        // [GIVEN] Contact "C" with Type::Person linked to another Contact with Type::Company via "Company No." field.
        LibraryMarketing.CreatePersonContactWithCompanyNo(ContactPerson);

        // [WHEN] Assign "C" to "V" as "Primary Contact No.".
        Vendor.Validate("Primary Contact No.", ContactPerson."No.");
        Vendor.Modify(true);

        // [THEN] ContactBusinessRelation record created for "V" and "C"."Company No." Contact.
        VerifyContactBusinessRelationForLinkTableAndContact(
          ContactPerson."Company No.", Vendor."No.", ContactBusinessRelation."Link to Table"::Vendor);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AssignUnlinkedContactWithCompany_ToUnlinkedCustomerPrimaryContactNo()
    var
        Customer: Record Customer;
        ContactPerson: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Customer]
        // [SCENARIO 257273] Assign unlinked Contact with Type::Person and with Company No. to a unlinked Customer as a Primary Contact No.
        Initialize;

        // [GIVEN] Customer "Cus" without ContactBusinessRelation record.
        CreateCustomerWithSetupBusinessRelation(Customer);

        // [GIVEN] Contact "C" with Type::Person linked to another Contact with Type::Company via "Company No." field.
        LibraryMarketing.CreatePersonContactWithCompanyNo(ContactPerson);

        // [WHEN] Assign "C" to "Cus" as "Primary Contact No.".
        Customer.Validate("Primary Contact No.", ContactPerson."No.");
        Customer.Modify(true);

        // [THEN] ContactBusinessRelation record created for "Cus" and "C"."Company No." Contact.
        VerifyContactBusinessRelationForLinkTableAndContact(
          ContactPerson."Company No.", Customer."No.", ContactBusinessRelation."Link to Table"::Customer);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AssignUnlinkedContact_ToLinkedVendorPrimaryContactNo()
    var
        Vendor: Record Vendor;
        ContactPerson: Record Contact;
    begin
        // [FEATURE] [UT] [Vendor]
        // [SCENARIO 257273] User cannot assign unlinked Contact with Type::Person to a linked Vendor as a Primary Contact No.
        Initialize;

        // [GIVEN] Vendor "V" linked to Contact "CompCont" with Type::Company.
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] Contact "C" with Type::Person which has no relations.
        LibraryMarketing.CreatePersonContact(ContactPerson);

        // [WHEN] Assign "C" to "V" as "Primary Contact No.".
        asserterror Vendor.Validate("Primary Contact No.", ContactPerson."No.");

        // [THEN] Error is invoked: Contact "C" is not related to vendor "V".
        Assert.ExpectedError(
          StrSubstNo(ContactNotRelatedToVendorErr, ContactPerson."No.", ContactPerson.Name, Vendor."No.", Vendor.Name));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AssignUnlinkedContact_ToLinkedCustomerPrimaryContactNo()
    var
        Customer: Record Customer;
        ContactPerson: Record Contact;
    begin
        // [FEATURE] [UT] [Customer]
        // [SCENARIO 257273] User cannot assign unlinked Contact with Type::Person to a linked Customer as a Primary Contact No.
        Initialize;

        // [GIVEN] Customer "Cus" linked to Contact "CompCont" with Type::Company.
        LibrarySales.CreateCustomer(Customer);

        // [GIVEN] Contact "C" with Type::Person which has no relations.
        LibraryMarketing.CreatePersonContact(ContactPerson);

        // [WHEN] Assign "C" to "Cus" as "Primary Contact No.".
        asserterror Customer.Validate("Primary Contact No.", ContactPerson."No.");

        // [THEN] Error is invoked: Contact "C" is not related to customer "Cus".
        Assert.ExpectedError(
          StrSubstNo(ContactNotRelatedToCustomerErr, ContactPerson."No.", ContactPerson.Name, Customer."No.", Customer.Name));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AssignLinkedContact_ToUnlinkedVendorPrimaryContactNo()
    var
        Vendor: array[2] of Record Vendor;
        ContactPerson: Record Contact;
        ContBusRel: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Vendor]
        // [SCENARIO 257273] User cannot assign linked Contact with Type::Person to a unlinked Vendor as a Primary Contact No.
        Initialize;

        // [GIVEN] Vendor "V1" linked to Contact "Comp" with Type::Company which is linked to a Contact "C" with Type::Person via "Company No." field.
        CreateVendorWithContactPerson(Vendor[1], ContactPerson, ContBusRel);

        // [GIVEN] Vendor "V2" without ContactBusinessRelation record.
        CreateVendorWithSetupBusinessRelation(Vendor[2]);

        // [WHEN] Assign "C" to "V2" as "Primary Contact No.".
        asserterror Vendor[2].Validate("Primary Contact No.", ContactPerson."No.");

        // [THEN] Error is invoked: Contact "C" already has a Contact Business Relation with Vendor "V".
        Assert.ExpectedError(
          StrSubstNo(RelationAlreadyExistWithVendorErr, ContBusRel."Contact No.", ContBusRel.TableCaption, Vendor[1]."No."));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AssignLinkedContact_ToUnlinkedCustomerPrimaryContactNo()
    var
        Customer: array[2] of Record Customer;
        ContactPerson: Record Contact;
        ContBusRel: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Customer]
        // [SCENARIO 257273] User cannot assign linked Contact with Type::Person to a unlinked Customer as a Primary Contact No.
        Initialize;

        // [GIVEN] Customer "Cus1" linked to Contact "Comp" with Type::Company which is linked to a Contact "C" with Type::Person via "Company No." field.
        CreateCustomerWithContactPerson(Customer[1], ContactPerson, ContBusRel);

        // [GIVEN] Customer "Cus2" without ContactBusinessRelation record.
        CreateCustomerWithSetupBusinessRelation(Customer[2]);

        // [WHEN] Assign "C" to "Cus2" as "Primary Contact No.".
        asserterror Customer[2].Validate("Primary Contact No.", ContactPerson."No.");

        // [THEN] Error is invoked: Contact "C" already has a Contact Business Relation with Customer "Cus1".
        Assert.ExpectedError(
          StrSubstNo(RelationAlreadyExistWithCustomerErr, ContBusRel."Contact No.", ContBusRel.TableCaption, Customer[1]."No."));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AssignLinkedContact_ToLinkedVendorPrimaryContactNo()
    var
        Vendor: array[2] of Record Vendor;
        ContactPerson: array[2] of Record Contact;
        ContBusRel: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Vendor]
        // [SCENARIO 257273] User cannot assign linked Contact with Type::Person to a linked Vendor as a Primary Contact No.
        Initialize;

        // [GIVEN] Vendor "V1" linked to Contact "Comp1" with Type::Company which is linked to a Contact "C1" with Type::Person via "Company No." field.
        CreateVendorWithContactPerson(Vendor[1], ContactPerson[1], ContBusRel);

        // [GIVEN] Vendor "V2" linked to Contact "Comp2" with Type::Company which is linked to a Contact "C2" with Type::Person via "Company No." field.
        CreateVendorWithContactPerson(Vendor[2], ContactPerson[2], ContBusRel);

        // [WHEN] Assign "C1" to "V2" as "Primary Contact No.".
        asserterror Vendor[2].Validate("Primary Contact No.", ContactPerson[1]."No.");

        // [THEN] Error is invoked: Contact "C1" is not related to vendor "V2".
        Assert.ExpectedError(
          StrSubstNo(ContactNotRelatedToVendorErr, ContactPerson[1]."No.", ContactPerson[1].Name, Vendor[2]."No.", Vendor[2].Name));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure AssignLinkedContact_ToLinkedCustomerPrimaryContactNo()
    var
        Customer: array[2] of Record Customer;
        ContactPerson: array[2] of Record Contact;
        ContBusRel: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Customer]
        // [SCENARIO 257273] User cannot assign linked Contact with Type::Person to a linked Customer as a Primary Contact No.
        Initialize;

        // [GIVEN] Customer "Cus1" linked to Contact "Comp1" with Type::Company which is linked to a Contact "C1" with Type::Person via "Company No." field.
        CreateCustomerWithContactPerson(Customer[1], ContactPerson[1], ContBusRel);

        // [GIVEN] Customer "Cus2" linked to Contact "Comp2" with Type::Company which is linked to a Contact "C2" with Type::Person via "Company No." field.
        CreateCustomerWithContactPerson(Customer[2], ContactPerson[2], ContBusRel);

        // [WHEN] Assign "C1" to "Cus2" as "Primary Contact No.".
        asserterror Customer[2].Validate("Primary Contact No.", ContactPerson[1]."No.");

        // [THEN] Error is invoked: Contact "C1" is not related to customer "Cus2".
        Assert.ExpectedError(
          StrSubstNo(ContactNotRelatedToCustomerErr, ContactPerson[1]."No.", ContactPerson[1].Name, Customer[2]."No.", Customer[2].Name));
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_ContBusRelCreateRelation_ForVendor()
    var
        Vendor: Record Vendor;
        ContactBusinessRelation: Record "Contact Business Relation";
        ContactCompanyNo: Code[20];
    begin
        // [FEATURE] [UT] [Vendor]
        // [SCENARIO 257273] UT ContactBusinessRelation.CreateRelation for Vendor side
        Initialize;

        CreateVendorWithSetupBusinessRelation(Vendor);
        ContactCompanyNo := LibraryMarketing.CreateCompanyContactNo;

        ContactBusinessRelation.CreateRelation(ContactCompanyNo, Vendor."No.", ContactBusinessRelation."Link to Table"::Vendor);

        VerifyContactBusinessRelationForLinkTableAndContact(
          ContactCompanyNo, Vendor."No.", ContactBusinessRelation."Link to Table"::Vendor);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_ContBusRelCreateRelation_ForCustomer()
    var
        Customer: Record Customer;
        ContactBusinessRelation: Record "Contact Business Relation";
        ContactCompanyNo: Code[20];
    begin
        // [FEATURE] [UT] [Customer]
        // [SCENARIO 257273] UT ContactBusinessRelation.CreateRelation for Customer side
        Initialize;

        CreateCustomerWithSetupBusinessRelation(Customer);
        ContactCompanyNo := LibraryMarketing.CreateCompanyContactNo;

        ContactBusinessRelation.CreateRelation(ContactCompanyNo, Customer."No.", ContactBusinessRelation."Link to Table"::Customer);

        VerifyContactBusinessRelationForLinkTableAndContact(
          ContactCompanyNo, Customer."No.", ContactBusinessRelation."Link to Table"::Customer);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_ContBusRelCreateRelation_WithNoBusRelCodeSetupForVendor()
    var
        Vendor: Record Vendor;
        ContactBusinessRelation: Record "Contact Business Relation";
        ContactCompanyNo: Code[20];
    begin
        // [FEATURE] [UT] [Vendor]
        // [SCENARIO 257273] UT ContactBusinessRelation.CreateRelation for Vendor side when MarketingSetup."Bus. Rel. Code for Vendors" is empty.
        Initialize;

        CreateVendorWithSetupBusinessRelation(Vendor);
        ContactCompanyNo := LibraryMarketing.CreateCompanyContactNo;

        ChangeBusinessRelationCodeForVendors('');
        asserterror
          ContactBusinessRelation.CreateRelation(
            ContactCompanyNo, Vendor."No.", ContactBusinessRelation."Link to Table"::Vendor);

        Assert.ExpectedError('Bus. Rel. Code for Vendors must have a value in Marketing Setup');
        VerifyNoContactBusinessRelationForLinkTableAndContact(
          ContactCompanyNo, Vendor."No.", ContactBusinessRelation."Link to Table"::Vendor);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_ContBusRelCreateRelation_WithNoBusRelCodeSetupForCustomer()
    var
        Customer: Record Customer;
        ContactBusinessRelation: Record "Contact Business Relation";
        ContactCompanyNo: Code[20];
    begin
        // [FEATURE] [UT] [Customer]
        // [SCENARIO 257273] UT ContactBusinessRelation.CreateRelation for Customer side when MarketingSetup."Bus. Rel. Code for Customers" is empty.
        Initialize;

        CreateCustomerWithSetupBusinessRelation(Customer);
        ContactCompanyNo := LibraryMarketing.CreateCompanyContactNo;

        ChangeBusinessRelationCodeForCustomers('');
        asserterror
          ContactBusinessRelation.CreateRelation(
            ContactCompanyNo, Customer."No.", ContactBusinessRelation."Link to Table"::Customer);

        Assert.ExpectedError('Bus. Rel. Code for Customers must have a value in Marketing Setup');
        VerifyNoContactBusinessRelationForLinkTableAndContact(
          ContactCompanyNo, Customer."No.", ContactBusinessRelation."Link to Table"::Customer);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_ContBusRelFindOrRestoreContactBusinessRelation_FindForVendor()
    var
        Vendor: Record Vendor;
        ContactPerson: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Vendor]
        // [SCENARIO 257273] UT ContactBusinessRelation.FindOrRestoreContactBusinessRelation for Vendor, find existing ContactBusinessRelation record by relation.
        Initialize;

        CreateVendorWithContactPerson(Vendor, ContactPerson, ContactBusinessRelation);

        ContactBusinessRelation.FindOrRestoreContactBusinessRelation(
          ContactPerson, Vendor, ContactBusinessRelation."Link to Table"::Vendor);

        VerifyContactBusinessRelationForLinkTableAndContact(
          ContactPerson."Company No.", Vendor."No.", ContactBusinessRelation."Link to Table"::Vendor);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_ContBusRelFindOrRestoreContactBusinessRelation_FindForCustomer()
    var
        Customer: Record Customer;
        ContactPerson: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Customer]
        // [SCENARIO 257273] UT ContactBusinessRelation.FindOrRestoreContactBusinessRelation for Customer, find existing ContactBusinessRelation record by relation.
        Initialize;

        CreateCustomerWithContactPerson(Customer, ContactPerson, ContactBusinessRelation);

        ContactBusinessRelation.FindOrRestoreContactBusinessRelation(
          ContactPerson, Customer, ContactBusinessRelation."Link to Table"::Customer);

        VerifyContactBusinessRelationForLinkTableAndContact(
          ContactPerson."Company No.", Customer."No.", ContactBusinessRelation."Link to Table"::Customer);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_ContBusRelFindOrRestoreContactBusinessRelation_RestoreForStandaloneContactForVendor()
    var
        Vendor: Record Vendor;
        ContactPerson: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Vendor]
        // [SCENARIO 257273] UT ContactBusinessRelation.FindOrRestoreContactBusinessRelation for Vendor, create ContactBusinessRelation for Contact without "Company No." link.
        Initialize;

        CreateVendorWithSetupBusinessRelation(Vendor);
        LibraryMarketing.CreatePersonContact(ContactPerson);

        ContactBusinessRelation.FindOrRestoreContactBusinessRelation(
          ContactPerson, Vendor, ContactBusinessRelation."Link to Table"::Vendor);

        ContactPerson.Find;
        VerifyContactBusinessRelationForLinkTableAndContact(
          ContactPerson."Company No.", Vendor."No.", ContactBusinessRelation."Link to Table"::Vendor);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_ContBusRelFindOrRestoreContactBusinessRelation_RestoreForStandaloneContactForCustomer()
    var
        Customer: Record Customer;
        ContactPerson: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Customer]
        // [SCENARIO 257273] UT ContactBusinessRelation.FindOrRestoreContactBusinessRelation for Customer, create ContactBusinessRelation for Contact without "Company No." link.
        Initialize;

        CreateCustomerWithSetupBusinessRelation(Customer);
        LibraryMarketing.CreatePersonContact(ContactPerson);

        ContactBusinessRelation.FindOrRestoreContactBusinessRelation(
          ContactPerson, Customer, ContactBusinessRelation."Link to Table"::Customer);

        ContactPerson.Find;
        VerifyContactBusinessRelationForLinkTableAndContact(
          ContactPerson."Company No.", Customer."No.", ContactBusinessRelation."Link to Table"::Customer);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_ContBusRelFindOrRestoreContactBusinessRelation_RestoreForContactWithCompanyForVendor()
    var
        Vendor: Record Vendor;
        ContactPerson: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Vendor]
        // [SCENARIO 257273] UT ContactBusinessRelation.FindOrRestoreContactBusinessRelation for Vendor, create ContactBusinessRelation for Contact with "Company No." link.
        Initialize;

        CreateVendorWithContactPerson(Vendor, ContactPerson, ContactBusinessRelation);
        ContactBusinessRelation.Delete;

        ContactBusinessRelation.FindOrRestoreContactBusinessRelation(
          ContactPerson, Vendor, ContactBusinessRelation."Link to Table"::Vendor);

        ContactPerson.Find;
        VerifyContactBusinessRelationForLinkTableAndContact(
          ContactPerson."Company No.", Vendor."No.", ContactBusinessRelation."Link to Table"::Vendor);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_ContBusRelFindOrRestoreContactBusinessRelation_RestoreForContactWithCompanyForCustomer()
    var
        Customer: Record Customer;
        ContactPerson: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Customer]
        // [SCENARIO 257273] UT ContactBusinessRelation.FindOrRestoreContactBusinessRelation for Customer, create ContactBusinessRelation for Contact with "Company No." link.
        Initialize;

        CreateCustomerWithContactPerson(Customer, ContactPerson, ContactBusinessRelation);
        ContactBusinessRelation.Delete;

        ContactBusinessRelation.FindOrRestoreContactBusinessRelation(
          ContactPerson, Customer, ContactBusinessRelation."Link to Table"::Customer);

        ContactPerson.Find;
        VerifyContactBusinessRelationForLinkTableAndContact(
          ContactPerson."Company No.", Customer."No.", ContactBusinessRelation."Link to Table"::Customer);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_ContBusRelFindOrRestoreContactBusinessRelation_ForContactWithCompanyTypeForVendor()
    var
        Vendor: Record Vendor;
        ContactCompany: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Vendor]
        // [SCENARIO 257273] UT ContactBusinessRelation.FindOrRestoreContactBusinessRelation for Vendor, Contact with Type::Company is not validated.
        Initialize;

        LibraryMarketing.CreateCompanyContact(ContactCompany);
        CreateVendorWithSetupBusinessRelation(Vendor);

        ContactBusinessRelation.FindOrRestoreContactBusinessRelation(
          ContactCompany, Vendor, ContactBusinessRelation."Link to Table"::Vendor);

        Vendor.Find;
        Vendor.TestField(Contact, '');
        Assert.AreNotEqual(Vendor.Contact, ContactCompany.Name, 'Contact with Type::Company must not be validated for Vendor');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_ContBusRelFindOrRestoreContactBusinessRelation_ForContactWithCompanyTypeForCustomer()
    var
        Customer: Record Customer;
        ContactCompany: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Customer]
        // [SCENARIO 257273] UT ContactBusinessRelation.FindOrRestoreContactBusinessRelation for Customer, Contact with Type::Company is not validated.
        Initialize;

        LibraryMarketing.CreateCompanyContact(ContactCompany);
        CreateCustomerWithSetupBusinessRelation(Customer);

        ContactBusinessRelation.FindOrRestoreContactBusinessRelation(
          ContactCompany, Customer, ContactBusinessRelation."Link to Table"::Customer);

        Customer.Find;
        Customer.TestField(Contact, '');
        Assert.AreNotEqual(Customer.Contact, ContactCompany.Name, 'Contact with Type::Company must not be validated for Customer');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CreateContsFromCustomersDoNotCreatePersonContactForCustWithBlankContact()
    var
        Customer: Record Customer;
        ContactType: Option Company,Person;
    begin
        // [FEATURE] [Create Contacts from Customers]
        // [SCENARIO 287705] Report "Create Contacts from Customers" doesn't create Person Contact in case Customer has <blank> Contact field
        Initialize;

        // [GIVEN] Customer with <blank> Contact field and no contacts created using Data Migration,
        Customer.SetInsertFromContact(true);  // avoid creation of Contact in OnInsert trigger
        Customer.Contact := '';
        Customer.Insert(true);
        Customer.SetRange("No.", Customer."No.");

        // [WHEN] Run report Create Contact for Customers
        RunCreateContsFromCustomersReport(Customer);

        // [THEN] Company Contact is created for Customer
        // [THEN] Customer has Primary Contact No. = Company Contact No.
        Customer.Find;
        VerifyContact(Customer."Primary Contact No.", ContactType::Company, '', '');

        // [THEN] Person Contact is not created for Company Contact
        VerifyContactNotExistWithCompanyNo(Customer."Primary Contact No.", ContactType::Person);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CreateContsFromVendorsDoNotCreatePersonContactForVendWithBlankContact()
    var
        Vendor: Record Vendor;
        ContactType: Option Company,Person;
    begin
        // [FEATURE] [Create Contacts from Vendors]
        // [SCENARIO 287705] Report "Create Contacts from Vendors" doesn't create Person Contact in case Vendor has <blank> Contact field
        Initialize;

        // [GIVEN] Vendor with <blank> Contact field and no contacts created using Data Migration,
        Vendor.SetInsertFromContact(true);  // avoid creation of Contact in OnInsert trigger
        Vendor.Contact := '';
        Vendor.Insert(true);
        Vendor.SetRange("No.", Vendor."No.");

        // [WHEN] Run report Create Contact for Vendors
        RunCreateContsFromVendorsReport(Vendor);

        // [THEN] Company Contact is created for Vendor
        // [THEN] Vendor has Primary Contact No. = Company Contact No.
        Vendor.Find;
        VerifyContact(Vendor."Primary Contact No.", ContactType::Company, '', '');

        // [THEN] Person Contact is not created for Company Contact
        VerifyContactNotExistWithCompanyNo(Vendor."Primary Contact No.", ContactType::Person);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_ContBusRel_UpdateEmptyNoForCustomerPrimaryContact()
    var
        PersonContact: Record Contact;
        Customer: Record Customer;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Customer] [Contact Business Relation]
        // [SCENARIO 309527] ContactBusinessRelations with a blank "No." is populated with Customer No. when the Customer is inserted
        Initialize;

        // [GIVEN] Person Contact created
        LibraryMarketing.CreatePersonContact(PersonContact);

        // [GIVEN] Customer is initialized and "Primary Contact No." validated
        Customer.Init;
        Customer.Validate("Primary Contact No.", PersonContact."No.");

        // [GIVEN] Company Contact created for initialized Customer with Company Contact and with Contact Business Relations with blank "No."
        ContactBusinessRelation.FindByRelation(ContactBusinessRelation."Link to Table"::Customer, '');

        // [WHEN] Customer record is inserted
        Customer.Insert(true);

        // [THEN] Contact Business Relation "No." has been updated with Customer "No."
        Assert.IsTrue(
          ContactBusinessRelation.FindByRelation(ContactBusinessRelation."Link to Table"::Customer, Customer."No."),
          ExpectedToFindRecErr);

        // [THEN] There are no Contact Business Relation entries with blank "No."
        VerifyContactBusinessRelationHasNoBlankValue(ContactBusinessRelation."Link to Table"::Customer);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_ContBusRel_UpdateEmptyNoForVendorPrimaryContact()
    var
        PersonContact: Record Contact;
        Vendor: Record Vendor;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Vendor] [Contact Business Relation]
        // [SCENARIO 309527] ContactBusinessRelations with a blank "No." is populated with Vendor No. when the Vendor is inserted
        Initialize;

        // [GIVEN] Person Contact created
        LibraryMarketing.CreatePersonContact(PersonContact);

        // [GIVEN] Vendor is initialized and "Primary Contact No." validated
        Vendor.Init;
        Vendor.Validate("Primary Contact No.", PersonContact."No.");

        // [GIVEN] Company Contact created for initialized Vendor with Company Contact and with Contact Business Relations with blank "No."
        ContactBusinessRelation.FindByRelation(ContactBusinessRelation."Link to Table"::Vendor, '');

        // [WHEN] Vendor record is inserted
        Vendor.Insert(true);

        // [THEN] Contact Business Relation "No." has been updated with Vendor "No."
        Assert.IsTrue(
          ContactBusinessRelation.FindByRelation(ContactBusinessRelation."Link to Table"::Vendor, Vendor."No."),
          ExpectedToFindRecErr);

        // [THEN] There are no Contact Business Relation entries with blank "No."
        VerifyContactBusinessRelationHasNoBlankValue(ContactBusinessRelation."Link to Table"::Vendor);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_UpdateEmptyNoForContact_NoEntity()
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Contact Business Relation]
        Initialize;

        Assert.IsFalse(
          ContactBusinessRelation.UpdateEmptyNoForContact(
            '', LibraryUtility.GenerateGUID, ContactBusinessRelation."Link to Table"::Customer),
          WrongValueErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_UpdateEmptyNoForContact_NoContact()
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Contact Business Relation]
        Initialize;

        Assert.IsFalse(
          ContactBusinessRelation.UpdateEmptyNoForContact(
            LibraryUtility.GenerateGUID, '', ContactBusinessRelation."Link to Table"::Customer),
          WrongValueErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_UpdateEmptyNoForContact_NoPersonContact()
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Contact Business Relation]
        Initialize;

        Assert.IsFalse(
          ContactBusinessRelation.UpdateEmptyNoForContact(
            LibraryUtility.GenerateGUID, LibraryUtility.GenerateGUID, ContactBusinessRelation."Link to Table"::Customer),
          WrongValueErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_UpdateEmptyNoForContact_NoCompanyContact()
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Contact Business Relation]
        Initialize;

        Assert.IsFalse(
          ContactBusinessRelation.UpdateEmptyNoForContact(
            LibraryUtility.GenerateGUID, LibraryMarketing.CreatePersonContactNo, ContactBusinessRelation."Link to Table"::Customer),
          WrongValueErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_UpdateEmptyNoForContact_NotFoundByCompanyContact()
    var
        PersonContact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Contact Business Relation]
        Initialize;

        LibraryMarketing.CreatePersonContactWithCompanyNo(PersonContact);

        Assert.IsFalse(
          ContactBusinessRelation.UpdateEmptyNoForContact(
            LibraryUtility.GenerateGUID, PersonContact."No.", ContactBusinessRelation."Link to Table"::Customer),
          WrongValueErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_UpdateEmptyNoForContact_IsNotBlankNo()
    var
        PersonContact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Contact Business Relation]
        Initialize;

        LibraryMarketing.CreatePersonContactWithCompanyNo(PersonContact);
        LibraryMarketing.CreateContactBusinessRelation(
          ContactBusinessRelation, PersonContact."Company No.",
          GetBusinessRelationCodeFromSetup(ContactBusinessRelation."Link to Table"::Customer));
        ContactBusinessRelation."Link to Table" := ContactBusinessRelation."Link to Table"::Customer;
        ContactBusinessRelation."No." := LibrarySales.CreateCustomerNo;
        ContactBusinessRelation.Modify;

        Assert.IsFalse(
          ContactBusinessRelation.UpdateEmptyNoForContact(
            LibraryUtility.GenerateGUID, PersonContact."No.", ContactBusinessRelation."Link to Table"::Customer),
          WrongValueErr);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_UpdateEmptyNoForContact_BlankNo()
    var
        Customer: Record Customer;
        PersonContact: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        // [FEATURE] [UT] [Contact Business Relation]
        Initialize;

        LibrarySales.CreateCustomer(Customer);
        LibraryMarketing.CreatePersonContactWithCompanyNo(PersonContact);
        LibraryMarketing.CreateContactBusinessRelation(
          ContactBusinessRelation, PersonContact."Company No.",
          GetBusinessRelationCodeFromSetup(ContactBusinessRelation."Link to Table"::Customer));
        ContactBusinessRelation."Link to Table" := ContactBusinessRelation."Link to Table"::Customer;
        ContactBusinessRelation.Modify;

        Assert.IsTrue(
          ContactBusinessRelation.UpdateEmptyNoForContact(
            Customer."No.", PersonContact."No.", ContactBusinessRelation."Link to Table"::Customer),
          WrongValueErr);

        ContactBusinessRelation.Find;
        ContactBusinessRelation.TestField("No.", Customer."No.");
    end;

    [Test]
    [HandlerFunctions('ContactListLookupModalPageHandler')]
    [Scope('OnPrem')]
    procedure UI_ContactCard_CompanyName_Lookup()
    var
        ContactCompany: Record Contact;
        ContactPerson: Record Contact;
        ContactCard: TestPage "Contact Card";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 345031] Stan can select Contact with type "Company" via lookup of "Company Name" field. "Company No." is validated after selection.
        Initialize;

        LibraryMarketing.CreateCompanyContact(ContactCompany);
        LibraryMarketing.CreatePersonContact(ContactPerson);

        ContactCompany.TestField(Name);
        ContactPerson.TestField("Company No.", '');
        ContactPerson.TestField("Company Name", '');

        LibraryVariableStorage.Enqueue(ContactCompany."No.");

        ContactCard.OpenEdit();
        ContactCard.FILTER.SetFilter("No.", ContactPerson."No.");
        ContactCard."Company No.".AssertEquals('');
        ContactCard."Company Name".AssertEquals('');
        ContactCard."Company Name".Lookup();
        ContactCard.Close();

        ContactPerson.Find();
        ContactPerson.TestField("Company No.", ContactCompany."No.");
        ContactPerson.TestField("Company Name", ContactCompany.Name);

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [Scope('OnPrem')]
    procedure UT_Contact_CompanyName_Relation()
    var
        Contact: Record Contact;
        TableRelationsMetadata: Record "Table Relations Metadata";
    begin
        // [FEATURE] [UT]
        // [SCENARIO 345031] Contact."Company Name" field's relation is Contact.Name
        Initialize;

        TableRelationsMetadata.SetRange("Table ID", DATABASE::Contact);
        TableRelationsMetadata.SetRange("Field No.", Contact.FieldNo("Company Name"));
        TableRelationsMetadata.FindFirst();
        TableRelationsMetadata.TestField("Related Table ID", DATABASE::Contact);
        TableRelationsMetadata.TestField("Related Field No.", Contact.FieldNo(Name));
        TableRelationsMetadata.TestField("Condition Type", TableRelationsMetadata."Condition Type"::CONST);
    end;

    local procedure Initialize()
    var
        MarketingSetup: Record "Marketing Setup";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"Marketing Contacts");
        BindActiveDirectoryMockEvents;
        LibraryVariableStorage.Clear;
        LibrarySetupStorage.Restore;

        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"Marketing Contacts");

        LibrarySales.SetCreditWarningsToNoWarnings;
        LibraryERMCountryData.CreateVATData;
        LibraryERMCountryData.CreateGeneralPostingSetupData;
        LibraryERMCountryData.UpdateGeneralPostingSetup;
        MarketingSetup.Get;
        MarketingSetup.Validate("Maintain Dupl. Search Strings", false);
        MarketingSetup.Modify(true);

        LibrarySetupStorage.Save(DATABASE::"Marketing Setup");
        LibrarySetupStorage.Save(DATABASE::"Company Information");

        IsInitialized := true;
        Commit;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Marketing Contacts");
    end;

    local procedure BindActiveDirectoryMockEvents()
    begin
        if ActiveDirectoryMockEvents.Enabled() then
            exit;
        BindSubscription(ActiveDirectoryMockEvents);
        ActiveDirectoryMockEvents.Enable();
    end;

    local procedure ChangeBusinessRelationCodeForCustomers(BusRelCodeForCustomers: Code[10])
    var
        MarketingSetup: Record "Marketing Setup";
    begin
        MarketingSetup.Get;
        MarketingSetup.Validate("Bus. Rel. Code for Customers", BusRelCodeForCustomers);
        MarketingSetup.Modify(true);
    end;

    local procedure ChangeBusinessRelationCodeForVendors(BusRelCodeForVendors: Code[10])
    var
        MarketingSetup: Record "Marketing Setup";
    begin
        MarketingSetup.Get;
        MarketingSetup.Validate("Bus. Rel. Code for Vendors", BusRelCodeForVendors);
        MarketingSetup.Modify(true);
    end;

    local procedure ChangeBusinessRelationCodeForBankAccount(BusRelCodeForBankAccs: Code[10]) OriginalBusRelCodeForBankAccs: Code[10]
    var
        MarketingSetup: Record "Marketing Setup";
    begin
        MarketingSetup.Get;
        OriginalBusRelCodeForBankAccs := MarketingSetup."Bus. Rel. Code for Bank Accs.";
        MarketingSetup.Validate("Bus. Rel. Code for Bank Accs.", BusRelCodeForBankAccs);
        MarketingSetup.Modify(true);
    end;

    local procedure CreateBankAccountWithCurrency(var BankAccount: Record "Bank Account"; CurrencyCode: Code[10])
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.Validate("Currency Code", CurrencyCode);
        BankAccount.Modify(true);
    end;

    local procedure CreateContactAsPerson(var Contact: Record Contact)
    begin
        LibraryMarketing.CreatePersonContact(Contact);
    end;

    local procedure CreateContactWithAddress(var Contact: Record Contact)
    begin
        CreateContactAsPerson(Contact);
        LibraryMarketing.UpdateContactAddress(Contact);
    end;

    local procedure CreateSalesQuote(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.Init;
        SalesHeader.Validate("Document Type", SalesHeader."Document Type"::Quote);
        SalesHeader.Insert(true);
    end;

    local procedure CreateSimpleContact(var Contact: Record Contact; ContactNo: Code[20])
    begin
        Contact.Init;
        Contact.Validate("No.", ContactNo);
        Contact.Insert(true);
    end;

    local procedure CreateCompanyContact(CompanyNo: Code[20]): Code[20]
    var
        Contact: Record Contact;
    begin
        with Contact do begin
            Init;
            "No." := CompanyNo;
            Type := Type::Company;
            Insert;
        end;
        exit(Contact."No.");
    end;

    local procedure CreateCustomerForContact(Contact: Record Contact; CustomerTemplateCode: Code[10]): Code[20]
    var
        ContBusRel: Record "Contact Business Relation";
        Customer: Record Customer;
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
        PaymentTerms: Record "Payment Terms";
    begin
        Contact.CreateCustomer(CustomerTemplateCode);
        ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
        ContBusRel.SetRange("Contact No.", Contact."No.");
        ContBusRel.FindFirst;
        LibraryERM.CreateGenBusPostingGroup(GenBusinessPostingGroup);
        LibraryERM.CreatePaymentTerms(PaymentTerms);
        Customer.Get(ContBusRel."No.");
        Customer.Validate("Gen. Bus. Posting Group", GenBusinessPostingGroup.Code);
        Customer.Validate("Payment Terms Code", PaymentTerms.Code);
        Customer.Modify;
        exit(Customer."No.");
    end;

    local procedure CreateCustomerFromContact(Contact: Record Contact; CustomerTemplateCode: Code[10]; var Customer: Record Customer)
    begin
        Contact.SetHideValidationDialog(true);
        Contact.CreateCustomer(CustomerTemplateCode);
        FindCustomerByCompanyName(Customer, Contact.Name);
    end;

    local procedure CreateCustomer(var Customer: Record Customer)
    begin
        with Customer do begin
            Init;
            "No." := LibraryUtility.GenerateRandomCode(FieldNo("No."), DATABASE::Customer);
            Name := CopyStr(CreateGuid, 1, 50);
            Insert;
        end;
    end;

    local procedure CreateCustomerTemplate(var CustomerTemplate: Record "Customer Template"; CustomerPriceGroupCode: Code[10])
    var
        Customer2: Record Customer;
        CountryRegion: Record "Country/Region";
        Currency: Record Currency;
        Territory: Record Territory;
    begin
        LibrarySales.CreateCustomer(Customer2);
        LibrarySales.CreateCustomerTemplate(CustomerTemplate);
        CustomerTemplate.Validate("Customer Price Group", CustomerPriceGroupCode);
        CustomerTemplate.Validate("Gen. Bus. Posting Group", Customer2."Gen. Bus. Posting Group");
        CustomerTemplate.Validate("VAT Bus. Posting Group", Customer2."VAT Bus. Posting Group");
        CustomerTemplate.Validate("Customer Posting Group", Customer2."Customer Posting Group");
        CustomerTemplate.Validate("Allow Line Disc.", true);
        CustomerTemplate.Validate("Payment Terms Code", Customer2."Payment Terms Code");
        CustomerTemplate.Validate("Payment Method Code", Customer2."Payment Method Code");
        CustomerTemplate.Validate("Shipment Method Code", Customer2."Shipment Method Code");
        LibraryERM.CreateCountryRegion(CountryRegion);
        CustomerTemplate.Validate("Country/Region Code", CountryRegion.Code);
        LibraryERM.CreateCurrency(Currency);
        CustomerTemplate.Validate("Currency Code", Currency.Code);
        Territory.FindFirst;
        CustomerTemplate.Validate("Territory Code", Territory.Code);
        CustomerTemplate.Modify(true);
        LibraryVariableStorage.Enqueue(CustomerTemplate.Code);
    end;

    local procedure CreateCustomerTemplates(var CustomerTemplate: array[2] of Record "Customer Template")
    begin
        LibrarySales.CreateCustomerTemplate(CustomerTemplate[1]);
        CustomerTemplate[1].Validate("Contact Type", CustomerTemplate[1]."Contact Type"::Company);
        CustomerTemplate[1].Modify(true);

        LibrarySales.CreateCustomerTemplate(CustomerTemplate[2]);
        CustomerTemplate[2].Validate("Contact Type", CustomerTemplate[2]."Contact Type"::Person);
        CustomerTemplate[2].Modify(true);
    end;

    local procedure CreateCustomerTemplateForContact(VATBusPostingGroupCode: Code[20]): Code[10]
    var
        CountryRegion: Record "Country/Region";
        CustomerTemplate: Record "Customer Template";
        GenBusPostingGroup: Record "Gen. Business Posting Group";
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        LibrarySales.CreateCustomerTemplate(CustomerTemplate);
        LibraryERM.CreateGenBusPostingGroup(GenBusPostingGroup);
        LibrarySales.CreateCustomerPostingGroup(CustomerPostingGroup);
        LibraryERM.CreateCountryRegion(CountryRegion);
        CustomerTemplate.Validate("Country/Region Code", CountryRegion.Code);
        CustomerTemplate.Validate("Gen. Bus. Posting Group", GenBusPostingGroup.Code);
        CustomerTemplate.Validate("Customer Posting Group", CustomerPostingGroup.Code);
        CustomerTemplate.Validate("VAT Bus. Posting Group", VATBusPostingGroupCode);
        CustomerTemplate.Modify;
        LibraryVariableStorage.Enqueue(CustomerTemplate.Code);
        exit(CustomerTemplate.Code);
    end;

    local procedure CreateCustomerWithCurrency(var Customer: Record Customer; CurrencyCode: Code[10])
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Currency Code", CurrencyCode);
        Customer.Modify(true);
    end;

    local procedure CreateCustomerWithContactPerson(var Customer: Record Customer; var Contact: Record Contact; var ContBusRel: Record "Contact Business Relation")
    begin
        LibrarySales.CreateCustomer(Customer);
        ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
        ContBusRel.SetRange("No.", Customer."No.");
        ContBusRel.FindFirst;
        LibraryMarketing.CreatePersonContact(Contact);
        Contact.Validate("Company No.", ContBusRel."Contact No.");
        Contact.Modify(true);
    end;

    local procedure CreateCustomerWithSetupBusinessRelation(var Customer: Record Customer)
    var
        BusinessRelation: Record "Business Relation";
    begin
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        ChangeBusinessRelationCodeForCustomers('');
        LibrarySales.CreateCustomer(Customer);
        ChangeBusinessRelationCodeForCustomers(BusinessRelation.Code);
    end;

    local procedure CreateVendor(var Vendor: Record Vendor)
    begin
        with Vendor do begin
            Init;
            "No." := LibraryUtility.GenerateRandomCode(FieldNo("No."), DATABASE::Vendor);
            Name := CopyStr(CreateGuid, 1, 50);
            Insert;
        end;
    end;

    local procedure CreateVendorWithCurrency(var Vendor: Record Vendor; CurrencyCode: Code[10])
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Currency Code", CurrencyCode);
        Vendor.Modify(true);
    end;

    local procedure CreateVendorWithContactPerson(var Vendor: Record Vendor; var Contact: Record Contact; var ContBusRel: Record "Contact Business Relation")
    begin
        LibraryPurchase.CreateVendor(Vendor);
        ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Vendor);
        ContBusRel.SetRange("No.", Vendor."No.");
        ContBusRel.FindFirst;
        LibraryMarketing.CreatePersonContact(Contact);
        Contact.Validate("Company No.", ContBusRel."Contact No.");
        Contact.Modify(true);
    end;

    local procedure CreateVendorWithSetupBusinessRelation(var Vendor: Record Vendor)
    var
        BusinessRelation: Record "Business Relation";
    begin
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        ChangeBusinessRelationCodeForVendors('');
        LibraryPurchase.CreateVendor(Vendor);
        ChangeBusinessRelationCodeForVendors(BusinessRelation.Code);
    end;

    local procedure CreateSegmentLine(var SegmentLine: Record "Segment Line"; AttachmentNo: Integer)
    begin
        with SegmentLine do begin
            Init;
            "Segment No." := LibraryUtility.GenerateRandomCode(FieldNo("Segment No."), DATABASE::"Segment Line");
            "Line No." := 10000;
            "Attachment No." := AttachmentNo;
            Insert;
        end;
    end;

    local procedure CreateInteractLogEntry(SegmentLineNo: Integer)
    var
        InteractLogEntry: Record "Interaction Log Entry";
    begin
        with InteractLogEntry do begin
            Init;
            "Entry No." := SegmentLineNo;
            Insert;
        end;
    end;

    local procedure CreateVATPostingSetup(var VATPostingSetup: Record "VAT Posting Setup")
    var
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        VATProductPostingGroup: Record "VAT Product Posting Group";
    begin
        LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
        LibraryERM.CreateVATProductPostingGroup(VATProductPostingGroup);
        LibraryERM.CreateVATPostingSetup(VATPostingSetup, VATBusinessPostingGroup.Code, VATProductPostingGroup.Code);
    end;

    local procedure CreateWriteAttachment(var Attachment: Record Attachment)
    var
        LastNo: Integer;
    begin
        if Attachment.FindLast then
            LastNo := Attachment."No.";
        Attachment.Init;
        Attachment."No." := LastNo + 1;
        Attachment."Attachment File".Import(CreateWriteTempFile);
        Attachment.Insert;
    end;

    local procedure CreateWriteTempFile() FileName: Text
    var
        FileMgt: Codeunit "File Management";
        TempFile: File;
    begin
        FileName := FileMgt.ServerTempFileName(ExtensionTxt);
        with TempFile do begin
            TextMode(true);
            WriteMode(true);
            if not Exists(FileName) then
                Create(FileName)
            else
                Open(FileName);
            Write(Name); // write FileName into file
            Close;
        end;
    end;

    local procedure CreateContactWithData(var Contact: Record Contact)
    var
        CountryRegion: Record "Country/Region";
        Currency: Record Currency;
        Territory: Record Territory;
    begin
        LibraryMarketing.CreatePersonContact(Contact);
        LibraryERM.CreateCountryRegion(CountryRegion);
        Contact.Validate("Country/Region Code", CountryRegion.Code);
        LibraryERM.CreateCurrency(Currency);
        Contact.Validate("Currency Code", Currency.Code);
        LibraryERM.CreateTerritory(Territory);
        Contact.Validate("Territory Code", Territory.Code);
        Contact.Modify(true);
    end;

    local procedure CreateContactWithToDos(var Contact: Record Contact)
    var
        Task: array[2] of Record "To-do";
    begin
        LibraryMarketing.CreateCompanyContact(Contact);
        CreateAndUpdateTask(Task[1], Contact);
        CreateAndUpdateTask(Task[2], Contact);
        Task[2].Validate("Organizer To-do No.", Task[1]."Organizer To-do No.");
        Task[2].Modify(true);
    end;

    local procedure CreateAndUpdateTask(var Task: Record "To-do"; Contact: Record Contact)
    begin
        LibraryMarketing.CreateTask(Task);
        Task.Validate(Date, WorkDate);
        Task.Validate("Contact No.", Contact."No.");
        Task.Validate("Salesperson Code", Contact."Salesperson Code");
        Task.Modify(true);
    end;

    local procedure CreatePostCode(var PostCode: Record "Post Code"; "Code": Code[20]; City: Text[30]; CountryCode: Code[10]; County: Text[30])
    begin
        PostCode.Init;
        PostCode.Code := Code;
        PostCode.City := City;
        PostCode."Search City" := City;
        PostCode."Country/Region Code" := CountryCode;
        PostCode.County := County;
        PostCode.Insert;
    end;

    local procedure DeleteCustomerTemplates()
    var
        CustomerTemplate: Record "Customer Template";
    begin
        CustomerTemplate.DeleteAll;
    end;

    local procedure FindContactBusinessRelation(var ContactBusinessRelation: Record "Contact Business Relation"; BusinessRelationCode: Code[20]; LinkToTable: Option; No: Code[20])
    begin
        ContactBusinessRelation.SetRange("Business Relation Code", BusinessRelationCode);
        ContactBusinessRelation.SetRange("Link to Table", LinkToTable);
        ContactBusinessRelation.SetFilter("No.", No);
        ContactBusinessRelation.FindFirst;
    end;

    local procedure GetCustFromContact(ContactNo: Code[20]): Code[20]
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        ContactBusinessRelation.SetRange("Link to Table", ContactBusinessRelation."Link to Table"::Customer);
        ContactBusinessRelation.SetRange("Contact No.", ContactNo);
        ContactBusinessRelation.FindFirst;
        exit(ContactBusinessRelation."No.");
    end;

    local procedure GetBusinessRelationCodeFromSetup(LinkToTable: Option): Code[10]
    var
        MarketingSetup: Record "Marketing Setup";
        ContactBusinessRelation: Record "Contact Business Relation";
        BusinessRelation: Record "Business Relation";
    begin
        LibraryMarketing.CreateBusinessRelation(BusinessRelation);
        case LinkToTable of
            ContactBusinessRelation."Link to Table"::Customer:
                begin
                    ChangeBusinessRelationCodeForCustomers(BusinessRelation.Code);
                    MarketingSetup.Get;
                    exit(MarketingSetup."Bus. Rel. Code for Customers");
                end;
            ContactBusinessRelation."Link to Table"::Vendor:
                begin
                    ChangeBusinessRelationCodeForVendors(BusinessRelation.Code);
                    MarketingSetup.Get;
                    exit(MarketingSetup."Bus. Rel. Code for Vendors");
                end;
        end;
    end;

    local procedure FindCustomerByCompanyName(var Customer: Record Customer; CompanyName: Text[100])
    begin
        Customer.SetRange(Name, CompanyName);
        Customer.FindFirst;
    end;

    local procedure NextStepMakePhoneCallWizard(var TempSegmentLine: Record "Segment Line" temporary)
    begin
        TempSegmentLine.Modify;
        TempSegmentLine.CheckPhoneCallStatus;
    end;

    local procedure OpenContactCard(var ContactCard: TestPage "Contact Card"; Contact: Record Contact)
    begin
        ContactCard.OpenView;
        ContactCard.GotoRecord(Contact);
    end;

    [HandlerFunctions('MyNotificationsModalPageHandler')]
    local procedure OpenMyNotificationsFromSettings()
    var
        MySettings: TestPage "My Settings";
    begin
        MySettings.OpenEdit();
        MySettings.MyNotificationsLbl.DrillDown();
        MySettings.Close();
    end;

    local procedure PrintSalesQuoteReport(SalesHeader: Record "Sales Header")
    var
        SalesQuote: TestPage "Sales Quote";
    begin
        SalesQuote.OpenEdit;
        SalesQuote.GotoRecord(SalesHeader);
        Commit;
        SalesQuote.Print.Invoke;
    end;

    local procedure RunCompanyDetails(Contact: Record Contact)
    var
        CompanyDetails: Page "Company Details";
    begin
        Clear(CompanyDetails);
        Contact.SetRange("No.", Contact."No.");
        CompanyDetails.SetTableView(Contact);
        CompanyDetails.SetRecord(Contact);
        CompanyDetails.RunModal;
    end;

    local procedure RunNameDetails(Contact: Record Contact)
    var
        NameDetails: Page "Name Details";
    begin
        Clear(NameDetails);
        Contact.SetRange("No.", Contact."No.");
        NameDetails.SetTableView(Contact);
        NameDetails.SetRecord(Contact);
        NameDetails.RunModal;
    end;

    local procedure RunCreateContsFromCustomersReport(var Customer: Record Customer)
    var
        CreateContsFromCustomers: Report "Create Conts. from Customers";
    begin
        CreateContsFromCustomers.UseRequestPage(false);
        CreateContsFromCustomers.SetTableView(Customer);
        CreateContsFromCustomers.Run;
    end;

    local procedure RunCreateContsFromVendorsReport(var Vendor: Record Vendor)
    var
        CreateContsFromVendors: Report "Create Conts. from Vendors";
    begin
        CreateContsFromVendors.UseRequestPage(false);
        CreateContsFromVendors.SetTableView(Vendor);
        CreateContsFromVendors.Run;
    end;

    local procedure SalesQuoteContactNoLookup(var SalesHeader: Record "Sales Header")
    var
        SalesQuote: TestPage "Sales Quote";
    begin
        SalesQuote.OpenEdit;
        SalesQuote.GotoRecord(SalesHeader);
        SalesQuote."Sell-to Contact No.".Lookup;
        SalesQuote.Close;
        SalesHeader.Get(SalesHeader."Document Type"::Quote, SalesHeader."No.");
    end;

    local procedure SetAddress(var Contact: Record Contact)
    begin
        Contact.Address := CopyStr(CreateGuid, 2, 30);
        Contact."Address 2" := CopyStr(CreateGuid, 2, 30);
        Contact.City := CopyStr(CreateGuid, 2, 30);
        Contact.County := CopyStr(CreateGuid, 2, 30);
        Contact."Post Code" := CopyStr(CreateGuid, 2, 20);
    end;

    local procedure UpdateContactCompanyDetails(var Contact: Record Contact; ContactPostCode: Code[20]; ContactCountryRegionCode: Code[10]; ContactPhoneNumber: Text[30])
    begin
        Contact.Validate("Country/Region Code", ContactCountryRegionCode);
        Contact.Validate("Post Code", ContactPostCode);
        Contact.Validate(Name, ContactPostCode);  // Input the same value as value is not important.
        Contact.Validate(Address, ContactPostCode);  // Input the same value as value is not important.
        Contact.Validate("Phone No.", ContactPhoneNumber);
        Contact.Validate("Fax No.", ContactPhoneNumber);
        Contact.Modify(true);
    end;

    local procedure UpdateContactNameDetails(var Contact: Record Contact; ContactSalutationCode: Code[10]; ContactLanguageCode: Code[10])
    begin
        Contact.Validate("Salutation Code", ContactSalutationCode);
        Contact.Validate(Name, ContactSalutationCode);  // Input the same value as value is not important.
        Contact.Validate("Job Title", ContactSalutationCode);  // Input the same value as value is not important.
        Contact.Validate(Initials, CopyStr(ContactSalutationCode, 1, 2));  // Input first two characters of Salutation Code as Initials.
        Contact.Validate("Language Code", ContactLanguageCode);
        Contact.Modify(true);
    end;

    local procedure UpdateNameOnContactCard(No: Code[20]; Name: Text[100])
    var
        ContactCard: TestPage "Contact Card";
    begin
        ContactCard.OpenEdit;
        ContactCard.FILTER.SetFilter("No.", No);
        ContactCard.Name.SetValue(Name);
        ContactCard.OK.Invoke;
    end;

    local procedure VerifySameAddress(ExpectedContact: Record Contact; ActualContact: Record Contact)
    begin
        Assert.AreEqual(ExpectedContact.Address, ActualContact.Address, 'Field value didn''t get updated.');
        Assert.AreEqual(ExpectedContact."Address 2", ActualContact."Address 2", 'Field value didn''t get updated.');
        Assert.AreEqual(ExpectedContact.City, ActualContact.City, 'Field value didn''t get updated.');
        Assert.AreEqual(ExpectedContact.County, ActualContact.County, 'Field value didn''t get updated.');
        Assert.AreEqual(ExpectedContact."Post Code", ActualContact."Post Code", 'Field value didn''t get updated.');
    end;

    local procedure VerifyContactCompanyDetails(var Contact: Record Contact; ContactPostCode: Code[20]; ContactCountryRegionCode: Code[10]; ContactPhoneNumber: Text[30])
    begin
        Contact.TestField("Post Code", ContactPostCode);
        Contact.TestField(Name, ContactPostCode);
        Contact.TestField(Address, ContactPostCode);
        Contact.TestField("Country/Region Code", ContactCountryRegionCode);
        Contact.TestField("Phone No.", ContactPhoneNumber);
        Contact.TestField("Fax No.", ContactPhoneNumber);
    end;

    local procedure VerifyContactNameDetails(var Contact: Record Contact; ContactSalutationCode: Code[10]; ContactLanguageCode: Code[10])
    begin
        Contact.TestField("Salutation Code", ContactSalutationCode);
        Contact.TestField(Name, ContactSalutationCode);
        Contact.TestField("Job Title", ContactSalutationCode);
        Contact.TestField(Initials, CopyStr(ContactSalutationCode, 1, 2));  // Since first two characters were input as Initials.
        Contact.TestField("Language Code", ContactLanguageCode);
    end;

    local procedure VerifyContact(ContactNo: Code[20]; ContactType: Option; ContactName: Text[100]; ContactPhoneNo: Text[30])
    var
        Contact: Record Contact;
    begin
        Contact.Get(ContactNo);
        Contact.TestField(Type, ContactType);
        Contact.TestField(Name, ContactName);
        Contact.TestField("Phone No.", ContactPhoneNo);
    end;

    local procedure VerifyCustomerCreatedByContact(CustomerTemplate: Record "Customer Template"; ContactNo: Code[20]; CustomerPriceGroupCode: Code[20])
    var
        Customer: Record Customer;
    begin
        Customer.Get(GetCustFromContact(ContactNo));

        Customer.TestField("Customer Price Group", CustomerPriceGroupCode);
        Customer.TestField("Gen. Bus. Posting Group", CustomerTemplate."Gen. Bus. Posting Group");
        Customer.TestField("VAT Bus. Posting Group", CustomerTemplate."VAT Bus. Posting Group");
        Customer.TestField("Customer Posting Group", CustomerTemplate."Customer Posting Group");
        Customer.TestField("Allow Line Disc.", CustomerTemplate."Allow Line Disc.");
        Customer.TestField("Payment Method Code", CustomerTemplate."Payment Method Code");
        Customer.TestField("Payment Terms Code", CustomerTemplate."Payment Terms Code");
        Customer.TestField("Shipment Method Code", CustomerTemplate."Shipment Method Code");
        Customer.TestField("Invoice Disc. Code");
        Customer.TestField("Territory Code", CustomerTemplate."Territory Code");
        Customer.TestField("Country/Region Code", CustomerTemplate."Country/Region Code");
        Customer.TestField("Currency Code", CustomerTemplate."Currency Code");
    end;

    local procedure VerifyCustomerInheritsDataFromContact(Contact: Record Contact)
    var
        Customer: Record Customer;
    begin
        Customer.Get(GetCustFromContact(Contact."No."));
        Customer.TestField("Currency Code", Contact."Currency Code");
        Customer.TestField("Country/Region Code", Contact."Country/Region Code");
        Customer.TestField("Territory Code", Contact."Territory Code");
    end;

    local procedure VerifyContactErrorMessage(FieldCaptionOfMarketingField: Text[30]; TableCaptionOfTable: Text[30])
    begin
        Assert.ExpectedError(StrSubstNo(RelationErrorServiceTier, FieldCaptionOfMarketingField, TableCaptionOfTable));
    end;

    local procedure VerifyContactBusinessRelationForLinkTableAndContact(ContactNo: Code[20]; LinkNo: Code[20]; LinkToTable: Option)
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        ContactBusinessRelation.SetRange("Contact No.", ContactNo);
        ContactBusinessRelation.SetRange("No.", LinkNo);
        ContactBusinessRelation.SetRange("Link to Table", LinkToTable);
        Assert.RecordIsNotEmpty(ContactBusinessRelation);
    end;

    local procedure VerifyNoContactBusinessRelationForLinkTableAndContact(ContactNo: Code[20]; LinkNo: Code[20]; LinkToTable: Option)
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        ContactBusinessRelation.SetRange("Contact No.", ContactNo);
        ContactBusinessRelation.SetRange("No.", LinkNo);
        ContactBusinessRelation.SetRange("Link to Table", LinkToTable);
        Assert.RecordIsEmpty(ContactBusinessRelation);
    end;

    local procedure VerifyContactBusinessRelationHasNoBlankValue(LinkToTable: Option)
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        ContactBusinessRelation.SetRange("No.", '');
        ContactBusinessRelation.SetRange("Link to Table", LinkToTable);
        Assert.RecordIsEmpty(ContactBusinessRelation);
    end;

    local procedure VerifyContactNotExistWithCompanyNo(CompanyNo: Code[20]; ContactType: Integer)
    var
        Contact: Record Contact;
    begin
        Contact.SetRange("Company No.", CompanyNo);
        Contact.SetRange(Type, ContactType);
        Assert.RecordIsEmpty(Contact);
    end;

    local procedure CreateContactNameWithBrackets() "Code": Code[20]
    begin
        Code := LibraryUtility.GenerateGUID;
        Code[StrLen(Code) + 1] := ')';
        Code[StrLen(Code) div 2] := '(';
        exit(Code);
    end;

    local procedure UpdateCompanyInformationPaymentInfo(AllowBlankPaymentInfo: Boolean)
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get;
        CompanyInformation.Validate("Allow Blank Payment Info.", AllowBlankPaymentInfo);
        CompanyInformation.Modify;
    end;

    local procedure VerifyContactCoverSheetCompanyInfoReport()
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get;
        LibraryReportDataset.AssertElementWithValueExists('CompanyAddress1', CompanyInformation.Name);
        LibraryReportDataset.AssertElementWithValueExists('CompanyAddress2', CompanyInformation.Address);
        LibraryReportDataset.AssertElementWithValueExists('CompanyInformationPhoneNo', CompanyInformation."Phone No.");
        LibraryReportDataset.AssertElementWithValueExists('CompanyInformationGiroNo', CompanyInformation."Giro No.");
        LibraryReportDataset.AssertElementWithValueExists('CompanyInformationVATRegNo', CompanyInformation."VAT Registration No.");
        LibraryReportDataset.AssertElementWithValueExists('CompanyInformationBankName', CompanyInformation."Bank Name");
        LibraryReportDataset.AssertElementWithValueExists('CompanyInformationBankAccountNo', CompanyInformation."Bank Account No.");
        LibraryReportDataset.AssertElementWithValueExists('Document_Date', Format(WorkDate, 0, 4));
    end;

    local procedure VerifyContactCoverSheetContactInfoReport(Contact: Record Contact)
    var
        CountryRegion: Record "Country/Region";
    begin
        CountryRegion.Get(Contact."Country/Region Code");
        LibraryReportDataset.AssertElementWithValueExists('ContactAddress1', Contact.Name);
        LibraryReportDataset.AssertElementWithValueExists('ContactAddress2', Contact.Address);
        LibraryReportDataset.AssertElementWithValueExists('ContactAddress3', Contact."Address 2");
        LibraryReportDataset.AssertElementWithValueExists('ContactAddress4', Contact.City + ', ' + Contact."Post Code");
        LibraryReportDataset.AssertElementWithValueExists('ContactAddress5', Contact.County);
        LibraryReportDataset.AssertElementWithValueExists('ContactAddress6', CountryRegion.Name);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure NameDetailsModalFormHandler(var NameDetails: Page "Name Details"; var Reply: Action)
    var
        Contact: Record Contact;
    begin
        Contact.Init;  // Required to initialize the variable.
        NameDetails.GetRecord(Contact);
        UpdateContactNameDetails(Contact,
          CopyStr(LibraryVariableStorage.DequeueText, 1, MaxStrLen(Contact."Salutation Code")),
          CopyStr(LibraryVariableStorage.DequeueText, 1, MaxStrLen(Contact."Language Code")));
        Reply := ACTION::OK;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure VerifyNameModalFormHandler(var NameDetails: Page "Name Details"; var Reply: Action)
    var
        Contact: Record Contact;
    begin
        Contact.Init;  // Required to initialize the variable.
        NameDetails.GetRecord(Contact);
        VerifyContactNameDetails(Contact,
          CopyStr(LibraryVariableStorage.DequeueText, 1, MaxStrLen(Contact."Salutation Code")),
          CopyStr(LibraryVariableStorage.DequeueText, 1, MaxStrLen(Contact."Language Code")));
        Reply := ACTION::OK;
    end;

    local procedure VerifyOpportunityEntry(OppNo: Code[20]; ExpectedValue: Decimal)
    var
        OpportunityEntry: Record "Opportunity Entry";
    begin
        with OpportunityEntry do begin
            SetRange("Opportunity No.", OppNo);
            SetRange(Active, true);
            FindFirst;
            Assert.AreEqual(
              ExpectedValue, "Calcd. Current Value (LCY)",
              StrSubstNo(WrongCalcdCurValueErr, FieldCaption("Calcd. Current Value (LCY)")));
        end;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure CompanyDetailsModalFormHandler(var CompanyDetails: Page "Company Details"; var Reply: Action)
    var
        Contact: Record Contact;
    begin
        Contact.Init;  // Required to initialize the variable.
        CompanyDetails.GetRecord(Contact);
        UpdateContactCompanyDetails(
          Contact,
          CopyStr(LibraryVariableStorage.DequeueText, 1, MaxStrLen(Contact."Post Code")),
          CopyStr(LibraryVariableStorage.DequeueText, 1, MaxStrLen(Contact."Country/Region Code")),
          CopyStr(LibraryVariableStorage.DequeueText, 1, MaxStrLen(Contact."Phone No.")));
        Reply := ACTION::OK;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure VerifyCompanyModalFormHandler(var CompanyDetails: Page "Company Details"; var Reply: Action)
    var
        Contact: Record Contact;
    begin
        Contact.Init;  // Required to initialize the variable.
        CompanyDetails.GetRecord(Contact);
        VerifyContactCompanyDetails(
          Contact,
          CopyStr(LibraryVariableStorage.DequeueText, 1, MaxStrLen(Contact."Post Code")),
          CopyStr(LibraryVariableStorage.DequeueText, 1, MaxStrLen(Contact."Country/Region Code")),
          CopyStr(LibraryVariableStorage.DequeueText, 1, MaxStrLen(Contact."Phone No.")));
        Reply := ACTION::OK;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure CustomerTempModalFormHandler(var CustomerTemplateList: Page "Customer Template List"; var Reply: Action)
    var
        CustomerTemplate: Record "Customer Template";
    begin
        CustomerTemplate.Init;  // Required to initialize the variable.
        CustomerTemplate.Get(LibraryVariableStorage.DequeueText);
        CustomerTemplateList.SetRecord(CustomerTemplate);
        Reply := ACTION::LookupOK;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure CreateInteractModalFormHandler(var CreateInteraction: Page "Create Interaction"; var Response: Action)
    var
        TempSegmentLine: Record "Segment Line" temporary;
        InteractionTemplateCode: Code[10];
    begin
        TempSegmentLine.Init;  // Required to initialize the variable.
        CreateInteraction.GetRecord(TempSegmentLine);
        TempSegmentLine.Insert;  // Insert temporary Segment Line to modify fields later.
        InteractionTemplateCode :=
          CopyStr(LibraryVariableStorage.DequeueText, 1, MaxStrLen(TempSegmentLine."Interaction Template Code"));
        TempSegmentLine.Validate("Interaction Template Code", InteractionTemplateCode);
        TempSegmentLine.Validate(Description, InteractionTemplateCode);
        NextStepMakePhoneCallWizard(TempSegmentLine);
        NextStepMakePhoneCallWizard(TempSegmentLine);

        TempSegmentLine."Cost (LCY)" := LibraryVariableStorage.DequeueDecimal;
        TempSegmentLine."Duration (Min.)" := LibraryVariableStorage.DequeueDecimal;
        TempSegmentLine.Modify(true);
        TempSegmentLine.FinishWizard(true);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure CreateOpportModalFormHandler(var CreateOpportunity: Page "Create Opportunity"; var Reply: Action)
    var
        TempOpportunity: Record Opportunity temporary;
        SalesCycleCode: Code[10];
    begin
        TempOpportunity.Init;  // Required to initialize the variable.
        CreateOpportunity.GetRecord(TempOpportunity);
        TempOpportunity.Insert;  // Insert temporary Opportunity to modify fields later.
        SalesCycleCode :=
          CopyStr(LibraryVariableStorage.DequeueText, 1, MaxStrLen(TempOpportunity."Sales Cycle Code"));
        TempOpportunity.Validate(Description, SalesCycleCode);
        TempOpportunity.Validate("Sales Cycle Code", SalesCycleCode);
        TempOpportunity.Validate("Activate First Stage", true);
        TempOpportunity.Validate("Wizard Estimated Value (LCY)", LibraryVariableStorage.DequeueDecimal);
        TempOpportunity.Validate("Wizard Chances of Success %", LibraryVariableStorage.DequeueDecimal);
        TempOpportunity.Modify;
        TempOpportunity.FinishWizard;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure CloseOpportModalFormHandler(var CloseOpportunity: Page "Close Opportunity"; var Reply: Action)
    var
        TempOpportunityEntry: Record "Opportunity Entry" temporary;
    begin
        TempOpportunityEntry.Init;  // Required to initialize the variable.
        CloseOpportunity.GetRecord(TempOpportunityEntry);
        TempOpportunityEntry.Insert;
        TempOpportunityEntry.Validate("Action Taken", TempOpportunityEntry."Action Taken"::Won);
        TempOpportunityEntry.Validate("Close Opportunity Code",
          CopyStr(LibraryVariableStorage.DequeueText, 1, MaxStrLen(TempOpportunityEntry."Close Opportunity Code")));
        TempOpportunityEntry.Validate("Calcd. Current Value (LCY)", LibraryVariableStorage.DequeueDecimal);
        TempOpportunityEntry.Modify;
        TempOpportunityEntry.CheckStatus;
        TempOpportunityEntry.FinishWizard;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ContactListModalPageHandler(var ContactList: TestPage "Contact List")
    var
        Contact: Record Contact;
    begin
        Contact.Get(LibraryVariableStorage.DequeueText);
        ContactList.GotoRecord(Contact);
        ContactList.OK.Invoke;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure EmailVerifyModalPageHandler(var EmailDialog: TestPage "Email Dialog")
    begin
        EmailDialog.SendTo.AssertEquals(LibraryVariableStorage.DequeueText);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure CustomerTempModalPageHandlerWithEnqueue(var CustomerTemplateList: Page "Customer Template List"; var Reply: Action)
    var
        VATPostingSetup: Record "VAT Posting Setup";
        CustomerTemplate: Record "Customer Template";
    begin
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        CustomerTemplate.Get(CreateCustomerTemplateForContact(VATPostingSetup."VAT Bus. Posting Group"));
        CustomerTemplateList.SetRecord(CustomerTemplate);
        LibraryVariableStorage.Enqueue(CustomerTemplate.Code);
        Reply := ACTION::LookupOK;
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandlerTrue(Question: Text[1024]; var Reply: Boolean)
    begin
        if Question = 'Do you want to create a follow-up task?' then
            Reply := false
        else
            Reply := true;
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandlerFalseWithTextVerification(Question: Text[1024]; var Reply: Boolean)
    begin
        Assert.AreEqual(LibraryVariableStorage.DequeueText, Question, 'Unexpected confirmation message');
        Reply := false;
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ModalFormMarketingSetup(var MarketingSetup: Page "Marketing Setup"; var Response: Action)
    var
        MarketingSetup2: Record "Marketing Setup";
    begin
        MarketingSetup.GetRecord(MarketingSetup2);
        MarketingSetup2."Attachment Storage Type" := MarketingSetup2."Attachment Storage Type"::"Disk File";
        MarketingSetup.SetRecord(MarketingSetup2);
        MarketingSetup.SetAttachmentStorageType;

        MarketingSetup2.Get;
        MarketingSetup2."Attachment Storage Location" := TemporaryPath;
        MarketingSetup.SetRecord(MarketingSetup2);
        MarketingSetup.SetAttachmentStorageLocation;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure BankAccountLinkPageHandler(var BankAccountLink: TestPage "Bank Account Link")
    var
        CurrMasterFields: Option Contact,Bank;
    begin
        BankAccountLink."No.".SetValue(LibraryVariableStorage.DequeueText);
        BankAccountLink.CurrMasterFields.SetValue(CurrMasterFields::Bank);  // Taking Value from Base Page's Option.
        BankAccountLink.OK.Invoke;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure CustomerLinkPageHandler(var CustomerLink: TestPage "Customer Link")
    begin
        CustomerLink."No.".SetValue(LibraryVariableStorage.DequeueText);
        CustomerLink.CurrMasterFields.SetValue(LibraryVariableStorage.DequeueInteger);  // Taking Value from Base Page's Option from test case.
        CustomerLink.OK.Invoke;
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure VendorLinkPageHandler(var VendorLink: TestPage "Vendor Link")
    var
        CurrMasterFields: Option Contact,Vendor;
    begin
        VendorLink."No.".SetValue(LibraryVariableStorage.DequeueText);
        VendorLink.CurrMasterFields.SetValue(CurrMasterFields::Vendor);  // Taking Value from Base Page's Option.
        VendorLink.OK.Invoke;
    end;

    local procedure ExecuteUIHandler()
    begin
        // Generate Dummy message. Required for executing the test case successfully.
        if Confirm(StrSubstNo(ExpectedMessage)) then;
    end;

    [PageHandler]
    [Scope('OnPrem')]
    procedure ContactHandler(var Contact: TestPage "Contact Card")
    begin
        Contact.New;
        Contact."Company Name".AssertEquals(LibraryVariableStorage.DequeueText);
        Contact.Type.AssertEquals(LibraryVariableStorage.DequeueText);
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure SalesQuoteReportRequestPageHandler(var StandardSalesQuote: TestRequestPage "Standard Sales - Quote")
    begin
        StandardSalesQuote.Cancel.Invoke;
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure ContactCoverSheetReportRequestPageHandler(var CoverSheet: TestRequestPage "Contact Cover Sheet")
    begin
        CoverSheet.LogInteraction.SetValue(LibraryVariableStorage.DequeueBoolean);
        CoverSheet.SaveAsXml(LibraryReportDataset.GetParametersFileName, LibraryReportDataset.GetFileName);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure CustomerTemplateListPageHandler(var CustomerTemplateList: TestPage "Customer Template List")
    begin
        CustomerTemplateList.First;
        Assert.AreEqual(LibraryVariableStorage.DequeueText, CustomerTemplateList.Code.Value, CustTemplateListErr);
        Assert.IsFalse(CustomerTemplateList.Next, CustTemplateListErr);
        CustomerTemplateList.OK.Invoke;
    end;

    [SendNotificationHandler]
    [Scope('OnPrem')]
    procedure NotificationHandler(var Notification: Notification): Boolean
    begin
        LibraryVariableStorage.Enqueue(Notification.Message);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure MyNotificationsModalPageHandler(var MyNotifications: TestPage "My Notifications")
    begin
        MyNotifications.FILTER.SetFilter("Notification Id", CustomerContNotifTok);
        MyNotifications.Enabled.SetValue(LibraryVariableStorage.DequeueBoolean);
        MyNotifications.FILTER.SetFilter("Notification Id", VendorContNotifTok);
        MyNotifications.Enabled.SetValue(LibraryVariableStorage.DequeueBoolean);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ContactListLookupModalPageHandler(var ContactList: TestPage "Contact List")
    begin
        ContactList.FILTER.SetFilter("No.", LibraryVariableStorage.DequeueText());
        ContactList.OK.Invoke();
    end;
}
