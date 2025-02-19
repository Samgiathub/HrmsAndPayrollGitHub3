
---18/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[AX_ERP_REPORT_NEW]
	  @Cmp_Id	numeric output	 
	 ,@To_Date  datetime
	 ,@Flag Char = 'C'
	 ,@AD_id_Pass Numeric = 0
AS
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

	Declare @AX Table
	(
	
	DOCDT	Datetime,
	EMPCD	varchar(50),
	EMPNAME	varchar(500),
	VOUDT	Datetime,
	BUSIUNIT varchar(50),	
	COSTCENT varchar(50),		
	DEPTCODE varchar(50),		
	BANKCODE varchar(50),		
	JOURTYPE varchar(50),		
	JOURNAME varchar(50),		
	OFFSETAC varchar(50),			
	ACCODE1	 varchar(50),			
	ACCTTYPE varchar(50),				
	ACCDDR	varchar(50)	,		
	PAYREFNO varchar(50),				
	PAYREFDT varchar(50),				
	AMOUNT	numeric(18,2),
	Transaction_Text nvarchar(500)	,
	CURRENCY varchar(50),					
	CUREXGRT varchar(50),						
	RECTNAME varchar(50),						
	VOUMONTH varchar(50),						
	EMPIND varchar(50),
	Cmp_id numeric(18,0),
	ad_id numeric(18,0),
	Dept_id numeric(18,0),
	cc_id numeric(18,0),
	ad_flag char(1),
	loan_id numeric(18,0),
	voucher_Flag Char(1),
	vender_Code Varchar(30)
	
)
Declare @vou_DT	datetime
Declare @Doc_DT	datetime
set @vou_DT	= DATEADD(dd,-(DAY(@To_Date)),@To_Date)
set @Doc_DT = DATEADD(dd,-(DAY(@To_Date)-1),@To_Date)

if @AD_id_Pass = 0
begin
	if @Flag = 'A'
	begin
		insert into @AX
		select @Doc_DT ,alpha_Emp_Code,Emp_Full_Name,@vou_DT, group1.Dealer_Code,group1.Center_Code,group1.Dept_Code,bank_code,'0','','0',AX_Head.Account,'0',Cmp_Account_No,'','',0,AX_Head.[Transaction Text],'INR','100.00','','','D',
		@Cmp_Id,AX_Head.Ad_id,group1.Dept_Id,group1.Center_ID,AX_Head.AD_FLAG,AX_Head.loan_id,'',vender_code
		from
		(SELECT   ax.Ad_id, Sorting_no, Account,  (case when Month_Year =1 then Narration + ' FOR THE MONTH OF '  + upper(cast(datename(MONTH,@to_date) as varchar(3))) + '.,' + cast(YEAR(@to_date) as varchar(5))
																		 when Month_Year =0 then Head_Name End) as [Transaction Text],
																		 ad.AD_FLAG,ax.Loan_id,isnull(Vender_code,'') as vender_code,CM.Cmp_Account_No 
		FROM         T9999_Ax_Mapping ax left join 
		T0050_AD_MASTER AD WITH (NOLOCK) on ad.AD_ID = ax.Ad_id
		left join T0010_COMPANY_MASTER CM WITH (NOLOCK) on ax.Cmp_id = CM.Cmp_Id
		 where ax.Cmp_id = @Cmp_Id and Ax.Ad_id=1015 ) as AX_Head

		cross join  

		(select   DM.Dept_Code ,CCM.Center_Code ,CCM.Cost_Element ,DM.Dept_ID , isnull(ccm.Center_ID,0) as Center_ID ,isnull(EM.Dealer_Code,'') Dealer_Code, alpha_Emp_Code,Emp_Full_Name,BM.Bank_Code  from T0080_EMP_MASTER EM WITH (NOLOCK)
		inner join (select I.Emp_Id,i.Dept_ID,i.Center_ID,I.Bank_ID from T0095_Increment I WITH (NOLOCK) inner join T0080_Emp_Master e WITH (NOLOCK) on i.Emp_ID = E.Emp_ID inner join 
							( select max(Increment_Id) as Increment_Id, Emp_ID from T0095_Increment WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_Id
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id) as INC on INC.Emp_ID = EM.Emp_ID
		inner join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = inc.Dept_ID
		left outer join T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) on CCM.Center_ID = INC.Center_ID
		left join T0040_BANK_MASTER BM WITH (NOLOCK) on INC.bank_id = BM.Bank_ID
		where  em.Cmp_ID = @Cmp_Id and isnull(Dept_Code,'0') <> '0'
		group by DM.Dept_Id,DM.Dept_Code,CCM.Center_Code,CCM.Cost_Element , ccm.Center_ID,EM.Dealer_Code,alpha_Emp_Code,Emp_Full_Name,bank_code  ) as group1

		order by Dept_Code, AX_Head.Sorting_no
	end
	else if @Flag = 'S'
	begin
		insert into @AX
		select @Doc_DT ,alpha_Emp_Code,Emp_Full_Name,@vou_DT, group1.Dealer_Code,group1.Center_Code,group1.Dept_Code,Bank_code,'0','','0',AX_Head.Account,'0',Cmp_Account_No,'','',0,AX_Head.[Transaction Text],'INR','100.00','','','D',
		@Cmp_Id,AX_Head.Ad_id,group1.Dept_Id,group1.Center_ID,AX_Head.AD_FLAG,AX_Head.loan_id,'',vender_code
		from
		(SELECT   ax.Ad_id, Sorting_no, Account,  (case when Month_Year =1 then Narration + ' FOR THE MONTH OF '  + upper(cast(datename(MONTH,@to_date) as varchar(3))) + '.,' + cast(YEAR(@to_date) as varchar(5))
																		 when Month_Year =0 then Head_Name End) as [Transaction Text],
																		 ad.AD_FLAG,ax.Loan_id,isnull(Vender_code,'') as vender_code,CM.Cmp_Account_No 
		FROM         T9999_Ax_Mapping ax left join 
		T0050_AD_MASTER AD WITH (NOLOCK) on ad.AD_ID = ax.Ad_id
		left join T0010_COMPANY_MASTER CM WITH (NOLOCK) on ax.Cmp_id = CM.Cmp_Id
		 where ax.Cmp_id = @Cmp_Id and Ax.Ad_id in ('1003','1040','1050','1051')) as AX_Head

		cross join  

		(select   DM.Dept_Code ,CCM.Center_Code ,CCM.Cost_Element ,DM.Dept_ID , isnull(ccm.Center_ID,0) as center_id ,isnull(EM.Dealer_Code,'') Dealer_Code, alpha_Emp_Code,Emp_Full_Name,Bank_code  from T0080_EMP_MASTER EM WITH (NOLOCK)
		inner join (select I.Emp_Id,i.Dept_ID,i.Center_ID,i.Bank_ID from T0095_Increment I WITH (NOLOCK) inner join T0080_Emp_Master e WITH (NOLOCK) on i.Emp_ID = E.Emp_ID inner join 
							( select max(Increment_Id) as Increment_Id, Emp_ID from T0095_Increment WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_Id
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id) as INC on INC.Emp_ID = EM.Emp_ID
		inner join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = inc.Dept_ID
		left outer join T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) on CCM.Center_ID = INC.Center_ID
		LEFT JOIN T0040_BANK_MASTER BM WITH (NOLOCK) ON INC.bank_id = BM.bank_id
		where  em.Cmp_ID = @Cmp_Id and isnull(Dept_Code,'0') <> '0'-- and inc.Emp_ID=608
		group by DM.Dept_Id,DM.Dept_Code,CCM.Center_Code,CCM.Cost_Element , ccm.Center_ID,EM.Dealer_Code,alpha_Emp_Code,Emp_Full_Name,bank_code  ) as group1
		order by Dept_Code, AX_Head.Sorting_no
	end
	else
	begin
		insert into @AX
		select @Doc_DT ,'','',@vou_DT, group1.Dealer_Code,group1.Center_Code,group1.Dept_Code,'','0','','0',AX_Head.Account,'0',Cmp_Account_No,'','',0,AX_Head.[Transaction Text],'INR','100.00','','','D',
		@Cmp_Id,AX_Head.Ad_id,group1.Dept_Id,group1.Center_ID,AX_Head.AD_FLAG,AX_Head.loan_id,'',vender_code
		from
		(SELECT   ax.Ad_id, Sorting_no, Account,  (case when Month_Year =1 then Narration + ' FOR THE MONTH OF '  + upper(cast(datename(MONTH,@to_date) as varchar(3))) + '.,' + cast(YEAR(@to_date) as varchar(5))
																		 when Month_Year =0 then Head_Name End) as [Transaction Text],
																		 ad.AD_FLAG,ax.Loan_id,isnull(Vender_code,'') as vender_code,CM.Cmp_Account_No 
		FROM         T9999_Ax_Mapping ax left join 
		T0050_AD_MASTER AD WITH (NOLOCK) on ad.AD_ID = ax.Ad_id
		left join T0010_COMPANY_MASTER CM WITH (NOLOCK) on ax.Cmp_id = CM.Cmp_Id
		 where ax.Cmp_id = @Cmp_Id) as AX_Head

		cross join  

		(select   DM.Dept_Code ,CCM.Center_Code ,CCM.Cost_Element ,DM.Dept_ID , isnull(ccm.Center_ID,0) as center_id ,isnull(EM.Dealer_Code,'') Dealer_Code  from T0080_EMP_MASTER EM WITH (NOLOCK)
		inner join (select I.Emp_Id,i.Dept_ID,i.Center_ID from T0095_Increment I WITH (NOLOCK) inner join T0080_Emp_Master e WITH (NOLOCK) on i.Emp_ID = E.Emp_ID inner join 
							( select max(Increment_Id) as Increment_Id, Emp_ID from T0095_Increment WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_Id
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id) as INC on INC.Emp_ID = EM.Emp_ID
		inner join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = inc.Dept_ID
		left outer join T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) on CCM.Center_ID = INC.Center_ID
		
		where  em.Cmp_ID = @Cmp_Id and isnull(Dept_Code,'0') <> '0' 
		group by DM.Dept_Id,DM.Dept_Code,CCM.Center_Code,CCM.Cost_Element , ccm.Center_ID,EM.Dealer_Code ) as group1

		order by Dept_Code, AX_Head.Sorting_no
	End	
end
else
begin

	insert into @AX
		select @Doc_DT ,alpha_Emp_Code,Emp_Full_Name,@vou_DT, group1.Dealer_Code,group1.Center_Code,group1.Dept_Code,bank_code,'0','','0',AX_Head.Account,'0',Cmp_Account_No,'','',0,AX_Head.[Transaction Text],'INR','100.00','','','D',
		@Cmp_Id,AX_Head.Ad_id,group1.Dept_Id,group1.Center_ID,AX_Head.AD_FLAG,AX_Head.loan_id,'',vender_code
		from
		(SELECT   ax.Ad_id, Sorting_no, Account,  (case when Month_Year =1 then Narration + ' FOR THE MONTH OF '  + upper(cast(datename(MONTH,@to_date) as varchar(3))) + '.,' + cast(YEAR(@to_date) as varchar(5))
																		 when Month_Year =0 then Head_Name End) as [Transaction Text],
																		 ad.AD_FLAG,ax.Loan_id,isnull(Vender_code,'') as vender_code,CM.Cmp_Account_No 
		FROM         T9999_Ax_Mapping ax left join 
		T0050_AD_MASTER AD WITH (NOLOCK) on ad.AD_ID = ax.Ad_id
		left join T0010_COMPANY_MASTER CM WITH (NOLOCK) on ax.Cmp_id = CM.Cmp_Id
		 where ax.Cmp_id = @Cmp_Id and Ax.Ad_id=@AD_id_Pass  ) as AX_Head

		cross join  

		(select   DM.Dept_Code ,CCM.Center_Code ,CCM.Cost_Element ,DM.Dept_ID , isnull(ccm.Center_ID,0) as center_id ,isnull(EM.Dealer_Code,'') Dealer_Code, alpha_Emp_Code,Emp_Full_Name,BM.Bank_Code  from T0080_EMP_MASTER EM WITH (NOLOCK)
		inner join (select I.Emp_Id,i.Dept_ID,i.Center_ID,I.Bank_ID from T0095_Increment I  WITH (NOLOCK) inner join T0080_Emp_Master e WITH (NOLOCK) on i.Emp_ID = E.Emp_ID inner join 
							( select max(Increment_Id) as Increment_Id, Emp_ID from T0095_Increment WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
							where Increment_Effective_date <= @To_Date
							and Cmp_ID = @Cmp_Id
							group by emp_ID  ) Qry on
							I.Emp_ID = Qry.Emp_ID	and I.Increment_Id = Qry.Increment_Id) as INC on INC.Emp_ID = EM.Emp_ID
		inner join T0040_DEPARTMENT_MASTER DM WITH (NOLOCK) on DM.Dept_Id = inc.Dept_ID
		left outer join T0040_COST_CENTER_MASTER CCM WITH (NOLOCK) on CCM.Center_ID = INC.Center_ID
		left join T0040_BANK_MASTER BM WITH (NOLOCK) on INC.bank_id = BM.Bank_ID
		where  em.Cmp_ID = @Cmp_Id and isnull(Dept_Code,'0') <> '0'
		group by DM.Dept_Id,DM.Dept_Code,CCM.Center_Code,CCM.Cost_Element , ccm.Center_ID,EM.Dealer_Code,alpha_Emp_Code,Emp_Full_Name,bank_code  ) as group1

		order by Dept_Code, AX_Head.Sorting_no

end
	
	
	DECLARE @CUR_CMP_ID AS NUMERIC(18,0)
	DECLARE @CUR_DEPT_ID AS NUMERIC(18,0)  
	DECLARE @CUR_CENTER_ID AS nvarchar(50)
	DECLARE @CUR_AD_ID AS NUMERIC(18,0)
	DECLARE @CUR_AD_FLAG AS CHAR(1)
	DECLARE @CUR_LOAN_ID AS NUMERIC(18,0)
	DECLARE @CUR_BUS_AREA AS nvarchar(50)
	DECLARE @ad_def_id AS NUMERIC(18,0)
	Declare @alpha_Emp_Code as NVarchar(200)
	

	DECLARE CUR_AX CURSOR FOR
		SELECT CMP_ID,DEPT_ID , cc_id,ad_id,ad_flag,loan_id,BUSIUNIT,EMPCD FROM @AX
	OPEN CUR_AX
	FETCH NEXT FROM CUR_AX INTO @CUR_CMP_ID,@CUR_DEPT_ID , @CUR_CENTER_ID,@CUR_AD_ID,@CUR_AD_FLAG,@CUR_LOAN_ID,@CUR_BUS_AREA,@alpha_Emp_Code
	While @@fetch_Status = 0
		begin
			
			declare @sum_amt as numeric(18,2) 
			
			declare @sum_amt_Sett as numeric(18,2)
			set @sum_amt_Sett=0 
			
			set @sum_amt = 0
			if @CUR_AD_ID = 0
				begin
						
						
						
						--SELECT @sum_amt= ISNULL(SUM(LOAN_RETURN),0)  FROM T0140_LOAN_TRANSACTION TLT
						--INNER JOIN (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I INNER JOIN T0080_EMP_MASTER E ON I.EMP_ID = E.EMP_ID INNER JOIN 
						--			( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT --Changed by Hardik 10/09/2014 for Same Date Increment
						--			WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
						--			AND CMP_ID = @CMP_ID 
						--			GROUP BY EMP_ID  ) QRY ON
						--			I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id 
						--			--and E.Emp_Left = 'N' OR -- Comment for Inducto on 18022015
						--			-- (E.Emp_Left = 'Y' AND month(@To_Date) > month(E.Emp_Left_Date) AND year(@To_Date) > year(E.Emp_Left_Date) 
						--			-- 	)
						--			 	) AS INC ON INC.EMP_ID = TLT.EMP_ID
						--WHERE INC.DEPT_ID = @CUR_DEPT_ID AND INC.CENTER_ID = @CUR_CENTER_ID AND MONTH(FOR_DATE) = MONTH(@TO_DATE) AND YEAR(FOR_DATE) = YEAR(@TO_DATE) and DAY(FOR_DATE)=DAY(@TO_DATE)
						--		AND TLT.LOAN_ID = @CUR_LOAN_ID and INC.Dealer_Code = @CUR_BUS_AREA 
						
							SELECT @sum_amt = isnull(SUM(MS.Loan_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)  
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) and isnull(ms.is_FNF,0)  = 0 and EM.Dealer_Code = @CUR_BUS_AREA
						
							
						update @AX set AMOUNT = @sum_amt,voucher_Flag ='C',JOURNAME='JVPC',vender_Code='V-00008203' where LOAN_ID = @CUR_LOAN_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID	and BUSIUNIT =  @CUR_BUS_AREA
						
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
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) and isnull(ms.is_FNF,0)  = 0 and EM.Dealer_Code = @CUR_BUS_AREA
						
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='D',JOURNAME='JVPD'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA
				end
			else if @CUR_AD_ID = 1003 and @Flag <> 'S' -- Net Amount
				begin
				
					SELECT @sum_amt = isnull(SUM(MS.Net_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK) 
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  and isnull(ms.is_FNF,0)  = 0 and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') not in ('MD','DI','TR')
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='C',JOURNAME='JVPC'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA
					
				end
				else if @CUR_AD_ID = 1006 -- LWF
				begin
				
					SELECT @sum_amt = isnull(SUM(MS.LWF_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK) 
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  and isnull(ms.is_FNF,0)  = 0 and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') not in ('MD','DI')
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='C',JOURNAME='JVPC'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA
					
				end
			else if @CUR_AD_ID = 1001 -- PT
				begin
				
				SELECT @sum_amt = isnull(SUM(MS.PT_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK)ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  and isnull(ms.is_FNF,0)  = 0 and EM.Dealer_Code = @CUR_BUS_AREA
						
					update @AX set Amount = @sum_amt,voucher_Flag ='C',JOURNAME='JVPC'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA
					
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
			else if @CUR_AD_ID = 1015 and @Flag <> 'A'-- Advance
				begin
					
				SELECT @sum_amt = isnull(SUM(MS.Advance_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  and isnull(ms.is_FNF,0)  = 0 and EM.Dealer_Code = @CUR_BUS_AREA
						
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='C',JOURNAME='JVPC'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA
					
				end
			else if @CUR_AD_ID = 1030 -- lEAVE Encashment
				begin
					
				SELECT @sum_amt = isnull(SUM(MS.Leave_Salary_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  and isnull(ms.is_FNF,0)  = 0 and EM.Dealer_Code = @CUR_BUS_AREA
						
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='D',JOURNAME='JVPD'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA
					
				end
			else if @CUR_AD_ID = 1040  and @Flag <> 'S' -- Net Salary MD
				begin
					
				SELECT @sum_amt = isnull(SUM(MS.Net_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  and isnull(ms.is_FNF,0)  = 0 and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') = 'MD'
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='C',JOURNAME='JVPC'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA
					
				end
			
				
			else if @CUR_AD_ID = 1050  and @Flag <> 'S' -- Net Salary DI
				begin
					
				SELECT @sum_amt = isnull(SUM(MS.Net_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  and isnull(ms.is_FNF,0)  = 0 and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') = 'DI'
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='C',JOURNAME='JVPC'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA
					
				end	
			else if @CUR_AD_ID = 1051  and @Flag <> 'S' -- Net Salary Trainee
				begin
					
				SELECT @sum_amt = isnull(SUM(MS.Net_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  and isnull(ms.is_FNF,0)  = 0 and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') = 'TR'
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='C',JOURNAME='JVPC'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA
					
				end		
				
			else if @CUR_AD_ID = 1060 -- PF MD
				begin
					
				SELECT @sum_amt = isnull(SUM(MAD.M_AD_AMOUNT),0) + isnull(SUM(MAD.M_AREAR_AMOUNT),0) FROM T0210_MONTHLY_AD_DETAIL MAD WITH (NOLOCK) 
						inner join T0200_MONTHLY_SALARY MS on mad.Sal_Tran_ID = MS.Sal_Tran_ID
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						inner join T0050_AD_MASTER AM WITH (NOLOCK) on MAD.AD_ID = AM.AD_ID and AM.AD_DEF_ID=2
						where INC.Dept_ID = @CUR_DEPT_ID and inc.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) and isnull(ms.is_FNF,0)  = 0 and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') ='MD' --and mad.AD_ID = @CUR_AD_id  -- Comented by rohi for inducto. on 18022015
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='C',JOURNAME='JVPC'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA
					
				end		
				
			else if @CUR_AD_ID = 1070 -- PF Di
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
						inner join T0050_AD_MASTER AM WITH (NOLOCK) on MAD.AD_ID = AM.AD_ID and AM.AD_DEF_ID=2
						where INC.Dept_ID = @CUR_DEPT_ID and inc.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) and isnull(ms.is_FNF,0)  = 0 and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') ='DI' -- and mad.AD_ID = @CUR_AD_id  Commented by rohit on 18022015
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='C',JOURNAME='JVPC'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA
					
				end		
				-- Added by rohit on 04032015
		else if @CUR_AD_ID = 2003 -- Basic Amount
				begin
				
					SELECT @sum_amt = isnull(SUM(MS.Salary_Amount),0) + isnull(SUM(MS.Arear_Basic ),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK) 
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  and isnull(ms.is_FNF,0)  = 0 and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') not in ('MD','DI','TR')
				
				--select @sum_amt_Sett = isnull(sum(S_Salary_Amount),0) from T0201_MONTHLY_SALARY_SETT  
				--inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I INNER JOIN T0080_EMP_MASTER E ON I.EMP_ID = E.EMP_ID INNER JOIN 
				--					( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT --Changed by Hardik 10/09/2014 for Same Date Increment
				--					WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
				--					AND CMP_ID = @CMP_ID 
				--					GROUP BY EMP_ID  ) QRY ON
				--					I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = T0201_MONTHLY_SALARY_SETT.EMP_ID
				--		 inner JOIN T0080_EMP_MASTER EM ON T0201_MONTHLY_SALARY_SETT.emp_id = EM.Emp_ID
				--		 where Month(@To_Date) = MONTH(s_Month_st_Date) and Year(@To_Date) = year(s_Month_st_Date)
				--		 and EM.Dealer_Code = @CUR_BUS_AREA and INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID 
				--		and isnull(Emp_Mark_Of_Identification,'') not in ('MD','DI','TR')
						
							SELECT @sum_amt_Sett = isnull(SUM(MS.S_Salary_Amount),0) 
							FROM  T0201_MONTHLY_SALARY_SETT MS WITH (NOLOCK)
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(S_Eff_Date) = MONTH(@To_Date)  and YEAR(S_Eff_Date) = YEAR(@To_Date)   and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') not in ('MD','DI','TR')
						
					set @sum_amt = @sum_amt + @sum_amt_Sett
				
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='D',JOURNAME='JVPD'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA
					
				end
		else if @CUR_AD_ID = 2040 -- Basic Salary MD
				begin
					
				SELECT @sum_amt = isnull(SUM(MS.Salary_Amount),0) + isnull(SUM(MS.Arear_Basic ),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  and isnull(ms.is_FNF,0)  = 0 and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') = 'MD'
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='D',JOURNAME='JVPD'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA
					
				end
		else if @CUR_AD_ID = 2050 -- Basic Salary DI
				begin
				SELECT @sum_amt = isnull(SUM(MS.Salary_Amount),0) + isnull(SUM(MS.Arear_Basic ),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  and isnull(ms.is_FNF,0)  = 0 and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') = 'DI'
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='D',JOURNAME='JVPD'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA
					
				end	
			else if @CUR_AD_ID = 2051 -- Basic Salary Trainee		
				begin
					
				SELECT @sum_amt = isnull(SUM(MS.Salary_Amount),0) + isnull(SUM(MS.Arear_Basic ),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  and isnull(ms.is_FNF,0)  = 0 and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') = 'TR'
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='D',JOURNAME='JVPD'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA
					
				end	
			-- Ended by rohit on 04032015
			
			else if @CUR_AD_ID = 1015 and @Flag = 'A' -- Advance
				begin
					
				SELECT @sum_amt = 
				isnull(SUM(MS.Adv_Amount),0) FROM  T0100_ADVANCE_PAYMENT MS WITH (NOLOCK)
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code,E.Alpha_Emp_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) 
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(For_Date) = MONTH(@To_Date)  and YEAR(For_Date) = YEAR(@To_Date)  and EM.Dealer_Code = @CUR_BUS_AREA and Em.Alpha_Emp_Code =@alpha_Emp_Code
						
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='A',JOURNAME='ICBP'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA and EMPCD = @alpha_Emp_Code
					
				end		
		else if @CUR_AD_ID = 1003 and @Flag = 'S' -- Net Amount
				begin
				
					SELECT @sum_amt = isnull(SUM(MS.Net_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  and isnull(ms.is_FNF,0)  = 0 and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') not in ('MD','DI','TR') and Em.Alpha_Emp_Code =@alpha_Emp_Code
					
					
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='S',JOURNAME='ICBP'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID	and BUSIUNIT =  @CUR_BUS_AREA  and EMPCD = @alpha_Emp_Code
					
				end		
		else if @CUR_AD_ID = 1040 and @Flag = 'S' -- Net Salary MD
				begin
				SELECT @sum_amt = isnull(SUM(MS.Net_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK)
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  and isnull(ms.is_FNF,0)  = 0 and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') = 'MD' and Em.Alpha_Emp_Code =@alpha_Emp_Code
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='S',JOURNAME='ICBP',EMPIND='M'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA and EMPCD = @alpha_Emp_Code
					
				end
     	else if @CUR_AD_ID = 1050 and @Flag = 'S' -- Net Salary DI
				begin
					
				SELECT @sum_amt = isnull(SUM(MS.Net_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK) 
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  and isnull(ms.is_FNF,0)  = 0 and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') = 'DI' and Em.Alpha_Emp_Code =@alpha_Emp_Code
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='S',JOURNAME='ICBP',EMPIND='D'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA and EMPCD = @alpha_Emp_Code
					
				end	
	    else if @CUR_AD_ID = 1051 and @Flag = 'S' -- Net Salary Trainee
				begin
					
				SELECT @sum_amt = isnull(SUM(MS.Net_Amount),0) FROM  T0200_MONTHLY_SALARY MS WITH (NOLOCK) 
						inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MS.EMP_ID
						inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON ms.emp_id = EM.Emp_ID
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date)  and isnull(ms.is_FNF,0)  = 0 and EM.Dealer_Code = @CUR_BUS_AREA
						and isnull(Emp_Mark_Of_Identification,'') = 'TR' and Em.Alpha_Emp_Code =@alpha_Emp_Code
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='S',JOURNAME='ICBP',EMPIND='T'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA and EMPCD = @alpha_Emp_Code
					
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
						left join T0050_AD_MASTER AM WITH (NOLOCK) on MAD.AD_ID = AM.AD_ID 
						where INC.Dept_ID = @CUR_DEPT_ID and INC.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date) and YEAR(month_end_date) = YEAR(@To_Date) and mad.AD_ID = @CUR_AD_id  and isnull(ms.is_FNF,0)  = 0 and EM.Dealer_Code = @CUR_BUS_AREA  
						--and Em.Alpha_Emp_Code =@alpha_Emp_Code
						and AM.AD_NOT_EFFECT_SALARY <>1
						
					set @sum_amt_Sett = 0
					
					select @sum_amt_Sett = isnull(sum(M_Ad_Amount),0)
					from t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
					T0201_MONTHLY_SALARY_SETT MSS WITH (NOLOCK) on MAD.Sal_Tran_ID=MSS.Sal_Tran_ID inner join 
					t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID
					inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT WITH (NOLOCK) --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MAD.EMP_ID
					
					and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
					inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON MAD.emp_id = EM.Emp_ID
					where 
					MAD.Cmp_ID = @cmp_id and month(MSS.S_Eff_Date) =  month(@To_Date ) and Year(MSS.S_Eff_Date) = year(@To_Date ) and
					Ad_Active = 1 And sal_type=1 and mad.ad_id =@CUR_AD_id and INC.Dept_ID = @CUR_DEPT_ID and inc.Center_ID = @CUR_CENTER_ID and  inc.Dealer_Code =  @CUR_BUS_AREA	
				and 1 = (case when  t0050_ad_master.AD_DEF_ID=2 and isnull(Emp_Mark_Of_Identification,'') in ('MD','DI') then 0 else 1 end )
				and t0050_ad_master.AD_NOT_EFFECT_SALARY <>1
				
					
				
					set @sum_amt = @sum_amt + @sum_amt_Sett		
						
					update @AX set Amount = @sum_amt,voucher_Flag ='D',JOURNAME='JVPD'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA	
					--AND  EMPCD =@alpha_Emp_Code		
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
						left join T0050_AD_MASTER Am WITH (NOLOCK) on  MAD.AD_ID = Am.AD_ID 
						where INC.Dept_ID = @CUR_DEPT_ID and inc.Center_ID =@CUR_CENTER_ID
						and MONTH(month_end_date) = MONTH(@To_Date)  and YEAR(month_end_date) = YEAR(@To_Date) and mad.AD_ID = @CUR_AD_id and isnull(ms.is_FNF,0)  = 0 and EM.Dealer_Code = @CUR_BUS_AREA 
						--and Em.Alpha_Emp_Code =@alpha_Emp_Code
						--and isnull(Emp_Mark_Of_Identification,'') Not in ('MD','DI')
						and 1 = (case when  AM.AD_DEF_ID=2 and isnull(Emp_Mark_Of_Identification,'') in ('MD','DI') then 0 else 1 end )
						and AM.AD_NOT_EFFECT_SALARY <>1
						
					set @sum_amt_Sett = 0
					
						
					select @sum_amt_Sett = isnull(sum(M_Ad_Amount),0)
					from t0210_monthly_ad_detail MAD WITH (NOLOCK) inner join
					T0201_MONTHLY_SALARY_SETT MSS on MAD.Sal_Tran_ID=MSS.Sal_Tran_ID inner join 
					t0050_ad_master WITH (NOLOCK) on MAD.Ad_Id = t0050_ad_master.Ad_ID
					inner join (SELECT I.EMP_ID,I.DEPT_ID,I.CENTER_ID ,E.Dealer_Code FROM T0095_INCREMENT I WITH (NOLOCK) INNER JOIN T0080_EMP_MASTER E WITH (NOLOCK) ON I.EMP_ID = E.EMP_ID INNER JOIN 
									( SELECT MAX(Increment_Id) AS Increment_Id , EMP_ID FROM T0095_INCREMENT --Changed by Hardik 10/09/2014 for Same Date Increment
									WHERE INCREMENT_EFFECTIVE_DATE <= @TO_DATE
									AND CMP_ID = @CMP_ID 
									GROUP BY EMP_ID  ) QRY ON
									I.EMP_ID = QRY.EMP_ID	AND I.Increment_Id = QRY.Increment_Id ) AS INC ON INC.EMP_ID = MAD.EMP_ID
					
					and MAD.Cmp_ID = t0050_ad_master.Cmp_Id
					inner JOIN T0080_EMP_MASTER EM WITH (NOLOCK) ON MAD.emp_id = EM.Emp_ID
					where 
					MAD.Cmp_ID = @cmp_id and month(MSS.S_Eff_Date) =  month(@To_Date ) and Year(MSS.S_Eff_Date) = year(@To_Date ) and
					Ad_Active = 1 And sal_type=1 and mad.ad_id =@CUR_AD_id and INC.Dept_ID = @CUR_DEPT_ID and inc.Center_ID = @CUR_CENTER_ID and  inc.Dealer_Code =  @CUR_BUS_AREA	
				and 1 = (case when  t0050_ad_master.AD_DEF_ID=2 and isnull(Emp_Mark_Of_Identification,'') in ('MD','DI') then 0 else 1 end )
				and t0050_ad_master.AD_NOT_EFFECT_SALARY <>1
				
					set @sum_amt = @sum_amt + @sum_amt_Sett	
						
						
					update @AX set AMOUNT = @sum_amt,voucher_Flag ='C',JOURNAME='JVPC'  where AD_ID = @CUR_AD_ID and Dept_ID = @CUR_DEPT_ID and cc_id = @CUR_CENTER_ID			and BUSIUNIT =  @CUR_BUS_AREA	
					--and EMPCD =@alpha_Emp_Code		
				end
				
			FETCH NEXT FROM CUR_AX INTO @CUR_CMP_ID,@CUR_DEPT_ID , @CUR_CENTER_ID,@CUR_AD_ID,@CUR_AD_FLAG,@CUR_LOAN_ID,@CUR_BUS_AREA,@alpha_Emp_Code
		end 
	close cur_ax
	Deallocate cur_ax
		
	if @Flag in ( 'D','A','S')
	begin 
	  SELECT replace(convert(NVARCHAR, DOCDT, 103), ' ', '/') as DOCDT,EMPCD,EMPNAME,row_number() OVER (ORDER BY Dept_ID,BUSIUNIT,AD_ID,COSTCENT DESC ) as VOUNO, replace(convert(NVARCHAR, VOUDT, 103), ' ', '/') as VOUDT,BUSIUNIT,COSTCENT,DEPTCODE,BANKCODE,JOURTYPE,JOURNAME,OFFSETAC,ACCODE1 as 'ACCDDR',ACCTTYPE,ACCDDR as 'ACCODECR',PAYREFNO,PAYREFDT,AMOUNT,Transaction_Text as 'Desc',CURRENCY,CUREXGRT,RECTNAME,VOUMONTH,EMPIND FROM @AX  where voucher_Flag = @Flag and AMOUNT>0 order BY BUSIUNIT,DEPTCODE,COSTCENT
	end 
	else
	begin
	  SELECT replace(convert(NVARCHAR, DOCDT, 103), ' ', '/') as DOCDT,EMPCD,EMPNAME,row_number() OVER (ORDER BY Dept_ID,BUSIUNIT,AD_ID,COSTCENT DESC ) as VOUNO, replace(convert(NVARCHAR, VOUDT, 103), ' ', '/') as VOUDT,BUSIUNIT,COSTCENT,DEPTCODE,BANKCODE,JOURTYPE,JOURNAME,OFFSETAC,ACCODE1 as ACCODECR,ACCTTYPE,ACCDDR,PAYREFNO,PAYREFDT,AMOUNT,Transaction_Text as 'Desc',CURRENCY,CUREXGRT,vender_Code as 'VENDOR CODE'  ,RECTNAME,VOUMONTH,EMPIND FROM @AX  where voucher_Flag = @Flag and AMOUNT>0 order BY BUSIUNIT,DEPTCODE,COSTCENT
	end
	--SELECT AMOUNT,ACCODE1,COSTCENT,deptcode FROM @AX  where voucher_Flag = @Flag and AMOUNT>0 order BY ACCODE1,COSTCENT,deptcode 
	
	

RETURN




