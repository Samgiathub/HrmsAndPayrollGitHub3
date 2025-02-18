using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class T0240PerquisitesEmployeeDynamic
{
    public decimal TranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal EmpId { get; set; }

    public decimal ItId { get; set; }

    public string FinancialYear { get; set; } = null!;

    public decimal Amount { get; set; }

    public DateTime ModifyDate { get; set; }
}
