CREATE TABLE [dbo].[T0100_LEFT_EMP] (
    [Left_ID]           NUMERIC (18)  NOT NULL,
    [Cmp_ID]            NUMERIC (18)  NOT NULL,
    [Emp_ID]            NUMERIC (18)  NOT NULL,
    [Left_Date]         DATETIME      NOT NULL,
    [Left_Reason]       VARCHAR (250) NOT NULL,
    [New_Employer]      VARCHAR (100) NULL,
    [Reg_Accept_Date]   DATETIME      NULL,
    [Is_Terminate]      TINYINT       CONSTRAINT [DF_T0100_LEFT_EMP_Is_Terminate] DEFAULT ((0)) NULL,
    [Uniform_Return]    NUMERIC (18)  NULL,
    [Exit_Interview]    NUMERIC (18)  NULL,
    [Notice_Period]     NUMERIC (18)  NULL,
    [Is_Death]          TINYINT       NULL,
    [Reg_Date]          DATETIME      NULL,
    [Is_FnF_Applicable] TINYINT       CONSTRAINT [DF_T0100_LEFT_EMP_Is_FnF_Applicable] DEFAULT ((1)) NOT NULL,
    [Rpt_Manager_ID]    NUMERIC (18)  NULL,
    [Is_Retire]         NUMERIC (1)   CONSTRAINT [DF_T0100_LEFT_EMP_IS_Retire] DEFAULT ((0)) NOT NULL,
    [LeftReasonValue]   VARCHAR (500) NULL,
    [LeftReasonText]    VARCHAR (500) NULL,
    [Request_Apr_ID]    NUMERIC (18)  DEFAULT ((0)) NOT NULL,
    [Res_Id]            INT           NULL,
    [Is_Absconded]      TINYINT       DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK_T0100_LEFT_EMP] PRIMARY KEY CLUSTERED ([Left_ID] ASC) WITH (FILLFACTOR = 80),
    CONSTRAINT [FK_T0100_LEFT_EMP_T0010_COMPANY_MASTER] FOREIGN KEY ([Cmp_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0100_LEFT_EMP_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID])
);


GO
CREATE NONCLUSTERED INDEX [IX_T0100_LEFT_EMP]
    ON [dbo].[T0100_LEFT_EMP]([Emp_ID] ASC, [Left_Date] ASC) WITH (FILLFACTOR = 80);


GO
CREATE STATISTICS [_dta_stat_78623323_12_3]
    ON [dbo].[T0100_LEFT_EMP]([Is_Death], [Emp_ID]);


GO





CREATE TRIGGER Tri_T0100_LEFT_EMP_UPDATE
ON dbo.T0100_LEFT_EMP 
FOR  UPDATE 
AS

	Declare @Emp_ID numeric 
	Declare @Left_Date Datetime
	Declare @Left_ID numeric 
	DEclare @Join_Date	DAtetime

	select @Emp_ID = Emp_ID , @left_Date = LEft_Date from inserted
	Update T0110_EMP_LEFT_JOIN_TRAN 
	Set Left_Date = @Left_DAte ,
		Left_ID	= @Left_ID 
	Where Emp_ID =@Emp_ID and Join_Date = (select Max(Join_Date)  From T0110_EMP_LEFT_JOIN_TRAN 
			Where Emp_ID = @Emp_ID and Join_Date <=@LEft_Date)
				




GO





CREATE TRIGGER Tri_T0100_LEFT_EMP
ON dbo.T0100_LEFT_EMP 
FOR  INSERT, DELETE 
AS

	Declare @Emp_ID numeric 
	Declare @Left_Date Datetime
	Declare @Left_ID numeric 
	DEclare @Join_Date	DAtetime
	 IF UPDATE (Left_ID)
		begin
			select @Emp_ID = Emp_ID , @left_Date = LEft_Date from inserted
			Update T0110_EMP_LEFT_JOIN_TRAN 
			Set Left_Date = @Left_DAte ,
				Left_ID	= @Left_ID 
			Where Emp_ID =@Emp_ID and Join_Date = (select Max(Join_Date)  From T0110_EMP_LEFT_JOIN_TRAN 
					Where Emp_ID = @Emp_ID and Join_Date <=@LEft_Date)
				
		End
	 else 
		begin
			select @Emp_ID = Emp_ID , @left_Date = LEft_Date from deleted
			Update T0110_EMP_LEFT_JOIN_TRAN 
			Set Left_Date = null ,
				Left_ID	= null 
			Where Emp_ID =@Emp_ID and @Left_Date =@Left_Date
			
		end
	 



