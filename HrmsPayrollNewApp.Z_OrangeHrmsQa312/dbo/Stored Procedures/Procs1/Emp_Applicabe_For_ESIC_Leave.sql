

-- =============================================
-- Author:		<Gadriwala Muslim>
-- Create date: <14/09/2015>
-- Description:	<check here Employee Applicable for ESIC leave>
---02/2/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE  [dbo].[Emp_Applicabe_For_ESIC_Leave]
	@Cmp_ID numeric(18,0),
	@Leave_ID	numeric(18,0),
	@Emp_ID numeric(18,0),
	@Effective_Date datetime = null 
AS
BEGIN
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	
	DECLARE @TEMP_EFFECTIVE_DATE AS DATETIME
	
	SET @TEMP_EFFECTIVE_DATE = @Effective_Date
	


		IF @Effective_Date = '1900-01-01 00:00:00' 
			begin
				set @Effective_Date = null
				set @TEMP_EFFECTIVE_DATE = null
			end
		else
			begin
				set @Effective_Date = dateadd(m,-1,@Effective_Date)
			end
			
	DECLARE @EXIST_FLAG AS TINYINT
	SET @EXIST_FLAG  = 1	
		

						
	WHILE(@EXIST_FLAG = 1 ) -- PREVIOUS DATE SALARY CHECK
		BEGIN
				IF EXISTS (
						SELECT 1 FROM T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						INNER JOIN T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) ON MS.SAL_TRAN_ID = MAD.SAL_TRAN_ID 
						INNER JOIN T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID 
						WHERE MS.Sal_Cal_Days = 0 AND  @EFFECTIVE_DATE BETWEEN MONTH_ST_DATE AND MONTH_END_DATE 
						AND MS.EMP_ID = @EMP_ID AND MS.CMP_ID  = @CMP_ID AND  ADM.AD_DEF_ID =  3
					  )
					BEGIN	
						SET @EFFECTIVE_DATE = DATEADD(M,-1,@EFFECTIVE_DATE)
					END
				ELSE
					BEGIN
						SET @EXIST_FLAG = 0 			
					END
		END	
		
    If isnull(@Emp_ID,0) <> 0 and @effective_Date is not null -- Added by Gadriwala Muslim 14-09-2015 for ESIC Leave
		begin
				
			if exists ( 
				
				Select 1 From T0210_MONTHLY_AD_DETAIL  MAD WITH (NOLOCK) Inner join			-- Last Month Salary Check..
				T0050_AD_MASTER ADM WITH (NOLOCK) ON MAD.AD_ID = ADM.AD_ID INNER JOIN 
				T0080_EMP_MASTER E WITH (NOLOCK) on MAD.emp_ID = E.emp_ID   
				WHERE E.Cmp_ID = @Cmp_ID	 and month(To_date) = month(@Effective_Date)  and Year(To_Date) = Year(@Effective_Date)
				and  ADM.AD_DEF_ID =  3 And  E.Emp_ID =  @Emp_ID and MAD.M_AD_Amount > 0
				UNION
				SELECT 1 from T0080_EMP_MASTER EM WITH (NOLOCK) Inner JOIN					-- First Month of Joining 	
				T0100_emp_Earn_Deduction EED WITH (NOLOCK) on EM.Emp_ID = EED.EMP_ID Inner JOIN
				T0050_AD_MASTER ADM WITH (NOLOCK) ON ADM.AD_ID = EED.AD_ID
				WHERE EED.CMP_ID = @cmp_ID AND ADM.AD_DEF_ID = 3 AND EM.Emp_ID = @emp_ID	
					AND month(EM.Date_Of_Join) = MONTH(@TEMP_EFFECTIVE_DATE) AND YEAR(EM.Date_Of_Join) = YEAR(@TEMP_EFFECTIVE_DATE)
				
				)  -- Employee applicable or not for ESIC leave as Per last month salary  
					begin
						 select 1 as Applicable   -- Applicable for ESIC Leave
					end
				else
					begin
						 select 0 as Applicable  --  Not Applicable for ESIC Leave
					end				
		end	
	else
		begin
			 select 0 as Applicable  -- Not Applicable for ESIC Leave
		end
		
END

