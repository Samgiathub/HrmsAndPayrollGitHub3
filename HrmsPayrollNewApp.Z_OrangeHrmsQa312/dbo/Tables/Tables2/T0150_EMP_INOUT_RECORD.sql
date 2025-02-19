CREATE TABLE [dbo].[T0150_EMP_INOUT_RECORD] (
    [IO_Tran_Id]          NUMERIC (18)  NOT NULL,
    [Emp_ID]              NUMERIC (18)  NOT NULL,
    [Cmp_ID]              NUMERIC (18)  NOT NULL,
    [For_Date]            DATETIME      NOT NULL,
    [In_Time]             DATETIME      NULL,
    [Out_Time]            DATETIME      NULL,
    [Duration]            VARCHAR (10)  NULL,
    [Reason]              VARCHAR (100) NULL,
    [Ip_Address]          VARCHAR (50)  NOT NULL,
    [In_Date_Time]        DATETIME      NULL,
    [Out_Date_Time]       DATETIME      NULL,
    [Skip_Count]          NUMERIC (18)  NULL,
    [Late_Calc_Not_App]   NUMERIC (1)   CONSTRAINT [DF_T0150_EMP_INOUT_RECORD_Late_Calc_Not_App] DEFAULT ((0)) NULL,
    [Chk_By_Superior]     TINYINT       CONSTRAINT [DF_T0150_EMP_INOUT_RECORD_Chk_By_Superior] DEFAULT ((0)) NULL,
    [Sup_Comment]         VARCHAR (100) NULL,
    [Half_Full_day]       VARCHAR (20)  NULL,
    [Is_Cancel_Late_In]   TINYINT       CONSTRAINT [DF_T0150_EMP_INOUT_RECORD_Is_Cancel_Late_In] DEFAULT ((0)) NULL,
    [Is_Cancel_Early_Out] TINYINT       CONSTRAINT [DF_T0150_EMP_INOUT_RECORD_Is_Cancel_Early_Out] DEFAULT ((0)) NULL,
    [Is_Default_In]       TINYINT       CONSTRAINT [DF_T0150_EMP_INOUT_RECORD_Is_Default_In] DEFAULT ((0)) NULL,
    [Is_Default_Out]      TINYINT       CONSTRAINT [DF_T0150_EMP_INOUT_RECORD_Is_Default_Out] DEFAULT ((0)) NULL,
    [Cmp_prp_in_flag]     NUMERIC (5)   CONSTRAINT [DF_T0150_EMP_INOUT_RECORD_Cmp_prp_in_flag] DEFAULT ((0)) NOT NULL,
    [Cmp_prp_out_flag]    NUMERIC (5)   CONSTRAINT [DF_T0150_EMP_INOUT_RECORD_Cmp_prp_out_flag] DEFAULT ((0)) NOT NULL,
    [is_Cmp_purpose]      TINYINT       CONSTRAINT [DF_T0150_EMP_INOUT_RECORD_is_Cmp_purpose] DEFAULT ((0)) NOT NULL,
    [App_Date]            DATETIME      NULL,
    [Apr_Date]            DATETIME      NULL,
    [System_date]         DATETIME      NULL,
    [Other_Reason]        VARCHAR (MAX) NULL,
    [ManualEntryFlag]     CHAR (3)      DEFAULT ('N') NULL,
    [StatusFlag]          CHAR (1)      DEFAULT (NULL) NULL,
    [In_Admin_Time]       CHAR (1)      NULL,
    [Out_Admin_Time]      CHAR (1)      NULL,
    CONSTRAINT [PK_T0150_EMP_INOUT_RECORD] PRIMARY KEY CLUSTERED ([IO_Tran_Id] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0150_EMP_INOUT_RECORD_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0150_EMP_INOUT_RECORD_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);


GO
CREATE UNIQUE NONCLUSTERED INDEX [NC_IX_T0150_EMP_INOUT_RECORD]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Cmp_ID] ASC, [Emp_ID] ASC, [For_Date] DESC, [In_Time] ASC, [Out_Time] ASC)
    INCLUDE([Duration], [Reason], [Chk_By_Superior], [Sup_Comment], [Half_Full_day], [Is_Cancel_Late_In], [Is_Cancel_Early_Out], [App_Date], [Apr_Date]) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [NC_IX_T0150_EMP_INOUT_RECORD_ALL]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Cmp_ID] ASC, [Emp_ID] ASC, [For_Date] DESC, [In_Time] ASC, [Out_Time] ASC, [IO_Tran_Id] ASC, [Reason] ASC, [Chk_By_Superior] ASC, [Is_Cancel_Late_In] ASC, [Is_Cancel_Early_Out] ASC, [ManualEntryFlag] ASC)
    INCLUDE([Duration], [Ip_Address], [In_Date_Time], [Out_Date_Time], [Skip_Count], [Late_Calc_Not_App], [Sup_Comment], [Half_Full_day], [Is_Default_In], [Is_Default_Out], [Cmp_prp_in_flag], [Cmp_prp_out_flag], [is_Cmp_purpose], [App_Date], [Apr_Date], [Other_Reason]) WITH (FILLFACTOR = 95);


GO
CREATE NONCLUSTERED INDEX [IX_T0150_EMP_INOUT_RECORD_MISSING_21790]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Emp_ID] ASC, [For_Date] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_T0150_EMP_INOUT_RECORD_Emp_ID_For_Date_Chk_By_Superior]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Emp_ID] ASC, [For_Date] ASC, [Chk_By_Superior] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_T0150_EMP_INOUT_RECORD_Emp_ID_For_Date_In_Time]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Emp_ID] ASC, [For_Date] ASC)
    INCLUDE([In_Time]);


GO
CREATE NONCLUSTERED INDEX [IX_T0150_EMP_INOUT_RECORD_Emp_ID_For_Date_Out_Time]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Emp_ID] ASC, [For_Date] ASC)
    INCLUDE([Out_Time]);


GO
CREATE NONCLUSTERED INDEX [IX_T0150_EMP_INOUT_RECORD_Emp_ID_For_Date]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Emp_ID] ASC)
    INCLUDE([For_Date]);


GO
CREATE NONCLUSTERED INDEX [IX_T0150_EMP_INOUT_RECORD_Emp_ID_Out_Time_For_Date]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Emp_ID] ASC, [Out_Time] ASC)
    INCLUDE([For_Date]);


GO
CREATE NONCLUSTERED INDEX [IX_T0150_EMP_INOUT_RECORD_Emp_ID_Out_Time_For_Date_In_Time]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Emp_ID] ASC, [Out_Time] ASC)
    INCLUDE([For_Date], [In_Time]);


GO
CREATE NONCLUSTERED INDEX [IX_T0150_EMP_INOUT_RECORD_Emp_ID_In_Time_For_Date]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Emp_ID] ASC, [In_Time] ASC)
    INCLUDE([For_Date]);


GO
CREATE NONCLUSTERED INDEX [IX_T0150_EMP_INOUT_RECORD_Emp_ID_For_Date_In_Time_Out_Time]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Emp_ID] ASC, [For_Date] ASC)
    INCLUDE([In_Time], [Out_Time]);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0150_EMP_INOUT_RECORD_24_1077578877__K2_K4_K3_K14_K1_K5_K23_K6]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Emp_ID] ASC, [For_Date] ASC, [Cmp_ID] ASC, [Chk_By_Superior] ASC, [IO_Tran_Id] ASC, [In_Time] ASC, [is_Cmp_purpose] ASC, [Out_Time] ASC);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0150_EMP_INOUT_RECORD_24_1077578877__K14_K2_K4_K1_K16_3_5_6_7_8_9_10_11_12_13_15_17_18_19_20_21_22_23_24]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Chk_By_Superior] ASC, [Emp_ID] ASC, [For_Date] ASC, [IO_Tran_Id] ASC, [Half_Full_day] ASC)
    INCLUDE([Cmp_ID], [In_Time], [Out_Time], [Duration], [Reason], [Ip_Address], [In_Date_Time], [Out_Date_Time], [Skip_Count], [Late_Calc_Not_App], [Sup_Comment], [Is_Cancel_Late_In], [Is_Cancel_Early_Out], [Is_Default_In], [Is_Default_Out], [Cmp_prp_in_flag], [Cmp_prp_out_flag], [is_Cmp_purpose], [App_Date]);


GO
CREATE NONCLUSTERED INDEX [ix_T0150_EMP_INOUT_RECORD_Reason]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Reason] ASC)
    INCLUDE([Emp_ID], [Chk_By_Superior], [App_Date], [Apr_Date]) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [ix_T0150_EMP_INOUT_RECORD_Cmp_IDFor_Date]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Cmp_ID] ASC, [For_Date] ASC)
    INCLUDE([Emp_ID], [Chk_By_Superior], [Half_Full_day], [Is_Cancel_Late_In], [Is_Cancel_Early_Out]) WITH (FILLFACTOR = 90);


GO
CREATE STATISTICS [_dta_stat_1077578877_4_5_23_6_2_14_3]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([For_Date], [In_Time], [is_Cmp_purpose], [Out_Time], [Emp_ID], [Chk_By_Superior], [Cmp_ID]);


GO
CREATE STATISTICS [_dta_stat_1077578877_4_1_2_3_5_6_23_14]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([For_Date], [IO_Tran_Id], [Emp_ID], [Cmp_ID], [In_Time], [Out_Time], [is_Cmp_purpose], [Chk_By_Superior]);


GO
CREATE STATISTICS [_dta_stat_1077578877_4_6]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([For_Date], [Out_Time]);


GO
CREATE STATISTICS [_dta_stat_1077578877_4_5_6_2_3_23]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([For_Date], [In_Time], [Out_Time], [Emp_ID], [Cmp_ID], [is_Cmp_purpose]);


GO
CREATE STATISTICS [_dta_stat_1077578877_4_1_2_3_14_5_23]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([For_Date], [IO_Tran_Id], [Emp_ID], [Cmp_ID], [Chk_By_Superior], [In_Time], [is_Cmp_purpose]);


GO
CREATE STATISTICS [_dta_stat_1077578877_1_23_4_2_14]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([IO_Tran_Id], [is_Cmp_purpose], [For_Date], [Emp_ID], [Chk_By_Superior]);


GO
CREATE STATISTICS [_dta_stat_1077578877_23_4_2_14]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([is_Cmp_purpose], [For_Date], [Emp_ID], [Chk_By_Superior]);


GO
CREATE STATISTICS [_dta_stat_1077578877_14_4]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Chk_By_Superior], [For_Date]);


GO
CREATE STATISTICS [_dta_stat_1077578877_2_4_14_16_1]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Emp_ID], [For_Date], [Chk_By_Superior], [Half_Full_day], [IO_Tran_Id]);


GO
CREATE STATISTICS [_dta_stat_1077578877_4_2_14_1]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([For_Date], [Emp_ID], [Chk_By_Superior], [IO_Tran_Id]);


GO
CREATE STATISTICS [_dta_stat_1077578877_16_1_2_4]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Half_Full_day], [IO_Tran_Id], [Emp_ID], [For_Date]);


GO
CREATE STATISTICS [_dta_stat_1074102867_5_2_1]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([In_Time], [Emp_ID], [IO_Tran_Id]);


GO
CREATE STATISTICS [_dta_stat_1074102867_21_3_2]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Is_Default_In], [Cmp_ID], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_1074102867_1_2]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([IO_Tran_Id], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_1074102867_4_8_2]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([For_Date], [Reason], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_1074102867_20_1]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Is_Cancel_Early_Out], [IO_Tran_Id]);


GO
CREATE STATISTICS [_dta_stat_1074102867_8_20_1_2_4]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Reason], [Is_Cancel_Early_Out], [IO_Tran_Id], [Emp_ID], [For_Date]);


GO
CREATE STATISTICS [_dta_stat_1074102867_8_2]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Reason], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_1077578877_19_2_4]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Is_Default_In], [Emp_ID], [For_Date]);


GO
CREATE STATISTICS [_dta_stat_1074102867_1_8_2]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([IO_Tran_Id], [Reason], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_1074102867_1_2_4_8]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([IO_Tran_Id], [Emp_ID], [For_Date], [Reason]);


GO
CREATE STATISTICS [_dta_stat_1074102867_2_20_4]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Emp_ID], [Is_Cancel_Early_Out], [For_Date]);


GO
CREATE STATISTICS [_dta_stat_1074102867_20_2_4_1]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Is_Cancel_Early_Out], [Emp_ID], [For_Date], [IO_Tran_Id]);


GO
CREATE STATISTICS [_dta_stat_1074102867_20_4_2_8]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Is_Cancel_Early_Out], [For_Date], [Emp_ID], [Reason]);


GO
CREATE STATISTICS [_dta_stat_1074102867_20_8_1_4]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([Is_Cancel_Early_Out], [Reason], [IO_Tran_Id], [For_Date]);


GO
CREATE STATISTICS [_dta_stat_1074102867_1_4_2_20]
    ON [dbo].[T0150_EMP_INOUT_RECORD]([IO_Tran_Id], [For_Date], [Emp_ID], [Is_Cancel_Early_Out]);


GO





CREATE TRIGGER [dbo].[Tri_T0150_EMP_INOUT_RECORD_20052022] 
ON [dbo].[T0150_EMP_INOUT_RECORD] 
FOR INSERT, UPDATE
AS
	set nocount on 
	
	Declare @Io_Tran_ID numeric 
	Declare @Enroll_No Varchar(50)
	Declare @Emp_Id Numeric
	

	select @Io_Tran_ID = Io_Tran_ID,@Emp_Id = Emp_ID from inserted ins	
	Select @Enroll_No = Enroll_No From T0080_EMP_MASTER Where Emp_ID = @Emp_Id	

					
	if exists(select Io_Tran_Id from T0150_emp_inout_Record where Io_Tran_Id=@Io_Tran_Id 
				and Out_Time is not null and In_Time >= Out_Time )
				Begin
				
					declare @str varchar(500)
					set @str = '@@Out Time Must be Greater than In Time for Enroll No:' + cast(@Enroll_No as varchar(50)) + '@@'
					Raiserror(@str,16,2)
					return
				end





GO
CREATE TRIGGER [dbo].[Tri_T0150_EMP_INOUT_RECORD] 
ON [dbo].[T0150_EMP_INOUT_RECORD] 
FOR INSERT, UPDATE
AS
	set nocount on 
	
	Declare @Io_Tran_ID numeric 
	Declare @Enroll_No Varchar(50)
	Declare @Emp_Id Numeric
	-- Start Added by Niraj (20052022)
	Declare @MobileNo varchar(12)  
	Declare @smstext as varchar(300)
	Declare @In_Time as datetime = null
	Declare @Out_Time as datetime = null
	-- End Added by Niraj (20052022)

	select @Io_Tran_ID = Io_Tran_ID,@Emp_Id = Emp_ID, @In_Time = In_Time, @Out_Time = Out_Time from inserted ins	
	Select @Enroll_No = Enroll_No From T0080_EMP_MASTER Where Emp_ID = @Emp_Id	

					
	if exists(select Io_Tran_Id from T0150_emp_inout_Record where Io_Tran_Id=@Io_Tran_Id 
				and Out_Time is not null and In_Time >= Out_Time )
				Begin
				
					declare @str varchar(500)
					set @str = '@@Out Time Must be Greater than In Time for Enroll No:' + cast(@Enroll_No as varchar(50)) + '@@'
					Raiserror(@str,16,2)
					return
				end
	--SET @MobileNo = (select Mobile_No From T0080_EMP_MASTER Where Emp_ID = @Emp_Id)  
	--IF @In_Time IS NOT NULL AND @Out_Time = NULL
	--	Begin
	--		exec Parwani_SMSAPI_Integration @MobileNo, @In_Time, 0
	--	END
	--Else
	--	Begin
	--		exec Parwani_SMSAPI_Integration @MobileNo, @Out_Time, 1
	--	End
	--SET @smstext = --(select smstext from inserted)  
	--SET @sResponse = 'test'
	--Exec pr_SendSmsSQL @MobileNo, @smstext, @sResponse



