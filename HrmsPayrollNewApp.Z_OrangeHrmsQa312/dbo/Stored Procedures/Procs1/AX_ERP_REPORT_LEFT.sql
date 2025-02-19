

CREATE PROCEDURE [dbo].[AX_ERP_REPORT_LEFT]
	  @Cmp_Id	numeric output	 
	 ,@To_Date  datetime
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON


	Declare @AX Table
	(
		Account nvarchar(50),
		Transaction_Text nvarchar(500),
		Debit numeric(18,2),
		Department nvarchar(50),
		Cost_Element nvarchar(50),
		Cost_Center nvarchar(50),
		Credit numeric(18,2),
		Gen_Date datetime,
		Sorting_No numeric,
		Cmp_id numeric(18,0),
		ad_id numeric(18,0),
		Dept_id numeric(18,0),
		cc_id numeric(18,0),
		ad_flag char(1),
		loan_id numeric(18,0),
		business_area varchar(150)
	)
	
	insert into @AX
	select AX_Head.Account,AX_Head.[Transaction Text],0,group1.Dept_Code,group1.Cost_Element,group1.Center_Code,0,
	@To_Date,AX_Head.Sorting_no,@Cmp_Id,AX_Head.Ad_id,group1.Dept_Id,group1.Center_ID,AX_Head.AD_FLAG , AX_Head.loan_id, group1.Dealer_Code  from
	(SELECT   ax.Ad_id, Sorting_no, Account,  (case when Month_Year =1 then Narration + ' FOR THE MONTH OF '  + upper(cast(datename(MONTH,@to_date) as varchar(3))) + '.,' + cast(YEAR(@to_date) as varchar(5))
																	 when Month_Year =0 then Head_Name End) as [Transaction Text],
																	 ad.AD_FLAG,
	ax.Loan_id
	FROM         T9999_Ax_Mapping ax WITH (NOLOCK) left join 
	T0050_AD_MASTER AD WITH (NOLOCK) on ad.AD_ID = ax.Ad_id where ax.Cmp_id = @Cmp_Id) as AX_Head

	cross join  

	(select   DM.Dept_Code ,CCM.Center_Code ,CCM.Cost_Element ,DM.Dept_ID , ccm.Center_ID ,isnull(EM.Dealer_Code,'') Dealer_Code  from T0080_EMP_MASTER EM WITH (NOLOCK)
	inner join (select I.Emp_Id,i.Dept_ID,i.Center_ID from T0095_Increment I WITH (NOLOCK) inner join T0080_Emp_Master e WITH (NOLOCK) on i.Emp_ID = E.Emp_ID inner join 
						( select max(Increment_Id) as Increment_Id , Emp_ID from T0095_Increment WITH (NOLOCK)  --Changed by Hardik 10/09/2014 for Same Date Increment
						where Increment_Effective_date <= @To_Date
						and Cmp_ID = @Cmp_Id
						group by emp_ID  ) Qry on
						I.Emp_ID = Qry.Emp_ID and I.Increment_Id = Qry.Increment_Id) as INC on INC.Emp_ID = EM.Emp_ID
	inner join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = inc.Dept_ID
	left outer join T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) on CCM.Center_ID = INC.Center_ID
	
	where  em.Cmp_ID = @Cmp_Id and isnull(Dept_Code,'0') <> '0' 
	group by DM.Dept_Id,DM.Dept_Code,CCM.Center_Code,CCM.Cost_Element , ccm.Center_ID,EM.Dealer_Code ) as group1

	order by Dept_Code, AX_Head.Sorting_no
			
	DECLARE @CUR_CMP_ID AS NUMERIC(18,0)
	DECLARE @CUR_DEPT_ID AS NUMERIC(18,0)  
	DECLARE @CUR_CENTER_ID AS nvarchar(50)
	DECLARE @CUR_AD_ID AS NUMERIC(18,0)
	DECLARE @CUR_AD_FLAG AS CHAR(1)
	DECLARE @CUR_LOAN_ID AS NUMERIC(18,0)
	DECLARE @CUR_BUS_AREA AS nvarchar(50)

	DECLARE CUR_AX CURSOR FOR
		SELECT CMP_ID,DEPT_ID , cc_id,ad_id,ad_flag,loan_id,business_area FROM @AX
	OPEN CUR_AX
	FETCH NEXT FROM CUR_AX INTO @CUR_CMP_ID,@CUR_DEPT_ID , @CUR_CENTER_ID,@CUR_AD_ID,@CUR_AD_FLAG,@CUR_LOAN_ID,@CUR_BUS_AREA
	While @@fetch_Status = 0
		begin
			
			declare @sum_amt as numeric(18,2) 
			
			set @sum_amt = 0
			if @CUR_AD_ID = 0
				begin					
						
						SELECT @sum_amt= ISNULL(SUM(LOAN_RETURN),0)  FROM T0140_LOAN_TRANSACTION TLT WITH (NOLOCK)
						INNER JOIN (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
							( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
							WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
							AND CMP_ID = @CMP_ID 
							GROUP BY EMP_ID  ) QRY ON
							I.EMP_ID = QRY.EMP_ID AND I.Increment_Id = QRY.Increment_Id AND E.Emp_Left = 'Y' 
							AND month(@To_Date) = month(E.Emp_Left_Date) AND year(@To_Date) = year(E.Emp_Left_Date)
							)AS INC ON INC.EMP_ID = TLT.EMP_ID
						WHERE INC.DEPT_ID = @CUR_DEPT_ID AND INC.CENTER_ID = @CUR_CENTER_ID 
						AND MONTH(FOR_DATE) = MONTH(@TO_DATE) AND YEAR(FOR_DATE) = YEAR(@TO_DATE) 
						AND TLT.LOAN_ID = @CUR_LOAN_ID and INC.Dealer_Code = @CUR_BUS_AREA 
							
						update @AX set Credit = @sum_amt where LOAN_ID = @CUR_LOAN_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID	and business_area =  @CUR_BUS_AREA
						
				end
			else if @CUR_AD_ID = 1002 -- Gross
				begin
				
								
					SELECT @sum_amt = isnull(SUM(MS.Gross_Salary),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK) 
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date) and YEAR(month_end_date) = YEAR(@To_Date) 
						and isnull(ms.is_FNF,0) = 1 and EM.Dealer_Code = @CUR_BUS_AREA
						
					update @AX set Debit = @sum_amt where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID and business_area =  @CUR_BUS_AREA
				end
			else if @CUR_AD_ID = 1003 -- Net Amount
				begin
				
					SELECT @sum_amt = isnull(SUM(MS.Net_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK)  --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) 
						and isnull(ms.is_FNF,0) = 1 and EM.Dealer_Code = @CUR_BUS_AREA
						
					update @AX set Credit = @sum_amt where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID	and business_area =  @CUR_BUS_AREA
					
				end
			else if @CUR_AD_ID = 1001 -- PT
				begin
				
					SELECT @sum_amt = isnull(SUM(MS.PT_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK) 
						inner join T0095_INCREMENT i WITH (NOLOCK) on  ms.Increment_ID = i.Increment_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where i.Dept_ID = @CUR_DEPT_ID and i.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)
						and isnull(ms.is_FNF,0) = 1 and EM.Dealer_Code = @CUR_BUS_AREA
						
					update @AX set Credit = @sum_amt where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and business_area =  @CUR_BUS_AREA
					
				end
			--else if @CUR_AD_ID = 1020 -- Notice Recovery
			--	begin
					
			--	SELECT @sum_amt = isnull(SUM(MS.Short_Fall_Dedu_Amount),0) FROM  T0200_MONTHLY_SALARY MS 
			--			inner join T0095_INCREMENT i on  ms.Increment_ID = i.Increment_ID
			--			inner join T0100_LEFT_EMP LE on i.Emp_ID = LE.Emp_ID
			--			where i.Dept_ID = @CUR_DEPT_ID and i.Center_ID =@CUR_CENTER_ID
			--			and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) and LE.Is_Terminate = 0 and MS.Is_FNF = 1
						
			--		update @AX set Credit = @sum_amt where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID		
					
			--	end
			else if @CUR_AD_ID = 1015 -- Advance
				begin
					
					SELECT @sum_amt = isnull(SUM(MS.Advance_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where inc.Dept_ID = @CUR_DEPT_ID and inc.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date) and YEAR(month_end_date) = YEAR(@To_Date)  
						and isnull(ms.is_FNF,0) = 1 and EM.Dealer_Code = @CUR_BUS_AREA
						
					update @AX set Credit = @sum_amt where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and business_area =  @CUR_BUS_AREA
					
				end
			else if @CUR_AD_FLAG = 'I' 
				begin		
				
						
						SELECT @sum_amt = isnull(SUM(MAD.M_AD_AMOUNT),0) + isnull(SUM(MAD.M_AREAR_AMOUNT),0) FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
						inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on mad.Sal_Tran_ID = MS.Sal_Tran_ID
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where inc.Dept_ID = @CUR_DEPT_ID and inc.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date) and YEAR(month_end_date) = YEAR(@To_Date) 
						and AD_ID = @CUR_AD_id  and isnull(ms.is_FNF,0) = 1 and EM.Dealer_Code = @CUR_BUS_AREA
						
					update @AX set Debit = @sum_amt where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID and business_area =  @CUR_BUS_AREA			
				end
			else if @CUR_AD_FLAG = 'D'
				begin	
								
					SELECT @sum_amt = isnull(SUM(MAD.M_AD_AMOUNT),0) + isnull(SUM(MAD.M_AREAR_AMOUNT),0) FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK)
						inner join T0200_MONTHLY_SALARY MS WITH (NOLOCK) on mad.Sal_Tran_ID = MS.Sal_Tran_ID
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where inc.Dept_ID = @CUR_DEPT_ID and inc.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) 
						and AD_ID = @CUR_AD_id and isnull(ms.is_FNF,0) = 1 and EM.Dealer_Code = @CUR_BUS_AREA
						
					update @AX set Credit = @sum_amt where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID	and business_area =  @CUR_BUS_AREA			
				end
				
			FETCH NEXT FROM CUR_AX INTO @CUR_CMP_ID,@CUR_DEPT_ID , @CUR_CENTER_ID,@CUR_AD_ID,@CUR_AD_FLAG,@CUR_LOAN_ID,@CUR_BUS_AREA
		end 
	close cur_ax
	Deallocate cur_ax
		
	SELECT Account,Transaction_Text ,Debit, business_area as 'Business Area' , Department, Cost_Element as 'Cost Element', Cost_Center as 'Cost Center', Credit, convert(nvarchar,Gen_Date,103) as Date,Sorting_No FROM @AX order BY business_area,Department,Cost_Center,Sorting_No

RETURN



