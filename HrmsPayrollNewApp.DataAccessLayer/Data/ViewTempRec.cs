using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class ViewTempRec
{
    public decimal CmpId { get; set; }

    public string JobTitle { get; set; } = null!;

    public DateTime? RecEndDate { get; set; }

    public decimal NoOfVacancies { get; set; }

    public int PostedStatus { get; set; }

    public string? LblStatus { get; set; }

    public int? TotalNoApp { get; set; }

    public decimal? RecPostId { get; set; }

    public byte? ResumeStatus { get; set; }

    public int? TotalNoFinalApp { get; set; }
}
