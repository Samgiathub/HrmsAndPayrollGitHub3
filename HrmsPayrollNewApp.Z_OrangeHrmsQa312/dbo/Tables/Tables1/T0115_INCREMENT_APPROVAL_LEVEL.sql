﻿CREATE TABLE [dbo].[T0115_INCREMENT_APPROVAL_LEVEL] (
    [Tran_ID]                       NUMERIC (18)    NOT NULL,
    [App_ID]                        NUMERIC (18)    NOT NULL,
    [Emp_ID]                        NUMERIC (18)    NOT NULL,
    [Cmp_ID]                        NUMERIC (18)    NOT NULL,
    [Branch_ID]                     NUMERIC (18)    NOT NULL,
    [Cat_ID]                        NUMERIC (18)    NULL,
    [Grd_ID]                        NUMERIC (18)    NOT NULL,
    [Dept_ID]                       NUMERIC (18)    NULL,
    [Desig_Id]                      NUMERIC (18)    NULL,
    [Type_ID]                       NUMERIC (18)    NULL,
    [Bank_ID]                       NUMERIC (18)    NULL,
    [Curr_ID]                       NUMERIC (18)    NULL,
    [Wages_Type]                    VARCHAR (10)    NULL,
    [Salary_Basis_On]               VARCHAR (20)    NULL,
    [Basic_Salary]                  NUMERIC (18, 4) NULL,
    [Gross_Salary]                  NUMERIC (18, 4) NULL,
    [Increment_Type]                VARCHAR (30)    NULL,
    [Appr_Date]                     DATETIME        NOT NULL,
    [Increment_Effective_Date]      DATETIME        NOT NULL,
    [Payment_Mode]                  VARCHAR (20)    NULL,
    [Inc_Bank_AC_No]                VARCHAR (20)    NULL,
    [Emp_OT]                        NUMERIC (18)    NULL,
    [Emp_OT_Min_Limit]              VARCHAR (10)    NULL,
    [Emp_OT_Max_Limit]              VARCHAR (10)    NULL,
    [Increment_Per]                 NUMERIC (18, 2) NULL,
    [Increment_Amount]              NUMERIC (18, 4) NULL,
    [Pre_Basic_Salary]              NUMERIC (18, 4) NULL,
    [Pre_Gross_Salary]              NUMERIC (18, 4) NULL,
    [Increment_Comments]            VARCHAR (250)   NULL,
    [Emp_Late_mark]                 NUMERIC (1)     NULL,
    [Emp_Full_PF]                   NUMERIC (1)     NULL,
    [Emp_PT]                        NUMERIC (1)     NULL,
    [Emp_Fix_Salary]                NUMERIC (1)     NULL,
    [Emp_Part_Time]                 TINYINT         CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Emp_Part_Time] DEFAULT ((0)) NULL,
    [Late_Dedu_Type]                VARCHAR (10)    NULL,
    [Emp_Late_Limit]                VARCHAR (10)    NULL,
    [Emp_PT_Amount]                 NUMERIC (5)     CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Emp_PT_Amount] DEFAULT ((0)) NULL,
    [Emp_Childran]                  TINYINT         CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Emp_Childran] DEFAULT ((0)) NULL,
    [Is_Master_Rec]                 TINYINT         CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Is_Master_Rec] DEFAULT ((0)) NULL,
    [Login_ID]                      NUMERIC (18)    NULL,
    [System_Date]                   DATETIME        NULL,
    [Yearly_Bonus_Amount]           NUMERIC (22, 2) NULL,
    [Deputation_End_Date]           DATETIME        NULL,
    [Is_Deputation_Reminder]        TINYINT         CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Is_Deputation_Reminder] DEFAULT ((1)) NULL,
    [Appr_Int_ID]                   NUMERIC (18)    NULL,
    [CTC]                           NUMERIC (18, 4) CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_CTC] DEFAULT ((0)) NULL,
    [Emp_Early_mark]                NUMERIC (1)     CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Emp_Early_mark] DEFAULT ((0)) NULL,
    [Early_Dedu_Type]               VARCHAR (10)    NULL,
    [Emp_Early_Limit]               VARCHAR (10)    CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Emp_Early_Limit] DEFAULT ((0)) NULL,
    [Emp_Deficit_mark]              NUMERIC (1)     CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Emp_Deficit_mark] DEFAULT ((0)) NULL,
    [Deficit_Dedu_Type]             VARCHAR (10)    NULL,
    [Emp_Deficit_Limit]             VARCHAR (10)    CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Emp_Deficit_Limit] DEFAULT ((0)) NULL,
    [Center_ID]                     NUMERIC (18)    NULL,
    [Emp_WeekDay_OT_Rate]           NUMERIC (10, 3) CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Emp_WeekDay_OT_Rate] DEFAULT ((0.0)) NULL,
    [Emp_WeekOff_OT_Rate]           NUMERIC (10, 3) CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Emp_WeekOff_OT_Rate] DEFAULT ((0.0)) NULL,
    [Emp_Holiday_OT_Rate]           NUMERIC (10, 3) CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Emp_Holiday_OT_Rate] DEFAULT ((0.0)) NULL,
    [Is_Metro_City]                 TINYINT         CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Is_Metro_City] DEFAULT ((0)) NOT NULL,
    [Pre_CTC_Salary]                NUMERIC (18, 4) CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Pre_CTC_Salary] DEFAULT ((0)) NOT NULL,
    [Incerment_Amount_gross]        NUMERIC (18, 4) CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Incerment_Amount_gross] DEFAULT ((0)) NOT NULL,
    [Incerment_Amount_CTC]          NUMERIC (18, 4) CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Incerment_Amount_CTC] DEFAULT ((0)) NOT NULL,
    [Increment_Mode]                TINYINT         CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Increment_Mode] DEFAULT ((1)) NOT NULL,
    [is_physical]                   TINYINT         CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_is_physical] DEFAULT ((0)) NULL,
    [SalDate_id]                    NUMERIC (18)    NULL,
    [Emp_Auto_Vpf]                  TINYINT         CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Emp_Auto_Vpf] DEFAULT ((0)) NOT NULL,
    [Segment_ID]                    NUMERIC (18)    NULL,
    [Vertical_ID]                   NUMERIC (18)    NULL,
    [SubVertical_ID]                NUMERIC (18)    NULL,
    [subBranch_ID]                  NUMERIC (18)    NULL,
    [Monthly_Deficit_Adjust_OT_Hrs] TINYINT         CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Monthly_Deficit_Adjust_OT_Hrs] DEFAULT ((0)) NOT NULL,
    [Fix_OT_Hour_Rate_WD]           NUMERIC (18, 3) CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Fix_OT_Hour_Rate_WD] DEFAULT ((0)) NOT NULL,
    [Fix_OT_Hour_Rate_WO_HO]        NUMERIC (18, 3) CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Fix_OT_Hour_Rate_WO_HO] DEFAULT ((0)) NOT NULL,
    [Bank_ID_Two]                   NUMERIC (18)    NULL,
    [Payment_Mode_Two]              VARCHAR (20)    NULL,
    [Inc_Bank_AC_No_Two]            VARCHAR (20)    NULL,
    [Bank_Branch_Name]              VARCHAR (50)    NULL,
    [Bank_Branch_Name_Two]          VARCHAR (50)    NULL,
    [Reason_ID]                     NUMERIC (5)     CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Reason_ID] DEFAULT ((0)) NOT NULL,
    [Reason_Name]                   VARCHAR (200)   NULL,
    [S_Emp_ID]                      NUMERIC (18)    NOT NULL,
    [Approval_Status]               VARCHAR (5)     NOT NULL,
    [Rpt_Level]                     INT             NOT NULL,
    [Customer_Audit]                TINYINT         CONSTRAINT [DF_T0115_INCREMENT_APPROVAL_LEVEL_Customer_Audit] DEFAULT ((0)) NOT NULL,
    [Sales_Code]                    VARCHAR (20)    NULL,
    [Is_Piece_Trans_Salary]         TINYINT         NULL,
    CONSTRAINT [PK_T0115_INCREMENT_APPROVAL_LEVEL] PRIMARY KEY CLUSTERED ([Tran_ID] ASC)
);

