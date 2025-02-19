

CREATE PROCEDURE [dbo].[P0190_Monthly_AD_Detail_Delete]    
 @Tran_ID numeric(18,0)
     
AS    
Declare @EMP_ID  decimal(12,0)
Declare @Cmp_id int
Declare @Branch_Id as int
Declare @Alpha_Emp_Code varchar(50)
Declare @Month int
Declare @Year  int
Declare @LogDesc	nvarchar(max)
Declare @ad_id int

set @Cmp_id =0
--if @Cmp_id=0
--set @Cmp_id=null 

		SELECT @EMP_ID = EMP_ID,@MONTH=[MONTH],@YEAR=[YEAR],
			   @ALPHA_EMP_CODE = ALPHA_EMP_CODE,@BRANCH_ID=BRANCH_ID,@AD_ID=AD_ID
			  ,@CMP_ID=CMP_ID  --ADDED BY JAINA 10-09-2020
		FROM V0190_MONTHLY_AD_DETAIL_IMPORT WITH(NOLOCK) WHERE TRAN_ID=@TRAN_ID
	--WHERE CMP_ID=@CMP_ID --AND TRAN_ID = @TRAN_ID
	
	
		IF EXISTS(SELECT EMP_ID FROM  T0200_MONTHLY_SALARY WITH(NOLOCK)
				  WHERE EMP_ID=@EMP_ID AND MONTH(MONTH_END_DATE)=@MONTH AND YEAR(MONTH_END_DATE)=@YEAR)
			BEGIN		
			
				--ADDED BY SUMIT 09072015-----------------------------------------------------------
			DECLARE @AD_NOT_EFFECT_SALARY AS TINYINT
			DECLARE @AD_CAL_IMPORTED AS TINYINT

			SELECT @AD_NOT_EFFECT_SALARY=AD_NOT_EFFECT_SALARY,
					@AD_CAL_IMPORTED=IS_CALCULATED_ON_IMPORTED_VALUE 
			FROM T0050_AD_MASTER WITH(NOLOCK)  WHERE AD_ID=@AD_ID AND CMP_ID=@CMP_ID
				--SELECT @AD_NOT_EFFECT_SALARY,@AD_CAL_IMPORTED 
				IF (@AD_NOT_EFFECT_SALARY <> 1 OR @AD_CAL_IMPORTED <> 1)
					BEGIN
				
					set @LogDesc = 'Emp_Code='+@Alpha_Emp_Code +', Month='+cast(@Month as varchar)+', Year='+cast(@Year as varchar)
						Insert Into dbo.T0080_Import_Log Values (0,0,@Alpha_Emp_Code,'Monthly salary Exists ' +@LogDesc ,'','Import proper Data',GetDate(),'Import Data Delete','')
						--exec Event_Logs_Insert 0,@Cmp_ID,@Emp_Id,@Login_ID,'Import','Monthly salary Exists',@LogDesc,1,''			
						Raiserror('Salary Exists',16,2)
						return -1		
				--Delete from T0190_Monthly_AD_Detail_IMPORT where Tran_ID=@Tran_ID 

				end
			end
			
		IF EXISTS(SELECT EMP_ID FROM  T0302_Process_Detail WHERE EMP_ID=@EMP_ID AND month(for_date)=@Month and Year(for_date)=@Year and Ad_id=@ad_id and payment_process_id <> 0)
			Begin	
					set @LogDesc = 'Emp_Code='+@Alpha_Emp_Code +', Month='+cast(@Month as varchar)+', Year='+cast(@Year as varchar)
						Insert Into dbo.T0080_Import_Log Values (0,0,@Alpha_Emp_Code,'Payment Process Exists ' +@LogDesc ,'','Import proper Data',GetDate(),'Import Data Delete','')
						--exec Event_Logs_Insert 0,@Cmp_ID,@Emp_Id,@Login_ID,'Import','Monthly salary Exists',@LogDesc,1,''			
						Raiserror('Payment Process Exists',16,2)
						return -1	
			end	
			IF EXISTS(SELECT EMP_ID FROM  MONTHLY_EMP_BANK_PAYMENT WHERE EMP_ID=@EMP_ID AND month(for_date)=@Month and Year(for_date)=@Year and Ad_Id=@ad_id)
			Begin		
						set @LogDesc = 'Emp_Code='+@Alpha_Emp_Code +', Month='+cast(@Month as varchar)+', Year='+cast(@Year as varchar)
						Insert Into dbo.T0080_Import_Log Values (0,0,@Alpha_Emp_Code,'Payment Process Exists' +@LogDesc ,'','Import proper Data',GetDate(),'Import Data Delete','')
						Raiserror('Payment Process Exists.',16,2)
						return -1	
			end
			
			IF EXISTS(SELECT EMP_ID FROM  T0210_ESIC_On_Not_Effect_on_Salary WHERE EMP_ID=@EMP_ID AND month(for_date)=@Month and Year(for_date)=@Year and Ad_Id=@ad_id)
			Begin		
						set @LogDesc = 'Emp_Code='+@Alpha_Emp_Code +', Month='+cast(@Month as varchar)+', Year='+cast(@Year as varchar)
						Insert Into dbo.T0080_Import_Log Values (0,0,@Alpha_Emp_Code,'TDS or Esic Calculation Exists' +@LogDesc ,'','Import proper Data',GetDate(),'Import Data Delete','')
						Raiserror('TDS or Esic Calculation Exists.',16,2)
						return -1	
			end
			
			Delete from T0190_Monthly_AD_Detail_IMPORT where Tran_ID=@Tran_ID 
			
 RETURN    
    
  


