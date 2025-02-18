using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TempKpaApprove
{
    public decimal? EmpId { get; set; }

    public decimal? KpaInitiateId { get; set; }

    public decimal? InitiateStatus { get; set; }

    public int? RptLevel { get; set; }

    public int? FinalApproval { get; set; }

    public string? AppType { get; set; }
}
