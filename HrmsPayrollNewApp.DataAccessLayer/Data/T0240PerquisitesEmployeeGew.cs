using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0240PerquisitesEmployeeGew
{
    public decimal? TransId { get; set; }

    public decimal? CmpId { get; set; }

    public decimal? EmpId { get; set; }

    public string? FinancialYear { get; set; }

    public decimal? TotalAmount { get; set; }

    public DateTime? FromDate { get; set; }

    public DateTime? ToDate { get; set; }

    public DateTime? ChangeDate { get; set; }
}
