

-- =============================================
-- Author:		<Mihir Trivedi>
-- ALTER date: <18/06/2012>
-- Description:	<Created to add financial year month as per FY>
---30/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
-- =============================================
CREATE PROCEDURE [dbo].[GET_FY_MONTH]
	@Cmp_ID Numeric,
	@Emp_ID Numeric,
	@YEAR Numeric
AS
BEGIN	
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @From_Date Datetime
	Declare @To_Date Datetime
	Declare @Count Numeric
	Declare @Amt numeric(18,2)
		Set @Amt = 0
	Declare @Amt_Ess numeric(18,2)
		Set @Amt_Ess = 0
		
	Declare @Doc_Name Varchar(200)  -- Added By Ali 20012014
		Set @Doc_Name = ''  -- Added By Ali 20012014
	
	Set @Count = 1
	Set @From_Date = '01-Apr-'+ Cast(@Year as varchar)
	Set @To_Date = '31-Mar-' + Cast(@Year + 1 as varchar)
	
	CREATE table #Year_Detail
	(
		Month varchar(10),
		--Amount varchar(20),
		--Amount_Ess varchar(20),
		Amount numeric(18,2),
		Amount_Ess numeric(18,2),
		DOC_NAME varchar(200)
	)
	while @From_Date <= @To_Date 
		BEGIN
			If @Count = 1
				BEGIN
					
					Select @Amt = AMOUNT from	T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
									     where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
									     and ('Apr-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
					
					Select @Amt_Ess = AMOUNT_ESS from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
												 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
												 and ('Apr-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
					
					 -- Added By Ali 20012014     
					 Select @Doc_Name = DOC_NAME from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID  
							 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1   
							 and ('Apr-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))  
				                  
					 Insert into #Year_Detail(Month, Amount, Amount_Ess,DOC_NAME)   
					 values('Apr-'+ Cast(@Year as varchar), @Amt, @Amt_Ess,@Doc_Name)
					
				END
			If @Count = 2
				BEGIN
				
					Select @Amt = AMOUNT from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
										 where ID.CMP_ID=@Cmp_ID and EMP_ID =@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
										 and ('May-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
					
					
					
					Select @Amt_Ess = AMOUNT_ESS from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
												 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
												 and ('May-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
													  
					     -- Added By Ali 20012014
					 Select @Doc_Name = DOC_NAME from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID  
							 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1   
							 and ('May-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))  
				     
				                 
					 Insert into #Year_Detail(Month, Amount, Amount_Ess,DOC_NAME)   
					 values('May-'+ Cast(@Year as varchar), @Amt, @Amt_Ess,@Doc_Name)  
					
				END
			If @Count = 3
				BEGIN
				
					Select @Amt = AMOUNT from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
										 where ID.CMP_ID=@Cmp_ID and EMP_ID =@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
										 and ('Jun-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
												
					Select @Amt_Ess = AMOUNT_ESS from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
												 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
												 and ('Jun-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
																		
					-- Added By Ali 20012014
					 Select @Doc_Name = DOC_NAME from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID  
							 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1   
							 and ('Jun-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))  
				     
				                    
					 Insert into #Year_Detail(Month, Amount, Amount_Ess,DOC_NAME)   
					 values('Jun-'+ Cast(@Year as varchar), @Amt, @Amt_Ess,@Doc_Name)
					
				END
			If @Count = 4
				BEGIN
				
					Select @Amt = AMOUNT from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
										 where ID.CMP_ID=@Cmp_ID and EMP_ID =@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
										 and ('Jul-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
												
					Select @Amt_Ess = AMOUNT_ESS from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
												 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
												 and ('Jul-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
												 
					-- Added By Ali 20012014        
					 Select @Doc_Name = DOC_NAME from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID  
							 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1   
							 and ('Jul-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))  
				               
					 Insert into #Year_Detail(Month, Amount, Amount_Ess,DOC_NAME)   
					 values('Jul-'+ Cast(@Year as varchar), @Amt, @Amt_Ess,@Doc_Name) 
					
				END
			If @Count = 5
				BEGIN
					
					Select @Amt = AMOUNT from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
										 where ID.CMP_ID=@Cmp_ID and EMP_ID =@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
										 and ('Aug-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
												
					Select @Amt_Ess = AMOUNT_ESS from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
												 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
												 and ('Aug-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
												 
					 -- Added By Ali 20012014       
					 Select @Doc_Name = DOC_NAME  from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID  
							 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1   
							 and ('Aug-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))  
				               
					 Insert into #Year_Detail(Month, Amount, Amount_Ess,DOC_NAME)   
					 values('Aug-'+ Cast(@Year as varchar), @Amt, @Amt_Ess,@Doc_Name)
					
				END
			If @Count = 6
				BEGIN
				  
				    Select @Amt = AMOUNT from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
										 where ID.CMP_ID=@Cmp_ID and EMP_ID =@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
										 and ('Sep-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
												
					Select @Amt_Ess = AMOUNT_ESS from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
												 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
												 and ('Sep-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
												 
					-- Added By Ali 20012014
					Select @Doc_Name = DOC_NAME from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID  
						 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1   
						 and ('Sep-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))  
			               
				 Insert into #Year_Detail(Month, Amount, Amount_Ess,DOC_NAME)   
				 values('Sep-'+ Cast(@Year as varchar), @Amt, @Amt_Ess,@Doc_Name)  
					
				END
			If @Count = 7
				BEGIN
				
					Select @Amt = AMOUNT from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
										 where ID.CMP_ID=@Cmp_ID and EMP_ID =@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
										 and ('Oct-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
												
					Select @Amt_Ess = AMOUNT_ESS from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM  WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
												 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
												 and ('Oct-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
												 
					-- Added By Ali 20012014
					 Select @Doc_Name = DOC_NAME from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID  
							 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1   
							 and ('Oct-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))  
				     
				               
					 Insert into #Year_Detail(Month, Amount, Amount_Ess,DOC_NAME)   
					 values('Oct-'+ Cast(@Year as varchar), @Amt, @Amt_Ess,@Doc_Name)  
					
				END
			If @Count = 8
				BEGIN
				
					Select @Amt = AMOUNT from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
										 where ID.CMP_ID=@Cmp_ID and EMP_ID =@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
										 and ('Nov-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
												
					Select @Amt_Ess = AMOUNT_ESS from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
												 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
												 and ('Nov-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
												 
					 -- Added By Ali 20012014       
					 Select @Doc_Name = DOC_NAME from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID  
							 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1   
							 and ('Nov-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))  
				     
				               
					 Insert into #Year_Detail(Month, Amount, Amount_Ess,DOC_NAME)   
					 values('Nov-'+ Cast(@Year as varchar), @Amt, @Amt_Ess,@Doc_Name) 
					
				END
			If @Count = 9
				BEGIN
				
				    Select @Amt = AMOUNT from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
										 where ID.CMP_ID=@Cmp_ID and EMP_ID =@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
										 and ('Dec-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
												
					Select @Amt_Ess = AMOUNT_ESS from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
												 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
												 and ('Dec-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
												 
					-- Added By Ali 20012014
					Select @Doc_Name = DOC_NAME from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID  
						 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1   
						 and ('Dec-'+ Cast(@Year as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))  
			        
			               
				 Insert into #Year_Detail(Month, Amount, Amount_Ess,DOC_NAME)   
				 values('Dec-'+ Cast(@Year as varchar), @Amt, @Amt_Ess,@Doc_Name)
					
				END
			If @Count = 10
				BEGIN
				
				    Select @Amt = AMOUNT from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
										 where ID.CMP_ID=@Cmp_ID and EMP_ID =@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
										 and ('Jan-'+ Cast(@Year + 1 as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
												
					Select @Amt_Ess = AMOUNT_ESS from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
												 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
												 and ('Jan-'+ Cast(@Year + 1 as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
												 
					-- Added By Ali 20012014
					 Select @Doc_Name = DOC_NAME from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID  
						 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1   
						 and ('Jan-'+ Cast(@Year + 1 as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))  
			        
			               
				 Insert into #Year_Detail(Month, Amount, Amount_Ess,DOC_NAME)   
				 values('Jan-'+ Cast(@Year + 1 as varchar), @Amt, @Amt_Ess,@Doc_Name) 
					
				END
			If @Count = 11
				BEGIN
				    
				    Select @Amt = AMOUNT from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
										 where ID.CMP_ID=@Cmp_ID and EMP_ID =@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
										 and ('Feb-'+ Cast(@Year + 1 as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
												
					Select @Amt_Ess = AMOUNT_ESS from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
												 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
												 and ('Feb-'+ Cast(@Year + 1 as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
												 
					Select @Doc_Name = DOC_NAME from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID  
					 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1   
					 and ('Feb-'+ Cast(@Year + 1 as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))  
			               
				 Insert into #Year_Detail(Month, Amount, Amount_Ess,DOC_NAME)   
				 values('Feb-'+ Cast(@Year + 1 as varchar), @Amt, @Amt_Ess,@Doc_Name)
					
				END
			If @Count = 12
				BEGIN
				
				    Select @Amt = AMOUNT from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
										 where ID.CMP_ID=@Cmp_ID and EMP_ID =@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
										 and ('Mar-'+ Cast(@Year + 1 as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
												
					Select @Amt_Ess = AMOUNT_ESS from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID
												 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1 
												 and ('Mar-'+ Cast(@Year + 1 as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))
												 
					-- Added By Ali 20012014
					Select @Doc_Name = DOC_NAME from T0100_IT_DECLARATION ID WITH (NOLOCK) INNER JOIN T0070_IT_MASTER IM WITH (NOLOCK) on ID.IT_ID = IM.IT_ID  
						 where ID.CMP_ID=@Cmp_ID and EMP_ID=@Emp_ID and YEAR(FOR_DATE) in (@Year,@Year + 1) and IT_Def_ID = 1   
						 and ('Mar-'+ Cast(@Year + 1 as varchar) = Substring(Datename(MM,For_Date),0,4) + '-' + Convert(varchar,Year(For_Date)))  
			        
			               
				 Insert into #Year_Detail(Month, Amount, Amount_Ess,DOC_NAME)   
				 values('Mar-'+ Cast(@Year + 1 as varchar), @Amt, @Amt_Ess,@Doc_Name) 
					
				END
				
			Set @From_Date = DateAdd(M, 1, @From_Date)
			Set @Count = @Count + 1
			Set @Amt = 0
			Set @Amt_Ess = 0
			Set @Doc_Name = ''    -- Added By Ali 20012014
		END

		

	Select Month, 
	--ISNULL(Amount, '') As Amount, Comment by nilesh patel on 08012014 
	--ISNULL(Amount_Ess, '') As Amount_Ess, Comment by nilesh patel on 08012014 
	COALESCE(Amount,0) As Amount,  --Added by nilesh patel on 08012014 
	COALESCE(Amount_Ess,0) As Amount_Ess, --Added by nilesh patel on 08012014 
	ISNULL(DOC_NAME,'') as DOC_NAME from #Year_Detail  
	Drop Table #Year_Detail
END
RETURN

