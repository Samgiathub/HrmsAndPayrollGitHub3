
-- Created by rohit for Customized report of Ax on 12022016
---28/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[AX_ERP_REPORT_Customized]
	  @Cmp_Id	numeric output	 
	 ,@From_Date  datetime
	 ,@To_Date  datetime
	 ,@Ax_Id  numeric(18,0)
	 ,@Branch_ID		varchar(MAX)  =''    --Added by Jaina 05-04-2018 Start      
	 ,@Cat_ID			varchar(MAX) = ''           
	 ,@Grd_ID			varchar(MAX) =''       
	 ,@Type_ID			varchar(MAX) =''                
	 ,@Dept_ID			varchar(MAX) =''                  
	 ,@Desig_ID			varchar(MAX) =''     --Added by Jaina 05-04-2018 End 
	 ,@Cost_Center		varchar(MAX) =''     --Added by Ramiz 22/05/2018
	 ,@Format			varchar(5) = ''		 --Added by Ramiz 22/05/2018
	 ,@Business_Segment varchar(MAX) = ''    --Added by Jaina 25-08-2020
AS
begin
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @sp_name as varchar(max)
Declare @sql_Query as varchar(Max)
Declare @parameter as varchar(50)
set @sp_name  = ''
set @sql_Query = ''

CREATE table #Emp_Cons 
(      
	Emp_ID NUMERIC ,     
	Branch_ID NUMERIC,
	Increment_ID NUMERIC
)	
	
exec SP_RPT_FILL_EMP_CONS_MULTIDROPDOWN @Cmp_ID,@From_Date,@To_Date,@Branch_ID,@Cat_ID,@Grd_ID,@Type_ID,@Dept_ID,@Desig_ID,0,'',0,0,'','0','0','',0,0,0,'0',0,0   
	
	
	

IF @AX_ID > 0
	BEGIN
		SELECT @SP_NAME = SP_NAME, @PARAMETER = PARAMETER  FROM T9999_AX_REPORT_SETTING WITH (NOLOCK) WHERE AX_ID = @AX_ID AND FORMAT = ISNULL(@Format,FORMAT)
	END

	if isnull(@parameter,'')<>''
		set @parameter= '@Flag ='''+ cast(@parameter as varchar(50))+ ''
	
	--SET @SQL_QUERY = 'EXEC ' + @SP_NAME + ' @CMP_ID = ' + CAST(@CMP_ID AS VARCHAR(4)) + ',@FROM_DATE= ''' + REPLACE(CONVERT(VARCHAR(11),@From_Date,106), ' ','-') + ''',@TO_DATE= ''' + REPLACE(CONVERT(VARCHAR(11),@To_Date,106), ' ','-') + ''',' + @parameter + ''''  
	
	IF @AX_ID  = 1 --COST CENTER FILTER ONLY WORKS IN "-SALARY-" SAP FILES
		BEGIN
			IF @Format = 'F6'
			BEGIN
				set @sp_name = 'AX_ERP_REPORT_Customized_Text'
				SET @SQL_QUERY = 'EXEC ' + @SP_NAME + ' @CMP_ID = ' + CAST(@CMP_ID AS VARCHAR(4)) + ',@FROM_DATE= ''' + REPLACE(CONVERT(VARCHAR(11),@From_Date,106), ' ','-') + ''',@TO_DATE= ''' + REPLACE(CONVERT(VARCHAR(11),@To_Date,106), ' ','-') + ''',@Branch_Id= ''' + CAST(@Branch_ID AS VARCHAR(10)) + ''',@Cat_ID= ''' + CAST(@Cat_ID AS VARCHAR(10)) + ''',@Grd_ID= ''' + CAST(@Grd_ID AS VARCHAR(10)) + ''',@Type_ID= ''' + CAST(@Type_ID AS VARCHAR(10)) + ''',@Dept_ID= ''' + CAST(@Dept_ID AS VARCHAR(10)) + ''',@Desig_ID= ''' + CAST(@Desig_ID AS VARCHAR(10)) + ''',@Cost_Center= ''' + CAST(@Cost_Center AS VARCHAR(10)) + ''',@Format= ''' + CAST(@Format AS VARCHAR(10)) + ''',@Business_Segment= ''' + CAST(@Business_Segment AS VARCHAR(10)) + ''''
			END
			ELSE
			BEGIN
				SET @SQL_QUERY = 'EXEC ' + @SP_NAME + ' @CMP_ID = ' + CAST(@CMP_ID AS VARCHAR(4)) + ',@FROM_DATE= ''' + REPLACE(CONVERT(VARCHAR(11),@From_Date,106), ' ','-') + ''',@TO_DATE= ''' + REPLACE(CONVERT(VARCHAR(11),@To_Date,106), ' ','-') + ''',' + @parameter + ''',@Cost_Center = ''' + @Cost_Center + ''',@Business_Segment = ''' + @Business_Segment + ''''
			END
		END
	Else IF @AX_ID  = 11 --Added by Mr.Mehul 26082022
		BEGIN
			SET @SQL_QUERY = 'EXEC ' + @SP_NAME + ' @CMP_ID = ' + CAST(@CMP_ID AS VARCHAR(4)) + ',@FROM_DATE= ''' + REPLACE(CONVERT(VARCHAR(11),@From_Date,106), ' ','-') + ''',@TO_DATE= ''' + REPLACE(CONVERT(VARCHAR(11),@To_Date,106), ' ','-') + ''',@Cost_Center = ''' + @Cost_Center + ''',@Business_Segment = ''' + @Business_Segment + ''''
		END
	ELSE
		BEGIN
			SET @SQL_QUERY = 'EXEC ' + @SP_NAME + ' @CMP_ID = ' + CAST(@CMP_ID AS VARCHAR(4)) + ',@FROM_DATE= ''' + REPLACE(CONVERT(VARCHAR(11),@From_Date,106), ' ','-') + ''',@TO_DATE= ''' + REPLACE(CONVERT(VARCHAR(11),@To_Date,106), ' ','-') + ''',' + @parameter + ''''		
		END
	
	--select @SP_NAME,CAST(@CMP_ID AS VARCHAR(4)),REPLACE(CONVERT(VARCHAR(11),@From_Date,106), ' ','-'),REPLACE(CONVERT(VARCHAR(11),@To_Date,106), ' ','-'), @parameter,@Cost_Center,@Business_Segment
	
	EXEC(@SQL_QUERY)
	
END
	
