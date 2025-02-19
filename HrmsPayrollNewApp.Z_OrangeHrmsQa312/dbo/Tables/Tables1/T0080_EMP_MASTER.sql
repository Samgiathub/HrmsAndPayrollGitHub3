CREATE TABLE [dbo].[T0080_EMP_MASTER] (
    [Emp_ID]                         NUMERIC (18)    NOT NULL,
    [Cmp_ID]                         NUMERIC (18)    NOT NULL,
    [Branch_ID]                      NUMERIC (18)    NOT NULL,
    [Cat_ID]                         NUMERIC (18)    NULL,
    [Grd_ID]                         NUMERIC (18)    NOT NULL,
    [Dept_ID]                        NUMERIC (18)    NULL,
    [Desig_Id]                       NUMERIC (18)    NULL,
    [Type_ID]                        NUMERIC (18)    NULL,
    [Shift_ID]                       NUMERIC (18)    NOT NULL,
    [Bank_ID]                        NUMERIC (18)    NULL,
    [Emp_code]                       NUMERIC (18)    NOT NULL,
    [Initial]                        VARCHAR (50)    NULL,
    [Emp_First_Name]                 VARCHAR (100)   NOT NULL,
    [Emp_Second_Name]                VARCHAR (100)   NOT NULL,
    [Emp_Last_Name]                  VARCHAR (100)   NOT NULL,
    [Curr_ID]                        NUMERIC (18)    NULL,
    [Date_Of_Join]                   DATETIME        NOT NULL,
    [SSN_No]                         VARCHAR (30)    NULL,
    [SIN_No]                         VARCHAR (30)    NULL,
    [Dr_Lic_No]                      VARCHAR (30)    NULL,
    [Pan_No]                         VARCHAR (30)    NULL,
    [Date_Of_Birth]                  DATETIME        NULL,
    [Marital_Status]                 VARCHAR (20)    NULL,
    [Gender]                         CHAR (1)        NULL,
    [Dr_Lic_Ex_Date]                 DATETIME        NULL,
    [Nationality]                    VARCHAR (20)    NULL,
    [Loc_ID]                         NUMERIC (18)    NULL,
    [Street_1]                       VARCHAR (250)   NULL,
    [City]                           VARCHAR (30)    NULL,
    [State]                          VARCHAR (100)   NULL,
    [Zip_code]                       VARCHAR (20)    NULL,
    [Home_Tel_no]                    VARCHAR (30)    NULL,
    [Mobile_No]                      VARCHAR (30)    NULL,
    [Work_Tel_No]                    VARCHAR (30)    NULL,
    [Work_Email]                     VARCHAR (50)    NULL,
    [Other_Email]                    VARCHAR (50)    NULL,
    [Basic_Salary]                   NUMERIC (18, 4) NULL,
    [Image_Name]                     VARCHAR (200)   NULL,
    [Emp_Full_Name]                  VARCHAR (250)   NULL,
    [Emp_Left]                       CHAR (1)        CONSTRAINT [DF_T0080_EMP_MASTER_Left_Emp] DEFAULT ('N') NULL,
    [Emp_Left_Date]                  DATETIME        NULL,
    [Increment_ID]                   NUMERIC (18)    NULL,
    [Present_Street]                 VARCHAR (250)   NULL,
    [Present_City]                   VARCHAR (30)    NULL,
    [Present_State]                  VARCHAR (100)   NULL,
    [Present_Post_Box]               VARCHAR (20)    NULL,
    [Emp_Superior]                   NUMERIC (18)    NULL,
    [Enroll_No]                      NUMERIC (18)    CONSTRAINT [DF_T0080_EMP_MASTER_Enroll_No] DEFAULT ((0)) NULL,
    [Blood_Group]                    VARCHAR (10)    NULL,
    [Tally_Led_Name]                 VARCHAR (100)   NULL,
    [Religion]                       VARCHAR (50)    NULL,
    [Height]                         VARCHAR (50)    NULL,
    [Emp_Mark_Of_Identification]     VARCHAR (250)   NULL,
    [Despencery]                     VARCHAR (250)   NULL,
    [Doctor_Name]                    VARCHAR (100)   NULL,
    [DespenceryAddress]              VARCHAR (250)   NULL,
    [Insurance_No]                   VARCHAR (50)    NULL,
    [Is_Gr_App]                      TINYINT         NULL,
    [Is_Yearly_Bonus]                TINYINT         NULL,
    [Yearly_Leave_Days]              NUMERIC (5, 2)  CONSTRAINT [DF_T0080_EMP_MASTER_Yearly_Leave_Days] DEFAULT ((0)) NULL,
    [Yearly_Leave_Amount]            NUMERIC (7)     CONSTRAINT [DF_T0080_EMP_MASTER_Yearly_Leave_Amount] DEFAULT ((0)) NULL,
    [Yearly_Bonus_Per]               NUMERIC (5, 2)  CONSTRAINT [DF_T0080_EMP_MASTER_Yearly_Bonus_Per] DEFAULT ((0)) NULL,
    [Yearly_Bonus_Amount]            NUMERIC (7)     CONSTRAINT [DF_T0080_EMP_MASTER_Yearly_Bonus_Amount] DEFAULT ((0)) NULL,
    [Emp_Confirm_Date]               DATETIME        NULL,
    [IS_Emp_FNF]                     TINYINT         CONSTRAINT [DF_T0080_EMP_MASTER_IS_Emp_FNF] DEFAULT ((0)) NULL,
    [Is_On_Probation]                TINYINT         CONSTRAINT [DF_T0080_EMP_MASTER_Is_On_Probation] DEFAULT ((0)) NULL,
    [Tally_Led_ID]                   NUMERIC (18)    NULL,
    [Login_ID]                       NUMERIC (18)    NULL,
    [System_Date]                    DATETIME        NULL,
    [Probation]                      NUMERIC (18, 2) CONSTRAINT [DF_T0080_EMP_MASTER_Probation] DEFAULT ((0)) NULL,
    [Worker_Adult_No]                NUMERIC (18)    NULL,
    [Father_name]                    VARCHAR (100)   NULL,
    [Bank_BSR]                       VARCHAR (100)   NULL,
    [Product_name]                   VARCHAR (50)    NULL,
    [Old_Ref_No]                     VARCHAR (50)    NULL,
    [Chg_Pwd]                        INT             NULL,
    [Alpha_Code]                     VARCHAR (20)    NULL,
    [Alpha_Emp_Code]                 VARCHAR (50)    NULL,
    [Ifsc_Code]                      VARCHAR (50)    NULL,
    [Leave_In_Probation]             TINYINT         NULL,
    [Is_LWF]                         TINYINT         CONSTRAINT [DF_T0080_EMP_MASTER_Is_LWF] DEFAULT ((0)) NOT NULL,
    [DBRD_Code]                      VARCHAR (50)    NULL,
    [Dealer_Code]                    VARCHAR (50)    NULL,
    [CCenter_Remark]                 VARCHAR (500)   NULL,
    [Emp_PF_Opening]                 NUMERIC (18, 2) CONSTRAINT [T0080_EMP_MASTER_PF_Opening] DEFAULT ((0)) NOT NULL,
    [Emp_Category]                   VARCHAR (50)    NULL,
    [Emp_UIDNo]                      VARCHAR (25)    NULL,
    [Emp_Cast]                       VARCHAR (50)    NULL,
    [Emp_Annivarsary_Date]           VARCHAR (50)    NULL,
    [Extra_AB_Deduction]             NUMERIC (18, 2) NULL,
    [CompOff_Min_hrs]                VARCHAR (10)    CONSTRAINT [DF_T0080_EMP_MASTER_CompOff_Min_hrs] DEFAULT ('00:00') NOT NULL,
    [mother_name]                    VARCHAR (100)   NULL,
    [Min_Wages]                      NUMERIC (18, 2) CONSTRAINT [DF_T0080_EMP_MASTER_Min_Wages] DEFAULT ((0)) NOT NULL,
    [Emp_Offer_Date]                 DATETIME        NULL,
    [Segment_ID]                     NUMERIC (18)    NULL,
    [Vertical_ID]                    NUMERIC (18)    NULL,
    [SubVertical_ID]                 NUMERIC (18)    NULL,
    [GroupJoiningDate]               DATETIME        NULL,
    [subBranch_ID]                   NUMERIC (18)    NULL,
    [Bank_ID_Two]                    NUMERIC (18)    NULL,
    [Ifsc_Code_Two]                  VARCHAR (50)    NULL,
    [Code_Date_Format]               VARCHAR (10)    NULL,
    [Code_Date]                      VARCHAR (10)    NULL,
    [EmpName_Alias_PrimaryBank]      VARCHAR (100)   NULL,
    [EmpName_Alias_SecondaryBank]    VARCHAR (100)   NULL,
    [EmpName_Alias_PF]               VARCHAR (100)   NULL,
    [EmpName_Alias_PT]               VARCHAR (100)   NULL,
    [EmpName_Alias_Tax]              VARCHAR (100)   NULL,
    [EmpName_Alias_ESIC]             VARCHAR (100)   NULL,
    [EmpName_Alias_Salary]           VARCHAR (100)   NULL,
    [Emp_Notice_Period]              NUMERIC (18)    CONSTRAINT [DF_T0080_EMP_MASTER_Emp_Notice_Period] DEFAULT ((0)) NOT NULL,
    [System_Date_Join_left]          DATETIME        NULL,
    [Emp_Canteen_Code]               VARCHAR (50)    NULL,
    [Emp_Dress_Code]                 VARCHAR (50)    NULL,
    [Emp_Shirt_Size]                 VARCHAR (20)    NULL,
    [Emp_Pent_Size]                  VARCHAR (20)    NULL,
    [Emp_Shoe_Size]                  VARCHAR (20)    NULL,
    [Thana_Id]                       NUMERIC (18)    CONSTRAINT [DF_T0080_EMP_MASTER_Thana_Id] DEFAULT ((0)) NOT NULL,
    [Tehsil]                         VARCHAR (50)    NULL,
    [District]                       VARCHAR (50)    NULL,
    [Thana_Id_Wok]                   NUMERIC (18)    CONSTRAINT [DF_T0080_EMP_MASTER_Thana_Id_Wok] DEFAULT ((0)) NOT NULL,
    [Tehsil_Wok]                     VARCHAR (50)    NULL,
    [District_Wok]                   VARCHAR (50)    NULL,
    [SkillType_ID]                   INT             CONSTRAINT [DF_T0080_EMP_MASTER_SkillType_ID] DEFAULT ((0)) NULL,
    [About_Me]                       NVARCHAR (MAX)  NULL,
    [UAN_No]                         VARCHAR (100)   NULL,
    [CompOff_WO_App_Days]            NUMERIC (18, 2) CONSTRAINT [DF_T0080_EMP_MASTER_CompOff_WO_App_Days] DEFAULT ((0)) NOT NULL,
    [CompOff_WO_Avail_Days]          NUMERIC (18, 2) CONSTRAINT [DF_T0080_EMP_MASTER_CompOff_WO_Avail_Days] DEFAULT ((0)) NOT NULL,
    [CompOff_WD_App_Days]            NUMERIC (18, 2) CONSTRAINT [DF_T0080_EMP_MASTER_CompOff_WD_App_Days] DEFAULT ((0)) NOT NULL,
    [CompOff_WD_Avail_Days]          NUMERIC (18, 2) CONSTRAINT [DF_T0080_EMP_MASTER_CompOff_WD_Avail_Days] DEFAULT ((0)) NOT NULL,
    [CompOff_HO_App_Days]            NUMERIC (18, 2) CONSTRAINT [DF_T0080_EMP_MASTER_CompOff_HO_Appl_Days] DEFAULT ((0)) NOT NULL,
    [CompOff_HO_Avail_Days]          NUMERIC (18, 2) CONSTRAINT [DF_T0080_EMP_MASTER_CompOff_HO_Avail_Days] DEFAULT ((0)) NOT NULL,
    [Date_of_Retirement]             DATETIME        NULL,
    [Salary_Depends_on_Production]   NUMERIC (1)     CONSTRAINT [DF_T0080_EMP_MASTER_Salary_Depends_on_Production] DEFAULT ((0)) NOT NULL,
    [Ration_Card_Type]               VARCHAR (10)    NULL,
    [Ration_Card_No]                 VARCHAR (50)    NULL,
    [Vehicle_NO]                     VARCHAR (50)    NULL,
    [Is_On_Training]                 NUMERIC (2)     DEFAULT ((0)) NOT NULL,
    [Training_Month]                 NUMERIC (18, 2) DEFAULT ((0)) NULL,
    [Aadhar_Card_No]                 VARCHAR (50)    NULL,
    [is_for_mobile_Access]           TINYINT         CONSTRAINT [DF_T0080_EMP_MASTER_is_for_mobile_inout] DEFAULT ((0)) NOT NULL,
    [Actual_Date_Of_Birth]           DATETIME        NULL,
    [is_PF_Trust]                    TINYINT         CONSTRAINT [DF_T0080_EMP_MASTER_is_pf_trust] DEFAULT ((0)) NOT NULL,
    [PF_Trust_No]                    VARCHAR (500)   NULL,
    [Extension_No]                   VARCHAR (10)    NULL,
    [Manager_Probation]              NUMERIC (18)    CONSTRAINT [DF_T0080_EMP_MASTER_Manager_Probation] DEFAULT ((0)) NOT NULL,
    [PF_Start_Date]                  DATETIME        NULL,
    [LinkedIn_ID]                    VARCHAR (100)   NULL,
    [Twitter_ID]                     VARCHAR (100)   NULL,
    [Is_On_Traning]                  NUMERIC (2)     DEFAULT ((0)) NOT NULL,
    [Traning]                        NUMERIC (2)     DEFAULT ((0)) NOT NULL,
    [Signature_Image_Name]           VARCHAR (200)   NULL,
    [Leave_Encash_Working_Days]      NUMERIC (18, 2) DEFAULT ((0)) NOT NULL,
    [Rejoin_Emp_Id]                  NUMERIC (18)    CONSTRAINT [DF_T0080_EMP_MASTER_Rejoin_Emp_Id] DEFAULT ((0)) NOT NULL,
    [Is_Camera_enable]               TINYINT         DEFAULT ((0)) NOT NULL,
    [Is_Geofence_enable]             TINYINT         DEFAULT ((0)) NOT NULL,
    [Is_Probation_Month_Days]        TINYINT         DEFAULT ((0)) NOT NULL,
    [Is_Trainee_Month_Days]          TINYINT         DEFAULT ((0)) NOT NULL,
    [Induction_Training]             VARCHAR (200)   NULL,
    [HolidayCompOffAvail_After_Days] NUMERIC (18)    DEFAULT ((0)) NULL,
    [WeekOffCompOffAvail_After_Days] NUMERIC (18)    DEFAULT ((0)) NULL,
    [WeekdayCompOffAvail_After_Days] NUMERIC (18)    DEFAULT ((0)) NULL,
    [Is_MobileWorkplan_Enable]       TINYINT         DEFAULT ((0)) NOT NULL,
    [Is_MobileStock_Enable]          TINYINT         DEFAULT ((0)) NOT NULL,
    [Is_VBA]                         TINYINT         DEFAULT ((0)) NOT NULL,
    [Is_Piece_Trans_Salary]          TINYINT         NULL,
    [Band_id]                        NUMERIC (18)    NULL,
    [Is_Pradhan_Mantri]              BIT             NULL,
    [Is_1time_PF_Member]             BIT             NULL,
    [Emp_Cast_Join]                  VARCHAR (50)    NULL,
    [Emp_Fav_Sport_id]               NVARCHAR (500)  NULL,
    [Emp_Fav_Sport_Name]             NVARCHAR (1000) NULL,
    [Emp_Hobby_id]                   NVARCHAR (500)  NULL,
    [Emp_Hobby_Name]                 NVARCHAR (1000) NULL,
    [Emp_Fav_Food]                   NVARCHAR (100)  NULL,
    [Emp_Fav_Restro]                 NVARCHAR (100)  NULL,
    [Emp_Fav_Trv_Destination]        NVARCHAR (100)  NULL,
    [Emp_Fav_Festival]               NVARCHAR (100)  NULL,
    [Emp_Fav_SportPerson]            NVARCHAR (100)  NULL,
    [Emp_Fav_Singer]                 NVARCHAR (100)  NULL,
    [Is_GuestPrivilege]              TINYINT         CONSTRAINT [DF_T0080_EMP_MASTER_Is_GuestPrivilege] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0080_EMP_MASTER] PRIMARY KEY CLUSTERED ([Emp_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0080_EMP_MASTER_T0001_LOCATION_MASTER] FOREIGN KEY ([Loc_ID]) REFERENCES [dbo].[T0001_LOCATION_MASTER] ([Loc_ID]),
    CONSTRAINT [FK_T0080_EMP_MASTER_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0080_EMP_MASTER_T0011_LOGIN] FOREIGN KEY ([Login_ID]) REFERENCES [dbo].[T0011_LOGIN] ([Login_ID]),
    CONSTRAINT [FK_T0080_EMP_MASTER_T0030_BRANCH_MASTER] FOREIGN KEY ([Branch_ID]) REFERENCES [dbo].[T0030_BRANCH_MASTER] ([Branch_ID]),
    CONSTRAINT [FK_T0080_EMP_MASTER_T0030_CATEGORY_MASTER] FOREIGN KEY ([Cat_ID]) REFERENCES [dbo].[T0030_CATEGORY_MASTER] ([Cat_ID]),
    CONSTRAINT [FK_T0080_EMP_MASTER_T0040_BANK_MASTER] FOREIGN KEY ([Bank_ID]) REFERENCES [dbo].[T0040_BANK_MASTER] ([Bank_ID]),
    CONSTRAINT [FK_T0080_EMP_MASTER_T0040_DEPARTMENT_MASTER] FOREIGN KEY ([Dept_ID]) REFERENCES [dbo].[T0040_DEPARTMENT_MASTER] ([Dept_Id]),
    CONSTRAINT [FK_T0080_EMP_MASTER_T0040_DESIGNATION_MASTER] FOREIGN KEY ([Desig_Id]) REFERENCES [dbo].[T0040_DESIGNATION_MASTER] ([Desig_ID]),
    CONSTRAINT [FK_T0080_EMP_MASTER_T0040_GRADE_MASTER] FOREIGN KEY ([Grd_ID]) REFERENCES [dbo].[T0040_GRADE_MASTER] ([Grd_ID]),
    CONSTRAINT [FK_T0080_EMP_MASTER_T0040_SHIFT_MASTER] FOREIGN KEY ([Shift_ID]) REFERENCES [dbo].[T0040_SHIFT_MASTER] ([Shift_ID]),
    CONSTRAINT [FK_T0080_EMP_MASTER_T0040_Tally_Led_Master] FOREIGN KEY ([Tally_Led_ID]) REFERENCES [dbo].[T0040_Tally_Led_Master] ([Tally_Led_ID]),
    CONSTRAINT [FK_T0080_EMP_MASTER_T0040_Type_Master] FOREIGN KEY ([Type_ID]) REFERENCES [dbo].[T0040_TYPE_MASTER] ([Type_ID]),
    CONSTRAINT [FK_T0080_EMP_MASTER_T0095_INCREMENT] FOREIGN KEY ([Increment_ID]) REFERENCES [dbo].[T0095_INCREMENT] ([Increment_ID])
);


GO
CREATE NONCLUSTERED INDEX [NCIX_T0080_EMP_MASTER]
    ON [dbo].[T0080_EMP_MASTER]([Emp_ID] ASC, [Cmp_ID] ASC, [Date_Of_Join] ASC, [Emp_Left] ASC, [Emp_Left_Date] ASC);


GO
CREATE NONCLUSTERED INDEX [Cmp_ID_Includes]
    ON [dbo].[T0080_EMP_MASTER]([Cmp_ID] ASC)
    INCLUDE([Emp_Full_Name], [Emp_Left], [Emp_Left_Date], [Alpha_Emp_Code]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_T0080_EMP_MASTER_C_E_I_E]
    ON [dbo].[T0080_EMP_MASTER]([Cmp_ID] ASC, [Emp_ID] ASC, [Increment_ID] ASC, [Emp_code] ASC);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0080_EMP_MASTER_24_437576597__K1_2_13_14_15_17_21_78_110]
    ON [dbo].[T0080_EMP_MASTER]([Emp_ID] ASC)
    INCLUDE([Cmp_ID], [Emp_First_Name], [Emp_Second_Name], [Emp_Last_Name], [Date_Of_Join], [Pan_No], [Alpha_Emp_Code], [EmpName_Alias_Salary]);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0080_EMP_MASTER_12_437576597__K1_K42_K17_K2]
    ON [dbo].[T0080_EMP_MASTER]([Emp_ID] ASC, [Increment_ID] ASC, [Date_Of_Join] ASC, [Cmp_ID] ASC);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0080_EMP_MASTER_24_437576597__K2_K1_K41_K11_21_39_78_96_97]
    ON [dbo].[T0080_EMP_MASTER]([Cmp_ID] ASC, [Emp_ID] ASC, [Emp_Left_Date] ASC, [Emp_code] ASC)
    INCLUDE([Pan_No], [Emp_Full_Name], [Alpha_Emp_Code], [Vertical_ID], [SubVertical_ID]);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0080_EMP_MASTER_24_437576597__K1_39_78]
    ON [dbo].[T0080_EMP_MASTER]([Emp_ID] ASC)
    INCLUDE([Emp_Full_Name], [Alpha_Emp_Code]);


GO
CREATE NONCLUSTERED INDEX [Cmp_ID_Emp_Left_Includes]
    ON [dbo].[T0080_EMP_MASTER]([Cmp_ID] ASC, [Emp_Left] ASC)
    INCLUDE([Branch_ID], [Desig_Id], [Emp_Full_Name], [Alpha_Emp_Code]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_T0080_EMP_MASTER_SP_IT_TAX_PREPARATION]
    ON [dbo].[T0080_EMP_MASTER]([Emp_Left_Date] ASC)
    INCLUDE([Cmp_ID]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [IX_T0080_EMP_MASTER_P_EMP_UAN_PAN_VALIDATION4]
    ON [dbo].[T0080_EMP_MASTER]([Cmp_ID] ASC, [Aadhar_Card_No] ASC, [Emp_ID] ASC)
    INCLUDE([Emp_Left]);


GO
CREATE STATISTICS [_dta_stat_437576597_80_1_17_2]
    ON [dbo].[T0080_EMP_MASTER]([Leave_In_Probation], [Emp_ID], [Date_Of_Join], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_1641824961_41_2]
    ON [dbo].[T0080_EMP_MASTER]([Emp_Left_Date], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_1641824961_1_2_41]
    ON [dbo].[T0080_EMP_MASTER]([Emp_ID], [Cmp_ID], [Emp_Left_Date]);


GO
CREATE STATISTICS [_dta_stat_1641824961_40_1]
    ON [dbo].[T0080_EMP_MASTER]([Emp_Left], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_1641824961_41_1]
    ON [dbo].[T0080_EMP_MASTER]([Emp_Left_Date], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_1641824961_42_1_66]
    ON [dbo].[T0080_EMP_MASTER]([Increment_ID], [Emp_ID], [Is_On_Probation]);


GO
CREATE STATISTICS [_dta_stat_1641824961_42_2]
    ON [dbo].[T0080_EMP_MASTER]([Increment_ID], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_1641824961_2_41_3]
    ON [dbo].[T0080_EMP_MASTER]([Cmp_ID], [Emp_Left_Date], [Branch_ID]);


GO
CREATE STATISTICS [_dta_stat_1641824961_39_42]
    ON [dbo].[T0080_EMP_MASTER]([Emp_Full_Name], [Increment_ID]);


GO
CREATE STATISTICS [_dta_stat_1641824961_40_1_42_2]
    ON [dbo].[T0080_EMP_MASTER]([Emp_Left], [Emp_ID], [Increment_ID], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_1641824961_66_40_42]
    ON [dbo].[T0080_EMP_MASTER]([Is_On_Probation], [Emp_Left], [Increment_ID]);


GO
CREATE STATISTICS [_dta_stat_1641824961_78_39_3]
    ON [dbo].[T0080_EMP_MASTER]([Alpha_Emp_Code], [Emp_Full_Name], [Branch_ID]);


GO
CREATE STATISTICS [_dta_stat_1641824961_80_2_1_40]
    ON [dbo].[T0080_EMP_MASTER]([Leave_In_Probation], [Cmp_ID], [Emp_ID], [Emp_Left]);


GO
CREATE STATISTICS [_dta_stat_1641824961_42_40]
    ON [dbo].[T0080_EMP_MASTER]([Increment_ID], [Emp_Left]);


GO
CREATE STATISTICS [_dta_stat_1641824961_42_66_40]
    ON [dbo].[T0080_EMP_MASTER]([Increment_ID], [Is_On_Probation], [Emp_Left]);


GO
CREATE STATISTICS [_dta_stat_1641824961_66_40_1_42]
    ON [dbo].[T0080_EMP_MASTER]([Is_On_Probation], [Emp_Left], [Emp_ID], [Increment_ID]);


GO
CREATE STATISTICS [_dta_stat_1641824961_2_40_42]
    ON [dbo].[T0080_EMP_MASTER]([Cmp_ID], [Emp_Left], [Increment_ID]);


GO
CREATE STATISTICS [_dta_stat_1641824961_1_3_2]
    ON [dbo].[T0080_EMP_MASTER]([Emp_ID], [Branch_ID], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_1641824961_1_47_78_39_3]
    ON [dbo].[T0080_EMP_MASTER]([Emp_ID], [Emp_Superior], [Alpha_Emp_Code], [Emp_Full_Name], [Branch_ID]);


GO
CREATE STATISTICS [_dta_stat_1641824961_1_66_40_42]
    ON [dbo].[T0080_EMP_MASTER]([Emp_ID], [Is_On_Probation], [Emp_Left], [Increment_ID]);


GO
CREATE STATISTICS [_dta_stat_1641824961_2_3]
    ON [dbo].[T0080_EMP_MASTER]([Cmp_ID], [Branch_ID]);


GO
CREATE STATISTICS [_dta_stat_1641824961_1_39_42]
    ON [dbo].[T0080_EMP_MASTER]([Emp_ID], [Emp_Full_Name], [Increment_ID]);


GO
CREATE STATISTICS [_dta_stat_1641824961_1_42_2]
    ON [dbo].[T0080_EMP_MASTER]([Emp_ID], [Increment_ID], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_1641824961_1_47_42_78_39_3]
    ON [dbo].[T0080_EMP_MASTER]([Emp_ID], [Emp_Superior], [Increment_ID], [Alpha_Emp_Code], [Emp_Full_Name], [Branch_ID]);


GO
CREATE STATISTICS [_dta_stat_1641824961_11_1]
    ON [dbo].[T0080_EMP_MASTER]([Emp_code], [Emp_ID]);


GO
CREATE STATISTICS [IS_T0080_EMP_MASTER_E_C_E]
    ON [dbo].[T0080_EMP_MASTER]([Emp_code], [Cmp_ID], [Emp_ID]);


GO
CREATE STATISTICS [IS_T0080_EMP_MASTER_E_I_C_E]
    ON [dbo].[T0080_EMP_MASTER]([Emp_ID], [Increment_ID], [Cmp_ID], [Emp_code]);


GO
CREATE STATISTICS [_dta_stat_437576597_41_1_2_11]
    ON [dbo].[T0080_EMP_MASTER]([Emp_Left_Date], [Emp_ID], [Cmp_ID], [Emp_code]);


GO
CREATE STATISTICS [_dta_stat_437576597_42_40_1]
    ON [dbo].[T0080_EMP_MASTER]([Increment_ID], [Emp_Left], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_437576597_42_1_2_40]
    ON [dbo].[T0080_EMP_MASTER]([Increment_ID], [Emp_ID], [Cmp_ID], [Emp_Left]);


GO
CREATE STATISTICS [_dta_stat_437576597_40_1]
    ON [dbo].[T0080_EMP_MASTER]([Emp_Left], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_1641824961_1_2_78_13_39]
    ON [dbo].[T0080_EMP_MASTER]([Emp_ID], [Cmp_ID], [Alpha_Emp_Code], [Emp_First_Name], [Emp_Full_Name]);


GO
CREATE STATISTICS [_dta_stat_1641824961_2_47]
    ON [dbo].[T0080_EMP_MASTER]([Cmp_ID], [Emp_Superior]);


GO
CREATE STATISTICS [_dta_stat_1641824961_47_42_2]
    ON [dbo].[T0080_EMP_MASTER]([Emp_Superior], [Increment_ID], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_1641824961_39_13_11_78_1]
    ON [dbo].[T0080_EMP_MASTER]([Emp_Full_Name], [Emp_First_Name], [Emp_code], [Alpha_Emp_Code], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_1641824961_1_42_39_13_11_78]
    ON [dbo].[T0080_EMP_MASTER]([Emp_ID], [Increment_ID], [Emp_Full_Name], [Emp_First_Name], [Emp_code], [Alpha_Emp_Code]);


GO


 
CREATE TRIGGER [DBO].[tr_T0080_EMP_MASTER_Insert] 
ON [dbo].[T0080_EMP_MASTER] 
FOR INSERT 
AS 

--DECLARE @Status int
--DECLARE @Emp_ID numeric(18,0)
--DECLARE @Emp_Code varchar(50)
--DECLARE @Initial varchar(50)
--DECLARE @Fname varchar(50)
--DECLARE @Mname varchar(50)
--DECLARE @Lname varchar(50)
--DECLARE @Address varchar(MAX)
--DECLARE @Pincode varchar(50)
--DECLARE @PhoneNo varchar(50)
--DECLARE @MobileNo varchar(50)
--DECLARE @Email varchar(50)
--DECLARE @Country_ID numeric(18,0)
--DECLARE @State_Name varchar(50)
--DECLARE @State_ID numeric(18,0)
--DECLARE @City_Name varchar(50)
--DECLARE @City_ID numeric(18,0)
--DECLARE @DOB datetime
--DECLARE @DOJ datetime
--DECLARE @Gender varchar(50)
--DECLARE @Vertical_ID numeric(18,0)
--DECLARE @Vertical_Name varchar(50)
--DECLARE @SubVertical_ID numeric(18,0)
--DECLARE @SubVertical_Name varchar(50)
--DECLARE @Branch_ID numeric(18,0)
--DECLARE @Branch_Name varchar(50)
--DECLARE @Dept_ID numeric(18,0)
--DECLARE @Dept_Name varchar(50)
--DECLARE @Desig_Id numeric(18,0)
--DECLARE @Desig_Name varchar(50)
--DECLARE @Emp_Left int
--DECLARE @Photo varchar(50)
--DECLARE @Cmp_Id numeric(18,0)
--DECLARE @Login_Alias varchar(50)
--DECLARE @Login_Name varchar(50)
--DECLARE @Login_Password varchar(50)	

INSERT INTO T0080_EMP_MASTER_shadow(Emp_ID,Cmp_ID,Branch_ID,Cat_ID,Grd_ID,Dept_ID,Desig_Id,Type_ID,Shift_ID,Bank_ID,Emp_code,Initial,Emp_First_Name,Emp_Second_Name,Emp_Last_Name,Curr_ID,Date_Of_Join,SSN_No,SIN_No,Dr_Lic_No,Pan_No,Date_Of_Birth,Marital_Status,Gender,Dr_Lic_Ex_Date,Nationality,Loc_ID,Street_1,City,State,Zip_code,Home_Tel_no,Mobile_No,Work_Tel_No,Work_Email,Other_Email,Basic_Salary,Image_Name,Emp_Full_Name,Emp_Left,Emp_Left_Date,Increment_ID,Present_Street,Present_City,Present_State,Present_Post_Box,Emp_Superior,Enroll_No,Blood_Group,Tally_Led_Name,Religion,Height,Emp_Mark_Of_Identification,Despencery,Doctor_Name,DespenceryAddress,Insurance_No,Is_Gr_App,Is_Yearly_Bonus,Yearly_Leave_Days,Yearly_Leave_Amount,Yearly_Bonus_Per,Yearly_Bonus_Amount,Emp_Confirm_Date,IS_Emp_FNF,Is_On_Probation,Tally_Led_ID,Login_ID,System_Date,Probation,Worker_Adult_No,Father_name,Bank_BSR,Product_name,Old_Ref_No,Chg_Pwd,Alpha_Code,Alpha_Emp_Code,AuditAction,login_id1) SELECT Emp_ID,Cmp_ID,Branch_ID,Cat_ID,Grd_ID,Dept_ID,Desig_Id,Type_ID,Shift_ID,Bank_ID,Emp_code,Initial,Emp_First_Name,Emp_Second_Name,Emp_Last_Name,Curr_ID,Date_Of_Join,SSN_No,SIN_No,Dr_Lic_No,Pan_No,Date_Of_Birth,Marital_Status,Gender,Dr_Lic_Ex_Date,Nationality,Loc_ID,Street_1,City,State,Zip_code,Home_Tel_no,Mobile_No,Work_Tel_No,Work_Email,Other_Email,Basic_Salary,Image_Name,Emp_Full_Name,Emp_Left,Emp_Left_Date,Increment_ID,Present_Street,Present_City,Present_State,Present_Post_Box,Emp_Superior,Enroll_No,Blood_Group,Tally_Led_Name,Religion,Height,Emp_Mark_Of_Identification,Despencery,Doctor_Name,DespenceryAddress,Insurance_No,Is_Gr_App,Is_Yearly_Bonus,Yearly_Leave_Days,Yearly_Leave_Amount,Yearly_Bonus_Per,Yearly_Bonus_Amount,Emp_Confirm_Date,IS_Emp_FNF,Is_On_Probation,Tally_Led_ID,Login_ID,System_Date,Probation,Worker_Adult_No,Father_name,Bank_BSR,Product_name,Old_Ref_No,Chg_Pwd,Alpha_Code,Alpha_Emp_Code,'I',0 FROM Inserted


--SELECT @Status = module_status  FROM T0011_module_detail WHERE module_name = 'LMS' --AND Cmp_id
--IF @Status = 1
--	BEGIN
--		SELECT @Emp_ID = ISNULL(MAX(Emp_ID),0) + 1 FROM Orange_LMS.dbo.T0040_Employee_Master
		
--		SELECT  @Emp_Code = Alpha_Emp_Code,@Initial = Initial,@Fname = Emp_First_Name,@Mname = Emp_Second_Name,
--		@Lname = Emp_Last_Name,@Address = Street_1,@Pincode = Zip_code,@PhoneNo = Home_Tel_no,@MobileNo = Mobile_No ,@Email = Work_Email,@Country_ID = Loc_ID,@State_Name = State,@City_Name = City,@DOB = Date_Of_Birth,@DOJ = Date_Of_Join,
--		@Gender = Gender,@Vertical_ID = Vertical_ID,@SubVertical_ID = SubVertical_ID,@Branch_ID = Branch_ID,@Dept_ID = Dept_ID,
--		@Desig_Id = Desig_Id, @Emp_Left = (CASE WHEN Emp_Left = 'N' THEN 0 ELSE 1 END) ,@Photo = Image_Name,@Cmp_Id = Cmp_ID FROM Inserted
		 
--		SELECT @Branch_Name = Branch_Name FROM T0030_BRANCH_MASTER WHERE Branch_ID = @Branch_ID
--		SELECT @Dept_Name = Dept_Name FROM T0040_DEPARTMENT_MASTER WHERE Dept_Id = @Dept_ID
--		SELECT @Desig_Name = Desig_Name FROM T0040_DESIGNATION_MASTER WHERE Desig_ID  = @Desig_Id
--		SELECT @Vertical_Name = Vertical_Name FROM T0040_Vertical_Segment WHERE Vertical_ID  = @Vertical_ID
--		SELECT @SubVertical_Name = SubVertical_Name FROM T0050_SubVertical WHERE SubVertical_ID = @SubVertical_ID
--		SELECT @Login_Alias = Login_Alias,@Login_Name = Login_Name,@Login_Password = Login_Password  FROM T0011_LOGIN WHERE Emp_ID = @Emp_ID
		
--		EXEC Orange_LMS.dbo.SP_EmployeeEntry_FromPayroll @Emp_Code,@Initial,@Fname,@Mname,@Lname,@Address,@Pincode,
--		@PhoneNo,@MobileNo,@Email,@Country_ID,@State_Name,@City_Name,@DOB,@DOJ,@Gender,@Vertical_Name,@SubVertical_Name,
--		@Branch_Name,@Dept_Name,@Desig_Name,@Emp_Left,@Photo,@Cmp_Id,@Login_Alias,@Login_Name,@Login_Password,'I'
	
--	END



GO


 
CREATE TRIGGER [DBO].[tr_T0080_EMP_MASTER_Update] 
ON [dbo].[T0080_EMP_MASTER] 
FOR UPDATE 
AS 

--DECLARE @Status int
--DECLARE @Emp_ID numeric(18,0)
--DECLARE @Emp_Code varchar(50)
--DECLARE @Initial varchar(50)
--DECLARE @Fname varchar(50)
--DECLARE @Mname varchar(50)
--DECLARE @Lname varchar(50)
--DECLARE @Address varchar(MAX)
--DECLARE @Pincode varchar(50)
--DECLARE @PhoneNo varchar(50)
--DECLARE @MobileNo varchar(50)
--DECLARE @Email varchar(50)
--DECLARE @Country_ID numeric(18,0)
--DECLARE @State_Name varchar(50)
--DECLARE @State_ID numeric(18,0)
--DECLARE @City_Name varchar(50)
--DECLARE @City_ID numeric(18,0)
--DECLARE @DOB datetime
--DECLARE @DOJ datetime
--DECLARE @Gender varchar(50)
--DECLARE @Vertical_ID numeric(18,0)
--DECLARE @Vertical_Name varchar(50)
--DECLARE @SubVertical_ID numeric(18,0)
--DECLARE @SubVertical_Name varchar(50)
--DECLARE @Branch_ID numeric(18,0)
--DECLARE @Branch_Name varchar(50)
--DECLARE @Dept_ID numeric(18,0)
--DECLARE @Dept_Name varchar(50)
--DECLARE @Desig_Id numeric(18,0)
--DECLARE @Desig_Name varchar(50)
--DECLARE @Emp_Left int
--DECLARE @Photo varchar(50)
--DECLARE @Cmp_Id numeric(18,0)
--DECLARE @Login_Alias varchar(50)
--DECLARE @Login_Name varchar(50)
--DECLARE @Login_Password varchar(50)

INSERT INTO T0080_EMP_MASTER_shadow(Emp_ID,Cmp_ID,Branch_ID,Cat_ID,Grd_ID,Dept_ID,Desig_Id,Type_ID,Shift_ID,Bank_ID,Emp_code,Initial,Emp_First_Name,Emp_Second_Name,Emp_Last_Name,Curr_ID,Date_Of_Join,SSN_No,SIN_No,Dr_Lic_No,Pan_No,Date_Of_Birth,Marital_Status,Gender,Dr_Lic_Ex_Date,Nationality,Loc_ID,Street_1,City,State,Zip_code,Home_Tel_no,Mobile_No,Work_Tel_No,Work_Email,Other_Email,Basic_Salary,Image_Name,Emp_Full_Name,Emp_Left,Emp_Left_Date,Increment_ID,Present_Street,Present_City,Present_State,Present_Post_Box,Emp_Superior,Enroll_No,Blood_Group,Tally_Led_Name,Religion,Height,Emp_Mark_Of_Identification,Despencery,Doctor_Name,DespenceryAddress,Insurance_No,Is_Gr_App,Is_Yearly_Bonus,Yearly_Leave_Days,Yearly_Leave_Amount,Yearly_Bonus_Per,Yearly_Bonus_Amount,Emp_Confirm_Date,IS_Emp_FNF,Is_On_Probation,Tally_Led_ID,Login_ID,System_Date,Probation,Worker_Adult_No,Father_name,Bank_BSR,Product_name,Old_Ref_No,Chg_Pwd,Alpha_Code,Alpha_Emp_Code,AuditAction,login_id1) SELECT Emp_ID,Cmp_ID,Branch_ID,Cat_ID,Grd_ID,Dept_ID,Desig_Id,Type_ID,Shift_ID,Bank_ID,Emp_code,Initial,Emp_First_Name,Emp_Second_Name,Emp_Last_Name,Curr_ID,Date_Of_Join,SSN_No,SIN_No,Dr_Lic_No,Pan_No,Date_Of_Birth,Marital_Status,Gender,Dr_Lic_Ex_Date,Nationality,Loc_ID,Street_1,City,State,Zip_code,Home_Tel_no,Mobile_No,Work_Tel_No,Work_Email,Other_Email,Basic_Salary,Image_Name,Emp_Full_Name,Emp_Left,Emp_Left_Date,Increment_ID,Present_Street,Present_City,Present_State,Present_Post_Box,Emp_Superior,Enroll_No,Blood_Group,Tally_Led_Name,Religion,Height,Emp_Mark_Of_Identification,Despencery,Doctor_Name,DespenceryAddress,Insurance_No,Is_Gr_App,Is_Yearly_Bonus,Yearly_Leave_Days,Yearly_Leave_Amount,Yearly_Bonus_Per,Yearly_Bonus_Amount,Emp_Confirm_Date,IS_Emp_FNF,Is_On_Probation,Tally_Led_ID,Login_ID,System_Date,Probation,Worker_Adult_No,Father_name,Bank_BSR,Product_name,Old_Ref_No,Chg_Pwd,Alpha_Code,Alpha_Emp_Code,'U',0 FROM inserted

--SELECT @Status = module_status  FROM T0011_module_detail WHERE module_name = 'LMS' --AND Cmp_id
--IF @Status = 1
--	BEGIN
		
--		SELECT  @Emp_Code = Alpha_Emp_Code,@Initial = Initial,@Fname = Emp_First_Name,@Mname = Emp_Second_Name,
--		@Lname = Emp_Last_Name,@Address = Street_1,@Pincode = Zip_code,@PhoneNo = Home_Tel_no,@MobileNo = Mobile_No ,@Email = Work_Email,@Country_ID = Loc_ID,@State_Name = State,@City_Name = City,@DOB = Date_Of_Birth,@DOJ = Date_Of_Join,
--		@Gender = Gender,@Vertical_ID = Vertical_ID,@SubVertical_ID = SubVertical_ID,@Branch_ID = Branch_ID,@Dept_ID = Dept_ID,
--		@Desig_Id = Desig_Id, @Emp_Left = (CASE WHEN Emp_Left = 'N' THEN 0 ELSE 1 END) ,@Photo = Image_Name,@Cmp_Id = Cmp_ID FROM Inserted
		
--		SELECT @Branch_Name = Branch_Name FROM T0030_BRANCH_MASTER WHERE Branch_ID = @Branch_ID
--		SELECT @Dept_Name = Dept_Name FROM T0040_DEPARTMENT_MASTER WHERE Dept_Id = @Dept_ID
--		SELECT @Desig_Name = Desig_Name FROM T0040_DESIGNATION_MASTER WHERE Desig_ID  = @Desig_Id
--		SELECT @Vertical_Name = Vertical_Name FROM T0040_Vertical_Segment WHERE Vertical_ID  = @Vertical_ID
--		SELECT @SubVertical_Name = SubVertical_Name FROM T0050_SubVertical WHERE SubVertical_ID = @SubVertical_ID
--		SELECT @Login_Alias = Login_Alias,@Login_Name = Login_Name,@Login_Password = Login_Password  
--		FROM T0011_LOGIN TL INNER JOIN T0080_EMP_MASTER EM ON TL.Emp_ID = EM.Emp_ID 
--		WHERE EM.Emp_code  = @Emp_Code
		
		
--		EXEC Orange_LMS.dbo.SP_EmployeeEntry_FromPayroll @Emp_Code,@Initial,@Fname,@Mname,@Lname,@Address,@Pincode,
--		@PhoneNo,@MobileNo,@Email,@Country_ID,@State_Name,@City_Name,@DOB,@DOJ,@Gender,@Vertical_Name,@SubVertical_Name,
--		@Branch_Name,@Dept_Name,@Desig_Name,@Emp_Left,@Photo,@Cmp_Id,@Login_Alias,@Login_Name,@Login_Password,'U'
--	END



GO


CREATE TRIGGER [DBO].[tr_T0080_EMP_MASTER_Insert_Import] 
ON [dbo].[T0080_EMP_MASTER] 
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;

	--if OBJECT_ID('tempdb..#DynamicValidation') is null 
	--	Begin
	--		return
	--	End

	If OBJECT_ID('#TempDB..#MandatoryFields') Is not null
		Begin
			Drop Table #MandatoryFields
		End

	Create Table #MandatoryFields
	(
		Fields_Name Varchar(200), 
		Column_Name Varchar(100),
		Is_Mandatory  tinyint 
	)
	

	--Insert into #MandatoryFields Values('Department Name','Dept_ID',1)
	--Insert into #MandatoryFields Values('Category Name','Cat_ID1',1)

	Declare @W_Str As NVarchar(1024) = ''
	Declare @Column_Name Varchar(100)= ''
	Declare @Emp_Code Varchar(100) = ''
	Declare @Validation_Value Varchar(100) = ''
	Declare @Fields_Name Varchar(100)= ''

	Declare Cur_Mandatory Cursor for
	Select Column_Name,Fields_Name From #MandatoryFields Where Is_Mandatory = 1
	Open Cur_Mandatory
	fetch next from Cur_Mandatory into @Column_Name,@Fields_Name
	while @@FETCH_STATUS >= 0
		Begin
			select * into #inserted from inserted

			SET @W_Str = 'SELECT @Emp_Code = Emp_Code,@Validation_Value = ' + @Column_Name + ' FROM #inserted'
			
			EXEC SP_EXECUTESQL @W_Str,
				N'@Validation_Value Varchar(100) OUTPUT,@Emp_Code Varchar(100) OUTPUT',				
				@Validation_Value = @Validation_Value OUTPUT,
				@Emp_Code = @Emp_Code OUTPUT

			    IF ISNULL(@Validation_Value,0) = 0 
					Begin
						Declare @msg as Varchar(200)
						Set @msg ='Please Enter valid ' + @Fields_Name + ' Detail.';
						RAISERROR(@msg,16,2)
						--Insert into #DynamicValidation Values(@Emp_Code,'Please Enter valid ' + @Fields_Name + ' Detail.')
						--return
					End
			fetch next from Cur_Mandatory into @Column_Name,@Fields_Name
		END
	Close Cur_Mandatory
	Deallocate Cur_Mandatory
	
	Insert into T0080_EMP_MASTER
	Select * From inserted
	
END
