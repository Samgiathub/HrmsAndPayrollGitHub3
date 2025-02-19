CREATE TABLE [dbo].[T0180_LOCKED_ATTENDANCE] (
    [Lock_Id]     INT      NOT NULL,
    [Cmp_Id]      INT      NOT NULL,
    [Emp_Id]      INT      NOT NULL,
    [Month]       TINYINT  NOT NULL,
    [Year]        SMALLINT NOT NULL,
    [From_Date]   DATETIME NOT NULL,
    [To_Date]     DATETIME NOT NULL,
    [CutOff_Date] DATETIME NOT NULL,
    [Login_Id]    INT      NOT NULL,
    [System_Date] DATETIME NOT NULL,
    CONSTRAINT [PK_T0180_LOCKED_ATTENDANCE] PRIMARY KEY CLUSTERED ([Lock_Id] ASC)
);


GO


-- =============================================
-- Author:		<Author,,Jimit>
-- Create date: <Create Date,,06032019>
-- Description:	<Description,,For check the validation when delete Locked attendance>
-- =============================================
CREATE TRIGGER [dbo].[Tri_T0180_LOCKED_ATTENDANCE]
ON [dbo].[T0180_LOCKED_ATTENDANCE] 
FOR DELETE 
AS
	Declare @Emp_ID numeric 
	Declare @MONTH	numeric 
	Declare @YEAR	numeric
	
	
	select @EMP_ID = EMP_ID,@MONTH = [MONTH], @YEAR = [YEAR] from deleted
	
		--begin			
		--	IF EXISTS(SELECT 1 FROM T0200_MONTHLY_SALARY WHERE 
		--				EMP_ID = @EMP_ID AND MONTH(MONTH_END_DATE) = @MONTH AND
		--				YEAR(MONTH_END_DATE) = @YEAR)
		--	BEGIN
		--			RAISERROR('@@THIS MONTHS SALARY EXISTS@@',18,2)
		--			RETURN							
		--	END
				
		--end
