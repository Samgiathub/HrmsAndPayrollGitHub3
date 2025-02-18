using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0020InactiveUserHistory
{
    public decimal HistoryId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal LoginId { get; set; }

    public string? Reason { get; set; }

    public DateTime SystemDate { get; set; }

    public string ActiveStatus { get; set; } = null!;
}
