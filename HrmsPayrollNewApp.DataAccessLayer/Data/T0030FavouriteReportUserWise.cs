using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0030FavouriteReportUserWise
{
    public decimal ReportFavId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public decimal? LoginId { get; set; }

    public string? ReportName { get; set; }

    public string? ReportUrl { get; set; }

    public string? ReportTitle { get; set; }

    public string? ReportGroup { get; set; }

    public bool EssReport { get; set; }
}
