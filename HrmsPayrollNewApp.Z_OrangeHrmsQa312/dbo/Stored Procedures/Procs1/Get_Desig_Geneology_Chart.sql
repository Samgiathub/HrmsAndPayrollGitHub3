

CREATE PROCEDURE [dbo].[Get_Desig_Geneology_Chart] 
@cmpid as numeric(18,0)
AS

		SET NOCOUNT ON 
		SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
		SET ARITHABORT ON

BEGIN

create table #final
(
     desigid numeric(18,0)
    ,parent_desigid  numeric(18,0)
    ,designame varchar(max)
    ,parent_designame varchar(max)
)
declare @desigid as numeric(18,0)
declare @designame as varchar(max)
declare @parent_designame as varchar(max)
declare @parent_desigid as numeric(18,0)
declare @ctr_desig as int
declare @parent_ctr_desig as int

declare cur  cursor
	for
		select desig_id,desig_name,Parent_ID from T0040_DESIGNATION_MASTER WITH (NOLOCK) where cmp_id = @cmpid --and desig_id in(3,59,49,25)
		open cur
		Fetch Next From cur into @desigid,@designame,@parent_desigid
		WHILE @@FETCH_STATUS = 0
			begin
				select @ctr_desig=COUNT(Emp_ID) from V0080_EMP_MASTER_INCREMENT_GET where Desig_Id=@desigid and Cmp_ID=@cmpid
				PRINT @ctr_desig
				--set @designame=@designame+'#' + CAST(@ctr_desig as VARCHAR) 
				set @designame = '<table><tr><td style="font-size:11px;font-family:Verdana;color:Black;cursor:pointer;"><a id="lnk_desig_'+ cast(@desigid as varchar) +'" runat="server" onclick="getemp(' + cast(@desigid as varchar) + ');">'+ @designame + '<br/><b>(' + CAST(@ctr_desig as VARCHAR) +')</b></a></td></tr></table>'
				--set @designame = '<table><tr><td style="font-size:11px;font-family:Verdana;color:Black;cursor:pointer;"><a id="lnk_desig_'+ cast(@desigid as varchar) +'" runat="server" onclick="getemp(' + cast(@desigid as varchar) + ');">'+ @designame +'</a></td></tr></table>'
			
				set @parent_designame=''
				
				if @parent_desigid is not null
					begin
						select @parent_designame = Desig_Name from T0040_DESIGNATION_MASTER WITH (NOLOCK) where cmp_id = @cmpid and Desig_ID = @parent_desigid
						
						select @parent_ctr_desig=COUNT(Emp_ID) from V0080_EMP_MASTER_INCREMENT_GET
						where Desig_Id=@parent_desigid and Cmp_ID=@cmpid
						
						
						--set @parent_designame=@parent_designame +'#' + CAST(@parent_ctr_desig as VARCHAR) 
						set @parent_designame = '<table><tr><td style="font-size:11px;font-family:Verdana;color:Black;cursor:pointer;"><a id="lnk_desig_'+ cast(@parent_desigid as varchar) +'" runat="server" onclick="getemp(' + cast(@parent_desigid as varchar) + ');">' + @parent_designame + '<br/><b>(' + CAST(@parent_ctr_desig as VARCHAR) +')</b></a></td></tr></table>'
						--set @parent_designame = '<table><tr><td style="font-size:11px;font-family:Verdana;color:Black;cursor:pointer;"><a id="lnk_desig_'+ cast(@parent_desigid as varchar) +'" runat="server" onclick="getemp(' + cast(@parent_desigid as varchar) + ');">' + @parent_designame +'</a></td></tr></table>'
					end
				
				insert into #final(desigid,parent_desigid,designame,parent_designame)
				values(@desigid, @parent_desigid,@designame,@parent_designame)
				
				
				Fetch Next From cur into @desigid,@designame,@parent_desigid
			end
		close cur
deallocate cur	


select * from #final order by parent_desigid
drop table #final
END


