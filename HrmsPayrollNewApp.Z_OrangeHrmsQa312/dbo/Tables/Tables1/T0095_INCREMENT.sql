CREATE TABLE [dbo].[T0095_INCREMENT] (
    [Increment_ID]                  NUMERIC (18)    NOT NULL,
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
    [Increment_Date]                DATETIME        NOT NULL,
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
    [Emp_Part_Time]                 TINYINT         CONSTRAINT [DF_T0095_INCREMENT_Emp_Part_Time] DEFAULT ((0)) NULL,
    [Late_Dedu_Type]                VARCHAR (10)    NULL,
    [Emp_Late_Limit]                VARCHAR (10)    NULL,
    [Emp_PT_Amount]                 NUMERIC (5)     CONSTRAINT [DF_T0095_INCREMENT_Emp_PT_Amount] DEFAULT ((0)) NULL,
    [Emp_Childran]                  TINYINT         CONSTRAINT [DF_T0095_INCREMENT_Emp_Childran] DEFAULT ((0)) NULL,
    [Is_Master_Rec]                 TINYINT         CONSTRAINT [DF_T0095_INCREMENT_Is_Master_Rec] DEFAULT ((0)) NULL,
    [Login_ID]                      NUMERIC (18)    NULL,
    [System_Date]                   DATETIME        NULL,
    [Yearly_Bonus_Amount]           NUMERIC (22, 2) NULL,
    [Deputation_End_Date]           DATETIME        NULL,
    [Is_Deputation_Reminder]        TINYINT         CONSTRAINT [DF_T0095_INCREMENT_Is_Deputation_Reminder] DEFAULT ((1)) NULL,
    [Appr_Int_ID]                   NUMERIC (18)    NULL,
    [CTC]                           NUMERIC (18, 4) CONSTRAINT [DF_T0095_INCREMENT_CTC] DEFAULT ((0)) NULL,
    [Emp_Early_mark]                NUMERIC (1)     CONSTRAINT [DF__T0095_INC__Emp_E__6D8D2138] DEFAULT ((0)) NULL,
    [Early_Dedu_Type]               VARCHAR (10)    NULL,
    [Emp_Early_Limit]               VARCHAR (10)    CONSTRAINT [DF__T0095_INC__Emp_E__6E814571] DEFAULT ((0)) NULL,
    [Emp_Deficit_mark]              NUMERIC (1)     CONSTRAINT [DF__T0095_INC__Emp_D__6F7569AA] DEFAULT ((0)) NULL,
    [Deficit_Dedu_Type]             VARCHAR (10)    NULL,
    [Emp_Deficit_Limit]             VARCHAR (10)    CONSTRAINT [DF__T0095_INC__Emp_D__70698DE3] DEFAULT ((0)) NULL,
    [Center_ID]                     NUMERIC (18)    NULL,
    [Emp_WeekDay_OT_Rate]           NUMERIC (10, 3) CONSTRAINT [DF__T0095_INC__Emp_W__542254F0] DEFAULT ((0.0)) NULL,
    [Emp_WeekOff_OT_Rate]           NUMERIC (10, 3) CONSTRAINT [DF__T0095_INC__Emp_W__523A0C7E] DEFAULT ((0.0)) NULL,
    [Emp_Holiday_OT_Rate]           NUMERIC (10, 3) CONSTRAINT [DF__T0095_INC__Emp_H__532E30B7] DEFAULT ((0.0)) NULL,
    [Is_Metro_City]                 TINYINT         CONSTRAINT [DF_T0095_INCREMENT_Is_Metro_City] DEFAULT ((0)) NOT NULL,
    [Pre_CTC_Salary]                NUMERIC (18, 4) CONSTRAINT [DF_T0095_INCREMENT_Pre_CTC] DEFAULT ((0)) NOT NULL,
    [Incerment_Amount_gross]        NUMERIC (18, 4) CONSTRAINT [DF_T0095_INCREMENT_Incerment_value_gross] DEFAULT ((0)) NOT NULL,
    [Incerment_Amount_CTC]          NUMERIC (18, 4) CONSTRAINT [DF_T0095_INCREMENT_Incerment_Amount_CTC] DEFAULT ((0)) NOT NULL,
    [Increment_Mode]                TINYINT         CONSTRAINT [DF_T0095_INCREMENT_Increment_Mode] DEFAULT ((1)) NOT NULL,
    [is_physical]                   TINYINT         CONSTRAINT [DF_T0095_INCREMENT_is_physical] DEFAULT ((0)) NULL,
    [SalDate_id]                    NUMERIC (18)    NULL,
    [Emp_Auto_Vpf]                  TINYINT         CONSTRAINT [DF_T0095_INCREMENT_Emp_Auto_Vpf] DEFAULT ((0)) NOT NULL,
    [Segment_ID]                    NUMERIC (18)    NULL,
    [Vertical_ID]                   NUMERIC (18)    NULL,
    [SubVertical_ID]                NUMERIC (18)    NULL,
    [subBranch_ID]                  NUMERIC (18)    NULL,
    [Monthly_Deficit_Adjust_OT_Hrs] TINYINT         CONSTRAINT [DF_T0095_INCREMENT_Monthly_Deficit_Adjust_OT_Hrs] DEFAULT ((0)) NOT NULL,
    [Fix_OT_Hour_Rate_WD]           NUMERIC (18, 3) CONSTRAINT [DF_T0095_INCREMENT_Fix_OT_Hour_Rate_WD] DEFAULT ((0)) NOT NULL,
    [Fix_OT_Hour_Rate_WO_HO]        NUMERIC (18, 3) CONSTRAINT [DF_T0095_INCREMENT_Fix_OT_Hour_Rate_WO_HO] DEFAULT ((0)) NOT NULL,
    [Bank_ID_Two]                   NUMERIC (18)    NULL,
    [Payment_Mode_Two]              VARCHAR (20)    NULL,
    [Inc_Bank_AC_No_Two]            VARCHAR (20)    NULL,
    [Bank_Branch_Name]              VARCHAR (2000)  NULL,
    [Bank_Branch_Name_Two]          VARCHAR (50)    NULL,
    [Reason_ID]                     NUMERIC (5)     DEFAULT ((0)) NOT NULL,
    [Reason_Name]                   VARCHAR (200)   NULL,
    [Customer_Audit]                TINYINT         CONSTRAINT [DF_T0095_INCREMENT_Customer_Audit] DEFAULT ((0)) NOT NULL,
    [Increment_App_ID]              NUMERIC (18)    NULL,
    [Sales_Code]                    VARCHAR (20)    NULL,
    [Physical_Percent]              NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [Is_Piece_Trans_Salary]         TINYINT         NULL,
    [Band_Id]                       NUMERIC (18)    NULL,
    [Is_Pradhan_Mantri]             BIT             NULL,
    [Is_1time_PF_Member]            BIT             NULL,
    [Remarks]                       VARCHAR (500)   NULL,
    [FullPension]                   BIT             DEFAULT ((0)) NULL,
    CONSTRAINT [PK_T0095_INCREMENT] PRIMARY KEY CLUSTERED ([Increment_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0095_INCREMENT_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_T0095_INCREMENT_For_SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN]
    ON [dbo].[T0095_INCREMENT]([Increment_Effective_Date] ASC)
    INCLUDE([Emp_ID]);


GO
CREATE UNIQUE NONCLUSTERED INDEX [NCIX_T0095_INCREMENT_COMMON1]
    ON [dbo].[T0095_INCREMENT]([Cmp_ID] ASC, [Emp_ID] ASC, [Increment_Effective_Date] DESC, [Increment_ID] DESC)
    INCLUDE([Branch_ID], [Cat_ID], [Grd_ID], [Dept_ID], [Desig_Id], [Type_ID], [Bank_ID], [Curr_ID], [Wages_Type], [Increment_Type]);


GO
CREATE NONCLUSTERED INDEX [IX_T0095_INCREMENT_For_SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN2]
    ON [dbo].[T0095_INCREMENT]([Emp_ID] ASC, [Increment_Effective_Date] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_T0095_INCREMENT_For_SP_Mobile_HRMS_WebService_AttendanceRegularization]
    ON [dbo].[T0095_INCREMENT]([Branch_ID] ASC)
    INCLUDE([Emp_ID], [Increment_Effective_Date]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_T0095_INCREMENT]
    ON [dbo].[T0095_INCREMENT]([Branch_ID] ASC, [Cat_ID] ASC, [Cmp_ID] ASC, [Dept_ID] ASC, [Desig_Id] ASC, [Emp_ID] ASC, [Grd_ID] ASC, [Increment_ID] ASC, [Type_ID] ASC, [Increment_Effective_Date] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0095_INCREMENT_24_997578592__K3_K2_K18_1]
    ON [dbo].[T0095_INCREMENT]([Cmp_ID] ASC, [Emp_ID] ASC, [Increment_Effective_Date] ASC)
    INCLUDE([Increment_ID]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [ix_T0095_INCREMENT_Increment_Effective_Date_1]
    ON [dbo].[T0095_INCREMENT]([Cmp_ID] ASC, [Increment_Effective_Date] ASC)
    INCLUDE([Branch_ID], [Cat_ID], [Dept_ID], [Desig_Id], [Emp_ID], [Grd_ID], [Segment_ID], [subBranch_ID], [SubVertical_ID], [Type_ID], [Vertical_ID]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_T0095_INCREMENT_C_I_B_E_G_I]
    ON [dbo].[T0095_INCREMENT]([Cmp_ID] ASC, [Increment_Effective_Date] ASC, [Branch_ID] ASC, [Emp_ID] ASC, [Grd_ID] ASC, [Increment_ID] ASC)
    INCLUDE([Dept_ID], [Desig_Id], [Type_ID]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_T0095_INCREMENT_Emp_ID]
    ON [dbo].[T0095_INCREMENT]([Emp_ID] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0095_INCREMENT_10_1427536169__K2_K3_1_4_5_6_7_8_9_10_11_18_52_63_65_66_67_68]
    ON [dbo].[T0095_INCREMENT]([Emp_ID] ASC, [Cmp_ID] ASC)
    INCLUDE([Bank_ID], [Branch_ID], [Cat_ID], [Center_ID], [Curr_ID], [Dept_ID], [Desig_Id], [Grd_ID], [Increment_Effective_Date], [Increment_ID], [SalDate_id], [Segment_ID], [subBranch_ID], [SubVertical_ID], [Type_ID], [Vertical_ID]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0095_INCREMENT_24_997578592__K2_K18_K3]
    ON [dbo].[T0095_INCREMENT]([Emp_ID] ASC, [Increment_Effective_Date] ASC, [Cmp_ID] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0095_INCREMENT_24_997578592__K2_K18_K31_K4]
    ON [dbo].[T0095_INCREMENT]([Emp_ID] ASC, [Increment_Effective_Date] ASC, [Emp_PT] ASC, [Branch_ID] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex-20181026-180310]
    ON [dbo].[T0095_INCREMENT]([Emp_ID] ASC, [Increment_Effective_Date] DESC, [Increment_ID] DESC, [Cmp_ID] ASC, [Branch_ID] ASC, [Cat_ID] ASC, [Grd_ID] ASC, [Dept_ID] ASC, [Desig_Id] ASC, [Type_ID] ASC, [Bank_ID] ASC, [Increment_Type] ASC, [Segment_ID] ASC, [Vertical_ID] ASC, [SubVertical_ID] ASC, [subBranch_ID] ASC)
    INCLUDE([Basic_Salary], [Early_Dedu_Type], [Emp_Auto_Vpf], [Emp_Early_Limit], [Emp_Early_mark], [Emp_Fix_Salary], [Emp_Full_PF], [Emp_Holiday_OT_Rate], [Emp_Late_Limit], [Emp_Late_mark], [Emp_OT], [Emp_OT_Max_Limit], [Emp_OT_Min_Limit], [Emp_PT], [Emp_WeekDay_OT_Rate], [Emp_WeekOff_OT_Rate], [Fix_OT_Hour_Rate_WD], [Fix_OT_Hour_Rate_WO_HO], [Gross_Salary], [Late_Dedu_Type], [Payment_Mode], [Reason_Name]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_T0095_INCREMENT_For_SP_CALCULATE_PRESENT_DAYS]
    ON [dbo].[T0095_INCREMENT]([Emp_OT_Min_Limit] ASC)
    INCLUDE([Emp_OT], [Emp_OT_Max_Limit]);


GO
CREATE NONCLUSTERED INDEX [ix_T0095_INCREMENT_Increment_Effective_Date]
    ON [dbo].[T0095_INCREMENT]([Increment_Effective_Date] ASC)
    INCLUDE([Branch_ID], [Cat_ID], [Cmp_ID], [Dept_ID], [Desig_Id], [Emp_ID], [Grd_ID], [Segment_ID], [subBranch_ID], [SubVertical_ID], [Type_ID], [Vertical_ID]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_T0095_INCREMENT_SP_IT_TAX_PREPARATION]
    ON [dbo].[T0095_INCREMENT]([Increment_Type] ASC, [Increment_Effective_Date] ASC)
    INCLUDE([Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_997578592_1_4_7]
    ON [dbo].[T0095_INCREMENT]([Increment_ID], [Branch_ID], [Dept_ID]);


GO
CREATE STATISTICS [_dta_stat_997578592_7_18_2_9]
    ON [dbo].[T0095_INCREMENT]([Dept_ID], [Increment_Effective_Date], [Emp_ID], [Type_ID]);


GO
CREATE STATISTICS [_dta_stat_997578592_6_18]
    ON [dbo].[T0095_INCREMENT]([Grd_ID], [Increment_Effective_Date]);


GO
CREATE STATISTICS [_dta_stat_997578592_8_18_2]
    ON [dbo].[T0095_INCREMENT]([Desig_Id], [Increment_Effective_Date], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_997578592_9_8_7_6_4_2]
    ON [dbo].[T0095_INCREMENT]([Type_ID], [Desig_Id], [Dept_ID], [Grd_ID], [Branch_ID], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_997578592_9_18_2_8_7_6_4]
    ON [dbo].[T0095_INCREMENT]([Type_ID], [Increment_Effective_Date], [Emp_ID], [Desig_Id], [Dept_ID], [Grd_ID], [Branch_ID]);


GO
CREATE STATISTICS [_dta_stat_997578592_4_18_2_9_8_7]
    ON [dbo].[T0095_INCREMENT]([Branch_ID], [Increment_Effective_Date], [Emp_ID], [Type_ID], [Desig_Id], [Dept_ID]);


GO
CREATE STATISTICS [_dta_stat_997578592_18_2_6_9_8]
    ON [dbo].[T0095_INCREMENT]([Increment_Effective_Date], [Emp_ID], [Grd_ID], [Type_ID], [Desig_Id]);


GO
CREATE STATISTICS [_dta_stat_1427536169_3_2_18_4]
    ON [dbo].[T0095_INCREMENT]([Cmp_ID], [Emp_ID], [Increment_Effective_Date], [Branch_ID]);


GO
CREATE STATISTICS [_dta_stat_997578592_18_3_9_8_7_6_4]
    ON [dbo].[T0095_INCREMENT]([Increment_Effective_Date], [Cmp_ID], [Type_ID], [Desig_Id], [Dept_ID], [Grd_ID], [Branch_ID]);


GO
CREATE STATISTICS [_dta_stat_997578592_3_18_2_9_8_7_6_4]
    ON [dbo].[T0095_INCREMENT]([Cmp_ID], [Increment_Effective_Date], [Emp_ID], [Type_ID], [Desig_Id], [Dept_ID], [Grd_ID], [Branch_ID]);


GO
CREATE STATISTICS [_dta_stat_997578592_18_9_8_7_6_4]
    ON [dbo].[T0095_INCREMENT]([Increment_Effective_Date], [Type_ID], [Desig_Id], [Dept_ID], [Grd_ID], [Branch_ID]);


GO
CREATE STATISTICS [_dta_stat_2073058421_3_18_1]
    ON [dbo].[T0095_INCREMENT]([Cmp_ID], [Increment_Effective_Date], [Increment_ID]);


GO
CREATE STATISTICS [_dta_stat_2073058421_3_2_18_1_8]
    ON [dbo].[T0095_INCREMENT]([Cmp_ID], [Emp_ID], [Increment_Effective_Date], [Increment_ID], [Desig_Id]);


GO
CREATE STATISTICS [_dta_stat_2073058421_2_18_1_8]
    ON [dbo].[T0095_INCREMENT]([Emp_ID], [Increment_Effective_Date], [Increment_ID], [Desig_Id]);


GO
CREATE STATISTICS [_dta_stat_2073058421_1_8]
    ON [dbo].[T0095_INCREMENT]([Increment_ID], [Desig_Id]);


GO
CREATE STATISTICS [_dta_stat_2073058421_2_1_8_3]
    ON [dbo].[T0095_INCREMENT]([Emp_ID], [Increment_ID], [Desig_Id], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_997578592_18_1_3]
    ON [dbo].[T0095_INCREMENT]([Increment_Effective_Date], [Increment_ID], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_997578592_21_2_18_3]
    ON [dbo].[T0095_INCREMENT]([Emp_OT], [Emp_ID], [Increment_Effective_Date], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_1427536169_2_4_3]
    ON [dbo].[T0095_INCREMENT]([Emp_ID], [Branch_ID], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_1427536169_2_4_6_9_8_7_1]
    ON [dbo].[T0095_INCREMENT]([Emp_ID], [Branch_ID], [Grd_ID], [Type_ID], [Desig_Id], [Dept_ID], [Increment_ID]);


GO
CREATE STATISTICS [_dta_stat_1427536169_1_9_2_3_4_6]
    ON [dbo].[T0095_INCREMENT]([Increment_ID], [Type_ID], [Emp_ID], [Cmp_ID], [Branch_ID], [Grd_ID]);


GO
CREATE STATISTICS [_dta_stat_1427536169_1_8_2_3_4_6_9_7]
    ON [dbo].[T0095_INCREMENT]([Increment_ID], [Desig_Id], [Emp_ID], [Cmp_ID], [Branch_ID], [Grd_ID], [Type_ID], [Dept_ID]);


GO
CREATE STATISTICS [_dta_stat_1427536169_7_1_2_3_4_6_9]
    ON [dbo].[T0095_INCREMENT]([Dept_ID], [Increment_ID], [Emp_ID], [Cmp_ID], [Branch_ID], [Grd_ID], [Type_ID]);


GO
CREATE STATISTICS [_dta_stat_1427536169_4_1_2]
    ON [dbo].[T0095_INCREMENT]([Branch_ID], [Increment_ID], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_1427536169_2_4_6_9_8_7_3]
    ON [dbo].[T0095_INCREMENT]([Emp_ID], [Branch_ID], [Grd_ID], [Type_ID], [Desig_Id], [Dept_ID], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_1427536169_1_2_3_4]
    ON [dbo].[T0095_INCREMENT]([Increment_ID], [Emp_ID], [Cmp_ID], [Branch_ID]);


GO
CREATE STATISTICS [_dta_stat_1427536169_1_6_2_3_4]
    ON [dbo].[T0095_INCREMENT]([Increment_ID], [Grd_ID], [Emp_ID], [Cmp_ID], [Branch_ID]);


GO
CREATE STATISTICS [_dta_stat_1427536169_1_4_2]
    ON [dbo].[T0095_INCREMENT]([Increment_ID], [Branch_ID], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_1427536169_43_1]
    ON [dbo].[T0095_INCREMENT]([Is_Deputation_Reminder], [Increment_ID]);


GO
CREATE STATISTICS [_dta_stat_1427536169_4_7]
    ON [dbo].[T0095_INCREMENT]([Branch_ID], [Dept_ID]);


GO
CREATE STATISTICS [_dta_stat_1427536169_43_7]
    ON [dbo].[T0095_INCREMENT]([Is_Deputation_Reminder], [Dept_ID]);


GO
CREATE STATISTICS [_dta_stat_1427536169_8_4_1_7]
    ON [dbo].[T0095_INCREMENT]([Desig_Id], [Branch_ID], [Increment_ID], [Dept_ID]);


GO
CREATE STATISTICS [_dta_stat_1427536169_7_4_1]
    ON [dbo].[T0095_INCREMENT]([Dept_ID], [Branch_ID], [Increment_ID]);


GO
CREATE STATISTICS [_dta_stat_1427536169_4_3_1]
    ON [dbo].[T0095_INCREMENT]([Branch_ID], [Cmp_ID], [Increment_ID]);


GO
CREATE STATISTICS [_dta_stat_1621580815_6_1]
    ON [dbo].[T0095_INCREMENT]([Grd_ID], [Increment_ID]);


GO
CREATE STATISTICS [IS_T0095_INCREMENT_I_I]
    ON [dbo].[T0095_INCREMENT]([Increment_ID], [Increment_Effective_Date]);


GO
CREATE STATISTICS [IS_T0095_INCREMENT_B_C]
    ON [dbo].[T0095_INCREMENT]([Branch_ID], [Cmp_ID]);


GO
CREATE STATISTICS [IS_T0095_INCREMENT_G_C_I]
    ON [dbo].[T0095_INCREMENT]([Grd_ID], [Cmp_ID], [Increment_Effective_Date]);


GO
CREATE STATISTICS [IS_T0095_INCREMENT_E_I_C_I_B]
    ON [dbo].[T0095_INCREMENT]([Emp_ID], [Increment_ID], [Cmp_ID], [Increment_Effective_Date], [Branch_ID]);


GO
CREATE STATISTICS [IS_T0095_INCREMENT_Branch_Emp_Cmp]
    ON [dbo].[T0095_INCREMENT]([Branch_ID], [Emp_ID], [Cmp_ID]);


GO
CREATE STATISTICS [IS_T0095_INCREMENT_Increment_Emp_cmp_Effective_Date]
    ON [dbo].[T0095_INCREMENT]([Branch_ID], [Grd_ID], [Increment_ID], [Emp_ID], [Cmp_ID], [Increment_Effective_Date]);


GO
CREATE STATISTICS [IS_T0095_INCREMENT_Emp_Cmp_Increment_Effective]
    ON [dbo].[T0095_INCREMENT]([Grd_ID], [Emp_ID], [Cmp_ID], [Increment_Effective_Date]);


GO
CREATE STATISTICS [IS_T0095_INCREMENT_Emp_Cmp]
    ON [dbo].[T0095_INCREMENT]([Emp_ID], [Cmp_ID]);


GO
CREATE STATISTICS [IS_T0095_INCREMENT_Emp_Grd_ID]
    ON [dbo].[T0095_INCREMENT]([Increment_ID], [Emp_ID], [Cmp_ID], [Increment_Effective_Date], [Grd_ID]);


GO
CREATE STATISTICS [IS_T0095_INCREMENT_Emp_cmp_Effective_Grd_ID]
    ON [dbo].[T0095_INCREMENT]([Increment_Effective_Date], [Emp_ID], [Cmp_ID], [Branch_ID], [Grd_ID]);


GO
CREATE STATISTICS [_dta_stat_997578592_4_1_2_3]
    ON [dbo].[T0095_INCREMENT]([Branch_ID], [Increment_ID], [Emp_ID], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_997578592_4_18_2_31]
    ON [dbo].[T0095_INCREMENT]([Branch_ID], [Increment_Effective_Date], [Emp_ID], [Emp_PT]);


GO
CREATE STATISTICS [_dta_stat_997578592_3_2_18_31_4]
    ON [dbo].[T0095_INCREMENT]([Cmp_ID], [Emp_ID], [Increment_Effective_Date], [Emp_PT], [Branch_ID]);


GO
CREATE STATISTICS [_dta_stat_997578592_3_1]
    ON [dbo].[T0095_INCREMENT]([Cmp_ID], [Increment_ID]);


GO
CREATE STATISTICS [_dta_stat_1427536169_1_18_4]
    ON [dbo].[T0095_INCREMENT]([Increment_ID], [Increment_Effective_Date], [Branch_ID]);


GO
CREATE STATISTICS [_dta_stat_1427536169_1_3_18_4]
    ON [dbo].[T0095_INCREMENT]([Increment_ID], [Cmp_ID], [Increment_Effective_Date], [Branch_ID]);


GO
CREATE STATISTICS [_dta_stat_1427536169_1_18_4_2]
    ON [dbo].[T0095_INCREMENT]([Increment_ID], [Increment_Effective_Date], [Branch_ID], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_1427536169_4_66_67_7_1]
    ON [dbo].[T0095_INCREMENT]([Branch_ID], [Vertical_ID], [SubVertical_ID], [Dept_ID], [Increment_ID]);


GO
CREATE STATISTICS [_dta_stat_1427536169_7_1_4_8_66_67]
    ON [dbo].[T0095_INCREMENT]([Dept_ID], [Increment_ID], [Branch_ID], [Desig_Id], [Vertical_ID], [SubVertical_ID]);


GO
CREATE STATISTICS [_dta_stat_1427536169_18_2_1_16]
    ON [dbo].[T0095_INCREMENT]([Increment_Effective_Date], [Emp_ID], [Increment_ID], [Increment_Type]);


GO
CREATE STATISTICS [_dta_stat_1427536169_16_1_2]
    ON [dbo].[T0095_INCREMENT]([Increment_Type], [Increment_ID], [Emp_ID]);

