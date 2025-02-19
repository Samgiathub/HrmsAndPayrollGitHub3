--- select dbo.fnc_SearchPagingFormat(2,30,10)
--- Drop function [dbo].[fnc_SearchPagingFormat]    
create FUNCTION [dbo].[fnc_SearchPagingFormat] 
(
	@PageIndex AS int,
	@TotalRecords AS int,
	@PageSize AS int
)
RETURNS varchar(5000)
AS
BEGIN
    DECLARE @MiddleRecord AS int,
            @Totalpages AS int
    SELECT
        @MiddleRecord = 4,
        @Totalpages = 0
    SELECT
        @Totalpages =
                     CASE @TotalRecords % @PageSize
                         WHEN 0 THEN (@TotalRecords / @PageSize)
                         ELSE CAST(((@TotalRecords / @PageSize)) AS int) + 1
                     END

    IF @Totalpages = 1
        RETURN ''

    DECLARE @startRecord AS int,
            @EndRecord AS int
    SELECT
        @startRecord = 1,
        @EndRecord = @MiddleRecord * 2
    IF ((@PageIndex + @MiddleRecord) <= @Totalpages)
    BEGIN
        SELECT
            @startRecord =
                          CASE
                              WHEN (@PageIndex - @MiddleRecord) > 0 THEN (@PageIndex - @MiddleRecord) + 1
                              ELSE @startRecord
                          END,
            @EndRecord =
                        CASE
                            WHEN (@PageIndex - @MiddleRecord) > 0 THEN (@PageIndex + @MiddleRecord)
                            ELSE @EndRecord
                        END
    END
    ELSE
    BEGIN
        SELECT
            @StartRecord =
                          CASE
                              WHEN (@Totalpages - @MiddleRecord * 2) <= 0 THEN 1
                              ELSE (@Totalpages - @MiddleRecord * 2)
                          END,
            @EndRecord = @Totalpages
    END

    IF (@Totalpages < @EndRecord)
    BEGIN
        SELECT
            @EndRecord = @Totalpages
    END

    DECLARE @count AS int,
            @OutPutPaging AS varchar(5000) = '',
            @TotalPage AS int
    SELECT
        @count = 1,
        @OutPutPaging = '<ul>',
        @TotalPage = @EndRecord - @startRecord + 1

    IF (@PageIndex > 1)
    BEGIN
        SELECT
            @OutPutPaging = @OutPutPaging + '<li><a href="javascript:void(0);" onClick="ChangePage(' + CAST(@PageIndex - 1 AS varchar(20)) + ');">Prev</a></li>'
    END

    WHILE (@count <= @TotalPage)
    BEGIN
        SELECT
            @OutPutPaging = @OutPutPaging + CASE @startRecord + (@count - 1)
                WHEN @Pageindex THEN '<li class="active">
				<a href="javascript:void(0);">' + CAST(@startRecord + (@count - 1) AS varchar(20)) + '</a>
					</li>'
                ELSE '<li> <a onclick="ChangePage(' + CAST(@startRecord + (@count - 1) AS varchar(20)) + ');"   href="javascript:void(0);" title="Go to page'
                    + CAST(@startRecord + (@count - 1) AS varchar(20)) + '">' + CAST(@startRecord + (@count - 1) AS varchar(20)) + ' </a></li>'
            END
        SELECT
            @count = @count + 1
    END


    IF (@PageIndex < @Totalpages)
    BEGIN
        SELECT
            @OutPutPaging = @OutPutPaging + '<li><a href="javascript:void(0);" onClick="ChangePage(' + CAST(@PageIndex + 1 AS varchar(20)) + ');">Next</a></li>'

    END
    SELECT
        @OutPutPaging = @OutPutPaging + '</ul>'

    RETURN @OutPutPaging
END