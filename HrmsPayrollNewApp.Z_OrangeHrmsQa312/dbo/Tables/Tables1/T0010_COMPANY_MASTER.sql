﻿CREATE TABLE [dbo].[T0010_COMPANY_MASTER] (
    [Cmp_Id]                           NUMERIC (18)   NOT NULL,
    [Cmp_Name]                         VARCHAR (100)  NOT NULL,
    [Cmp_Address]                      VARCHAR (250)  NOT NULL,
    [Loc_ID]                           NUMERIC (18)   NULL,
    [Cmp_City]                         VARCHAR (50)   NOT NULL,
    [Cmp_PinCode]                      VARCHAR (10)   NOT NULL,
    [Cmp_Phone]                        VARCHAR (20)   NOT NULL,
    [Cmp_Email]                        VARCHAR (50)   NOT NULL,
    [Cmp_Web]                          VARCHAR (50)   NULL,
    [Date_Format]                      VARCHAR (5)    NOT NULL,
    [From_Date]                        DATETIME       NOT NULL,
    [To_Date]                          DATETIME       NOT NULL,
    [PF_No]                            VARCHAR (20)   NULL,
    [ESIC_No]                          VARCHAR (20)   NULL,
    [Domain_Name]                      VARCHAR (50)   NULL,
    [Image_name]                       VARCHAR (200)  NULL,
    [Default_Holiday]                  VARCHAR (120)  NULL,
    [Cmp_Type]                         VARCHAR (30)   NULL,
    [Cmp_State_Name]                   VARCHAR (20)   NULL,
    [Cmp_HR_Manager]                   VARCHAR (50)   NULL,
    [Cmp_HR_Manager_Desig]             VARCHAR (30)   NULL,
    [Cmp_HR_Assistant]                 VARCHAR (50)   NULL,
    [Cmp_HR_Assistant_Desig]           VARCHAR (30)   NULL,
    [Cmp_PAN_No]                       VARCHAR (30)   NULL,
    [Cmp_TAN_No]                       VARCHAR (30)   NULL,
    [database_file_name]               VARCHAR (50)   NULL,
    [Is_Organise_chart]                TINYINT        NULL,
    [Image_file_Path]                  VARCHAR (1000) NULL,
    [Cmp_Code]                         VARCHAR (50)   NULL,
    [Is_Auto_Alpha_Numeric_Code]       TINYINT        CONSTRAINT [DF_T0010_COMPANY_MASTER_Is_Auto_Alpha_Numeric_Code] DEFAULT ((0)) NOT NULL,
    [No_Of_Digit_Emp_Code]             NUMERIC (18)   CONSTRAINT [DF_T0010_COMPANY_MASTER_No_Of_Digit_Emp_Code] DEFAULT ((4)) NOT NULL,
    [Cmp_Signature]                    NVARCHAR (MAX) CONSTRAINT [DF__T0010_COM__Cmp_S__296D0115] DEFAULT ('') NULL,
    [is_GroupOFCmp]                    TINYINT        CONSTRAINT [DF__T0010_COM__is_Gr__6581EB1C] DEFAULT ((0)) NULL,
    [is_Main]                          TINYINT        CONSTRAINT [DF__T0010_COM__is_Ma__6FFF798F] DEFAULT ((0)) NULL,
    [is_Organo_designationwise]        TINYINT        NULL,
    [Nature_of_Business]               VARCHAR (100)  CONSTRAINT [DF_T0010_COMPANY_MASTER_Nature_of_Business] DEFAULT (NULL) NULL,
    [Registration_No]                  VARCHAR (50)   CONSTRAINT [DF_T0010_COMPANY_MASTER_Registration_No] DEFAULT (NULL) NULL,
    [License_No]                       VARCHAR (50)   CONSTRAINT [DF_T0010_COMPANY_MASTER_License_No] DEFAULT (NULL) NULL,
    [NIC_Code_No]                      VARCHAR (50)   CONSTRAINT [DF_T0010_COMPANY_MASTER_NIC_Code_No] DEFAULT (NULL) NULL,
    [Date_of_Establishment]            DATETIME       CONSTRAINT [DF_T0010_COMPANY_MASTER_Date_of_Establishment] DEFAULT (NULL) NULL,
    [Factory_Type]                     VARCHAR (100)  NULL,
    [Income_Tax_No]                    VARCHAR (50)   NULL,
    [PF_Office]                        VARCHAR (150)  NULL,
    [ESIC_Office]                      VARCHAR (150)  NULL,
    [Tax_Manager_Form_16]              VARCHAR (100)  NULL,
    [Father_Name_Form_16]              VARCHAR (100)  NULL,
    [Designation_Manager_Form_16]      VARCHAR (100)  NULL,
    [cmp_logo]                         IMAGE          NULL,
    [Inout_Duration]                   NUMERIC (10)   CONSTRAINT [DF__T0010_COM__Inout__31D829E4] DEFAULT ((300)) NOT NULL,
    [Is_Alpha_Numeric_Branchwise]      TINYINT        CONSTRAINT [DF_T0010_COMPANY_MASTER_Is_Alpha_Numeric_Branchwise] DEFAULT ((0)) NOT NULL,
    [Is_Contractor_Company]            TINYINT        CONSTRAINT [DF_T0010_COMPANY_MASTER_Is_Contractor_Company] DEFAULT ((0)) NOT NULL,
    [Is_PF_APPLICABLE]                 NUMERIC (18)   CONSTRAINT [DF_T0010_COMPANY_MASTER_Is_PF_APPLICABLE] DEFAULT ((0)) NOT NULL,
    [Is_ESIC_APPLICABLE]               NUMERIC (18)   CONSTRAINT [DF_T0010_COMPANY_MASTER_Is_ESIC_APPLICABLE] DEFAULT ((0)) NOT NULL,
    [CIT_Address]                      NVARCHAR (200) NULL,
    [CIT_City]                         NVARCHAR (50)  NULL,
    [CIT_Pin]                          NUMERIC (18)   NULL,
    [Has_Digital_Certi]                TINYINT        CONSTRAINT [DF__T0010_COM__Has_D__2B2BF7AC] DEFAULT ((0)) NULL,
    [Digital_Certi_FileName]           VARCHAR (100)  NULL,
    [Digital_Certi_Password]           VARCHAR (50)   NULL,
    [Date_Form_16_Submit]              DATETIME       NULL,
    [License_Office]                   VARCHAR (50)   NULL,
    [Is_CompanyWise]                   TINYINT        CONSTRAINT [DF_T0010_COMPANY_MASTER_Is_CompanyWise] DEFAULT ((0)) NOT NULL,
    [Is_DateWise]                      TINYINT        CONSTRAINT [DF_T0010_COMPANY_MASTER_Is_DateWise] DEFAULT ((0)) NOT NULL,
    [Is_JoiningDateWise]               TINYINT        CONSTRAINT [DF_T0010_COMPANY_MASTER_Is_JoiningDateWise] DEFAULT ((0)) NOT NULL,
    [DateFormat]                       VARCHAR (10)   NULL,
    [Reset_Sequance]                   TINYINT        CONSTRAINT [DF_T0010_COMPANY_MASTER_Reset_Sequance] DEFAULT ((0)) NULL,
    [Max_Emp_Code]                     VARCHAR (50)   DEFAULT ('Company_Wise') NOT NULL,
    [Sample_Emp_Code]                  VARCHAR (500)  NULL,
    [Is_Desig]                         TINYINT        CONSTRAINT [DF_T0010_COMPANY_MASTER_Is_Desig] DEFAULT ((0)) NOT NULL,
    [Is_Cate]                          TINYINT        CONSTRAINT [DF_T0010_COMPANY_MASTER_Is_Cate] DEFAULT ((0)) NOT NULL,
    [Is_EmpType]                       TINYINT        CONSTRAINT [DF_T0010_COMPANY_MASTER_Is_EmpType] DEFAULT ((0)) NOT NULL,
    [Is_DateofBirth]                   TINYINT        CONSTRAINT [DF_T0010_COMPANY_MASTER_Is_DateofBirth] DEFAULT ((0)) NOT NULL,
    [Is_Current_Date]                  TINYINT        CONSTRAINT [DF_T0010_COMPANY_MASTER_Is_Current_Date] DEFAULT ((0)) NOT NULL,
    [DateFormat_Birth]                 VARCHAR (15)   NULL,
    [DateFormat_Current]               VARCHAR (15)   NULL,
    [Cmp_Account_No]                   VARCHAR (100)  NULL,
    [IS_Active]                        NUMERIC (18)   DEFAULT ((1)) NOT NULL,
    [State_ID]                         NUMERIC (18)   NULL,
    [Leave_Balance_Display_FixOpening] TINYINT        CONSTRAINT [DF_T0010_COMPANY_MASTER_Leave_Balance_Display_FixOpening] DEFAULT ((0)) NOT NULL,
    [PfTrustNo]                        VARCHAR (50)   NULL,
    [Alt_W_Name]                       VARCHAR (100)  NULL,
    [Alt_W_Full_Day_Cont]              VARCHAR (50)   NULL,
    [Cmp_Header]                       VARCHAR (1000) NULL,
    [Cmp_Footer]                       VARCHAR (1000) NULL,
    [GST]                              TINYINT        CONSTRAINT [DF_T0010_COMPANY_MASTER_GST_No] DEFAULT ((0)) NOT NULL,
    [GST_No]                           NVARCHAR (50)  NULL,
    [GST_Cmp_Name]                     NVARCHAR (250) NULL,
    [LWF_Number]                       VARCHAR (100)  NULL,
    [Password_Verification]            NVARCHAR (250) NULL,
    CONSTRAINT [PK_T0010_COMPANY_MASTER] PRIMARY KEY CLUSTERED ([Cmp_Id] ASC) WITH (FILLFACTOR = 80)
);


GO
CREATE STATISTICS [_dta_stat_1598680793_2_1]
    ON [dbo].[T0010_COMPANY_MASTER]([Cmp_Name], [Cmp_Id]);

