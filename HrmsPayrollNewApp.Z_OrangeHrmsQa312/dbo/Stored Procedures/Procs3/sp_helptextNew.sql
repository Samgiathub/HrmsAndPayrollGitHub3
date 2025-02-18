﻿

-- created by rohit for script generate proper.
-- created date:- 03032016
---22/1/2021 (EDIT BY MEHUL ) (SP WITH NOLOCK)---
CREATE PROCEDURE [dbo].[sp_helptextNew]
@objname nvarchar(776)
,@columnname sysname = NULL
as
SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
SET ARITHABORT ON

declare @dbname sysname
,@objid	int
,@BlankSpaceAdded   int
,@BasePos       int
,@CurrentPos    int
,@TextLength    int
,@LineId        int
,@AddOnLen      int
,@LFCR          int --lengths of line feed carriage return
,@DefinedLength int

/* NOTE: Length of @SyscomText is 4000 to replace the length of
** text column in syscomments.
** lengths on @Line, #CommentText Text column and
** value for @DefinedLength are all 255. These need to all have
** the same values. 255 was selected in order for the max length
** display using down level clients
*/
,@SyscomText	nvarchar(max)
,@Line          nvarchar(max)

select @DefinedLength = 4000
select @BlankSpaceAdded = 0 /*Keeps track of blank spaces at end of lines. Note Len function ignores
                             trailing blank spaces*/
CREATE TABLE #CommentText
(LineId	int
 ,Text  nvarchar(max) collate database_default)

/*
**  Make sure the @objname is local to the current database.
*/
select @dbname = parsename(@objname,3)
if @dbname is null
	select @dbname = db_name()
else if @dbname <> db_name()
        begin
                raiserror(15250,-1,-1)
                return (1)
        end

/*
**  See if @objname exists.
*/
select @objid = object_id(@objname)
if (@objid is null)
        begin
		raiserror(15009,-1,-1,@objname,@dbname)
		return (1)
        end

-- If second parameter was given.
if ( @columnname is not null)
    begin
        -- Check if it is a table
        if (select count(*) from sys.objects where object_id = @objid and type in ('S ','U ','TF'))=0
            begin
                raiserror(15218,-1,-1,@objname)
                return(1)
            end
        -- check if it is a correct column name
        if ((select 'count'=count(*) from sys.columns where name = @columnname and object_id = @objid) =0)
            begin
                raiserror(15645,-1,-1,@columnname)
                return(1)
            end
    if (ColumnProperty(@objid, @columnname, 'IsComputed') = 0)
		begin
			raiserror(15646,-1,-1,@columnname)
			return(1)
		end

        declare ms_crs_syscom  CURSOR LOCAL
        FOR select text from syscomments where id = @objid and encrypted = 0 and number =
                        (select column_id from sys.columns where name = @columnname and object_id = @objid)
                        order by number,colid
        FOR READ ONLY

    end
else if @objid < 0	-- Handle system-objects
	begin
		-- Check count of rows with text data
		if (select count(*) from master.sys.syscomments where id = @objid and text is not null) = 0
			begin
				raiserror(15197,-1,-1,@objname)
				return (1)
			end
			
		declare ms_crs_syscom CURSOR LOCAL FOR select text from master.sys.syscomments where id = @objid
			ORDER BY number, colid FOR READ ONLY
	end
else
    begin
        /*
        **  Find out how many lines of text are coming back,
        **  and return if there are none.
        */
        if (select count(*) from syscomments c, sysobjects o where o.xtype not in ('S', 'U')
            and o.id = c.id and o.id = @objid) = 0
                begin
                        raiserror(15197,-1,-1,@objname)
                        return (1)
                end

        if (select count(*) from syscomments where id = @objid and encrypted = 0) = 0
                begin
                        raiserror(15471,-1,-1,@objname)
                        return (0)
                end

		declare ms_crs_syscom  CURSOR LOCAL
		FOR select text from syscomments where id = @objid and encrypted = 0
				ORDER BY number, colid
		FOR READ ONLY

    end

/*
**  else get the text.
*/
select @LFCR = 2
select @LineId = 1


OPEN ms_crs_syscom

FETCH NEXT from ms_crs_syscom into @SyscomText

WHILE @@fetch_status >= 0
begin

    select  @BasePos = 1
    select  @CurrentPos = 1
    select  @TextLength = LEN(@SyscomText)

    WHILE @CurrentPos  != 0
    begin
        --Looking for end of line followed by carriage return
        select @CurrentPos =   CHARINDEX(char(13)+char(10), @SyscomText, @BasePos)

        --If carriage return found
        IF @CurrentPos != 0
        begin
            /*If new value for @Lines length will be > then the
            **set length then insert current contents of @line
            **and proceed.
            */
            while (isnull(LEN(@Line),0) + @BlankSpaceAdded + @CurrentPos-@BasePos + @LFCR) > @DefinedLength
            begin
                select @AddOnLen = @DefinedLength-(isnull(LEN(@Line),0) + @BlankSpaceAdded)
                INSERT #CommentText VALUES
                ( @LineId,
                  isnull(@Line, N'') + isnull(SUBSTRING(@SyscomText, @BasePos, @AddOnLen), N''))
                select @Line = NULL, @LineId = @LineId + 1,
                       @BasePos = @BasePos + @AddOnLen, @BlankSpaceAdded = 0
            end
            select @Line    = isnull(@Line, N'') + isnull(SUBSTRING(@SyscomText, @BasePos, @CurrentPos-@BasePos + @LFCR), N'')
            select @BasePos = @CurrentPos+2
            INSERT #CommentText VALUES( @LineId, @Line )
            select @LineId = @LineId + 1
            select @Line = NULL
        end
        else
        --else carriage return not found
        begin
            IF @BasePos <= @TextLength
            begin
                /*If new value for @Lines length will be > then the
                **defined length
                */
                while (isnull(LEN(@Line),0) + @BlankSpaceAdded + @TextLength-@BasePos+1 ) > @DefinedLength
                begin
                    select @AddOnLen = @DefinedLength - (isnull(LEN(@Line),0) + @BlankSpaceAdded)
                    INSERT #CommentText VALUES
                    ( @LineId,
                      isnull(@Line, N'') + isnull(SUBSTRING(@SyscomText, @BasePos, @AddOnLen), N''))
                    select @Line = NULL, @LineId = @LineId + 1,
                        @BasePos = @BasePos + @AddOnLen, @BlankSpaceAdded = 0
                end
                select @Line = isnull(@Line, N'') + isnull(SUBSTRING(@SyscomText, @BasePos, @TextLength-@BasePos+1 ), N'')
                if LEN(@Line) < @DefinedLength and charindex(' ', @SyscomText, @TextLength+1 ) > 0
                begin
                    select @Line = @Line + ' ', @BlankSpaceAdded = 1
                end
            end
        end
    end

	FETCH NEXT from ms_crs_syscom into @SyscomText
end

IF @Line is NOT NULL
    INSERT #CommentText VALUES( @LineId, @Line )

select Text from #CommentText order by LineId

CLOSE  ms_crs_syscom
DEALLOCATE 	ms_crs_syscom

DROP TABLE 	#CommentText

return (0) -- sp_helptext

