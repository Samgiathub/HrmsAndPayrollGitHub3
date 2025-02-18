using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0055HrmsFillProcessDetail
{
    public string ProcessName { get; set; } = null!;

    public decimal ProcessId { get; set; }

    public decimal InterviewProcessDetailId { get; set; }

    public decimal CmpId { get; set; }

    public decimal RecPostId { get; set; }

    public decimal? Expr1 { get; set; }

    public decimal? SEmpId { get; set; }

    public decimal? DisNo { get; set; }
}
