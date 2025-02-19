CREATE TABLE [dbo].[T0110_Uniform_Dispatch_Detail] (
    [Uni_Disp_Id]           NUMERIC (18)   IDENTITY (1, 1) NOT NULL,
    [Uni_Apr_Id]            NUMERIC (18)   NULL,
    [Uni_Req_App_Id]        NUMERIC (18)   NULL,
    [Uni_Req_App_Detail_Id] NUMERIC (18)   NULL,
    [CMP_ID]                NUMERIC (18)   NULL,
    [Emp_ID]                NUMERIC (18)   NULL,
    [Dispatch_Code]         NUMERIC (18)   NULL,
    [Dispatch_Date]         DATETIME       NULL,
    [Refund_Installment]    INT            NULL,
    [Deduction_Installment] INT            NULL,
    [Refund_Start_Date]     DATETIME       NULL,
    [Deduction_Start_Date]  DATETIME       NULL,
    [Dispatch_By_Emp_ID]    NUMERIC (18)   NULL,
    [System_Datetime]       DATETIME       NULL,
    [Comments]              NVARCHAR (250) NULL,
    [Ip_Address]            VARCHAR (100)  NULL,
    CONSTRAINT [PK_T0110_Uniform_Dispatch_Detail] PRIMARY KEY CLUSTERED ([Uni_Disp_Id] ASC) WITH (FILLFACTOR = 95),
    CONSTRAINT [FK_T0110_Uniform_Dispatch_Detail_T0010_COMPANY_MASTER] FOREIGN KEY ([CMP_ID]) REFERENCES [dbo].[T0010_COMPANY_MASTER] ([Cmp_Id]),
    CONSTRAINT [FK_T0110_Uniform_Dispatch_Detail_T0080_EMP_MASTER] FOREIGN KEY ([Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0110_Uniform_Dispatch_Detail_T0080_EMP_MASTER1] FOREIGN KEY ([Dispatch_By_Emp_ID]) REFERENCES [dbo].[T0080_EMP_MASTER] ([Emp_ID]),
    CONSTRAINT [FK_T0110_Uniform_Dispatch_Detail_T0090_Uniform_Requisition_Application] FOREIGN KEY ([Uni_Req_App_Id]) REFERENCES [dbo].[T0090_Uniform_Requisition_Application] ([Uni_Req_App_Id]),
    CONSTRAINT [FK_T0110_Uniform_Dispatch_Detail_T0095_Uniform_Requisition_Application_Detail] FOREIGN KEY ([Uni_Req_App_Detail_Id]) REFERENCES [dbo].[T0095_Uniform_Requisition_Application_Detail] ([Uni_Req_App_Detail_Id])
);


GO
-- =============================================
-- Author:		Binal Prajapati
-- Create date: 08-08-2020
-- Description:	For Uniform Employee Issues At Dispacth Time
-- =============================================
CREATE TRIGGER [dbo].[Tri_T0110_Uniform_Dispatch_Detail]
ON [dbo].[T0110_Uniform_Dispatch_Detail]
For INSERT,DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	DECLARE @Uni_Apr_Id Numeric(18,0)
	DECLARE @Cmp_ID Numeric(18,0)
	DECLARE @Uni_ID Numeric(18,0)
	DECLARE @Emp_ID Numeric(18,0)
	DECLARE @Issue_Date Datetime
    DECLARE @Uni_Pieces Numeric(18,0)
    DECLARE @Uni_Rate Numeric(18,2)
    DECLARE @Uni_Amount Numeric(18,2)
    DECLARE @Uni_deduct_Installment  Numeric(18,0)
    DECLARE @Uni_deduct_Amount Numeric(18,2)
    DECLARE @Uni_Refund_Installment Numeric(18,0)
    DECLARE @Uni_Refund_Amount Numeric(18,2)
    DECLARE @Deduct_Pending_Amount Numeric(18,2)
    DECLARE @Refund_Pending_Amount Numeric(18,2)
    DECLARE @Modify_By  varchar(100)
    DECLARE @Modify_Date Datetime
    DECLARE @Ip_Address varchar(100)
    DECLARE @Uni_Stitching_Price Numeric(18,2)
    DECLARE @Deduction_Start_Date Datetime
    DECLARE @Refund_Start_Date Datetime
    DECLARE @New_Req_Apr_Id Numeric(18,0)
    
	SET @Deduction_Start_Date = null
    SET @Refund_Start_Date =null	
	SET @New_Req_Apr_Id = null
	SET @Modify_by = ''
	SET @Ip_Address = ''
	SET @Modify_Date = NULL
	
	SELECT @Uni_Apr_Id = Isnull(Max(Uni_Apr_Id),0) + 1 FROM T0100_Uniform_Emp_Issue
	
	IF UPDATE(Uni_Apr_Id)
		BEGIN
			SELECT @Cmp_ID = ins.Cmp_ID,
					@Uni_ID = URA.Uni_Id,
					@Emp_ID = ins.Emp_ID,
					@Issue_Date = ins.Dispatch_Date,
					@Uni_Amount = URD.Uni_Amount,	
					@Uni_Rate = URD.Uni_Fabric_Price,
					@Uni_Rate = URD.Uni_Pieces,
					@Uni_Stitching_Price=URD.Uni_Stitching_Price,
					@Modify_by = ins.Dispatch_By_Emp_ID,
					@Modify_Date = ins.System_Datetime,
					@Ip_Address = ins.Ip_Address,
					@Uni_deduct_Installment=ins.Deduction_Installment,
					@Uni_Refund_Installment=ins.Refund_Installment,
					@Deduct_Pending_Amount=URD.Uni_Amount,
					@Refund_Pending_Amount=URD.Uni_Amount,
					@Deduction_Start_Date=ins.Deduction_Start_Date,
					@Refund_Start_Date=ins.Refund_Start_Date,
					@New_Req_Apr_Id=ins.Uni_Apr_Id,
					@Uni_Pieces=URD.Uni_Pieces,
					@Uni_deduct_Amount=CASE WHEN ISNULL(ins.Deduction_Installment,0) <> 0 THEN ROUND((URD.Uni_Amount/ins.Deduction_Installment),0) ELSE 0 END,
					@Uni_Refund_Amount=CASE WHEN ISNULL(ins.Refund_Installment,0) <> 0 THEN ROUND((URD.Uni_Amount/ins.Refund_Installment),0) ELSE 0 END
			FROM inserted ins 
			INNER JOIN T0100_Uniform_Requisition_Approval URD ON INS.Uni_Req_App_Detail_Id=Urd.Uni_Req_App_Detail_Id and INS.Uni_Req_App_Id=Urd.Uni_Req_App_Id
			INNER JOIN T0090_Uniform_Requisition_Application URA ON URA.Uni_Req_App_Id =ins.Uni_Req_App_Id
			
			IF Not Exists(Select 1 From T0100_Uniform_Emp_Issue WITH (NOLOCK) Where New_Req_Apr_Id=@New_Req_Apr_Id)
			BEGIN
				
				INSERT T0100_Uniform_Emp_Issue
					  (Uni_Apr_Id,Cmp_ID,Emp_ID,Issue_Date,Uni_Id,Uni_Pieces,Uni_Rate,Uni_Amount,Uni_deduct_Installment,Uni_deduct_Amount,Uni_Refund_Installment,Uni_Refund_Amount,Deduct_Pending_Amount,Refund_Pending_Amount,Modify_By,Modify_Date,Ip_Address,Uni_Stitching_Price,Deduction_Start_Date,Refund_Start_Date,New_Req_Apr_Id)
				VALUES(@Uni_Apr_Id,@Cmp_ID,@Emp_ID,@Issue_Date,@Uni_Id,@Uni_Pieces,@Uni_Rate,@Uni_Amount,@Uni_deduct_Installment,@Uni_deduct_Amount,@Uni_Refund_Installment,@Uni_Refund_Amount,@Deduct_Pending_Amount,@Refund_Pending_Amount,@Modify_By,@Modify_Date,@Ip_Address,@Uni_Stitching_Price,@Deduction_Start_Date,@Refund_Start_Date,@New_Req_Apr_Id)
			END
			ELSE 
			BEGIN
				UPDATE T0100_Uniform_Emp_Issue 
				SET Uni_Id=@Uni_Id,
					Uni_Pieces=@Uni_Pieces,
					Uni_Rate=@Uni_Rate,
					Uni_Amount=@Uni_Amount,
					Uni_deduct_Installment=@Uni_deduct_Installment,
					Uni_deduct_Amount=@Uni_deduct_Amount,
					Uni_Refund_Installment=@Uni_Refund_Installment,
					Uni_Refund_Amount=@Uni_Refund_Amount,
					Deduct_Pending_Amount=@Deduct_Pending_Amount,
					Refund_Pending_Amount=@Refund_Pending_Amount,
					Modify_By=@Modify_By,
					Modify_Date=@Modify_Date,
					Ip_Address=@Ip_Address,
					Uni_Stitching_Price=@Uni_Stitching_Price,
					Deduction_Start_Date=@Deduction_Start_Date,
					Refund_Start_Date=@Refund_Start_Date
				WHERE New_Req_Apr_Id=@New_Req_Apr_Id

			END
				
			
		END
	ELSE
		BEGIN
			DECLARE curDel CURSOR FOR
				SELECT  del.Uni_Apr_Id,del.CMP_ID,del.Emp_ID
				FROM deleted del
				INNER JOIN T0100_Uniform_Requisition_Approval URD ON del.Uni_Req_App_Detail_Id=URD.Uni_Req_App_Detail_Id and del.Uni_Req_App_Id=URD.Uni_Req_App_Id
				INNER JOIN T0090_Uniform_Requisition_Application URA ON URA.Uni_Req_App_Id =del.Uni_Req_App_Id
			
			OPEN curDel
			FETCH NEXT FROM curDel INTO @Uni_Apr_Id,@Cmp_ID,@Emp_ID
			WHILE @@fetch_status = 0
			BEGIN 
				
				--IF NOT EXISTS(SELECT 1 FROM T0140_Uniform_Payment_Transcation UP
				--			  INNER JOIN T0100_Uniform_Emp_Issue UEI ON UP.Uni_Apr_Id =UEI.Uni_Apr_Id
				--			  Where UEI.New_Req_Apr_Id=@Uni_Apr_Id
				--			 )
				--BEGIN
					DELETE FROM T0100_Uniform_Emp_Issue
					WHERE New_Req_Apr_Id=@Uni_Apr_Id	 
				--END
				
				FETCH NEXT FROM curDel INTO @Uni_Apr_Id,@Cmp_ID,@Emp_ID
			END				
			CLOSE curDel
			DEALLOCATE curDel
		END
END
