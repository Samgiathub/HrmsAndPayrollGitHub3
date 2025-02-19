CREATE TABLE [dbo].[T9999_MOBILE_INOUT_DETAIL] (
    [IO_Tran_DetailsID]    NUMERIC (18)  IDENTITY (1, 1) NOT NULL,
    [IO_Tran_ID]           NUMERIC (18)  NULL,
    [Cmp_ID]               NUMERIC (18)  NULL,
    [Emp_ID]               NUMERIC (18)  NULL,
    [IO_Datetime]          DATETIME      NULL,
    [IMEI_No]              VARCHAR (50)  NULL,
    [In_Out_Flag]          CHAR (10)     NULL,
    [Latitude]             VARCHAR (50)  NULL,
    [Longitude]            VARCHAR (50)  NULL,
    [Location]             VARCHAR (MAX) NULL,
    [Emp_Image]            VARCHAR (50)  NULL,
    [Reason]               VARCHAR (255) NULL,
    [Approval_Status]      NUMERIC (18)  DEFAULT ((0)) NOT NULL,
    [Approval_by]          NUMERIC (18)  NULL,
    [Approval_date]        DATETIME      NULL,
    [Approval_From_Mobile] NUMERIC (18)  DEFAULT ((0)) NOT NULL,
    [Is_Verify]            INT           CONSTRAINT [DF_T9999_MOBILE_INOUT_DETAIL_Is_Verify] DEFAULT ((0)) NULL,
    [IsOffline]            TINYINT       DEFAULT ((0)) NOT NULL,
    [Vertical_ID]          NUMERIC (18)  NULL,
    [SubVertical_ID]       NUMERIC (18)  NULL,
    [ManagerComment]       VARCHAR (255) NULL,
    [R_Emp_ID]             NUMERIC (18)  NULL,
    CONSTRAINT [PK_T9999_MOBILE_INOUT_DETAIL_1] PRIMARY KEY CLUSTERED ([IO_Tran_DetailsID] ASC) WITH (FILLFACTOR = 80)
);


GO


 
CREATE TRIGGER [dbo].[Tri_T9999_MOBILE_INOUT_DETAIL]
   ON  [dbo].[T9999_MOBILE_INOUT_DETAIL]
   FOR  INSERT,UPDATE
AS 

SET NOCOUNT ON 

DECLARE @EMP_ID NUMERIC(18,0)
DECLARE @CMP_ID NUMERIC(18,0)
DECLARE @IO_DATETIME datetime
DECLARE @IP_ADDRESS varchar(50)
DECLARE @In_Out_flag int
DECLARE @Flag int
DECLARE @Approval_Required INT = 0
DECLARE @Approval_Status INT
DECLARE @Getdate datetime = CAST(GETDATE() AS VARCHAR(11)) 
--IF UPDATE(IO_Tran_DetailsID)
	BEGIN
		
		 SELECT  @EMP_ID = Emp_ID,@CMP_ID = Cmp_ID,@IO_DATETIME = IO_Datetime,@IP_ADDRESS = IMEI_No,
		 @In_Out_flag = (CASE WHEN In_Out_Flag = 'I' THEN 0 ELSE 1 END),@Approval_Status=Approval_Status FROM inserted 
		
		 --SET @IO_DATETIME = CAST(@IO_DATETIME as varchar(11))
		 
		 SELECT @Approval_Required = ISNULL(Setting_Value,0) 
		 FROM T0040_SETTING 
		 WHERE Cmp_ID = @CMP_ID AND Setting_Name = 'Required Mobile In Out Approval'  --Mukti(01092017)
		
		-- EXEC SP_EMP_INOUT_SYNCHRONIZATION @EMP_ID,@CMP_ID,@IO_DATETIME,@IP_ADDRESS,@In_Out_flag,0
		
		SET @IO_DATETIME = CAST(@IO_DATETIME AS VARCHAR(11)) + ' ' + dbo.F_GET_AMPM(@IO_DATETIME)
		
		IF @IP_ADDRESS = 'PAYROLL'
		BEGIN 
			--print 'PAYROLL'
			SET @APPROVAL_REQUIRED = 0
		END

		IF @Approval_Required = 1 
			BEGIN
				IF (@Approval_Status = 1 OR @Approval_Status = 2) --Mukti(01092017)
					BEGIN
						
						EXEC SP_EMP_INOUT_SYNCHRONIZATION_FromDate_ToDate @CMP_ID,@IO_DATETIME,@Getdate,0,0,0,0,0,0,@EMP_ID,'','',0,'','','',0,@IP_ADDRESS
					END
			END
		ELSE 
			BEGIN
			
				IF ISNULL(@EMP_ID,0) > 0
					BEGIN
						EXEC SP_EMP_INOUT_SYNCHRONIZATION_WITH_INOUT_FLAG @EMP_ID,@CMP_ID,@IO_DATETIME,@IP_ADDRESS,@In_Out_flag,0
					END
			END
	END
