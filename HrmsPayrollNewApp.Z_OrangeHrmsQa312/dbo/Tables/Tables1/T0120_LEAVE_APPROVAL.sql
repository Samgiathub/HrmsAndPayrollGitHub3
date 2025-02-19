CREATE TABLE [dbo].[T0120_LEAVE_APPROVAL] (
    [Leave_Approval_ID]         NUMERIC (18)  NOT NULL,
    [Leave_Application_ID]      NUMERIC (18)  NULL,
    [Cmp_ID]                    NUMERIC (18)  NOT NULL,
    [Emp_ID]                    NUMERIC (18)  NOT NULL,
    [S_Emp_ID]                  NUMERIC (18)  NULL,
    [Approval_Date]             DATETIME      NOT NULL,
    [Approval_Status]           CHAR (1)      NOT NULL,
    [Approval_Comments]         VARCHAR (250) NOT NULL,
    [Login_ID]                  NUMERIC (18)  NOT NULL,
    [System_Date]               DATETIME      NOT NULL,
    [M_Cancel_WO_HO]            TINYINT       CONSTRAINT [DF_T0120_LEAVE_APPROVAL_M_Cancel_WO_HO] DEFAULT ((0)) NOT NULL,
    [Is_Backdated_App]          TINYINT       CONSTRAINT [DF_T0120_LEAVE_APPROVAL_Is_Backdated_App] DEFAULT ((0)) NOT NULL,
    [Is_Auto_Leave_From_Salary] TINYINT       DEFAULT ((0)) NULL,
    CONSTRAINT [PK_T0120_LEAVE_APPROVAL] PRIMARY KEY CLUSTERED ([Leave_Approval_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0120_LEAVE_APPROVAL_T0010_COMPANY_MASTER] FOREIGN KEY ([S_Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0120_LEAVE_APPROVAL_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0120_LEAVE_APPROVAL_T0080_EMP_MASTER1] FOREIGN KEY ([S_Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0120_LEAVE_APPROVAL_T0100_LEAVE_APPLICATION] FOREIGN KEY ([Leave_Application_ID]) REFERENCES [dbo].[T0100_LEAVE_APPLICATION] ([Leave_Application_ID]),
    CONSTRAINT [FK_T0120_LEAVE_APPROVAL_T0120_LEAVE_APPROVAL] FOREIGN KEY ([Leave_Approval_ID]) REFERENCES [dbo].[T0120_LEAVE_APPROVAL] ([Leave_Approval_ID])
);


GO
CREATE NONCLUSTERED INDEX [T0120_LEAVE_APPROVAL_New]
    ON [dbo].[T0120_LEAVE_APPROVAL]([Leave_Approval_ID] ASC, [Cmp_ID] ASC, [Emp_ID] ASC, [Approval_Date] ASC, [Approval_Status] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0120_LEAVE_APPROVAL_26_866102126__K7_K4_K1_2]
    ON [dbo].[T0120_LEAVE_APPROVAL]([Approval_Status] ASC, [Emp_ID] ASC, [Leave_Approval_ID] ASC)
    INCLUDE([Leave_Application_ID]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0120_LEAVE_APPROVAL_26_866102126__K1_K7_K4]
    ON [dbo].[T0120_LEAVE_APPROVAL]([Leave_Approval_ID] ASC, [Approval_Status] ASC, [Emp_ID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [_dta_index_T0120_LEAVE_APPROVAL_26_866102126__K7_K4]
    ON [dbo].[T0120_LEAVE_APPROVAL]([Approval_Status] ASC, [Emp_ID] ASC) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_T0120_LEAVE_APPROVAL_MISSING_170]
    ON [dbo].[T0120_LEAVE_APPROVAL]([Emp_ID] ASC)
    INCLUDE([Leave_Approval_ID]);


GO
CREATE NONCLUSTERED INDEX [IX_T0120_LEAVE_APPROVAL_SP_GET_EMP_FNF_DETAIL]
    ON [dbo].[T0120_LEAVE_APPROVAL]([Leave_Application_ID] ASC, [Approval_Status] ASC);


GO
CREATE STATISTICS [_dta_stat_866102126_1_4_7]
    ON [dbo].[T0120_LEAVE_APPROVAL]([Leave_Approval_ID], [Emp_ID], [Approval_Status]);


GO
CREATE STATISTICS [_dta_stat_866102126_4_7]
    ON [dbo].[T0120_LEAVE_APPROVAL]([Emp_ID], [Approval_Status]);


GO
CREATE STATISTICS [_dta_stat_1365579903_7_4]
    ON [dbo].[T0120_LEAVE_APPROVAL]([Approval_Status], [Emp_ID]);


GO
CREATE STATISTICS [_dta_stat_1365579903_1_4_7]
    ON [dbo].[T0120_LEAVE_APPROVAL]([Leave_Approval_ID], [Emp_ID], [Approval_Status]);


GO





CREATE TRIGGER Tri_T0120_LEAVE_APPROVAL_DELETE
ON dbo.T0120_LEAVE_APPROVAL 
FOR DELETE 
AS
	Declare @Leave_Application_ID numeric 
	Declare @Leave_Approval_ID	numeric 
	Declare @Approval_Status	varchar(1)
	
	
	select @Approval_Status = Approval_Status, @Leave_Application_ID = isnull(Leave_Application_ID,0) from deleted
	if isnull(@Leave_Application_ID,0) > 0	
		begin
			Update t0100_leave_application 
			set Application_Status = 'P'
			where Leave_Application_ID = @Leave_Application_ID
		end 
		




GO




CREATE TRIGGER Tri_T0120_LEAVE_APPROVAL
ON dbo.T0120_LEAVE_APPROVAL 
FOR INSERT, UPDATE --, DELETE 
AS
	Declare @Leave_Application_ID numeric 
	Declare @Leave_Approval_ID	numeric 
	Declare @Approval_Status	varchar(1)

	
			select @Approval_Status = Approval_Status, @Leave_Application_ID = isnull(Leave_Application_ID,0) from inserted 
			
			if isnull(@Leave_Application_ID,0) > 0	
				begin
					Update t0100_leave_application 
					set Application_Status = @Approval_Status
					where Leave_Application_ID = @Leave_Application_ID
				end 




