﻿CREATE TABLE [dbo].[T0110_CLAIM_APPLICATION_DETAIL] (
    [Claim_App_Detail_ID]      NUMERIC (18)    NOT NULL,
    [Cmp_ID]                   NUMERIC (18)    NOT NULL,
    [Claim_App_ID]             NUMERIC (18)    NOT NULL,
    [For_Date]                 DATETIME        NOT NULL,
    [Application_Amount]       NUMERIC (18, 2) NOT NULL,
    [Claim_Description]        NVARCHAR (MAX)  NULL,
    [Claim_ID]                 NUMERIC (18)    NOT NULL,
    [Curr_ID]                  NUMERIC (18)    NULL,
    [Curr_Rate]                NUMERIC (18, 2) NULL,
    [Claim_Amount]             NUMERIC (18, 2) NOT NULL,
    [Petrol_Km]                NUMERIC (18, 2) CONSTRAINT [DF_T0110_CLAIM_APPLICATION_DETAIL_Petrol_Km] DEFAULT ((0)) NOT NULL,
    [Claim_Attachment]         NVARCHAR (500)  NULL,
    [Claim_Model]              VARCHAR (500)   NULL,
    [Claim_IMEI]               VARCHAR (500)   NULL,
    [Claim_NoofPerson]         VARCHAR (500)   NULL,
    [Claim_DateOfPurchase]     SMALLDATETIME   NULL,
    [Claim_BookName]           VARCHAR (200)   NULL,
    [Claim_Subject]            VARCHAR (200)   NULL,
    [Claim_ActualPrice]        FLOAT (53)      NULL,
    [Claim_PriceAfterDiscount] FLOAT (53)      NULL,
    [Claim_FamilyMember]       VARCHAR (200)   NULL,
    [Claim_Relation]           VARCHAR (100)   NULL,
    [Claim_Age]                FLOAT (53)      NULL,
    [Claim_Limit]              FLOAT (53)      NULL,
    [Claim_FamilyMeberId]      INT             NULL,
    [Claim_UnitName]           VARCHAR (100)   NULL,
    [Claim_UnitFlag]           INT             NULL,
    [Claim_ConversionRate]     FLOAT (53)      NULL,
    [ClaimSelf_Value]          NUMERIC (18, 2) NULL,
    [Claim_Date_Label]         VARCHAR (100)   NULL,
    [Claim_From_Loc_ID]        NUMERIC (10)    CONSTRAINT [DF__T0110_CLA__Claim__429BC690] DEFAULT ((0)) NULL,
    [Claim_To_Loc_ID]          NUMERIC (10)    CONSTRAINT [DF__T0110_CLA__Claim__438FEAC9] DEFAULT ((0)) NULL,
    [City_name]                VARCHAR (20)    DEFAULT (NULL) NULL,
    CONSTRAINT [PK_T0110_CLAIM_APPLICATION_DETAIL] PRIMARY KEY CLUSTERED ([Claim_App_Detail_ID] ASC) WITH (FILLFACTOR = 80)
);

